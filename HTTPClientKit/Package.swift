// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "HTTPClientKit",
  platforms: [
    .macOS(.v15),
  ],
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
