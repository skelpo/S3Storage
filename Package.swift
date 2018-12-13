// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "S3Storage",
    products: [
        .library(name: "S3Storage", targets: ["S3Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skelpo/Storage.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "S3Storage", dependencies: ["Storage"]),
        .testTarget(name: "S3StorageTests", dependencies: ["S3Storage"]),
    ]
)