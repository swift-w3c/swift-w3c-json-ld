extension W3C_JSON_LD {

    public enum Error: Swift.Error, Sendable, Equatable {

        case json(RFC_8259.Error)

        case document

        case keyword(String)

        case unsupported(String)

        case context(String)

        case recursion(String)
    }
}
