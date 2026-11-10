extension W3C_JSON_LD {

    public static let keywords: Set<String> = [
        "@base", "@container", "@context", "@direction", "@graph", "@id", "@import", "@included",
        "@index", "@json", "@language", "@list", "@nest", "@none", "@prefix", "@propagate",
        "@protected", "@reverse", "@set", "@type", "@value", "@version", "@vocab",
    ]

    static func isKeyword(_ value: String) -> Bool {
        keywords.contains(value)
    }

    static func looksLikeKeyword(_ value: String) -> Bool {
        guard value.first == "@", value.count > 1 else { return false }
        return value.dropFirst().allSatisfy { $0.isASCII && $0.isLetter }
    }

    static func isAbsolute(_ value: String) -> Bool {
        guard let colon = value.firstIndex(of: ":"), colon != value.startIndex else { return false }
        let scheme = value[..<colon]
        guard let first = scheme.first, first.isASCII, first.isLetter else { return false }
        return scheme.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "+" || $0 == "-" || $0 == ".") }
    }
}
