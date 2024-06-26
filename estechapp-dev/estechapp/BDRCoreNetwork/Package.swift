// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BDRCoreNetwork",
    platforms: [
      .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BDRCoreNetwork",
            targets: ["BDRCoreNetwork"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.4.0")),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .exact("4.2.0")),
        .package(path: "../BDRModel")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BDRCoreNetwork",
            dependencies: ["Alamofire","AlamofireImage","BDRModel"]),
        .testTarget(
            name: "BDRCoreNetworkTests",
            dependencies: ["BDRCoreNetwork"]),
    ]
)
