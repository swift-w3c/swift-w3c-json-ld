extension W3C_JSON_LD.Context {

    public struct Definition: Sendable, Hashable {

        public var base: String?

        public var vocabulary: String?

        public var language: RFC_5646.LanguageTag?

        public var terms: [Term]

        public init(
            base: String? = nil,
            vocabulary: String? = nil,
            language: RFC_5646.LanguageTag? = nil,
            terms: [Term] = []
        ) {
            self.base = base
            self.vocabulary = vocabulary
            self.language = language
            self.terms = terms
        }
    }
}
