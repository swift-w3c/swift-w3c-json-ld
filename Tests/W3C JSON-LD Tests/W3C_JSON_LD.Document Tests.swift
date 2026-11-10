import Testing
import W3C_JSON_LD

enum `W3C_JSON_LD.Document Tests` {}

extension `W3C_JSON_LD.Document Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `W3C_JSON_LD.Document Tests` {

    static func text(_ document: W3C_JSON_LD.Document) -> String {
        String(decoding: document.bytes, as: UTF8.self)
    }

    static func parse(_ text: String) throws(W3C_JSON_LD.Error) -> W3C_JSON_LD.Document {
        try W3C_JSON_LD.Document(parsing: Array(text.utf8))
    }

    static func reading(_ text: String) -> W3C_JSON_LD.Error? {
        do throws(W3C_JSON_LD.Error) {
            _ = try parse(text)
            return nil
        } catch {
            return error
        }
    }
}

extension `W3C_JSON_LD.Document Tests`.Test.Unit {

    @Test
    func `one node writes one object with context, id and type first`() {
        let node = W3C_JSON_LD.Node(
            id: "https://rule.law/#site",
            types: ["WebSite"],
            properties: [.init("name", [.string("rule.law")]), .init("inLanguage", [.string("nl")])]
        )
        let document = W3C_JSON_LD.Document(node, context: .iri("https://schema.org"))
        #expect(
            `W3C_JSON_LD.Document Tests`.text(document)
                == #"{"@context":"https://schema.org","@id":"https://rule.law/#site","@type":"WebSite","name":"rule.law","inLanguage":"nl"}"#
        )
    }

    @Test
    func `one value is written bare, several as an array, none not at all`() {
        let node = W3C_JSON_LD.Node(
            types: ["Thing", "Product"],
            properties: [
                .init("name", [.string("a")]),
                .init("sameAs", [.string("x"), .string("y")]),
                .init("image", []),
            ]
        )
        #expect(
            `W3C_JSON_LD.Document Tests`.text(W3C_JSON_LD.Document(node))
                == #"{"@type":["Thing","Product"],"name":"a","sameAs":["x","y"]}"#
        )
    }

    @Test
    func `several nodes are written as a graph under one context`() {
        let document = W3C_JSON_LD.Document(
            graph: [W3C_JSON_LD.Node(types: ["Organization"]), W3C_JSON_LD.Node(types: ["WebSite"])],
            context: .iri("https://schema.org")
        )
        #expect(
            `W3C_JSON_LD.Document Tests`.text(document)
                == #"{"@context":"https://schema.org","@graph":[{"@type":"Organization"},{"@type":"WebSite"}]}"#
        )
    }

    @Test
    func `a document reads back as it was written`() throws {
        let text =
            #"{"@context":{"@vocab":"https://schema.org/","@language":"nl"},"@id":"_:b0","@type":"Book","name":"Wet","author":{"@type":"Person","name":"A"},"position":3,"free":true,"tags":{"@list":["a","b"]},"note":{"@value":"x","@language":"en"},"date":{"@value":"2026-11-10","@type":"Date"}}"#
        let document = try `W3C_JSON_LD.Document Tests`.parse(text)
        #expect(`W3C_JSON_LD.Document Tests`.text(document) == text)
    }

    @Test
    func `numbers keep the text they were written as`() throws {
        let document = try `W3C_JSON_LD.Document Tests`.parse(#"{"price":1.50,"count":1e2}"#)
        #expect(`W3C_JSON_LD.Document Tests`.text(document) == #"{"price":1.50,"count":1e2}"#)
    }

    @Test
    func `a top-level graph object reads as a graph`() throws {
        let document = try `W3C_JSON_LD.Document Tests`.parse(
            #"{"@context":"https://schema.org","@graph":[{"@type":"A"},{"@type":"B"}]}"#
        )
        #expect(document.context == .iri("https://schema.org"))
        #expect(document.nodes.map(\.types) == [["A"], ["B"]])
    }

    @Test
    func `a top-level array reads as a graph and is written with @graph`() throws {
        let document = try `W3C_JSON_LD.Document Tests`.parse(
            #"[{"@context":"https://schema.org","@type":"A"},{"@type":"B"}]"#
        )
        #expect(document.context == nil)
        #expect(
            `W3C_JSON_LD.Document Tests`.text(document)
                == #"{"@graph":[{"@context":"https://schema.org","@type":"A"},{"@type":"B"}]}"#
        )
    }

    @Test
    func `values of different representable types share one context when equal`() {
        struct A: W3C_JSON_LD.Representable {
            static var context: W3C_JSON_LD.Context { .iri("https://schema.org") }
            var node: W3C_JSON_LD.Node { W3C_JSON_LD.Node(types: ["A"]) }
        }
        struct B: W3C_JSON_LD.Representable {
            static var context: W3C_JSON_LD.Context { .iri("https://schema.org") }
            var node: W3C_JSON_LD.Node { W3C_JSON_LD.Node(types: ["B"]) }
        }
        struct C: W3C_JSON_LD.Representable {
            static var context: W3C_JSON_LD.Context { .vocabulary("https://example.com/") }
            var node: W3C_JSON_LD.Node { W3C_JSON_LD.Node(types: ["C"]) }
        }
        #expect(W3C_JSON_LD.Document(graph: A(), B()).context == .iri("https://schema.org"))
        let mixed = W3C_JSON_LD.Document(graph: A(), C())
        #expect(mixed.context == nil)
        #expect(mixed.nodes.map(\.context) == [.iri("https://schema.org"), .vocabulary("https://example.com/")])
    }
}

extension `W3C_JSON_LD.Document Tests`.Test.`Edge Case` {

    @Test
    func `plain value objects, nulls, nested arrays and sets read as plain values`() throws {
        let document = try `W3C_JSON_LD.Document Tests`.parse(
            #"{"a":{"@value":"x"},"b":null,"c":{"@value":null},"d":[["y"],[{"@set":["z"]}]]}"#
        )
        #expect(`W3C_JSON_LD.Document Tests`.text(document) == #"{"a":"x","d":["y","z"]}"#)
    }

    @Test
    func `keys that only look like keywords are ignored`() throws {
        let document = try `W3C_JSON_LD.Document Tests`.parse(#"{"@foo":1,"name":"a"}"#)
        #expect(`W3C_JSON_LD.Document Tests`.text(document) == #"{"name":"a"}"#)
    }

    @Test(arguments: [
        (#"{"@reverse":{}}"#, "@reverse"),
        (#"{"@included":[]}"#, "@included"),
        (#"{"@nest":{}}"#, "@nest"),
        (#"{"@index":"a"}"#, "@index"),
        (#"{"a":{"@value":{"x":1},"@type":"@json"}}"#, "@json"),
        (#"{"@id":"x","@graph":[]}"#, "@graph"),
        (#"{"@context":{"@protected":true}}"#, "@protected"),
        (#"{"@context":{"@import":"x"}}"#, "@import"),
        (#"{"@context":{"@direction":"ltr"}}"#, "@direction"),
        (#"{"@context":{"a":{"@id":"x","@container":"@index"}}}"#, "@container"),
        (#"{"@context":{"a":{"@id":"x","@context":{}}}}"#, "@context"),
    ])
    func `keywords out of scope are refused as unsupported`(text: String, keyword: String) {
        #expect(`W3C_JSON_LD.Document Tests`.reading(text) == .unsupported(keyword))
    }

    @Test(arguments: [
        (#"{"@id":3}"#, "@id"),
        (#"{"@type":[1]}"#, "@type"),
        (#"{"a":{"@value":"x","@language":"not a tag"}}"#, "@language"),
        (#"{"a":{"@value":"x","@direction":"up"}}"#, "@direction"),
        (#"{"a":{"@value":"x","@type":"T","@language":"en"}}"#, "@type"),
        (#"{"@context":3}"#, "@context"),
    ])
    func `malformed keywords are refused`(text: String, keyword: String) {
        #expect(`W3C_JSON_LD.Document Tests`.reading(text) == .keyword(keyword))
    }

    @Test
    func `text that is not a JSON object or array is refused`() {
        #expect(`W3C_JSON_LD.Document Tests`.reading(#""text""#) == .document)
        guard case .json = `W3C_JSON_LD.Document Tests`.reading(#"{"a":}"#) else {
            Issue.record("malformed JSON should fail as JSON")
            return
        }
    }
}
