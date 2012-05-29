module: dylan-user

define library json
  use common-dylan;
  use io;
  use strings;
  export json;
end;

define module json
  create
    encode-json,
    parse-json,
    <json-error>,
    $null;
end;

define module %json
  use common-dylan;
  use json;
  use streams;
  use strings;
end;
