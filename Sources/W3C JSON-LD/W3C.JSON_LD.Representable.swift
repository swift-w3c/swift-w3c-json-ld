public import W3C

extension W3C.JSON_LD {

    public protocol Representable {

        static var context: W3C.JSON_LD.Context { get }

        var node: W3C.JSON_LD.Node { get }
    }
}
