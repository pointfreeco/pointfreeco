// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "PointFree", targets: ["PointFree"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("2128f69")),
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("17d2746")),
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
