# JSON

Opendylan library to parse the JSON standard file format.

## Install

Add `json` to your project dependencies

```json
"dependencies": [ "json" ],
```

Update the dependencies:

```
dylan update
```

## Usage

Add `use json;` in the library and module section of your
`library.dylan` file.

This library exports the following methods:

- `parse-json` and
- `print-json`

### Parse JSON

An example of usage of `parse-json`:

```dylan
let json = """
  {
    "a": 1,
    "b": 2
  }
  """;

let json-table = parse-json(json);
format-out("a = %d", json-table["a"]);
```

[Run this code](https://play.opendylan.org/shared/d123253033bda66a) in
https://play.opendylan.org

### Print JSON

`print-json` is used to pretty print a `table` in JSON format,
following the previous example:

```dylan
print-json(json-table, *standard-output*, indent: 2);
```

[Run a complete example](https://play.opendylan.org/shared/06af84b39fab129b) in
https://play.opendylan.org
