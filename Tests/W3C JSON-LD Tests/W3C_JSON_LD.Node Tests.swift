import Testing
import W3C_JSON_LD

enum `W3C_JSON_LD.Node Tests` {}

extension `W3C_JSON_LD.Node Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `W3C_JSON_LD.Node Tests` {

    static func expanded(_ text: String) throws(W3C_JSON_LD.Error) -> W3C_JSON_LD.Document {
        try W3C_JSON_LD.Document(parsing: Array(text.utf8)).expanded()
    }

    static func text(_ document: W3C_JSON_LD.Document) -> String {
        String(decoding: document.bytes, as: UTF8.self)
    }
}

extension `W3C_JSON_LD.Node Tests`.Test.Unit {

    @Test
    func `expansion gives absolute keys, types and ids`() throws {
        let document = try `W3C_JSON_LD.Node Tests`.expanded(
            ##"{"@context":{"@vocab":"https://schema.org/","@base":"https://rule.law/"},"@id":"#site","@type":"WebSite","name":"rule.law","publisher":{"@context":{"@vocab":"https://example.com/"},"@type":"Org"}}"##
        )
        #expect(
            `W3C_JSON_LD.Node Tests`.text(document)
                == ##"{"@id":"https://rule.law/#site","@type":"https://schema.org/WebSite","https://schema.org/name":"rule.law","https://schema.org/publisher":{"@type":"https://example.com/Org"}}"##
        )
    }

    @Test
    func `keyword aliases become the id and types`() throws {
        let document = try `W3C_JSON_LD.Node Tests`.expanded(
            #"{"@context":{"@vocab":"https://schema.org/","id":"@id","type":"@type"},"id":"https://a/","type":"Person"}"#
        )
        #expect(`W3C_JSON_LD.Node Tests`.text(document) == #"{"@id":"https://a/","@type":"https://schema.org/Person"}"#)
    }

    @Test
    func `terms coerce types, languages and lists`() throws {
        let document = try `W3C_JSON_LD.Node Tests`.expanded(
            #"{"@context":{"@language":"nl","url":{"@id":"https://schema.org/url","@type":"@id"},"kind":{"@id":"https://schema.org/kind","@type":"@vocab"},"date":{"@id":"https://schema.org/date","@type":"https://schema.org/Date"},"en":{"@id":"https://schema.org/en","@language":"en"},"steps":{"@id":"https://schema.org/steps","@container":"@list"},"@vocab":"https://schema.org/"},"url":"https://rule.law/","kind":"Free","date":"2026-11-10","en":"Law","name":"Wet","steps":["a","b"],"n":1}"#
        )
        #expect(
            `W3C_JSON_LD.Node Tests`.text(document)
                == #"{"https://schema.org/url":{"@id":"https://rule.law/"},"https://schema.org/kind":{"@id":"https://schema.org/Free"},"https://schema.org/date":{"@value":"2026-11-10","@type":"https://schema.org/Date"},"https://schema.org/en":{"@value":"Law","@language":"en"},"https://schema.org/name":{"@value":"Wet","@language":"nl"},"https://schema.org/steps":{"@list":[{"@value":"a","@language":"nl"},{"@value":"b","@language":"nl"}]},"https://schema.org/n":1}"#
        )
    }

    @Test
    func `compaction writes terms against the given context`() throws {
        let document = try W3C_JSON_LD.Document(
            parsing: Array(#"{"@context":{"s":"http://schema.org/"},"@type":"s:Person","s:name":"A"}"#.utf8)
        )
        let compacted = try document.compacted(to: .vocabulary("http://schema.org/"))
        #expect(
            `W3C_JSON_LD.Node Tests`.text(compacted)
                == #"{"@context":{"@vocab":"http://schema.org/"},"@type":"Person","name":"A"}"#
        )
    }
}

extension `W3C_JSON_LD.Node Tests`.Test.`Edge Case` {

    @Test
    func `keys that expand to no IRI are dropped`() throws {
        let document = try `W3C_JSON_LD.Node Tests`.expanded(#"{"name":"A","https://schema.org/x":"B"}"#)
        #expect(`W3C_JSON_LD.Node Tests`.text(document) == #"{"https://schema.org/x":"B"}"#)
    }

    @Test
    func `the subscript keeps order, replaces in place and removes on empty`() {
        var node = W3C_JSON_LD.Node(properties: [.init("a", [.string("1")]), .init("b", [.string("2")])])
        node["a"] = [.string("3")]
        node["c"] = [.string("4")]
        node["b"] = []
        #expect(node.properties.map(\.key) == ["a", "c"])
        #expect(node["a"] == [.string("3")])
        #expect(node["missing"].isEmpty)
    }
}
