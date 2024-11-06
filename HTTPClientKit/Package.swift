// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "HTTPClientKit",
  products: [
    .library(
      name: "HTTPClientKit",
      targets: ["HTTPClientKit"]
    ),
  ],
  targets: [
    .target(
      name: "HTTPClientKit"),
    .testTarget(
      name: "HTTPClientKitTests",
      dependencies: ["HTTPClientKit"]
    ),
  ]
)
