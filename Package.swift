// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StyleSource",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "StyleSource",
            targets: ["StyleSource"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.14.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Core",
            dependencies: ["PathKit", "Stencil", "Yams", "CryptoSwift"]),
        .target(
            name: "StyleSource",
            dependencies: ["Core"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "PathKit", "Stencil", "Yams"]),
    ]
)
