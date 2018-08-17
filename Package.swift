// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeMocks", targets: ["PointFreeMocks"]),
    .library(name: "PointFreeTestCase", targets: ["PointFreeTestCase"]),
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("5d5005d")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .revision("69b48c8")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("507379f")),
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
        "PointFreeMocks",
        "PointFreeTestCase"
        ]
    ),

    .target(
      name: "PointFreeMocks",
      dependencies: [
        "Either",
        "PointFree",
        "Prelude",
        ]
    ),

    .target(
      name: "PointFreeTestCase",
      dependencies: []),

    .target(
      name: "Runner",
      dependencies: ["PointFree"]),

    .target(
      name: "Server",
      dependencies: ["PointFree", "PointFreeMocks"]),

    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: ["Styleguide", "CssTestSupport", "PointFreeMocks", "PointFreeTestCase"]),

    ],
  swiftLanguageVersions: [4]
)
