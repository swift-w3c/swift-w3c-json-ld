extension W3C_JSON_LD.Context {

    public struct Term: Sendable, Hashable {

        public var name: String

        public var id: String?

        public var type: String?

        public var container: String?

        public var language: RFC_5646.LanguageTag?

        public var prefix: Bool?

        public init(
            _ name: String,
            id: String?,
            type: String? = nil,
            container: String? = nil,
            language: RFC_5646.LanguageTag? = nil,
            prefix: Bool? = nil
        ) {
            self.name = name
            self.id = id
            self.type = type
            self.container = container
            self.language = language
            self.prefix = prefix
        }
    }
}

extension W3C_JSON_LD.Context.Term {

    public var isSimple: Bool {
        id != nil && type == nil && container == nil && language == nil && prefix == nil
    }

    public var isPrefix: Bool {
        if let prefix { return prefix && id != nil }
        guard isSimple, let last = id?.last else { return false }
        return W3C_JSON_LD.Context.Term.delimiters.contains(last)
    }

    static let delimiters: Set<Character> = [":", "/", "?", "#", "[", "]", "@"]
}
