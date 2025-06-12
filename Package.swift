// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Injection",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v2)
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
