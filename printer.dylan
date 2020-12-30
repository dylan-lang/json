Module: %json
Copyright: Original Code is Copyright (c) 2011 Dylan Hackers
           All rights reserved.
License: See License.txt in this distribution for details.


/*
Notes on pretty printing:

* For now this code either prints without whitespace at all or prints objects
  with one key per line. There is no attempt to fit multiple key/value pairs on
  one line or to output { "one": "pair" } on one line.

* If a prefix is given, the block's indentation level is at the column after
  where the prefix ends.

* The suffix, if given, begins at the block's indentation level.

* I am not an expert, but the above two facts appear to make prefix/suffix
  unusable if you want this style of braces:

      "ghi": {
         "pqr": "stu",
         "jkl": "mno"
      }

*/

define thread variable *indent* :: false-or(<string>) = #f;
define thread variable *sort-keys?* :: <boolean> = #f;

// Call this to print an object on `stream` in json format. If `indent` is
// false `object` is printed with minimal whitespace. If `indent` is an integer
// then use pretty printing and output `indent` spaces for each indent level.
// If `sort-keys?` is true then output object keys in lexicographical order.
define function print
    (object :: <object>, stream :: <stream>,
     #key indent :: false-or(<integer>), sort-keys? :: <boolean>);
  if (indent)
    dynamic-bind (*indent* = make(<string>, size: indent, fill: ' '),
                  *sort-keys?* = sort-keys?,
                  *print-pretty?* = #t) // bug: shouldn't be required.
      io/printing-logical-block(stream)
        print-json(object, stream);
      end;
    end
  else
    print-json(object, stream);
  end;
end function;

// Override this to print your own objects in json format. It can be
// implemented by converting objects to built-in Dylan types (tables,
// collections, etc) and calling `print` on those objects, or by writing json
// syntax directly to `stream`.
//
// If `indent:` was passed to `print` then `stream` will be a pretty printing
// stream and the io:pprint module may be used to implement pretty printing.
define open generic print-json (object :: <object>, stream :: <stream>);

define method print-json (object == $null, stream :: <stream>)
  write(stream, "null");
end method;

define method print-json (object :: <integer>, stream :: <stream>)
  write(stream, integer-to-string(object));
end method;

define method print-json (object :: <float>, stream :: <stream>)
  write(stream, float-to-string(object));
end method;

define method print-json (object :: <boolean>, stream :: <stream>)
  write(stream, if (object) "true" else "false" end);
end method;

define method print-json (object :: <string>, stream :: <stream>)
  write-element(stream, '"');
  let zero :: <integer> = as(<integer>, '0');
  let a :: <integer> = as(<integer>, 'a') - 10;
  local
    method write-hex-digit (code :: <integer>)
      write-element(stream, as(<character>,
                               if (code < 10) zero + code else a + code end));
    end,
    method write-unicode-escape (code :: <integer>)
      write(stream, "\\u");
      write-hex-digit(ash(logand(code, #xf000), -12));
      write-hex-digit(ash(logand(code, #x0f00), -8));
      write-hex-digit(ash(logand(code, #x00f0), -4));
      write-hex-digit(logand(code, #x000f));
    end;
  for (char in object)
    let code = as(<integer>, char);
    case
      code <= #x1f =>
        let escape-char = select (char)
                            '\b' => 'b';
                            '\f' => 'f';
                            '\n' => 'n';
                            '\r' => 'r';
                            '\t' => 't';
                            otherwise => #f;
                          end;
        if (escape-char)
          write-element(stream, '\\');
          write-element(stream, escape-char);
        else
          write-unicode-escape(code);
        end;
      char == '"' =>
        write(stream, "\\\"");
      char == '\\' =>
        write(stream, "\\\\");
      code < 127 =>             // omits DEL
        write-element(stream, char);
      otherwise =>
        write-unicode-escape(code);
    end case;
  end for;
  write-element(stream, '"');
end method;

define method print-json (object :: <collection>, stream :: <stream>)
  io/printing-logical-block (stream, prefix: "[", suffix: "]")
    for (o in object,
         i from 0)
      if (i > 0)
        write(stream, ",");
        if (*indent*)
          // TODO: is there a way to tell the pretty printer to output a space
          // only if the conditional newline isn't output? Don't want trailing
          // spaces.
          write(stream, " ");
          io/pprint-newline(#"fill", stream);
        end;
      end if;
      print-json(o, stream);
    end for;
  end;
end method;

// TODO: print on a single line when entire table fits, otherwise always output
// one element per line. Not sure if the pretty printer can be coaxed into
// doing that. Might be easier to do it (even just the current functionality)
// by hand.
define method print-json (object :: <table>, stream :: <stream>)
  local
    method print-key-value-pairs-body (stream, i, key, value)
      if (i > 0)
        write(stream, ",");
        *indent* & io/pprint-newline(#"mandatory", stream);
      end if;
      print-json(key, stream);
      write(stream, ":");
      *indent* & write(stream, " ");
      print-json(value, stream);
    end method,
    method print-key-value-pairs (stream :: <stream>)
      if (*sort-keys?*)
        for (key in sort!(key-sequence(object)), i from 0)
          print-key-value-pairs-body(stream, i, key, object[key]);
        end;
      else
        for (value keyed-by key in object, i from 0)
          print-key-value-pairs-body(stream, i, key, value)
        end for;
      end;
    end method;
  write(stream, "{");
  if (~empty?(object))
    if (*indent*)
      io/pprint-newline(#"mandatory", stream);
      io/printing-logical-block (stream, per-line-prefix: *indent*)
        print-key-value-pairs(stream)
      end;
      io/pprint-newline(#"mandatory", stream);
    else
      print-key-value-pairs(stream);
    end;
  end;
  write(stream, "}");
end method;
