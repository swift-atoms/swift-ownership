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
            ]
        ),
        .testTarget(
            name: "Ownership Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Borrow Tests",
            dependencies: [
                .target(name: "Ownership"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "Ownership Inout Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Unique Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Immutable Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Mutable Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Slot Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Latch Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Box Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Transfer Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .testTarget(
            name: "Ownership Transfer Erased Tests",
            dependencies: [
                .target(name: "Ownership"),
            ]
        ),
        .target(
            name: "Ownership Test Support",
            dependencies: [
                .target(name: "Ownership"),
            ],
            path: "Tests/Support"
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
