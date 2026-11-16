// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "macdev",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "macdev", targets: ["macdev"])
    ],
    targets: [
        .target(name: "MacDevKit"),
        .executableTarget(name: "macdev", dependencies: ["MacDevKit"]),
        .testTarget(name: "MacDevKitTests", dependencies: ["MacDevKit"])
    ]
)
