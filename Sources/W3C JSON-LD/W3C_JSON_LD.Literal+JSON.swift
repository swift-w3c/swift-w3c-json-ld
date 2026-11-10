extension W3C_JSON_LD.Literal {

    public var value: RFC_8259.Value {
        let scalar: RFC_8259.Value =
            switch self.scalar {
            case .string(let string): .string(string)
            case .number(let number): .number(number)
            case .bool(let bool): .bool(bool)
            }
        guard !isPlain else { return scalar }
        var members: [(key: String, value: RFC_8259.Value)] = [(key: "@value", value: scalar)]
        if let type {
            members.append((key: "@type", value: .string(type)))
        }
        if let language {
            members.append((key: "@language", value: .string(language.value)))
        }
        if let direction {
            members.append((key: "@direction", value: .string(direction.text)))
        }
        return .object(RFC_8259.Object(members))
    }

    init?(_ object: RFC_8259.Object) throws(W3C_JSON_LD.Error) {
        let scalar: Scalar
        switch object["@value"] {
        case .null, .none:
            return nil

        case .string(let string):
            scalar = .string(string)

        case .number(let number):
            scalar = .number(number)

        case .bool(let bool):
            scalar = .bool(bool)

        case .array, .object:
            throw .unsupported("@json")
        }
        self.init(scalar)
        for (key, value) in object {
            switch (key, value) {
            case ("@value", _):
                continue

            case ("@type", .string(let type)):
                self.type = type

            case ("@language", .string(let language)):
                self.language = try W3C_JSON_LD.Context.tag(language)

            case ("@direction", .string(let direction)):
                guard let direction = Direction(direction) else { throw .keyword("@direction") }
                self.direction = direction

            case ("@index", _):
                throw .unsupported("@index")

            default:
                throw .keyword(key)
            }
        }
        if type != nil, language != nil || direction != nil {
            throw .keyword("@type")
        }
    }
}
