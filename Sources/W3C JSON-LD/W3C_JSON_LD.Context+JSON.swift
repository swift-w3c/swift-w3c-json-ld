extension W3C_JSON_LD.Context {

    public var value: RFC_8259.Value {
        switch self {
        case .null:
            return .null

        case .iri(let iri):
            return .string(iri)

        case .list(let contexts):
            return .array(RFC_8259.Array(contexts.map(\.value)))

        case .definition(let definition):
            return definition.value
        }
    }

    public init(_ value: RFC_8259.Value) throws(W3C_JSON_LD.Error) {
        switch value {
        case .null:
            self = .null

        case .string(let iri):
            self = .iri(iri)

        case .array(let array):
            var contexts: [Self] = []
            for element in array {
                contexts.append(try Self(element))
            }
            self = .list(contexts)

        case .object(let object):
            self = .definition(try Definition(object))

        default:
            throw .keyword("@context")
        }
    }
}

extension W3C_JSON_LD.Context {

    static func tag(_ text: String) throws(W3C_JSON_LD.Error) -> RFC_5646.LanguageTag {
        do throws(RFC_5646.Error) {
            return try RFC_5646.LanguageTag(text)
        } catch {
            throw .keyword("@language")
        }
    }
}
