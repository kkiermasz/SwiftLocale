// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "SwiftLocale",
  products: [
    .library(
        name: "SwiftLocale",
        targets: ["SwiftLocale"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-foundation-icu", from: "0.0.5"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
  ],
  targets: [
    .target(
        name: "SwiftLocale",
        dependencies: [
            .product(name: "FoundationICU", package: "swift-foundation-icu"),
            .product(name: "Logging", package: "swift-log"),
        ]
    ),
    .testTarget(
        name: "SwiftLocaleTests",
        dependencies: [
            "SwiftLocale",
        ]
    ),
  ]
)
