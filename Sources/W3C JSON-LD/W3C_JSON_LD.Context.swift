extension W3C_JSON_LD {

    public indirect enum Context: Sendable, Hashable {

        case null

        case iri(String)

        case definition(Definition)

        case list([Context])
    }
}

extension W3C_JSON_LD.Context {

    public static func vocabulary(_ iri: String) -> Self {
        .definition(Definition(vocabulary: iri))
    }
}
