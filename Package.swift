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
            name: "Ownership Primitive",
            targets: ["Ownership Primitive"]
        ),

        .library(
            name: "Ownership Borrow",
            targets: ["Ownership Borrow"]
        ),
        .library(
            name: "Ownership Inout",
            targets: ["Ownership Inout"]
        ),
        .library(
            name: "Ownership Unique",
            targets: ["Ownership Unique"]
        ),
        .library(
            name: "Ownership Immutable",
            targets: ["Ownership Immutable"]
        ),
        .library(
            name: "Ownership Mutable",
            targets: ["Ownership Mutable"]
        ),
        .library(
            name: "Ownership Slot",
            targets: ["Ownership Slot"]
        ),
        .library(
            name: "Ownership Latch",
            targets: ["Ownership Latch"]
        ),
        .library(
            name: "Ownership Box",
            targets: ["Ownership Box"]
        ),
        .library(
            name: "Ownership Transfer",
            targets: ["Ownership Transfer"]
        ),
        .library(
            name: "Ownership Transfer Erased",
            targets: ["Ownership Transfer Erased"]
        ),

        .library(
            name: "Ownership Standard Library Integration",
            targets: ["Ownership Standard Library Integration"]
        ),

        .library(
            name: "Ownership",
            targets: ["Ownership"]
        ),

        .library(
            name: "Ownership Test Support",
            targets: ["Ownership Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        )
    ],
    targets: [

        .target(
            name: "Ownership Primitive",
            dependencies: []
        ),

        .target(
            name: "Ownership Borrow",
            dependencies: [
                "Ownership Primitive",
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Ownership Inout",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Unique",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Immutable",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Mutable",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Slot",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Latch",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Box",
            dependencies: [
                "Ownership Primitive"
            ]
        ),
        .target(
            name: "Ownership Transfer",
            dependencies: [
                "Ownership Primitive",
                "Ownership Latch",
            ]
        ),
        .target(
            name: "Ownership Transfer Erased",
            dependencies: [
                "Ownership Transfer",
                "Ownership Latch",
            ]
        ),

        .target(
            name: "Ownership Standard Library Integration",
            dependencies: [
                "Ownership Primitive"
            ]
        ),

        .target(
            name: "Ownership",
            dependencies: [
                "Ownership Primitive",
                "Ownership Borrow",
                "Ownership Inout",
                "Ownership Unique",
                "Ownership Immutable",
                "Ownership Mutable",
                "Ownership Slot",
                "Ownership Latch",
                "Ownership Box",
                "Ownership Transfer",
                "Ownership Transfer Erased",
                "Ownership Standard Library Integration",
            ]
        ),

        .target(
            name: "Ownership Test Support",
            dependencies: [
                "Ownership",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Ownership Tests",
            dependencies: [
                "Ownership",
                "Ownership Test Support",
            ]
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
