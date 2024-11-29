****
json
****

.. current-library:: json
.. current-module:: json

.. toctree::
   :maxdepth: 2
   :hidden:

This library provides essential functionality for working with JSON data.  JSON
(JavaScript Object Notation) is a lightweight data interchange format that is easy for
humans to read and write, and easy for machines to parse and generate.


The json Module
===============

Constants
---------

.. constant:: $null

   When parsing, JSON's "null" is converted to this value and when printing this value is
   printed as "null".


Conditions
----------

.. class:: <json-error>
   :open:
   :instantiable:

   All JSON errors are subclasses of this class.

   :superclasses: :class:`<format-string-condition>` :drm:`<error>`

.. class:: <json-parse-error>
   :instantiable:

   Any error signalled during parsing (except for file system errors) will be an instance
   of this class.

   :superclasses: :class:`<json-error>`


Parsing
-------

.. generic-function:: parse-json
   :open:

   Parse JSON formatted text from the given *source*.  This is the
   main user-visible entry point for parsing.  *table-class*, if
   provided, should be a subclass of :class:`<table>` to use when
   creating a json "object".

   :signature: parse-json (source, #key strict?, table-class) => (json)
   :parameter source: An :drm:`<object>`.
   :parameter #key strict?: An instance of :drm:`<boolean>`.
   :parameter #key table-class: Default to :class:`<string-table>`.
   :value json: A JSON :drm:`<object>`

   :discussion:

      The parse is strict by default. If ``strict?:`` :drm:`#f` is
      used then:

      - `#` is allowed as a comment character

      - ``\<c>`` is equivalent to ``<c>``, where ``<c>`` is not a defined
        escape character.

      - Trailing commas are allowed in arrays and objects.

.. method:: parse-json
   :specializer: <string>

   Parse a JSON object from a :drm:`<string>`.

   :signature: parse-json (source, #key strict?, table-class) => (json)
   :parameter source: An instance of :drm:`<string>`
   :parameter #key strict?: An instance of :drm:`<boolean>`. The default is :drm:`#t`.
   :parameter #key table-class: A subclass of :class:`<table>`.
   :value json: An instance of :drm:`<object>`.

   :example:

      .. code-block:: dylan

        let data = """{"a": 1, "b": 2,}""";
        let parsed = parse-json(data, strict?: #f);
	let a = parsed["a"];

      `Run this example <https://play.opendylan.org/shared/89037b0be1300a55>`_
      in https://play.opendylan.org

      Note the use of ``strict?: #f`` is needed since *data* has a
      trailing comma after the number 2.

.. method:: parse-json
   :specializer: <stream>

   Parse a JSON object from a :class:`<stream>`.

   :signature: parse-json (source, #key strict?, table-class) => (json)
   :parameter source: An instance of :class:`<stream>`.
   :parameter #key strict?: An instance of :drm:`<boolean>`. The default is :drm:`#f`.
   :parameter #key table-class: A subclass of :class:`<table>`.
   :value json: An instance of :drm:`<object>`.

   :example:

      .. code-block:: dylan

        with-open-file (fs = "data.json")
	  let data = parse-json(fs, strict?: #f);
	  ...
	end;

      `Run an example
      <https://play.opendylan.org/shared/24c4ac32aaf6a5b5>`_ with a
      string stream in https://play.opendylan.org


Printing
--------

.. function:: print-json

   Print an object in JSON format.

   :signature: print-json (object, stream, #key indent, sort-keys?) => ()
   :parameter object: The object to print. An instance of :drm:`<object>`.
   :parameter stream: Stream on wich to do output. An instance of :class:`<stream>`.
   :parameter #key indent: :drm:`#f` or an instance of :drm:`<integer>`.
   :parameter #key sort-keys?: An instance of :drm:`<boolean>`.

   :discussion:

      If ``indent`` is false, *object* is printed with minimal whitespace. If ``indent``
      is an integer, then pretty printing is used, with *indent* spaces for each indent
      level.

      If ``sort-keys?`` is true, output object keys in lexicographical
      order.

      This function does some initial setup and then calls :gf:`do-print-json` to print
      ``object``.  :gf:`do-print-json` has methods for most built-in Dylan types.

.. generic-function:: do-print-json
   :open:

   :signature: do-print-json (object, stream) => ()
   :parameter object: An instance of :drm:`<object>`.
   :parameter stream: An instance of :class:`<stream>`.

   :description:

      This method may be overridden for your own classes in order to print them in JSON
      format. Often the simplest way to implement your method will be to convert your
      object to a :drm:`<table>` and then pass it to :func:`print-json` to print it on
      *stream*.

      It is also possible to write JSON syntax directly to *stream*.  If `indent:` was
      passed to *print* then *stream* will be a pretty printing stream and the `pprint
      module <https://opendylan.org/library-reference/io/print.html#the-pprint-module>`_
      in the IO library may be used to implement pretty printing.

.. method:: do-print-json
   :specializer: == $null

   Prints "null" on the output stream.

.. method:: do-print-json
   :specializer: <integer>

   Prints an :drm:`<integer>` on the output stream.

.. method:: do-print-json
   :specializer: <float>

   Prints a :drm:`<float>` on the output stream.

.. method:: do-print-json
   :specializer: <boolean>

   Prints a :drm:`<boolean>` on the output stream as "true" or "false".

.. method:: do-print-json
   :specializer: <string>

   Prints a :drm:`<string>` on the output stream as a JSON compatible
   string. Specifically, this method limits the escape codes to those recognized by the
   JSON format and converts non-printable characters to Unicode escape sequences.

.. method:: do-print-json
   :specializer: <collection>

   Prints a :drm:`<collection>` on the output stream as a JSON array.

.. method:: do-print-json
   :specializer: <table>

   Prints a :drm:`<table>` on the output stream as a JSON "object".
