// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GradientEditor",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GradientEditor",
            targets: ["GradientEditor"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GradientEditor",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GradientEditorTests",
            dependencies: ["GradientEditor"]
        ),
    ]
)
