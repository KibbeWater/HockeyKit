// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HockeyKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HockeyKit",
            targets: ["HockeyKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hyperoslo/Cache.git", from: "7.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HockeyKit",
            dependencies: ["Cache"]),
        .testTarget(
            name: "HockeyKitTests",
            dependencies: ["HockeyKit"]),
    ],
    swiftLanguageModes: [.v6]
)
