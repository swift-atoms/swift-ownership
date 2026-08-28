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
            dependencies: []
        ),

        .target(
            name: "Ownership Borrow",
            dependencies: [
                .target(name: "Ownership"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Ownership Inout",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Unique",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Immutable",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Mutable",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Slot",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Latch",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Box",
            dependencies: [
                .target(name: "Ownership")
            ]
        ),
        .target(
            name: "Ownership Transfer",
            dependencies: [
                .target(name: "Ownership"),
                .target(name: "Ownership Latch"),
            ]
        ),
        .target(
            name: "Ownership Transfer Erased",
            dependencies: [
                .target(name: "Ownership Transfer"),
                .target(name: "Ownership Latch"),
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
                .target(name: "Ownership Borrow"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "Ownership Inout Tests",
            dependencies: [
                .target(name: "Ownership Inout"),
            ]
        ),
        .testTarget(
            name: "Ownership Unique Tests",
            dependencies: [
                .target(name: "Ownership Unique"),
            ]
        ),
        .testTarget(
            name: "Ownership Immutable Tests",
            dependencies: [
                .target(name: "Ownership Immutable"),
            ]
        ),
        .testTarget(
            name: "Ownership Mutable Tests",
            dependencies: [
                .target(name: "Ownership Mutable"),
            ]
        ),
        .testTarget(
            name: "Ownership Slot Tests",
            dependencies: [
                .target(name: "Ownership Slot"),
            ]
        ),
        .testTarget(
            name: "Ownership Latch Tests",
            dependencies: [
                .target(name: "Ownership Latch"),
            ]
        ),
        .testTarget(
            name: "Ownership Box Tests",
            dependencies: [
                .target(name: "Ownership Box"),
            ]
        ),
        .testTarget(
            name: "Ownership Transfer Tests",
            dependencies: [
                .target(name: "Ownership Transfer"),
            ]
        ),
        .testTarget(
            name: "Ownership Transfer Erased Tests",
            dependencies: [
                .target(name: "Ownership Transfer Erased"),
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
