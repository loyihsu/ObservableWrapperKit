// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ObservableWrapperKit",
    platforms: [
        // Runtime support for parameterized protocol types.
        .macOS(.v13), .iOS(.v16),
    ],
    products: [
        .library(
            name: "ObservableWrapperKit",
            targets: ["ObservableWrapperKit"]
        ),
    ],
    targets: [
        .target(
            name: "ObservableWrapperKit"
        ),
        .testTarget(
            name: "ObservableWrapperKitTests",
            dependencies: ["ObservableWrapperKit"]
        ),
    ]
)
