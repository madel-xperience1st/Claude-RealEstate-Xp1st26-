// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PropHub",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "PropHub", targets: ["PropHub"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    ],
    targets: [
        .target(
            name: "PropHub",
            dependencies: [
                "Kingfisher",
                "KeychainAccess",
            ],
            path: "PropHub",
            resources: [
                .process("Core/Config/AppConfig.plist"),
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PropHubTests",
            dependencies: ["PropHub"],
            path: "PropHubTests"
        ),
    ]
)
