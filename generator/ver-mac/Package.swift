// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YamlParser",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "generator",
            dependencies: ["Yams"],
            path: "src"
        )
    ]
)
