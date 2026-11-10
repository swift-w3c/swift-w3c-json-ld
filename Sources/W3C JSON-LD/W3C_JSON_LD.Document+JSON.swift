extension W3C_JSON_LD.Document {

    public var bytes: [UInt8] {
        RFC_8259.Encode.encode(value)
    }

    public var value: RFC_8259.Value {
        switch body {
        case .node(let node):
            var node = node
            switch (context, node.context) {
            case (.some(let outer), .some(let inner)):
                node.context = .list([outer, inner])

            case (.some(let outer), .none):
                node.context = outer

            case (.none, _):
                break
            }
            return node.value

        case .graph(let nodes):
            var members: [(key: String, value: RFC_8259.Value)] = []
            if let context {
                members.append((key: "@context", value: context.value))
            }
            members.append((key: "@graph", value: .array(RFC_8259.Array(nodes.map(\.value)))))
            return .object(RFC_8259.Object(members))
        }
    }
}

extension W3C_JSON_LD.Document {

    public init<Bytes: Swift.Collection<UInt8>>(parsing bytes: Bytes) throws(W3C_JSON_LD.Error) {
        let value: RFC_8259.Value
        do throws(RFC_8259.Error) {
            value = try RFC_8259.Decode.parse(bytes.map { Byte(bitPattern: $0) })
        } catch {
            throw .json(error)
        }
        try self.init(value)
    }

    public init(_ value: RFC_8259.Value) throws(W3C_JSON_LD.Error) {
        switch value {
        case .object(let object):
            let keys = Set(object.keys)
            if keys.contains("@graph") {
                guard keys.isSubset(of: ["@context", "@graph"]) else {
                    throw .unsupported("@graph")
                }
                let context = try object["@context"].map(W3C_JSON_LD.Context.init)
                let nodes = try W3C_JSON_LD.Node.nodes(object["@graph"] ?? .null)
                self.init(graph: nodes, context: context)
            } else {
                var node = try W3C_JSON_LD.Node(object)
                let context = node.context
                node.context = nil
                self.init(node, context: context)
            }

        case .array(let array):
            var nodes: [W3C_JSON_LD.Node] = []
            for element in array {
                nodes += try W3C_JSON_LD.Node.nodes(element)
            }
            self.init(graph: nodes)

        default:
            throw .document
        }
    }
}
