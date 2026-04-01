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
            url: "https://mmi-api-team.s3.amazonaws.com/mappls-sdk-ios/mappls-map/MapplsMap.xcframework-6.1.3.zip",
            checksum: "f93ad4b46e2e46cac2f8c397409802fb2b9dd513ea1f25915db0c138b2705142"
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
