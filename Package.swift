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
            url: "https://mmi-api-team.s3.amazonaws.com/mappls-sdk-ios/mappls-map/MapplsMap.xcframework-7.0.0.zip",
            checksum: "a602d4ef50aec7a9843ad9c0973b46715d5f704f2e1015bc36c4f337a5a55f21"
        )
    ]
)
