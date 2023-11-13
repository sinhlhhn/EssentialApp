// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "EssentialFeed",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "EssentialFeed",
            targets: ["EssentialFeed"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "EssentialFeed",
            dependencies: []),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed"]),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed"]),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed"]),
    ]
)
