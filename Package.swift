// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HockeyKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
        // Linux is automatically supported without explicit declaration
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HockeyKit",
            targets: ["HockeyKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HockeyKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]),
        .testTarget(
            name: "HockeyKitTests",
            dependencies: ["HockeyKit"]),
    ],
    swiftLanguageModes: [.v6]
)
