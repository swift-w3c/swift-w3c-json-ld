extension W3C_JSON_LD.Context {

    public struct Loader: Sendable {

        public let load: @Sendable (String) -> W3C_JSON_LD.Context?

        public init(_ load: @escaping @Sendable (String) -> W3C_JSON_LD.Context?) {
            self.load = load
        }
    }
}

extension W3C_JSON_LD.Context.Loader {

    public static let none = Self { _ in nil }

    public static func merging(_ loaders: [Self]) -> Self {
        Self { iri in
            for loader in loaders {
                if let context = loader.load(iri) { return context }
            }
            return nil
        }
    }
}
