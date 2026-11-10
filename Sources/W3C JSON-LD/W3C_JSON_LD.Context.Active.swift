import RFC_3986

extension W3C_JSON_LD.Context {

    public struct Active: Sendable, Hashable {

        public var base: String?

        public var vocabulary: String?

        public var language: RFC_5646.LanguageTag?

        public var terms: [String: Term]

        public init(base: String? = nil) {
            self.base = base
            self.vocabulary = nil
            self.language = nil
            self.terms = [:]
        }
    }
}

extension W3C_JSON_LD.Context.Active {

    static let limit = 32

    public func applying(
        _ context: W3C_JSON_LD.Context,
        loader: W3C_JSON_LD.Context.Loader = .none
    ) throws(W3C_JSON_LD.Error) -> Self {
        var visited: [String] = []
        return try applying(context, loader: loader, visited: &visited)
    }

    func applying(
        _ context: W3C_JSON_LD.Context,
        loader: W3C_JSON_LD.Context.Loader,
        visited: inout [String]
    ) throws(W3C_JSON_LD.Error) -> Self {
        switch context {
        case .null:
            return Self(base: base)

        case .list(let contexts):
            var result = self
            for context in contexts {
                result = try result.applying(context, loader: loader, visited: &visited)
            }
            return result

        case .iri(let iri):
            guard !visited.contains(iri), visited.count < Self.limit else {
                throw .recursion(iri)
            }
            guard let loaded = loader.load(iri) else {
                throw .context(iri)
            }
            visited.append(iri)
            defer { visited.removeLast() }
            return try applying(loaded, loader: loader, visited: &visited)

        case .definition(let definition):
            return try applying(definition)
        }
    }

    func applying(_ definition: W3C_JSON_LD.Context.Definition) throws(W3C_JSON_LD.Error) -> Self {
        var result = self
        if let base = definition.base {
            result.base = resolve(base)
        }
        if let vocabulary = definition.vocabulary {
            result.vocabulary = result.expand(vocabulary, at: .vocabulary) ?? vocabulary
        }
        if let language = definition.language {
            result.language = language
        }
        var local: [String: W3C_JSON_LD.Context.Term] = [:]
        for term in definition.terms {
            local[term.name] = term
        }
        var defined: Set<String> = []
        for term in definition.terms {
            var defining: Set<String> = []
            try result.define(term.name, local: local, defined: &defined, defining: &defining)
        }
        return result
    }

    mutating func define(
        _ name: String,
        local: [String: W3C_JSON_LD.Context.Term],
        defined: inout Set<String>,
        defining: inout Set<String>
    ) throws(W3C_JSON_LD.Error) {
        guard !defined.contains(name), let term = local[name] else { return }
        guard !defining.contains(name) else { throw .recursion(name) }
        defining.insert(name)
        var resolved = term
        let isNull = term.id == nil && term.type == nil && term.container == nil && term.language == nil
        if !isNull {
            let source = term.id ?? name
            if W3C_JSON_LD.isKeyword(source) {
                resolved.id = source
            } else if let colon = source.firstIndex(of: ":") {
                let prefix = String(source[..<colon])
                let suffix = source[source.index(after: colon)...]
                if prefix != name, local[prefix] != nil {
                    try define(prefix, local: local, defined: &defined, defining: &defining)
                }
                if prefix != "_", !suffix.hasPrefix("//"), let iri = terms[prefix]?.id {
                    resolved.id = iri + suffix
                } else {
                    resolved.id = source
                }
            } else if source != name, local[source] != nil {
                try define(source, local: local, defined: &defined, defining: &defining)
                resolved.id = terms[source]?.id
            } else if let vocabulary {
                resolved.id = vocabulary + source
            } else {
                resolved.id = source
            }
            if let type = term.type, !W3C_JSON_LD.isKeyword(type) {
                resolved.type = expand(type, at: .vocabulary) ?? type
            }
        }
        terms[name] = resolved
        defined.insert(name)
        defining.remove(name)
    }
}

extension W3C_JSON_LD.Context.Active {

    public func expand(_ value: String, at position: W3C_JSON_LD.Context.Position) -> String? {
        let isVocabulary = position == .vocabulary
        if W3C_JSON_LD.isKeyword(value) { return value }
        if W3C_JSON_LD.looksLikeKeyword(value) { return nil }
        if isVocabulary, let term = terms[value] {
            return term.id
        }
        if let colon = value.firstIndex(of: ":") {
            let prefix = String(value[..<colon])
            let suffix = value[value.index(after: colon)...]
            if prefix == "_" || suffix.hasPrefix("//") { return value }
            if let term = terms[prefix], term.isPrefix, let iri = term.id {
                return iri + suffix
            }
            if W3C_JSON_LD.isAbsolute(value) { return value }
        }
        if isVocabulary, let vocabulary {
            return vocabulary + value
        }
        if !isVocabulary {
            return resolve(value)
        }
        return value
    }

    func resolve(_ value: String) -> String {
        guard !W3C_JSON_LD.isAbsolute(value), let base else { return value }
        do throws(RFC_3986.Error) {
            return try RFC_3986.URI(base).resolve(value).value
        } catch {
            return value
        }
    }
}

extension W3C_JSON_LD.Context.Active {

    public func compact(_ iri: String, at position: W3C_JSON_LD.Context.Position) -> String {
        let isVocabulary = position == .vocabulary
        if isVocabulary {
            let matches = terms.filter { $0.value.id == iri }.map(\.key)
            if let best = matches.min(by: Self.shorter) {
                return best
            }
            if W3C_JSON_LD.isKeyword(iri) { return iri }
            if let vocabulary, iri.hasPrefix(vocabulary), iri.count > vocabulary.count {
                let suffix = String(iri.dropFirst(vocabulary.count))
                if terms[suffix] == nil { return suffix }
            }
        }
        if W3C_JSON_LD.isKeyword(iri) { return iri }
        var candidates: [String] = []
        for (name, term) in terms where term.isPrefix {
            guard let id = term.id, iri.hasPrefix(id), iri.count > id.count else { continue }
            let candidate = name + ":" + iri.dropFirst(id.count)
            if let existing = terms[candidate], existing.id != iri { continue }
            candidates.append(candidate)
        }
        if let best = candidates.min(by: Self.shorter) {
            return best
        }
        return iri
    }

    static func shorter(_ lhs: String, _ rhs: String) -> Bool {
        lhs.count != rhs.count ? lhs.count < rhs.count : lhs < rhs
    }
}
