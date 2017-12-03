// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("7bb13df")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("a253396")),
    .package(url: "https://github.com/vapor/postgresql.git", from: "2.0.0"),
  ],
  targets: [
    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),
    .testTarget(
      name: "StyleguideTests",
      dependencies: ["Styleguide", "CssTestSupport"]),

    .target(
      name: "PointFreeTestSupport",
      dependencies: ["Either", "PointFree", "Prelude"]),

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
  ],
  swiftLanguageVersions: [4]
)
