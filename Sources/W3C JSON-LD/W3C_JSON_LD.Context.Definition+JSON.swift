extension W3C_JSON_LD.Context.Definition {

    public var value: RFC_8259.Value {
        var members: [(key: String, value: RFC_8259.Value)] = []
        if let base {
            members.append((key: "@base", value: .string(base)))
        }
        if let vocabulary {
            members.append((key: "@vocab", value: .string(vocabulary)))
        }
        if let language {
            members.append((key: "@language", value: .string(language.value)))
        }
        for term in terms {
            members.append((key: term.name, value: term.value))
        }
        return .object(RFC_8259.Object(members))
    }

    init(_ object: RFC_8259.Object) throws(W3C_JSON_LD.Error) {
        self.init()
        for (key, value) in object {
            switch (key, value) {
            case ("@base", .string(let base)):
                self.base = base

            case ("@vocab", .string(let vocabulary)):
                self.vocabulary = vocabulary

            case ("@language", .string(let language)):
                self.language = try W3C_JSON_LD.Context.tag(language)

            case ("@version", .number(let version)) where version.double == 1.1:
                continue

            case ("@base", _), ("@vocab", _), ("@language", _), ("@version", _):
                throw .keyword(key)

            case _ where W3C_JSON_LD.isKeyword(key):
                throw .unsupported(key)

            default:
                terms.append(try W3C_JSON_LD.Context.Term(key, value))
            }
        }
    }
}
