extension W3C_JSON_LD {

    public struct Document: Sendable, Hashable {

        public var context: Context?

        public var body: Body

        public init(context: Context? = nil, body: Body) {
            self.context = context
            self.body = body
        }
    }
}

extension W3C_JSON_LD.Document {

    public init(_ node: W3C_JSON_LD.Node, context: W3C_JSON_LD.Context? = nil) {
        self.init(context: context, body: .node(node))
    }

    public init(graph nodes: [W3C_JSON_LD.Node], context: W3C_JSON_LD.Context? = nil) {
        self.init(context: context, body: .graph(nodes))
    }

    public init<Value: W3C_JSON_LD.Representable>(_ value: Value) {
        self.init(value.node, context: Value.context)
    }

    public init<each Value: W3C_JSON_LD.Representable>(graph values: repeat each Value) {
        var contexts: [W3C_JSON_LD.Context] = []
        var nodes: [W3C_JSON_LD.Node] = []
        for value in repeat each values {
            contexts.append(type(of: value).context)
            nodes.append(value.node)
        }
        if let first = contexts.first, contexts.allSatisfy({ $0 == first }) {
            self.init(graph: nodes, context: first)
        } else {
            for index in nodes.indices {
                nodes[index].context = contexts[index]
            }
            self.init(graph: nodes)
        }
    }
}

extension W3C_JSON_LD.Document {

    public var nodes: [W3C_JSON_LD.Node] {
        switch body {
        case .node(let node): [node]
        case .graph(let nodes): nodes
        }
    }

    public func expanded(loader: W3C_JSON_LD.Context.Loader = .none) throws(W3C_JSON_LD.Error) -> Self {
        var active = W3C_JSON_LD.Context.Active()
        if let context {
            active = try active.applying(context, loader: loader)
        }
        switch body {
        case .node(let node):
            return Self(try node.expanded(in: active, loader: loader))

        case .graph(let nodes):
            var expanded: [W3C_JSON_LD.Node] = []
            for node in nodes {
                expanded.append(try node.expanded(in: active, loader: loader))
            }
            return Self(graph: expanded)
        }
    }

    public func compacted(
        to context: W3C_JSON_LD.Context,
        loader: W3C_JSON_LD.Context.Loader = .none
    ) throws(W3C_JSON_LD.Error) -> Self {
        let expanded = try expanded(loader: loader)
        let active = try W3C_JSON_LD.Context.Active().applying(context, loader: loader)
        switch expanded.body {
        case .node(let node):
            return Self(node.compacted(to: active), context: context)

        case .graph(let nodes):
            return Self(graph: nodes.map { $0.compacted(to: active) }, context: context)
        }
    }
}
