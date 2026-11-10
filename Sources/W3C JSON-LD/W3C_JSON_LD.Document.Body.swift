extension W3C_JSON_LD.Document {

    public enum Body: Sendable, Hashable {

        case node(W3C_JSON_LD.Node)

        case graph([W3C_JSON_LD.Node])
    }
}
