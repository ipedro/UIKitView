// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "swift-uikitview",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
        .tvOS(.v14),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "UIKitView",
            targets: ["UIKitView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0")
    ],
    targets: [
        .target(
            name: "UIKitView",
            dependencies: []),
        .testTarget(
            name: "UIKitViewTests",
            dependencies: [
                "UIKitView",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
    ]
)
