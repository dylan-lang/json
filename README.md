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

An example of usage of `parse-json`:

```dylan
// Create a JSON string
let json = #:raw:({
  "a": 1,
  "b": 2,
});

// Parse JSON to a table
let json-table = parse-json(json);

format-out("a = %d", json-table["a"]);
```

`print-json` is used to pretty print a `table` in JSON format:

```dylan
print-json(json-table, *standard-output*);
```
