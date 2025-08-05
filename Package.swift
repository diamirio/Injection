// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Injection",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Injection",
            targets: ["Injection"]
        ),
    ],
    targets: [
        .target(
            name: "Injection"),
        .testTarget(
            name: "InjectionTests",
            dependencies: ["Injection"]
        ),
    ]
)
