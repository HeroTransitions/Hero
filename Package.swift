// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
