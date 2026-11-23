public import W3C

extension W3C.JSON_LD.Context {

    public var value: IETF.RFC.`8259`.Value {
        switch self {
        case .null:
            return .null

        case .iri(let iri):
            return .string(iri)

        case .list(let contexts):
            return .array(IETF.RFC.`8259`.Array(contexts.map(\.value)))

        case .definition(let definition):
            return definition.value
        }
    }

    public init(_ value: IETF.RFC.`8259`.Value) throws(W3C.JSON_LD.Error) {
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

extension W3C.JSON_LD.Context {

    static func tag(_ text: String) throws(W3C.JSON_LD.Error) -> IETF.RFC.`5646`.Tag {
        do throws(IETF.RFC.`5646`.Error) {
            return try IETF.RFC.`5646`.Tag(text)
        } catch {
            throw .keyword("@language")
        }
    }
}
