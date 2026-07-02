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
        .package(url: "https://github.com/mappls-api/mappls-api-core-ios-distribution.git", from: "2.1.3"),
        .package(url: "https://github.com/mappls-api/mappls-api-kit-ios-distribution.git", from: "3.0.6")
    ],
    targets: [
        .binaryTarget(
            name: "MapplsMap",
            url: "https://mmi-api-team.s3.amazonaws.com/mappls-sdk-ios/mappls-map/MapplsMap.xcframework-6.1.5.zip",
            checksum: "fbc4e5edd02330482ea34ffb27c045347846f5b28ff8b648e1d46df9732b8646"
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
