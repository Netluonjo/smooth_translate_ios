// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmoothTranslate",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SmoothTranslate",
            targets: ["SmoothTranslate"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SmoothTranslate",
            dependencies: [],
            path: "SmoothTranslate",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
