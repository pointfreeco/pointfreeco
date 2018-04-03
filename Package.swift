// swift-tools-version:4.0

import Foundation
import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("a3cd883")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("0a86107")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("0d4397e")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.1")),
    .package(url: "https://github.com/IBM-Swift/Kitura.git", .branch("swift-4.1")),
    .package(url: "https://github.com/IBM-Swift/Kitura-Compression", .exact("2.1.1")),
    ],
  targets: [
    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: ["Styleguide", "CssTestSupport", "PointFreeTestSupport"]),

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
        "UrlFormEncoding",
        ]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "CssTestSupport",
        "HtmlTestSupport",
        "HttpPipelineTestSupport",
        "PointFree",
        "PointFreeTestSupport",
        ]
    ),

    .target(
      name: "PointFreeTestSupport",
      dependencies: [
        "Either",
        "PointFree",
        "Prelude",
        "SnapshotTesting",
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
    ],
  swiftLanguageVersions: [4]
)
