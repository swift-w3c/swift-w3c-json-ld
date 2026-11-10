import Testing
import W3C_JSON_LD

enum `W3C_JSON_LD.Context.Active Tests` {}

extension `W3C_JSON_LD.Context.Active Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `W3C_JSON_LD.Context.Active Tests` {

    static func active(_ text: String) throws(W3C_JSON_LD.Error) -> W3C_JSON_LD.Context.Active {
        let document = try W3C_JSON_LD.Document(parsing: Array(("{\"@context\":" + text + "}").utf8))
        return try W3C_JSON_LD.Context.Active().applying(document.context ?? .null)
    }
}

extension `W3C_JSON_LD.Context.Active Tests`.Test.Unit {

    @Test
    func `terms, prefixes and the vocabulary expand keys and types`() throws {
        let active = try `W3C_JSON_LD.Context.Active Tests`.active(
            #"{"@vocab":"https://schema.org/","foaf":"http://xmlns.com/foaf/0.1/","nick":"foaf:nick"}"#
        )
        #expect(active.expand("name", at: .vocabulary) == "https://schema.org/name")
        #expect(active.expand("foaf:knows", at: .vocabulary) == "http://xmlns.com/foaf/0.1/knows")
        #expect(active.expand("nick", at: .vocabulary) == "http://xmlns.com/foaf/0.1/nick")
        #expect(active.expand("https://example.com/x", at: .vocabulary) == "https://example.com/x")
        #expect(active.expand("_:b0", at: .vocabulary) == "_:b0")
    }

    @Test
    func `document positions resolve against the base and ignore terms`() throws {
        let active = try `W3C_JSON_LD.Context.Active Tests`.active(
            #"{"@base":"https://rule.law/apps/","@vocab":"https://schema.org/","home":"https://example.com/"}"#
        )
        #expect(active.expand("../about#org", at: .document) == "https://rule.law/about#org")
        #expect(active.expand("home", at: .document) == "https://rule.law/apps/home")
    }

    @Test
    func `compaction prefers a term, then a vocabulary name, then the shortest compact IRI`() throws {
        let active = try `W3C_JSON_LD.Context.Active Tests`.active(
            #"{"@vocab":"https://schema.org/","fullName":"https://schema.org/name","s":"https://schema.org/","foaf":"http://xmlns.com/foaf/0.1/"}"#
        )
        #expect(active.compact("https://schema.org/name", at: .vocabulary) == "fullName")
        #expect(active.compact("https://schema.org/author", at: .vocabulary) == "author")
        #expect(active.compact("http://xmlns.com/foaf/0.1/knows", at: .vocabulary) == "foaf:knows")
        #expect(active.compact("https://schema.org/author", at: .document) == "s:author")
        #expect(active.compact("https://example.com/x", at: .vocabulary) == "https://example.com/x")
    }

    @Test
    func `remote contexts come only from the loader`() throws {
        let loader = W3C_JSON_LD.Context.Loader { iri in
            iri == "https://schema.org" ? .vocabulary("http://schema.org/") : nil
        }
        let active = try W3C_JSON_LD.Context.Active().applying(.iri("https://schema.org"), loader: loader)
        #expect(active.vocabulary == "http://schema.org/")
        #expect(throws: W3C_JSON_LD.Error.context("https://example.com/c")) {
            try W3C_JSON_LD.Context.Active().applying(.iri("https://example.com/c"), loader: loader)
        }
    }
}

extension `W3C_JSON_LD.Context.Active Tests`.Test.`Edge Case` {

    @Test
    func `a term ending without a delimiter is not a prefix unless marked`() throws {
        let active = try `W3C_JSON_LD.Context.Active Tests`.active(
            #"{"ex":"https://example.com/x","px":{"@id":"https://example.com/p","@prefix":true}}"#
        )
        #expect(active.expand("ex:y", at: .vocabulary) == "ex:y")
        #expect(active.expand("px:y", at: .vocabulary) == "https://example.com/py")
    }

    @Test
    func `a null term decouples the name and a keyword-like name expands to nothing`() throws {
        let active = try `W3C_JSON_LD.Context.Active Tests`.active(#"{"@vocab":"https://schema.org/","name":null}"#)
        #expect(active.expand("name", at: .vocabulary) == nil)
        #expect(active.expand("@foo", at: .vocabulary) == nil)
        #expect(active.expand("@id", at: .vocabulary) == "@id")
    }

    @Test
    func `remote contexts that load each other are refused`() {
        let loader = W3C_JSON_LD.Context.Loader { iri in
            iri == "a" ? .iri("b") : .iri("a")
        }
        #expect(throws: W3C_JSON_LD.Error.recursion("a")) {
            try W3C_JSON_LD.Context.Active().applying(.iri("a"), loader: loader)
        }
    }

    @Test
    func `terms that define each other are refused`() {
        #expect(throws: W3C_JSON_LD.Error.recursion("a")) {
            try `W3C_JSON_LD.Context.Active Tests`.active(#"{"a":{"@id":"b","@type":"@id"},"b":{"@id":"a","@type":"@id"}}"#)
        }
    }
}
