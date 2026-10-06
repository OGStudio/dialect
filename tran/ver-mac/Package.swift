// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DialectTran",
    platforms: [.macOS(.v13)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "tran",
            path: "src"
        )
    ]
)
