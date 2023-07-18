// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncHttpClient",
    platforms: [
        .macOS(.v12), .iOS(.v13)
    ],
    products: [
        .library(
            name: "AsyncHttpClient",
            targets: ["AsyncHttpClient"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AsyncHttpClient",
            dependencies: []),
        .testTarget(
            name: "AsyncHttpClientTests",
            dependencies: ["AsyncHttpClient"]),
    ]
)
