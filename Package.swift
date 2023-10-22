// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UkatonKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UkatonKit",
            targets: ["UkatonKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Finnvoor/StaticLogger.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UkatonKit",
            dependencies: ["StaticLogger"]),
        .testTarget(
            name: "UkatonKitTests",
            dependencies: ["UkatonKit"]),
    ])
