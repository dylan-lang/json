Json Library Reference
**********************

.. current-library:: json
.. current-module:: json

The json module
===============

Constants
---------

.. constant:: $null

   Is what "null" parses to.

Conditions
----------

.. class:: <json-error>
   :open:
   :instantiable:

   All JSON errors are subclasses of this class.

   :superclasses: :class:`<format-string-condition>` :drm:`<error>`

.. class:: <json-parse-error>
   :instantiable:

   Any error signalled during parsing (except for file system errors)
   will be an instance of this.

   :superclasses: :class:`<json-error>`

``parse-json``
--------------

.. generic-function:: parse-json
   :open:

   Parse json formatted text from the given *source*.  This is the
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

      - "\<c>" is equivalent to ``<c>``, where <c> is not a defined
        escape character.

      - trailing commas are allowed in arrays and objects

.. method:: parse-json
   :specializer: <string>

   Parse a JSON object from a :drm:`<string>`.

   :signature: parse-json (source, #key strict?, table-class) => (json)
   :parameter source: An instance of :drm:`<string>`
   :parameter #key strict?: An instance of :drm:`<boolean>`. Default to :drm:`#t`.
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
   :parameter #key strict?: An instance of :drm:`<boolean>`. Default to :drm:`#f`.
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

``print-json``
--------------

.. function:: print-json

   Print an object in JSON format.

   :signature: print-json (object, stream, #key indent, sort-keys?) => ()
   :parameter object: The object to print. An instance of :drm:`<object>`.
   :parameter stream: Stream on wich to do output. An instance of :class:`<stream>`.
   :parameter #key indent: :drm:`#f` or an instance of :drm:`<integer>`.
   :parameter #key sort-keys?: An instance of :drm:`<boolean>`.

   :discussion:

      If `indent` is false, *object* is printed with minimal
      whitespace. If an integer, then use pretty printing and output
      *indent* spaces for each indent level.

      If `sort-keys?:` is true, output object keys in lexicographical
      order.

``do-print-json``
^^^^^^^^^^^^^^^^^

Override this to print your own objects in JSON format. It can be
implemented by converting objects to built-in Dylan types (tables,
collections, etc) and calling *print-json* on those objects, or by
writing json syntax directly to *stream*.

If `indent:` was passed to *print* then *stream* will be a pretty
printing stream and the io:pprint module may be used to implement
pretty printing.

.. generic-function:: do-print-json
   :open:

   :signature: do-print-json (object, stream) => ()
   :parameter object: An instance of :drm:`<object>`.
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: $null

   :parameter object: $null 
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: <integer>

   Print an :drm:`<integer>` in JSON format.

   :parameter object: An instance of :drm:`<integer>`.
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: <float>

   Print a :drm:`<float>` in JSON format.

   :parameter object: An instance of :drm:`<float>`.
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: <boolean>

   Print a :drm:`<boolean>` in JSON format.

   :parameter object: An instance of :drm:`<boolean>`.
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: <string>

   Print a :drm:`<string>` in JSON format.

   :parameter object: An instance of :drm:`<string>`.
   :parameter stream: An instance of :class:`<stream>`.

.. method:: do-print-json
   :specializer: <collection>

   Print a :drm:`<collection>` in JSON format.

   :parameter object: An instance of :drm:`<collection>`.
   :parameter stream: An instance of :class:`<stream>`.
