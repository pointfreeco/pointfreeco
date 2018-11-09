// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("7a04ca2")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("86f36c9")),
    .package(url: "https://github.com/pointfreeco/swift-html.git", .revision("0.1.3")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("885d3cb")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
    ],
  targets: [
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
        "HtmlPlainTextPrint",
        "HtmlPrettyPrint",
        "HttpPipeline",
        "HttpPipelineHtmlSupport",
        "Optics",
        "PostgreSQL",
        "Styleguide",
        "Tuple",
        "UrlFormEncoding",
        "View",
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
        "HtmlPrettyPrint",
        "HttpPipelineTestSupport",
        "PointFree",
        "Prelude",
        "SnapshotTesting",
        ]
    ),

    .target(
      name: "Runner",
      dependencies: ["PointFree"]),

    .target(
      name: "Server",
      dependencies: ["PointFree"]),

    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: ["Styleguide", "CssTestSupport", "PointFreeTestSupport"]),
    ]
)
