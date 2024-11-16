// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "HTTPClientKit",
  platforms: [
    .macOS(.v15),
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "HTTPClientKit",
      targets: ["HTTPClientKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.1"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
    .package(url: "https://github.com/zunda-pixel/LicenseProvider", from: "1.3.1"),
  ],
  targets: [
    .target(
      name: "HTTPClientKit",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "OrderedCollections", package: "swift-collections"),
      ],
      plugins: [
        .plugin(name: "LicenseProviderPlugin", package: "LicenseProvider"),
      ]
    ),
    .testTarget(
      name: "HTTPClientKitTests",
      dependencies: ["HTTPClientKit"]
    ),
  ]
)
