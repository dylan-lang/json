Module: json-test-suite
Synopsis: Tests for the JSON printer

define function jprint(object)
  with-output-to-string(s)
    print-json(object, s);
  end
end function;

define test test-print-integer ()
  assert-equal(jprint(0), "0");
  assert-equal(jprint(1000), "1000");
end test;

define test test-print-float ()
  assert-equal(jprint(1.0), "1.0000000");
  assert-equal(jprint(1.000_001), "1.0000010");
end test;

define test test-print-false ()
  assert-equal(jprint(#f), "false");
end;

define test test-print-true ()
  assert-equal(jprint(#t), "true");
end test;

define test test-print-string ()
  assert-equal(jprint(""), #:raw:{""});
  assert-equal(jprint("a"), #:raw:{"a"});
  assert-equal(jprint("a\\b"), #:raw:{"a\\b"});
  assert-equal(jprint("\0"), #:raw:{"\u0000"});
  assert-equal(jprint("\b\f\n\r\t"), #:raw:{"\b\f\n\r\t"});
  assert-equal(jprint("\<1f>"), #:raw:{"\u001f"});
  assert-equal(jprint("a b"), #:raw:{"a b"});
end test;

define test test-print-sequence ()
  assert-equal(jprint(#[]), "[]");
  assert-equal(jprint(#()), "[]");
  assert-equal(jprint(#[8]), "[8]");
  assert-equal(jprint(#[8, 7, 6]), "[8,7,6]");
  assert-equal(jprint(#[#[8, 7, 6], #[5, 4]]), "[[8,7,6],[5,4]]");
end test;

define test test-pretty-print-sequence ()
  assert-equal("[]", with-output-to-string (s)
                       print-json(#[], s, indent: 2);
                     end);
  assert-equal("[2]", with-output-to-string (s)
                        print-json(#[2], s, indent: 2);
                      end);
  assert-equal(#:raw:{["first string",
 "second string"]},
               with-output-to-string (s)
                 dynamic-bind (*default-line-length* = 20)
                   print-json(#["first string", "second string"], s, indent: 2);
                 end;
               end);
  assert-equal(#:raw:{["one", "two", "three",
 "four", "five", "six"]},
               with-output-to-string (s)
                 dynamic-bind (*default-line-length* = 24)
                   print-json(#["one", "two", "three", "four", "five", "six"], s, indent: 2);
                 end;
               end);
end test;

define test test-print-table ()
  assert-equal(jprint(make-table()), "{}");
  assert-equal(jprint(make-table(2 => 3)), "{2:3}");
  assert-equal(jprint(make-table(3 => 4)), "{3:4}");
  let got = jprint(make-table(2 => 3, 3 => 4));
  assert-true(member?(got, #("{2:3,3:4}", "{3:4,2:3}"), test: \=),
              format-to-string("%s is either {2:3,3:4} or {3:4,2:3}", got));
end test;

define test test-pretty-print-table ()
  assert-equal("{}", with-output-to-string (s)
                       print-json(make-table(), s, indent: 2)
                     end);

  let table
    = make-table("abc" => "def",
                 "ghi" => make-table("jkl" => "mno",
                                     "pqr" => "stu"),
                 "vwx" => make-table("y" => "z"),
                 "long-long-long-key" => "long-long-long-value");
  // Expected output with sorted keys.
  let want = #:raw:[{
  "abc": "def",
  "ghi": {
    "jkl": "mno",
    "pqr": "stu"
  },
  "long-long-long-key": "long-long-long-value",
  "vwx": {
    "y": "z"
  }
}];
  let got = with-output-to-string (s)
              print-json(table, s, indent: 2, sort-keys?: #t)
            end;
  assert-equal(got, want);

  // Check the unsorted output. We don't know where the commas will be so just
  // remove them and make sure all lines are present in any order.
  let got-unsorted = with-output-to-string (s)
                       print-json(table, s, indent: 2, sort-keys?: #f);
                     end;
  let want-lines = map(rcurry(remove, ','), split(want, '\n'));
  let got-lines = map(rcurry(remove, ','), split(got-unsorted, '\n'));
  assert-equal(size(want-lines),
               size(intersection(want-lines, got-lines, test: \=)));

  // Use a different indent width.
  let got3 = with-output-to-string(s)
               print-json(make-table("2" => 3, "4" => 5), s, indent: 3, sort-keys?: #t);
             end;
  assert-equal(got3, #:raw:[{
   "2": 3,
   "4": 5
}]);
end test;

define test test-null ()
  assert-equal(jprint($null), "null");
end test;

define class <unsupported> (<object>) end;

define test test-print-unsupported-type ()
  // Should be <dispatch-error> but that's not exported.
  assert-signals(<error>, jprint(make(<unsupported>)));
end test;


// Verify that if a do-print-json method calls print-json recursively the
// values of dynamically bound *indent* and *sort-keys?* are preserved.
// Unfortunately it's difficult to test the sort-keys? option fully since
// it needs to be #t to have predictable output to compare against.

define class <test-recursive-calls-to-print-json> (<object>)
  constant slot the-table, required-init-keyword: the-table:;
end class;

define method do-print-json
    (thing :: <test-recursive-calls-to-print-json>, stream :: <stream>)
  // This call to print-json should match the original, top-level call to
  // print-json in its optional arguments.
  print-json(thing.the-table, stream)
end method;

define test test-recursive-calls-to-print-json ()
  let thing1 = make(<test-recursive-calls-to-print-json>,
                    the-table: make-table(1 => 2,
                                          3 => make-table(4 => 5,
                                                          6 => 7),
                                          8 => 9));
  let thing2 = make(<test-recursive-calls-to-print-json>,
                    the-table: make-table(10 => thing1));
  let result1 = with-output-to-string (stream)
                  print-json(thing2, stream, sort-keys?: #t)
                end;
  assert-equal(#:raw:"{10:{1:2,3:{4:5,6:7},8:9}}", result1);
  let result2 = with-output-to-string (stream)
                  print-json(thing2, stream, sort-keys?: #t, indent: 2)
                end;
  assert-equal(#:raw:"{
  10: {
    1: 2,
    3: {
      4: 5,
      6: 7
    },
    8: 9
  }
}", result2);
end test;
