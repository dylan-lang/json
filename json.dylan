module: json

define generic encode-json (stream :: <stream>, object :: <object>);

define constant $escapes = 
  vector(pair("\\", "\\\\"),
         pair("\"", "\\\""),
         pair("\n", "\\n"),
         pair("\t", "\\t"));

define method encode-json (stream :: <stream>, object :: <string>)
  write(stream, "\"");
  for (escape in $escapes)
    object := substring-replace(object, head(escape), tail(escape));
  end for;
  write(stream, object);
  write(stream, "\"");
end;

define method encode-json (stream :: <stream>, object :: <integer>)
  format(stream, "%d", object);
end;

define method encode-json (stream :: <stream>, object :: <float>)
  format(stream, "%f", object);
end;

define method encode-json (stream :: <stream>, object :: singleton(#f))
  write(stream, "false");
end;

define method encode-json (stream :: <stream>, object :: singleton(#t))
  write(stream, "true");
end;

define method encode-json (stream :: <stream>, object :: <collection>)
  write(stream, "[");
  for (o in object,
       i from 0)
    if (i > 0)
      write(stream, ", ");
    end if;
    encode-json(stream, o);
  end for;
  write(stream, "]");
end;

define method encode-json (stream :: <stream>, object :: <table>)
  write(stream, "{");
  for (value keyed-by key in object,
       i from 0)
    if (i > 0)
      write(stream, ", ");
    end if;
    encode-json(stream, key);
    write(stream, ":");
    encode-json(stream, value);
  end for;
  write(stream, "}");
end;