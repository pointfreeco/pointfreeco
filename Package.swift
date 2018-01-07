// swift-tools-version:4.0

import Foundation
import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9a635ce")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("c510e7d")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("35421ef")),
    .package(url: "https://github.com/vapor/postgresql.git", from: "2.0.0"),

    ProcessInfo.processInfo.environment["OSS"] == "1"
      ? .package(url: "https://github.com/pointfreeco/episode-transcripts-oss.git", .revision("2a6472f"))
      : .package(url: "https://github.com/mbrandonw/episode-transcripts.git", .revision("5d786e7"))
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
        "EpisodeTranscripts",
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
        "EpisodeTranscripts",
        "PointFree",
        "Prelude",
        "SnapshotTesting"
      ]),
    ],
  swiftLanguageVersions: [4]
)
