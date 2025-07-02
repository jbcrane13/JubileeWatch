// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "JubileeWatch",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "JubileeWatch",
            targets: ["JubileeWatch"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/danielgindi/Charts", from: "5.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "JubileeWatch",
            dependencies: [
                "Alamofire",
                "Charts",
                "Starscream"
            ]
        ),
        .testTarget(
            name: "JubileeWatchTests",
            dependencies: ["JubileeWatch"]
        ),
    ]
)