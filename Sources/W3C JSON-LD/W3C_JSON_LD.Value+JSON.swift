extension W3C_JSON_LD.Value {

    public var value: RFC_8259.Value {
        switch self {
        case .literal(let literal):
            return literal.value

        case .node(let node):
            return node.value

        case .list(let values):
            return .object(RFC_8259.Object([(key: "@list", value: .array(RFC_8259.Array(values.map(\.value))))]))
        }
    }

    static func values(_ value: RFC_8259.Value) throws(W3C_JSON_LD.Error) -> [Self] {
        switch value {
        case .null:
            return []

        case .string(let string):
            return [.string(string)]

        case .number(let number):
            return [.number(number)]

        case .bool(let bool):
            return [.literal(W3C_JSON_LD.Literal(.bool(bool)))]

        case .array(let array):
            var values: [Self] = []
            for element in array {
                values += try Self.values(element)
            }
            return values

        case .object(let object):
            let keys = Set(object.keys)
            if keys.contains("@value") {
                guard let literal = try W3C_JSON_LD.Literal(object) else { return [] }
                return [.literal(literal)]
            }
            if keys.contains("@list") {
                guard keys == ["@list"] else { throw .keyword("@list") }
                return [.list(try Self.values(object["@list"] ?? .null))]
            }
            if keys.contains("@set") {
                guard keys == ["@set"] else { throw .keyword("@set") }
                return try Self.values(object["@set"] ?? .null)
            }
            return [.node(try W3C_JSON_LD.Node(object))]
        }
    }
}
