// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "EssentialFeediOS",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "EssentialFeediOS",
            targets: ["EssentialFeediOS"]),
    ],
    dependencies: [
        .package(path: "../EssentialFeed")
    ],
    targets: [
        .target(
            name: "EssentialFeediOS",
            dependencies: ["EssentialFeed"]),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: ["EssentialFeediOS"]),
    ]
)
