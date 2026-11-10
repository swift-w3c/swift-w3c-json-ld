extension W3C_JSON_LD.Context.Term {

    public var value: RFC_8259.Value {
        if isSimple, let id {
            return .string(id)
        }
        var members: [(key: String, value: RFC_8259.Value)] = []
        if let id {
            members.append((key: "@id", value: .string(id)))
        }
        if let type {
            members.append((key: "@type", value: .string(type)))
        }
        if let container {
            members.append((key: "@container", value: .string(container)))
        }
        if let language {
            members.append((key: "@language", value: .string(language.value)))
        }
        if let prefix {
            members.append((key: "@prefix", value: .bool(prefix)))
        }
        guard !members.isEmpty else { return .null }
        return .object(RFC_8259.Object(members))
    }

    init(_ name: String, _ value: RFC_8259.Value) throws(W3C_JSON_LD.Error) {
        switch value {
        case .null:
            self.init(name, id: nil)

        case .string(let id):
            self.init(name, id: id)

        case .object(let object):
            self.init(name, id: nil)
            for (key, value) in object {
                switch (key, value) {
                case ("@id", .string(let id)):
                    self.id = id

                case ("@type", .string(let type)):
                    self.type = type

                case ("@container", .string(let container)) where ["@list", "@set"].contains(container):
                    self.container = container

                case ("@language", .string(let language)):
                    self.language = try W3C_JSON_LD.Context.tag(language)

                case ("@prefix", .bool(let prefix)):
                    self.prefix = prefix

                case ("@id", _), ("@type", _), ("@language", _), ("@prefix", _):
                    throw .keyword(key)

                default:
                    throw .unsupported(key)
                }
            }
            if id == nil, type == nil, container == nil, language == nil, prefix == nil {
                throw .keyword(name)
            }

        default:
            throw .keyword(name)
        }
    }
}
