extension W3C_JSON_LD {

    public indirect enum Value: Sendable, Hashable {

        case literal(Literal)

        case node(Node)

        case list([Value])
    }
}

extension W3C_JSON_LD.Value {

    public static func string(_ value: String) -> Self {
        .literal(W3C_JSON_LD.Literal(.string(value)))
    }

    public static func number(_ value: RFC_8259.Number) -> Self {
        .literal(W3C_JSON_LD.Literal(.number(value)))
    }

    public static func reference(_ id: String) -> Self {
        .node(W3C_JSON_LD.Node(id: id))
    }
}

extension W3C_JSON_LD.Value {

    public var literal: W3C_JSON_LD.Literal? {
        guard case .literal(let value) = self else { return nil }
        return value
    }

    public var node: W3C_JSON_LD.Node? {
        guard case .node(let value) = self else { return nil }
        return value
    }

    public var list: [W3C_JSON_LD.Value]? {
        guard case .list(let value) = self else { return nil }
        return value
    }
}
