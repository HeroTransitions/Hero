// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hero",
    products: [
        .library(name: "Hero",  targets: ["Hero"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Hero", path: "Sources")
    ]
)
