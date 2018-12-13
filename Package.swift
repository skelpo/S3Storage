// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "S3Storage",
    products: [
        .library(name: "S3Storage", targets: ["S3Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-rc2"),
        .package(url: "https://github.com/skelpo/Storage.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "S3Storage", dependencies: ["Storage", "S3"]),
        .testTarget(name: "S3StorageTests", dependencies: ["S3Storage"]),
    ]
)