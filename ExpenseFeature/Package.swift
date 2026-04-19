// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpenseFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ExpenseFeature",
            targets: ["ExpenseFeature"]
        ),
    ],
    targets: [
        // 1. The Composition layer (depends on internal layers)
        .target(
            name: "ExpenseFeature",
            dependencies: ["Domain", "Storage"]
        ),
        .testTarget(
            name: "ExpenseFeatureTests",
            dependencies: ["ExpenseFeature"]
        ),
        
        // 2. The Core
        .target(
            name: "Domain",
        ),
        
        // 3. The Infrastructure (depends on Core)
        .target(
            name: "Storage",
            dependencies: ["Domain"]
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: ["Storage"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
