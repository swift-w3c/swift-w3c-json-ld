extension W3C_JSON_LD.Node {

    public func expanded(
        in active: W3C_JSON_LD.Context.Active = W3C_JSON_LD.Context.Active(),
        loader: W3C_JSON_LD.Context.Loader = .none
    ) throws(W3C_JSON_LD.Error) -> Self {
        var active = active
        if let context {
            active = try active.applying(context, loader: loader)
        }
        var result = Self()
        if let id {
            result.id = active.expand(id, at: .document) ?? id
        }
        result.types = types.compactMap { active.expand($0, at: .vocabulary) }
        for property in properties {
            guard let key = active.expand(property.key, at: .vocabulary) else { continue }
            let term = active.terms[property.key]
            switch key {
            case "@id":
                if result.id == nil, let value = property.values.first?.literal?.string {
                    result.id = active.expand(value, at: .document) ?? value
                }

            case "@type":
                for value in property.values {
                    if let value = value.literal?.string, let type = active.expand(value, at: .vocabulary) {
                        result.types.append(type)
                    }
                }

            default:
                guard !W3C_JSON_LD.isKeyword(key), key.contains(":") else { continue }
                var values: [W3C_JSON_LD.Value] = []
                for value in property.values {
                    values.append(try value.expanded(in: active, term: term, loader: loader))
                }
                if term?.container == "@list", !(values.count == 1 && values.first?.list != nil) {
                    values = [.list(values)]
                }
                result[key] += values
            }
        }
        return result
    }

    public func compacted(to active: W3C_JSON_LD.Context.Active) -> Self {
        var result = Self()
        result.id = id.map { active.compact($0, at: .document) }
        result.types = types.map { active.compact($0, at: .vocabulary) }
        for property in properties {
            let key = active.compact(property.key, at: .vocabulary)
            result[key] += property.values.map { $0.compacted(to: active) }
        }
        return result
    }
}
