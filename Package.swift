// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "EyezonSDK2",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "EyezonSDK2",
            targets: ["EyezonSDK2"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "EyezonSDK2",
            dependencies: [
                "SwiftyJSON",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "EyezonSDK2.0",
            exclude: [
                "Pods",
                "Podfile",
                "Podfile.lock",
                "EyezonSDK-2.0.podspec"
            ],  // Exclude 'Pods' directories and pod files
            sources: nil,
            resources: [.process("EyezonSDK2.0/Sources/Media.xcassets")]
        )
    ]
)
