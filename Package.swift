// swift-tools-version:4.0
import Foundation
import PackageDescription

let episodesDependency: Package.Dependency
if ProcessInfo.processInfo.environment["ENV"] == "PF" {
  episodesDependency = .package(url: "https://github.com/mbrandonw/episodes.git", .revision("947706b"))
} else {
  episodesDependency = .package(url: "https://github.com/pointfreeco/episodes-oss.git", .revision("8e0751d"))
}

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
    .package(url: "https://github.com/pointfreeco/episode-models.git", .revision("d3f2ef3")),
    .package(url: "https://github.com/vapor/postgresql.git", from: "2.0.0"),
    episodesDependency
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
        "Episodes",
        "EpisodeModels",
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

    .target(
      name: "PointFreeTestSupport",
      dependencies: ["Either", "PointFree", "Prelude"]),
    ],
  swiftLanguageVersions: [4]
)
