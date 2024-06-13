Module: dylan-user
Synopsis: JSON test suite
Copyright: Copyright (c) 2012 Dylan Hackers.  All rights reserved.
License: See License.txt in this distribution for details.


define library json-test-suite
  use collections,
    import: { table-extensions };
  use common-dylan,
    import: { common-dylan, threads };
  use json;
  use io,
    import: { format, pprint, streams };
  use system,
    import: { locators };
  use testworks;
end;

define module json-test-suite
  use common-dylan;
  use table-extensions,
    import: {},
    rename: { tabling => make-table,
              <case-insensitive-string-table> => <istring-table> };
  use json;
  use format,
    import: { format-to-string };
  use locators,
    import: { <file-locator>,
              locator-name };
  use pprint,
    import: { *default-line-length* };
  use streams,
    import: { with-output-to-string };
  use testworks;
  use threads,
    import: { dynamic-bind };
end;
