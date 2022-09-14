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
    .package(
        url: "https://github.com/Quick/Nimble.git",
        from: "10.0.0"
    )
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
            "Nimble"
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
