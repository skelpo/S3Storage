// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "S3Storage",
    products: [
        .library(name: "S3Storage", targets: ["S3Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LiveUI/S3.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/skelpo/Storage.git", from: "1.0.0-alpha")
    ],
    targets: [
        .target(name: "S3Storage", dependencies: ["Storage", "S3"]),
        .testTarget(name: "S3StorageTests", dependencies: ["S3Storage"]),
    ]
)
