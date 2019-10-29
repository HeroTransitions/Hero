// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hero",
    platforms: [
        .tvOS(.v9),
        .iOS(.v9)
    ],
    products: [
        .library(name: "Hero",
                 type: .dynamic,
                 targets: ["Hero"]),
    ],
    targets: [
        .target(name: "Hero", path: "Sources"),
        .testTarget(name: "HeroTests",
                    dependencies: [.target(name: "Hero")],
                    path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
