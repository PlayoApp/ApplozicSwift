// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ApplozicSwift",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "ApplozicSwift",
            targets: ["ApplozicSwift"]
        ),
        .library(
            name: "RichMessageKit",
            targets: ["RichMessageKit"]
        ),
    ],
    dependencies: [
        .package(name: "Applozic", url: "https://github.com/AppLozic/Applozic-Chat-iOS-Framework.git", .exact("8.1.0")),
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", "5.14.0" ..< "5.15.0"),
        .package(name: "SwipeCellKit", url: "https://github.com/SwipeCellKit/SwipeCellKit.git", from: "2.7.1"),
    ],
    targets: [
        .target(name: "ApplozicSwift",
                dependencies: ["RichMessageKit",
                               .product(name: "ApplozicCore", package: "Applozic"),
                               "Kingfisher",
                               "SwipeCellKit"],
                path: "Sources",
                exclude: ["Extras"],
                linkerSettings: [
                    .linkedFramework("Foundation"),
                    .linkedFramework("SystemConfiguration"),
                    .linkedFramework("UIKit", .when(platforms: [.iOS])),
                ]),
        .target(name: "RichMessageKit",
                dependencies: [],
                path: "RichMessageKit",
                linkerSettings: [
                    .linkedFramework("Foundation"),
                    .linkedFramework("UIKit", .when(platforms: [.iOS])),
                ]),
    ]
)
