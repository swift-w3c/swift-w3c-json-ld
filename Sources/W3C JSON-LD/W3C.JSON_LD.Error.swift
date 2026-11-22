public import W3C

extension W3C.JSON_LD {

    public enum Error: Swift.Error, Sendable, Equatable {

        case json(IETF.RFC.`8259`.Error)

        case document

        case keyword(String)

        case unsupported(String)

        case context(String)

        case recursion(String)
    }
}
