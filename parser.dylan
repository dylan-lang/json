Module: %json
Synopsis: Ad-hoc recursive descent parser for JSON -- http://www.json.org/
Author: Carl Gay
Copyright: Copyright (c) 2012 Dylan Hackers.  All rights reserved.
License:   See LICENSE.txt in this distribution for details.


// Notes:
// * Objects are parsed as <string-table>s.

// TODO(cgay):
// * parse exponents
// * Is spec specific about whitespace handling?  e.g., is "true123" a bool
//   and an int, or an error?  What about 123{} ?



define constant <json-object> = <string-table>;

define constant $whitespace :: <string>
  = " \t\n\r";

// Things that terminate numbers and booleans
define constant $token-terminators :: <string>
  = concatenate($whitespace, "{}[]\"");



/// Synopsis: Parse json formatted text from the given 'source'.
///           This is the main user-visible entry point for parsing.
define open generic parse-json
    (source :: <object>, #key strict? :: <boolean>)
 => (json :: <object>);

define method parse-json
    (source :: <stream>, #key strict? :: <boolean>) => (json :: <object>)
  parse-any(make(<json-parser>,
                 source: source,
                 text: read-to-end(source),
                 strict?: strict?))
end;

define method parse-json
    (source :: <string>, #key strict? :: <boolean>) => (json :: <object>)
  parse-any(make(<json-parser>,
                 source: source,
                 text: source,
                 strict?: strict?))
end;


/// Synopsis: parse and return any valid json entity.  An object, array,
///           integer, float, string, boolean, or null.  This is used for
///           parsing list elements and member values, for example.
/// Arguments:
///   p   - Json parser.
///
define method parse-any
    (p :: <json-parser>) => (object :: <object>)
  eat-whitespace-and-comments(p);
  let char = p.next;
  select (char by member?)
    "'\"" =>
      parse-string(p);
    "{" =>
      parse-object(p);
    "[" =>
      parse-array(p);
    "-0123456789" =>
      parse-number(p);
    // TODO(cgay): validate that the next char is a token delimeter
    "t" =>
      expect(p, "true");
      #t;
    "f" =>
      expect(p, "false");
      #f;
    "n" =>
      expect(p, "null");
      $null;
    otherwise =>
      parse-error(p, "Unexpected input starting with %=.", char);
  end select
end method parse-any;


/// Synopsis: Parse a JSON "object", i.e. hash table
///
define method parse-object
    (p :: <json-parser>) => (object :: <json-object>)
  let object = make(<json-object>);
  eat-whitespace-and-comments(p);
  select (p.next)
    '{' =>
      p.consume;
      parse-members(p, object);
      expect(p, "}");
    otherwise =>
      parse-error(p, "Invalid object.  Expected '{'.");
  end;
  object
end method parse-object;


/// Synopsis: Parse the members of an object and add them to the 'object'
///           argument passed in.
define method parse-members
    (p :: <json-parser>, object :: <json-object>) => ()
  iterate loop ()
    eat-whitespace-and-comments(p);
    select (p.next)
      '}', #f =>
        #f;  // done
      '"' =>
        let key = parse-string(p);
        // empty strings are a hack to eat whitespace.
        expect(p, "", ":", "");
        let value = parse-any(p);
        object[key] := value;
        eat-whitespace-and-comments(p);
        if (p.next = ',')
          p.consume;
        end;
        loop();
      otherwise =>
        parse-error(p, "Expected '\"' or '}'.");
    end;
  end iterate;
end method parse-members;


define method eat-whitespace-and-comments
    (p :: <json-parser>) => ()
  iterate loop ()
    if (~p.strict? & (p.next = '#'))
      eat-comment(p);
      loop()
    elseif (p.next & whitespace?(p.next))
      p.consume;
      loop()
    end;
  end;
end;

/// Synopsis: Consume a comment that starts with '#' and ends with '\n'.
///
define method eat-comment
    (p :: <json-parser>) => ()
  iterate loop ()
    let char = p.next;
    if (char)
      p.consume;
      if ((char = '\r') & (p.next = '\n'))
          p.consume;
      end;
      if (char ~= '\r' & char ~= '\n')
        loop()
      end;
    end;
  end;
end method eat-comment;


/// Synopsis: Parse a json array, which we represent as a vector in Dylan.
///
define method parse-array
    (p :: <json-parser>) => (array :: <vector>)
  let array = make(<stretchy-vector>);
  if (p.next ~= '[')
    parse-error(p, "Array expected");
  end;
  p.consume;  // '['
  parse-array-elements(p, array);
  expect(p, "]");
  array
end method parse-array;

define function parse-array-elements
    (p :: <json-parser>, array :: <stretchy-vector>) => ()
  iterate loop ()
    eat-whitespace-and-comments(p);
    if (p.next & (p.next ~= ']'))
      add!(array, parse-any(p));
      loop()
    end
  end;
end function parse-array-elements;

/// Synopsis: Parse an integer or float (digits on both sides of the '.' required)
///
// TODO(cgay): This doesn't parse floats correctly.
define method parse-number
    (p :: <json-parser>)
 => (number :: <number>)
  let chars = make(<stretchy-vector>);
  if (p.next = '-')
    add!(chars, p.consume);
  end;
  if (~decimal-digit?(p.next))
    parse-error(p, "Invalid number: Digit expected but got %=", p.next);
  end;
  iterate loop ()
    let char = p.next;
    if (~char)
      #f
    elseif (decimal-digit?(char))
      p.consume;
      add!(chars, char);
      loop();
    elseif (char = '.')
      if (member?('.', chars))
        parse-error(p, "Invalid float: '.' already seen.");
      end;
      p.consume;
      add!(chars, char);
      loop();
    elseif (~member?(char, $token-terminators))
      parse-error(p, "Invalid number: %c unexpected", char);
    end;
  end;
  let string = map-as(<string>, identity, chars);
  if (member?('.', string))
    string-to-float(string)
  else
    string-to-integer(string)
  end
end method parse-number;

define method parse-string
    (p :: <json-parser>) => (string :: <string>)
  let start-char = p.consume;
  assert(start-char = '"');
  let string = parse-simple-string(p);
  if (p.next ~= start-char)
    parse-error(p, "Unterminated string.");
  end;
  p.consume;
  string
end method parse-string;

define table $escape-chars = { 'b' => '\b',
                               'f' => '\f',
                               'n' => '\n',
                               'r' => '\r',
                               't' => '\t',
                               '\\' => '\\',
                               '"' => '"',
                               '/' => '/' };

define method parse-simple-string
    (p :: <json-parser>)
  let chars = make(<stretchy-vector>);
  iterate loop (escaped? = #f)
    let char = p.next;
    if (escaped?)
      p.consume;
      let actual = if (char = 'u')
                     parse-unicode-escape(p)
                   else
                     element($escape-chars, char, default: #f)
                   end;
      if (~actual)
        if (p.strict?)
          parse-error(p, "Invalid character escape sequence: \\%c", char);
        else
          actual := char;
        end;
      end;
      add!(chars, actual);
      loop(#f)
    else
      select (char)
        '\\' =>
          p.consume;
          loop(#t);
        '\n', '\r' =>
          parse-error(p, "Unterminated string");
        '"' =>
          map-as(<string>, identity, chars);   // done
        otherwise =>
          p.consume;
          add!(chars, char);
          loop(#f);
      end
    end
  end
end method parse-simple-string;

/// Synopsis: parse four hex digits and turn it into a unicode character.
///
define function parse-unicode-escape
    (p :: <json-parser>) => (char :: <character>)
  parse-error(p, "Unicode is not yet supported.");
  /*
  local method getchar ()
          let char = as-lowercase(p.consume);
          if (decimal-digit?(char))
            as(<integer>, char) - as(<integer>, '0')
          elseif (member?(char, "abcdef"))
            as(<integer>, char) - as(<integer>, 'a') + 10
          else
            parse-error(p, "Hex digit expected for unicode escape");
          end
        end;
  let c1 = getchar();
  let c2 = getchar();
  let c3 = getchar();
  let c4 = getchar();
  ...
  */
end function parse-unicode-escape;

/// Synopsis: '$null' is what "null" parses to.
///
define class <null> (<object>) end;  // TODO(cgay): make singleton
define constant $null :: <null> = make(<null>);

define class <json-parser> (<object>)
  // Source is for error reporting only.  It could be a file name, a stream, etc.
  constant slot input-source :: <object>, required-init-keyword: source:;

  // Text is the entire original source text.
  // TODO(cgay): Support streams better.  Probably make stream optional and use
  // a buffer.  If string supplied, init buffer to the string.
  constant slot input-text :: <string> = "", required-init-keyword: text:;

  // Index points to the next character to be read by "consume".
  slot current-index :: <integer> = 0;

  // Line and column are for error reporting.  They are maintained by "consume".
  slot line-number :: <integer> = 1, init-keyword: line:;
  slot column-number :: <integer> = 1, init-keyword: column:;

  // If true, do not allow comments or illegal escape characters in strings.
  constant slot strict? :: <boolean> = #t,
    init-keyword: strict?:;
end class <json-parser>;


/// Synopsis: All json errors are subclasses of this.
///
define open class <json-error> (<format-string-condition>, <error>)
end;


/// Synopsis: Any error signalled during parsing (except for file
///           system errors) will be an instance of this.
define class <json-parse-error> (<json-error>)
end;


/// Synopsis: Signal <json-parse-error> with the given 'format-string' and
///           'args' as the message.  If the current source location is known
///           it is prefixed to the message.
define method parse-error
    (p :: <json-parser>, format-string, #rest args)
  let context = format-to-string("@%d:%d ", p.line-number, p.column-number);
  let message = concatenate(context,
                            apply(format-to-string, format-string, args),
                            "\n", p.current-line,
                            "\n", p.indicator-line);
  error(make(<json-parse-error>, format-string: message));
end;

/// Synopsis: Return the line pointed to by 'current-index'.
///
define method current-line
    (p :: <json-parser>) => (line :: <string>)
  let max = p.input-text.size;
  let curr = p.current-index;
  let epos = min(position(p.input-text, '\n', start: curr) | max,
                 position(p.input-text, '\r', start: curr) | max);
  copy-sequence(p.input-text,
                start: curr - p.column-number + 1,
                end: epos)
end;

/// Synopsis: Return a line that indicates which character 'current-index'
///           points to.  ".........^"
define method indicator-line
    (p :: <json-parser>) => (line :: <string>)
  let line = make(<string>, size: p.column-number, fill: '.');
  line[p.column-number - 1] := '^';
  line
end;

/// Synopsis: Return the next unread input character, or #f if at end.
define method next
    (p :: <json-parser>, #key offset :: <integer> = 0)
 => (char :: false-or(<character>))
  let text = p.input-text;
  let idx = p.current-index;
  if (idx + offset >= text.size)
    #f
  else
    text[idx + offset]
  end
end method next;

/// Synopsis: Consume and return the next unread input character.  If at
///           end-of-input signal <json-parse-error>.
define method consume
    (p :: <json-parser>) => (char :: false-or(<character>))
  let char = p.next;
  if (char)
    p.current-index := p.current-index + 1;
    if (char = '\n')
      p.line-number := p.line-number + 1;
      p.column-number := 1;
    else
      p.column-number := p.column-number + 1;
    end;
    char
  else
    parse-error(p, "End of json text encountered.");
  end;
end method consume;

define method expect
    (p :: <json-parser>, #rest strings :: <string>) => ()
  for (string in strings)
    let start = p.current-index;
    for (char in string)
      if (char = p.next)
        p.consume
      else
        parse-error(p, "Expected %= but got %=", string,
                    copy-sequence(p.input-text,
                                  start: start, end: p.current-index));
      end;
    end;
    eat-whitespace-and-comments(p);
  end;
end method expect;


