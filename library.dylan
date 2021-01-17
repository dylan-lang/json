module: dylan-user

define library json
  use common-dylan;
  use io;
  use strings;

  export json;
end;

define module json
  create
    <json-error>,
    <json-parse-error>,

    parse-json,

    print-json,                 // call this
    do-print-json,              // implement this

    $null;
end;

define module %json
  use common-dylan;
  use format,
    import: { format, format-to-string };
  use json;
  use pprint,
    prefix: "io/",
    import: { printing-logical-block, pprint-indent, pprint-newline };
  use print,
    import: { *print-pretty?* };
  use streams;
  use strings,
    import: { decimal-digit?, replace-substrings };
  use threads,
    import: { dynamic-bind };
end;
