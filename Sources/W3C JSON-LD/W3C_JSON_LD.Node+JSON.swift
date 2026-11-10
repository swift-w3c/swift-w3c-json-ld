extension W3C_JSON_LD.Node {

    static func nodes(_ value: RFC_8259.Value) throws(W3C_JSON_LD.Error) -> [Self] {
        switch value {
        case .null:
            return []

        case .object(let object):
            return [try Self(object)]

        case .array(let array):
            var nodes: [Self] = []
            for element in array {
                nodes += try Self.nodes(element)
            }
            return nodes

        default:
            throw .keyword("@graph")
        }
    }

    public var value: RFC_8259.Value {
        var members: [(key: String, value: RFC_8259.Value)] = []
        if let context {
            members.append((key: "@context", value: context.value))
        }
        if let id {
            members.append((key: "@id", value: .string(id)))
        }
        if types.count == 1, let type = types.first {
            members.append((key: "@type", value: .string(type)))
        } else if !types.isEmpty {
            members.append((key: "@type", value: .array(RFC_8259.Array(types.map { .string($0) }))))
        }
        for property in properties where !property.values.isEmpty {
            if property.values.count == 1, let value = property.values.first {
                members.append((key: property.key, value: value.value))
            } else {
                members.append((key: property.key, value: .array(RFC_8259.Array(property.values.map(\.value)))))
            }
        }
        return .object(RFC_8259.Object(members))
    }

    public init(_ object: RFC_8259.Object) throws(W3C_JSON_LD.Error) {
        self.init()
        for (key, value) in object {
            switch key {
            case "@context":
                context = try W3C_JSON_LD.Context(value)

            case "@id":
                guard case .string(let id) = value else { throw .keyword("@id") }
                self.id = id

            case "@type":
                switch value {
                case .string(let type):
                    types.append(type)

                case .array(let array):
                    for element in array {
                        guard case .string(let type) = element else { throw .keyword("@type") }
                        types.append(type)
                    }

                default:
                    throw .keyword("@type")
                }

            case _ where W3C_JSON_LD.isKeyword(key):
                throw .unsupported(key)

            case _ where W3C_JSON_LD.looksLikeKeyword(key):
                continue

            default:
                self[key] += try W3C_JSON_LD.Value.values(value)
            }
        }
    }
}
