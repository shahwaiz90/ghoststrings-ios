// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GhostStrings",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "GhostStrings",
            targets: ["GhostStrings"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GhostStrings",
            dependencies: []),
        .testTarget(
            name: "GhostStringsTests",
            dependencies: ["GhostStrings"]),
    ]
)
