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
        .library(
            name: "Ownership",
            targets: ["Ownership"]
        ),
        .library(
            name: "Ownership Standard Library Integration",
            targets: ["Ownership Standard Library Integration"]
        ),
        .library(
            name: "Ownership Apple Foundation Integration",
            targets: ["Ownership Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Ownership",
            dependencies: []
        ),
        .target(
            name: "Ownership Standard Library Integration",
            dependencies: ["Ownership"]
        ),
        .target(
            name: "Ownership Apple Foundation Integration",
            dependencies: [
                "Ownership",
                "Ownership Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Ownership Tests",
            dependencies: ["Ownership"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
