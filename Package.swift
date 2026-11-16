// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MapplsMap",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MapplsMap",
            targets: ["MapplsMap"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "MapplsMap",
            url: "https://mmi-api-team.s3.amazonaws.com/mappls-sdk-ios/mappls-map/MapplsMap.xcframework-7.0.1.zip",
            checksum: "45bc002a5d90746f7a83208d6a4740ab5d347d98c8619fbaae09a576b54589d4"
        )
    ]
)
