// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YamlParser",
    platforms: [.macOS(.v13)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "generator",
            path: "src"
        )
    ]
)
