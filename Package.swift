// swift-tools-version:4.0

import Foundation
import PackageDescription

let extraProducts: [Product]
let extraTargets: [Target]
let skipTests = ProcessInfo.processInfo.environment["SKIP_TESTS"].map { $0.uppercased() }
if skipTests == nil || skipTests == .some("0") || skipTests == .some("F") || skipTests == .some("FALSE") {
  extraProducts = [.library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"])]
  extraTargets = [
    .testTarget(
      name: "StyleguideTests",
      dependencies: ["Styleguide", "CssTestSupport", "PointFreeTestSupport"]),
    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "CssTestSupport",
        "HtmlTestSupport",
        "HttpPipelineTestSupport",
        "PointFree",
        "PointFreeTestSupport"
      ]
    ),
    .target(
      name: "PointFreeTestSupport",
      dependencies: [
        "Either",
        "PointFree",
        "Prelude",
        "SnapshotTesting"
      ]),
  ]
} else {
  extraProducts = []
  extraTargets = []
}

let package = Package(
  name: "PointFree",
  products: [
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    ]
    + extraProducts,
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("45bb2cc")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("c510e7d")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("37c7d8e")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact(.init(2, 1, 1))),
    .package(url: "https://github.com/IBM-Swift/Kitura.git", .exact("2.1.0")),
    .package(url: "https://github.com/IBM-Swift/Kitura-Compression", .exact("2.1.0")),
    ],
  targets: [
    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),

    .target(
      name: "PointFree",
      dependencies: [
        "ApplicativeRouter",
        "ApplicativeRouterHttpPipelineSupport",
        "Css",
        "CssReset",
        "Either",
        "Html",
        "HtmlCssSupport",
        "HttpPipeline",
        "HttpPipelineHtmlSupport",
        "Optics",
        "PostgreSQL",
        "Styleguide",
        "Tuple",
        "UrlFormEncoding"
      ]
    ),

    .target(
      name: "Server",
      dependencies: [
        "Kitura",
        "KituraCompression",
        "PointFree",
        ]
    ),
    ]
    + extraTargets,
  swiftLanguageVersions: [4]
)
