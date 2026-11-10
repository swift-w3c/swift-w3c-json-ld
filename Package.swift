// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-w3c-json-ld",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "W3C JSON-LD", targets: ["W3C JSON-LD"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-8259.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5646.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "W3C JSON-LD",
            dependencies: [
                .product(name: "RFC 8259", package: "swift-rfc-8259"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 5646", package: "swift-rfc-5646"),
            ]
        ),
        .testTarget(
            name: "W3C JSON-LD Tests",
            dependencies: [
                .target(name: "W3C JSON-LD")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
