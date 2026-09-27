// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HelloWorld",
    platforms: [
        .iOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "HelloWorld",
            path: "src",
            exclude: ["Info.plist"]
        )
    ]
)