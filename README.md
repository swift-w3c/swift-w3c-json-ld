# swift-w3c-json-ld

Use this package when you write or read JSON-LD 1.1 documents in their compacted form, such as the structured data a web page carries in `<script type="application/ld+json">`. Start from `W3C_JSON_LD.Document` (also spelled `JSONLD.Document`): build one from a `W3C_JSON_LD.Node` or from any `W3C_JSON_LD.Representable` value, take its `bytes`, or read one with `W3C_JSON_LD.Document(parsing:)`. To read a document whose terms come from a context, call `expanded(loader:)` for absolute IRIs, or `compacted(to:loader:)` to rewrite it against another context. If you want the schema.org vocabulary as Swift types, use swift-schema-org-vocabulary, which is built on this package.

## Laws

- A document holds one node or a graph of nodes. One node is written as one JSON object with the document's `@context` first, then `@id`, `@type` and its properties in the order they were set. A graph is written as `{"@context": …, "@graph": […]}`.
- A property with one value is written as that value, with several as an array, and with none not at all. One type is written as a string, several as an array.
- Reading takes a top-level object with `@graph`, and at most `@context` beside it, as a graph, any other object as one node, and a top-level array as a graph, which is written back with `@graph`.
- A value object with only `@value` reads as the plain value. `null` values and `{"@value": null}` are dropped, nested arrays are flattened, `@set` is unwrapped and `@list` keeps its order as a list. Numbers keep the text they were written as.
- Keys that look like keywords but are not, such as `@foo`, are ignored.
- These are refused as unsupported: `@reverse`, `@included`, `@nest` and `@index`; JSON literals (`@json`); `@graph` inside a node or beside `@id`; `@protected`, `@propagate`, `@import` and `@direction` in a context; and in a term definition anything but `@id`, `@type`, `@language`, `@prefix` and a `@container` of `@list` or `@set`.
- A keyword with the wrong kind of value is refused: `@id` that is not a string, `@type` that is not one or more strings, `@language` that is not an RFC 5646 language tag, `@direction` other than `ltr` or `rtl`, a value object with both `@type` and `@language`, and a `@context` that is not a string, object, array or null.
- Text that is not JSON fails as JSON. JSON that is neither an object nor an array is refused.
- Expansion makes keys and types absolute through the context: a term, then a compact IRI whose prefix is a simple term ending in `:`, `/`, `?`, `#`, `[`, `]` or `@` or one marked `@prefix`, then `@vocab`. An `@id` resolves against `@base` by RFC 3986 and ignores terms. Keyword aliases such as `"id": "@id"` become the node's id and types. A key that expands to no IRI is dropped, and a term mapped to null expands to nothing.
- Expansion applies a term's `@type` of `@id`, `@vocab` or a datatype, its `@language`, the context's default `@language`, and a `@container` of `@list`. Other containers are not supported.
- Contexts nested in a node apply to that node and the nodes inside it.
- A context given as an IRI is never fetched. It comes from the loader, and a loader that has none fails with `W3C_JSON_LD.Error.context`. Contexts that load each other, or more than 32 in a chain, and terms whose definitions refer to each other fail with `W3C_JSON_LD.Error.recursion`.
- Compaction writes an IRI as the shortest term that maps to it, then as a name relative to `@vocab` if that name is not a term, then as the shortest compact IRI, and otherwise unchanged. It never writes a relative IRI. A language equal to the default is dropped. Term type coercion and containers are not applied when compacting.
- `W3C_JSON_LD.Document(graph:)` with values of several types gives the document one context when all their contexts are equal. Otherwise each node carries its own.
- `W3C_JSON_LD.Node`'s subscript reads every value of a key, replaces them in place, appends a new key at the end, and removes the key when set to no values.
- Not covered: the expanded document form, flattening, framing, conversion to RDF, named graphs, reverse properties, scoped contexts, language, index, id and type maps, and fetching remote contexts.
