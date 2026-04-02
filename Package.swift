// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MapplsMap",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MapplsMap",
            targets: ["MapplsMapWrapper"])
    ],
    dependencies: [
        .package(url: "https://github.com/mappls-api/mappls-api-core-ios-distribution.git", from: "2.1.2"),
        .package(url: "https://github.com/mappls-api/mappls-api-kit-ios-distribution.git", from: "3.0.4")
    ],
    targets: [
        .binaryTarget(
            name: "MapplsMap",
            url: "https://mmi-api-team.s3.amazonaws.com/mappls-sdk-ios/mappls-map/MapplsMap.xcframework-6.1.4.zip",
            checksum: "239f826001581e141eb44fc6bc572b3a39a0c9562cb12ac6936da69ac6c8391b"
        ),
        .target(
            name: "MapplsMapWrapper",
            dependencies: [
                "MapplsMap",
                .product(name: "MapplsAPICore", package: "mappls-api-core-ios-distribution"),
                .product(name: "MapplsAPIKit", package: "mappls-api-kit-ios-distribution")
            ]
        ),
    ]
)
