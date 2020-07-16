// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebMIDIKit",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v9),
        .macOS(SupportedPlatform.MacOSVersion.v10_11)
    ],
    products: [
        .library(
            name: "WebMIDIKit",
            targets: ["WebMIDIKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "WebMIDIKit",
            dependencies: []),
        .testTarget(
            name: "WebMIDIKitTests",
            dependencies: []),
    ]
)
