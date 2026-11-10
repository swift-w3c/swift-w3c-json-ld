extension W3C_JSON_LD {

    public struct Node: Sendable, Hashable {

        public var context: Context?

        public var id: String?

        public var types: [String]

        public var properties: [Property]

        public init(
            id: String? = nil,
            types: [String] = [],
            properties: [Property] = [],
            context: Context? = nil
        ) {
            self.context = context
            self.id = id
            self.types = types
            self.properties = properties
        }
    }
}

extension W3C_JSON_LD.Node {

    public subscript(key: String) -> [W3C_JSON_LD.Value] {
        get {
            properties.first { $0.key == key }?.values ?? []
        }
        set {
            if let index = properties.firstIndex(where: { $0.key == key }) {
                if newValue.isEmpty {
                    properties.remove(at: index)
                } else {
                    properties[index].values = newValue
                }
            } else if !newValue.isEmpty {
                properties.append(Property(key, newValue))
            }
        }
    }
}
