// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDataStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftDataStorage",
            targets: ["SwiftDataStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../ExpenseFeature")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftDataStorage",
            dependencies: [
                "ExpenseFeature"
            ],
            path: "Sources/Storage"
        ),
        .testTarget(
            name: "SwiftDataStorageTests",
            dependencies: ["SwiftDataStorage"],
            path: "Tests/StorageTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
