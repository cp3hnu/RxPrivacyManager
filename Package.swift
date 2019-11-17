// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxPrivacyManager",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "PrivacyManager", targets: ["PrivacyManager"]),
        .library(name: "PrivacyPhoto", targets: ["PrivacyPhoto"]),
        .library(name: "PrivacyCamera", targets: ["PrivacyCamera"]),
        .library(name: "PrivacyContact", targets: ["PrivacyContact"]),
        .library(name: "PrivacyMicrophone", targets: ["PrivacyMicrophone"]),
        .library(name: "PrivacyLocation", targets: ["PrivacyLocation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "PrivacyManager", dependencies: ["RxSwift"], path: "PrivacyManager"),
        .target(name: "PrivacyPhoto", dependencies: ["RxSwift", "PrivacyManager"], path: "PrivacyPhoto"),
        .target(name: "PrivacyCamera", dependencies: ["RxSwift", "PrivacyManager"], path: "PrivacyCamera"),
        .target(name: "PrivacyContact", dependencies: ["RxSwift", "PrivacyManager"], path: "PrivacyContact"),
        .target(name: "PrivacyMicrophone", dependencies: ["RxSwift", "PrivacyManager"], path: "PrivacyMicrophone"),
        .target(name: "PrivacyLocation", dependencies: ["RxSwift", "RxCocoa", "PrivacyManager"], path: "PrivacyLocation"),
    ],
    swiftLanguageVersions: [.v5]
)
