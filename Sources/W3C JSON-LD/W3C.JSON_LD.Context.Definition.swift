public import W3C

extension W3C.JSON_LD.Context {

    public struct Definition: Sendable, Hashable {

        public var base: String?

        public var vocabulary: String?

        public var language: IETF.RFC.`5646`.LanguageTag?

        public var terms: [Term]

        public init(
            base: String? = nil,
            vocabulary: String? = nil,
            language: IETF.RFC.`5646`.LanguageTag? = nil,
            terms: [Term] = []
        ) {
            self.base = base
            self.vocabulary = vocabulary
            self.language = language
            self.terms = terms
        }
    }
}
