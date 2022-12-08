// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "PatternCompleteness",
  products: [
    .executable(name: "patchk", targets: ["CLI"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "CompletenessChecker"),

    .executableTarget(
      name: "CLI",
      dependencies: ["CompletenessChecker"]),

    .testTarget(
      name: "CompletenessCheckerTests",
      dependencies: ["CompletenessChecker"]),
  ])
