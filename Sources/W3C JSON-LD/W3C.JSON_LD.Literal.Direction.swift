public import W3C

extension W3C.JSON_LD.Literal {

    public enum Direction: Sendable, Hashable {

        case ltr

        case rtl
    }
}

extension W3C.JSON_LD.Literal.Direction {

    public init?(_ text: String) {
        switch text {
        case "ltr":
            self = .ltr

        case "rtl":
            self = .rtl

        default:
            return nil
        }
    }

    public var text: String {
        switch self {
        case .ltr:
            "ltr"

        case .rtl:
            "rtl"
        }
    }
}
