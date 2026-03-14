// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "PriorityQueue",
  platforms: [
    .iOS(.v14),
    .macOS(.v12),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "PriorityQueue", targets: ["PriorityQueue"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "PriorityQueue",
      dependencies: []
    ),
    .testTarget(
      name: "PriorityQueueTests",
      dependencies: ["PriorityQueue"]
    ),
  ]
)
