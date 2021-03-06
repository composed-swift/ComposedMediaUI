// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ComposedMediaUI",
    platforms: [
        .iOS(.v11)

    ],
    products: [
        .library(
            name: "ComposedMediaUI",
            targets: ["ComposedMediaUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/composed-swift/ComposedMedia", from: "0.0.0"),
        .package(url: "https://github.com/composed-swift/ComposedUI", from: "1.0.0"),
        .package(url: "https://github.com/composed-swift/ComposedLayouts", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ComposedMediaUI",
            dependencies: ["ComposedMedia", "ComposedUI", "ComposedLayouts"]),
    ]
)
