Module: json-test-suite
Synopsis: JSON test suite
Author: Carl Gay
Copyright: Copyright (c) 2012 Dylan Hackers.  All rights reserved.
License: See License.txt in this distribution for details.


// TODO(cgay): intentional parse errors.

define function main ()
  let filename = locator-name(as(<file-locator>, application-name()));
  if (split(filename, ".")[0] = "json-test-suite")
    run-test-application(json-test-suite);
  end;
end function main;

define macro make-object
    { make-object(?rest:*) }
 => { make-table(<string-table>, ?rest); }
end;


define suite json-test-suite ()
  suite parser-test-suite;
end suite json-test-suite;

define suite parser-test-suite ()
  test test-parse-object;
  test test-parse-array;
  test test-parse-string;
  test test-parse-number;
  test test-parse-constants;
  test test-parse-whitespace;
end suite parser-test-suite;

define test test-parse-object ()
  check-equal("a", parse-json("{}"), make-object());
  check-equal("b", parse-json("{\"a\": 1}"), make-object("a" => 1));
  check-equal("c", parse-json("{\"a\": true,\"b\": false, \"c\": null}"),
              make-object("a" => #t, "b" => #f, "c" => $null));
  check-equal("Trailing comma allowed in non-strict mode?",
              parse-json("{\"a\": true,}", strict?: #f),
              make-object("a" => #t));
  check-condition("Trailing comma allowed in non-strict mode?",
                  <json-error>, parse-json("{\"a\": true,}"));
end test test-parse-object;

define test test-parse-array ()
  check-equal("a", parse-json("[]"), #[]);
  check-equal("b", parse-json("[null,true,false]"), vector($null, #t, #f));
  check-equal("Trailing comma allowed in non-strict mode?",
              parse-json("[null,]", strict?: #f),
              vector($null));
  check-condition("Trailing comma disallowed in strict mode?",
                  <json-error>, parse-json("[null,true,false,]"))
end test test-parse-array;

define test test-parse-string ()
  check-equal("a", parse-json("\"foo\""), "foo");
  check-equal("b", parse-json("\"foo\\nbar\""), "foo\nbar");
  check-equal("c", parse-json("\"\\\"\\\\\\/\\b\\f\\n\\r\\t\""), "\"\\/\b\f\n\r\t");
end test test-parse-string;

define test test-parse-number ()
  for (item in #[#["123", 123],
                 #["-123", -123],
                 #["123e3", 123000],
                 #["123E3", 123000],
                 #["123e+3", 123000],
                 #["123E+3", 123000],
                 #["123e-3", 0.123d0],
                 #["123E-3", 0.123d0],
                 #["123.123", 123.123d0],
                 #["123.123e3", 123123],
                 #["123.1e-3", 0.1231d0],
                 #["-123", -123],
                 #["-123.4", -123.4d0],
                 #["-123.4e3", -123400.0d0]])
    let (input, expected) = apply(values, item);
    check-equal(format-to-string("%s => %s", input, expected),
                parse-json(input), expected);
  end;
end test test-parse-number;

define test test-parse-constants ()
  check-equal("a", parse-json("null"), $null);
  check-equal("b", parse-json("true"), #t);
  check-equal("c", parse-json("false"), #f);
  check-condition("d", <json-error>, parse-json("null123"));
end test test-parse-constants;

/// Synopsis: Verify that whitespace (including CR, CRLF, and LF) is ignored.
///
define test test-parse-whitespace ()
  let obj = make(<string-table>);
  obj["key"] := 123;
  check-equal("a", parse-json(" {\n\"key\"\r:\r\n123\r }"), obj);
end test test-parse-whitespace;


main();
