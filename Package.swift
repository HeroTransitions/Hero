// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let ciDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/danger/swift.git", from: "1.0.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.35.8"),
    .package(url: "https://github.com/Realm/SwiftLint", from: "0.28.1"),
    .package(url: "https://github.com/orta/Komondor", from: "1.0.0")]

let dependencies = ciDependencies

let package = Package(
    name: "Hero",
    platforms: [
        .tvOS(.v10),
        .iOS(.v10)
    ],
    products: [
        .library(name: "Hero",
                 type: .dynamic,
                 targets: ["Hero"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(name: "Hero", path: "Sources"),
        .testTarget(name: "HeroTests",
                    dependencies: [.target(name: "Hero")],
                    path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)

// The settings for the git hooks for our repo
#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfig([
        "komondor": [
            // When someone has run `git commit`, first run
            // SwiftFormat and the auto-correcter for SwiftLint
            "pre-commit": [
                "swift run swiftformat .",
                "swift run swiftlint autocorrect",
                "git add .",
            ],
        ]
    ])
#endif
