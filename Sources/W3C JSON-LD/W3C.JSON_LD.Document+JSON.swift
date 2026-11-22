public import W3C

extension W3C.JSON_LD.Document {

    public var bytes: [UInt8] {
        IETF.RFC.`8259`.Encode.encode(value)
    }

    public var value: IETF.RFC.`8259`.Value {
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
            var members: [(key: String, value: IETF.RFC.`8259`.Value)] = []
            if let context {
                members.append((key: "@context", value: context.value))
            }
            members.append((key: "@graph", value: .array(IETF.RFC.`8259`.Array(nodes.map(\.value)))))
            return .object(IETF.RFC.`8259`.Object(members))
        }
    }
}

extension W3C.JSON_LD.Document {

    public init<Bytes: Swift.Collection<UInt8>>(parsing bytes: Bytes) throws(W3C.JSON_LD.Error) {
        let value: IETF.RFC.`8259`.Value
        do throws(IETF.RFC.`8259`.Error) {
            value = try IETF.RFC.`8259`.Decode.parse(bytes.map { Byte(bitPattern: $0) })
        } catch {
            throw .json(error)
        }
        try self.init(value)
    }

    public init(_ value: IETF.RFC.`8259`.Value) throws(W3C.JSON_LD.Error) {
        switch value {
        case .object(let object):
            let keys = Set(object.keys)
            if keys.contains("@graph") {
                guard keys.isSubset(of: ["@context", "@graph"]) else {
                    throw .unsupported("@graph")
                }
                let context = try object["@context"].map(W3C.JSON_LD.Context.init)
                let nodes = try W3C.JSON_LD.Node.nodes(object["@graph"] ?? .null)
                self.init(graph: nodes, context: context)
            } else {
                var node = try W3C.JSON_LD.Node(object)
                let context = node.context
                node.context = nil
                self.init(node, context: context)
            }

        case .array(let array):
            var nodes: [W3C.JSON_LD.Node] = []
            for element in array {
                nodes += try W3C.JSON_LD.Node.nodes(element)
            }
            self.init(graph: nodes)

        default:
            throw .document
        }
    }
}
