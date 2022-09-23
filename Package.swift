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
    .package(url: "https://github.com/apple/swift-log.git", from: "1.4.4")
  ],
  targets: [
    .target(
        name: "SwiftLocale",
        dependencies: [
            "icu-locale",
            .product(name: "Logging", package: "swift-log")
        ]
    ),
    .testTarget(
        name: "SwiftLocaleTests",
        dependencies: [
            "SwiftLocale",
        ]
    ),
    .systemLibrary(
        name: "icu-locale",
        pkgConfig: "icu-uc",
        providers: [
            .brew(["icu4c"])
        ]
    )
  ]
)
