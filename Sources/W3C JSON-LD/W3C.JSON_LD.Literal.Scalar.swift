public import W3C

extension W3C.JSON_LD.Literal {

    public enum Scalar: Sendable, Hashable {

        case string(String)

        case number(RFC_8259.Number)

        case bool(Bool)
    }
}
