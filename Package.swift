// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "EpisodeModels", targets: ["EpisodeModels"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9a635ce")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("c510e7d")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("d483620")),
    .package(url: "https://github.com/mbrandonw/episodes.git", .revision("306f1f3")),
    .package(url: "https://github.com/vapor/postgresql.git", from: "2.0.0"),
    ],
  targets: [
    .target(
      name: "EpisodeModels",
      dependencies: []),
    .testTarget(
      name: "EpisodeModelsTests",
      dependencies: ["EpisodeModels"]),

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
        "PointFree",
        "Prelude",
        "SnapshotTesting"
      ]),
    ],
  swiftLanguageVersions: [4]
)
