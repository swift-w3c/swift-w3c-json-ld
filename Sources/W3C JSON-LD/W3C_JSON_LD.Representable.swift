extension W3C_JSON_LD {

    public protocol Representable {

        static var context: W3C_JSON_LD.Context { get }

        var node: W3C_JSON_LD.Node { get }
    }
}
