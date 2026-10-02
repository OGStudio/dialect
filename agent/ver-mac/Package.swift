// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DialectAgent",
    platforms: [.macOS(.v13)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "agent",
            path: "src"
        )
    ]
)
