// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("e9cc7cd")),
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("a8a4849")),
  ],
  targets: [
    .target(
      name: "Styleguide",
      dependencies: ["Html", "Css"]),
    .testTarget(
       name: "StyleguideTests",
       dependencies: ["Styleguide", "CssTestSupport"]),

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
        "Styleguide",
      ]
    ),
    .testTarget(
      name: "PointFreeTests",
       dependencies: [
         "CssTestSupport",
         "HtmlTestSupport",
         "HttpPipelineTestSupport",
         "PointFree",
         ]
     ),
  ],
  swiftLanguageVersions: [4]
)
