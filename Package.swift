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
  targets: [
    .target(
        name: "SwiftLocale",
        dependencies: [
            "icu-locale"
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
