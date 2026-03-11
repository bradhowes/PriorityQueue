// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "PriorityQueue",
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
