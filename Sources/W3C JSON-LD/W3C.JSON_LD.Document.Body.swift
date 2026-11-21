public import W3C

extension W3C.JSON_LD.Document {

    public enum Body: Sendable, Hashable {

        case node(W3C.JSON_LD.Node)

        case graph([W3C.JSON_LD.Node])
    }
}
