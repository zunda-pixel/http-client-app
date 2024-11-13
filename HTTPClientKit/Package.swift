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
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0"),
  ],
  targets: [
    .target(
      name: "HTTPClientKit",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
      ]
    ),
    .testTarget(
      name: "HTTPClientKitTests",
      dependencies: ["HTTPClientKit"]
    ),
  ]
)
