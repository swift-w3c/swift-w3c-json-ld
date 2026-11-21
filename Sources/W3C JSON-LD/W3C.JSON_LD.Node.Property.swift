public import W3C

extension W3C.JSON_LD.Node {

    public struct Property: Sendable, Hashable {

        public var key: String

        public var values: [W3C.JSON_LD.Value]

        public init(_ key: String, _ values: [W3C.JSON_LD.Value]) {
            self.key = key
            self.values = values
        }
    }
}
