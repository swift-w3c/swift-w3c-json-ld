public import W3C

extension W3C.JSON_LD {

    public struct Literal: Sendable, Hashable {

        public var scalar: Scalar

        public var type: String?

        public var language: IETF.RFC.`5646`.LanguageTag?

        public var direction: Direction?

        public init(
            _ scalar: Scalar,
            type: String? = nil,
            language: IETF.RFC.`5646`.LanguageTag? = nil,
            direction: Direction? = nil
        ) {
            self.scalar = scalar
            self.type = type
            self.language = language
            self.direction = direction
        }
    }
}

extension W3C.JSON_LD.Literal {

    public var isPlain: Bool {
        type == nil && language == nil && direction == nil
    }

    public var string: String? {
        guard case .string(let value) = scalar else { return nil }
        return value
    }

    public var number: IETF.RFC.`8259`.Number? {
        guard case .number(let value) = scalar else { return nil }
        return value
    }

    public var bool: Bool? {
        guard case .bool(let value) = scalar else { return nil }
        return value
    }
}
