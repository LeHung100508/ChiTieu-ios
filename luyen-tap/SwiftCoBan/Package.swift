// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCoBan",
    platforms: [
        .macOS(.v14),
        .iOS("26.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftCoBan",
            targets: ["SwiftCoBan"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftCoBan",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .swiftLanguageMode(.v6)
            ],
        ),
        .testTarget(
            name: "SwiftCoBanTests",
            dependencies: ["SwiftCoBan"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .swiftLanguageMode(.v6)
            ],
        ),
    ]
)
