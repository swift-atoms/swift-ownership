// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-ownership",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Ownership", targets: ["Ownership"]),
        .library(name: "Ownership Standard Library Integration", targets: ["Ownership Standard Library Integration"]),
        .library(name: "Ownership Foundation Library Integration", targets: ["Ownership Foundation Library Integration"]),
        .library(name: "Ownership Test Support", targets: ["Ownership Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "Ownership",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Sources/Ownership"
        ),
        .target(
            name: "Ownership Standard Library Integration",
            dependencies: [
                .target(name: "Ownership"),
            ],
            path: "Sources/Ownership Standard Library Integration"
        ),
        .target(
            name: "Ownership Foundation Library Integration",
            dependencies: [
                .target(name: "Ownership"),
                .target(name: "Ownership Standard Library Integration"),
            ],
            path: "Sources/Ownership Foundation Library Integration"
        ),
        .target(
            name: "Ownership Test Support",
            dependencies: [
                .target(name: "Ownership"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Ownership Tests",
            dependencies: [
                .target(name: "Ownership"),
                .product(name: "Tagged", package: "swift-tagged"),
                .target(name: "Ownership Test Support"),
                .target(name: "Ownership Standard Library Integration"),
                .target(name: "Ownership Foundation Library Integration"),
            ],
            path: "Tests/Ownership Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
