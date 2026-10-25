// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ImageLoading",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ImageLoading", targets: ["ImageLoading"]),
    ],
    dependencies: [
        .package(path: "../Networking"),
    ],
    targets: [
        .target(name: "ImageLoading", dependencies: ["Networking"]),
    ]
)
