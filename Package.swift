// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxPrivacyManager",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "RxPrivacyManager", targets: ["RxPrivacyManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "RxPrivacyManager", dependencies: ["RxSwift", "RxCocoa"], path: "PrivacyManager")
    ],
    swiftLanguageVersions: [.v5]
)
