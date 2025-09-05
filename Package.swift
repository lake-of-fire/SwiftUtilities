// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUtilities",
    platforms: [.macOS(.v13), .iOS(.v15)],
    products: [
        .library(
            name: "SwiftUtilities",
            targets: ["SwiftUtilities"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftUtilities",
            dependencies: []),
        .testTarget(
            name: "SwiftUtilitiesTests",
            dependencies: ["SwiftUtilities"]),
    ]
)
