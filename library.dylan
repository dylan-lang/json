module: dylan-user

define library json
  use dylan;
  use common-dylan;
  use io;
  use string-extensions;
  export json;
end;

define module json
  use dylan;
  use streams;
  use common-extensions;
  use substring-search;
  use format;
  export encode-json;
end;
