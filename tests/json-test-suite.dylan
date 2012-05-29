Module: json-test-suite
Synopsis: JSON test suite
Author: Carl Gay
Copyright: Copyright (c) 2012 Dylan Hackers.  All rights reserved.
License: See License.txt in this distribution for details.


define function main ()
  let filename = locator-name(as(<file-locator>, application-name()));
  if (split(filename, ".")[0] = "json-test-suite")
    run-test-application(json-test-suite);
  end;
end function main;


define suite json-test-suite ()
  test test-object;
  test test-array;
  test test-string;
  test test-number;
  test test-constants;
  test test-whitespace;
end;

define test test-object ()
end;

define test test-array ()
end;

define test test-string ()
  check-equal("a", parse-json("\"foo\""), "foo");
  check-equal("b", parse-json("\"foo\\nbar\""), "foo\nbar");
  check-equal("c", parse-json("\"\\\"\\\\\\/\\b\\f\\n\\r\\t"), "\"\\/\b\f\n\r\t");
end;

define test test-number ()
  for (item in #[#["123", 123],
                 #["123e3", 123000],
                 #["123E3", 123000],
                 #["123e+3", 123000],
                 #["123E+3", 123000],
                 #["123e-3", 0.123],
                 #["123E-3", 0.123],
                 #["123.123", 123.123],
                 #["123.123e3", 123123],
                 #["-123", -123],
                 #["-123.4", -123.4],
                 #["-123.4e3", -123400]])
    let (input, expected) = apply(values, item);
    check-equal(format-to-string("%s => %s", input, expected),
                parse-json(input), expected);
  end;
end test test-number;

define test test-constants ()
  check-equal("a", parse-json("null"), $null);
  check-equal("b", parse-json("true"), #t);
  check-equal("c", parse-json("false"), #f);
end;

/// Synopsis: Verify that whitespace (including CR, CRLF, and LF) is ignored.
///
define test test-whitespace ()
  let obj = make(<string-table>);
  obj["key"] := 123;
  check-equal("a", parse-json(" {\n\"key\"\r:\r\n123\r }"), obj);
end test test-whitespace;


main();
