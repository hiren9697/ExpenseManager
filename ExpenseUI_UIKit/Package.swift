// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpenseUI_UIKit",
    platforms: [
        .iOS(.v17), .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExpenseUI_UIKit",
            targets: ["ExpenseUI_UIKit"]
        ),
    ],
    dependencies: [
        .package(path: "../ExpensePresentation")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ExpenseUI_UIKit",
            dependencies: [
                "ExpensePresentation"
            ]
        ),
        .testTarget(
            name: "ExpenseUI_UIKitTests",
            dependencies: ["ExpenseUI_UIKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
