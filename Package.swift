// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "S3Storage",
    products: [
        .library(name: "S3Storage", targets: ["S3Storage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "S3Storage", dependencies: []),
        .testTarget(name: "S3StorageTests", dependencies: ["S3Storage"]),
    ]
)