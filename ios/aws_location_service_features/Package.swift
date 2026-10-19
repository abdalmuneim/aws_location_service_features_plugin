// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws_location_service_features",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "aws-location-service-features", targets: ["aws_location_service_features"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Amazon Location Mobile SDKs for iOS (Swift Package Manager only).
        .package(url: "https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios", from: "1.2.0"),
        .package(url: "https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios", from: "1.1.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.6.37"),
    ],
    targets: [
        .target(
            name: "aws_location_service_features",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AmazonLocationiOSAuthSDK", package: "amazon-location-mobile-auth-sdk-ios"),
                .product(name: "AmazonLocationiOSTrackingSDK", package: "amazon-location-mobile-tracking-sdk-ios"),
                .product(name: "AWSLocation", package: "aws-sdk-swift"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
