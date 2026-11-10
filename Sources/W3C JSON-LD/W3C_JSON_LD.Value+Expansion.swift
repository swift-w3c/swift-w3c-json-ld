extension W3C_JSON_LD.Value {

    func expanded(
        in active: W3C_JSON_LD.Context.Active,
        term: W3C_JSON_LD.Context.Term?,
        loader: W3C_JSON_LD.Context.Loader
    ) throws(W3C_JSON_LD.Error) -> Self {
        switch self {
        case .node(let node):
            return .node(try node.expanded(in: active, loader: loader))

        case .list(let values):
            var expanded: [Self] = []
            for value in values {
                expanded.append(try value.expanded(in: active, term: term, loader: loader))
            }
            return .list(expanded)

        case .literal(var literal):
            if literal.isPlain, let string = literal.string {
                switch term?.type {
                case "@id":
                    return .reference(active.expand(string, at: .document) ?? string)

                case "@vocab":
                    return .reference(active.expand(string, at: .vocabulary) ?? string)

                case .some(let type):
                    literal.type = type
                    return .literal(literal)

                case .none:
                    if let language = term?.language ?? active.language {
                        literal.language = language
                    }
                    return .literal(literal)
                }
            }
            if let type = literal.type {
                literal.type = active.expand(type, at: .vocabulary) ?? type
            }
            return .literal(literal)
        }
    }

    func compacted(to active: W3C_JSON_LD.Context.Active) -> Self {
        switch self {
        case .node(let node):
            return .node(node.compacted(to: active))

        case .list(let values):
            return .list(values.map { $0.compacted(to: active) })

        case .literal(var literal):
            if let type = literal.type {
                literal.type = active.compact(type, at: .vocabulary)
            }
            if literal.language != nil, literal.language == active.language {
                literal.language = nil
            }
            return .literal(literal)
        }
    }
}
