// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Database", targets: ["Database"]),
    .library(name: "DatabaseTestSupport", targets: ["DatabaseTestSupport"]),
    .library(name: "FunctionalCss", targets: ["FunctionalCss"]),
    .library(name: "GitHub", targets: ["GitHub"]),
    .library(name: "GitHubTestSupport", targets: ["GitHubTestSupport"]),
    .library(name: "Mailgun", targets: ["Mailgun"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ModelsTestSupport", targets: ["ModelsTestSupport"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreePrelude", targets: ["PointFreePrelude"]),
    .library(name: "PointFreeRouter", targets: ["PointFreeRouter"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    .library(name: "Stripe", targets: ["Stripe"]),
    .library(name: "StripeTestSupport", targets: ["StripeTestSupport"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "Syndication", targets: ["Syndication"]),
    .library(name: "Views", targets: ["Views"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/ianpartridge/swift-backtrace.git", .exact("1.1.0")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/pointfreeco/swift-html.git", .revision("3a1b7e4")),
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", .revision("fde36b6")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("f827fb9")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
  ],
  targets: [

    .target(
      name: "Database",
      dependencies: [
        "Either",
        "GitHub",
        "Logging",
        "Models",
        "PostgreSQL",
        "Prelude",
        "Stripe",
        "Tagged",
      ]
    ),

    .target(
      name: "DatabaseTestSupport",
      dependencies: [
        "Database",
        "Either",
        "Models",
        "ModelsTestSupport",
        "Optics",
        "PointFreePrelude",
        "PostgreSQL",
        "Prelude",
      ]
    ),

    .testTarget(
      name: "DatabaseTests",
      dependencies: [
        "Database",
        "DatabaseTestSupport",
        "GitHubTestSupport",
        "Logging",
        "ModelsTestSupport",
        "SnapshotTesting",
      ]
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        "Css",
        "Html",
        "Prelude"
      ]
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "CssTestSupport",
        "FunctionalCss",
        "Html",
        "SnapshotTesting",
      ]
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "Either",
        "Logging",
        "Optics",
        "PointFreePrelude",
        "Prelude",
        "Tagged",
      ]
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "Either",
        "GitHub",
        "Prelude",
      ]
    ),

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        "SnapshotTesting",
      ]
    ),

    .target(
      name: "Mailgun",
      dependencies: [
        "Either",
        "HttpPipeline",
        "Logging",
        "Models",
        "PointFreePrelude",
        "UrlFormEncoding",
      ]
    ),

    .target(
      name: "Models",
      dependencies: [
        "GitHub",
        "PointFreePrelude",
        "Stripe",
        "Tagged",
      ]
    ),

    .target(
      name: "ModelsTestSupport",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        "Models",
        "Optics",
        "Prelude",
        "PointFreePrelude",
        "Stripe",
        "StripeTestSupport",
      ]
    ),

    .testTarget(
      name: "ModelsTests",
      dependencies: [
        "Models",
        "ModelsTestSupport",
      ]
    ),

    .target(
      name: "PointFree",
      dependencies: [
        "ApplicativeRouter",
        "ApplicativeRouterHttpPipelineSupport",
        "Backtrace",
        "Css",
        "CssReset",
        "Database",
        "Either",
        "GitHub",
        "Html",
        "HtmlCssSupport",
        "HtmlPlainTextPrint",
        "Html",
        "HttpPipeline",
        "HttpPipelineHtmlSupport",
        "Mailgun",
        "Models",
        "Optics",
        "PointFreeRouter",
        "PointFreePrelude",
        "PostgreSQL",
        "Stripe",
        "Styleguide",
        "Syndication",
        "TaggedMoney",
        "Tuple",
        "UrlFormEncoding",
        "Views",
      ]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "CssTestSupport",
        "HtmlSnapshotTesting",
        "HtmlSnapshotTesting",
        "HttpPipelineTestSupport",
        "PointFree",
        "PointFreeTestSupport",
      ]
    ),

    .target(
      name: "PointFreeRouter",
      dependencies: [
        "ApplicativeRouter",
        "HttpPipeline",
        "Models",
        "Prelude",
        "Tagged",
        "UrlFormEncoding"
      ]
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        "SnapshotTesting",
        "UrlFormEncoding"
      ]
    ),

    .target(
      name: "PointFreePrelude",
      dependencies: [
        "Either",
        "Logging",
        "Optics",
        "Prelude",
        "Tagged",
        "Tuple",
        "UrlFormEncoding",
      ]
    ),

    .target(
      name: "PointFreeTestSupport",
      dependencies: [
        "Database",
        "DatabaseTestSupport",
        "Either",
        "GitHub",
        "GitHubTestSupport",
        "HttpPipelineTestSupport",
        "Models",
        "ModelsTestSupport",
        "Logging",
        "PointFree",
        "PointFreePrelude",
        "Prelude",
        "SnapshotTesting",
        "Stripe",
        "StripeTestSupport",
      ]
    ),

    .target(
      name: "Runner",
      dependencies: [
        "PointFree",
    ]),

    .target(
      name: "Server",
      dependencies: [
        "PointFree",
    ]),

    .target(
      name: "Stripe",
      dependencies: [
        "Either",
        "Logging",
        "PointFreePrelude",
        "Prelude",
        "Tagged",
        "TaggedMoney"
      ]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "Either",
        "Logging",
        "Optics",
        "PointFreePrelude",
        "Prelude",
        "Stripe",
      ]
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "SnapshotTesting",
        "Stripe",
        "StripeTestSupport",
      ]
    ),

    .target(
      name: "Styleguide",
      dependencies: [
        "Css",
        "FunctionalCss",
        "Html",
        "HtmlCssSupport",
        "Prelude",
    ]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "CssTestSupport",
        "HtmlSnapshotTesting",
        "SnapshotTesting",
        "Styleguide",
    ]),

    .target(
      name: "Syndication",
      dependencies: [
        "Html",
    ]),

    .testTarget(
      name: "SyndicationTests",
      dependencies: [
        "Syndication",
    ]),

    .target(
      name: "Views",
      dependencies: [
        "Css",
        "FunctionalCss",
        "Html",
        "PointFreeRouter",
        "Prelude",
        "Styleguide",
    ]),

    .testTarget(
      name: "ViewsTests",
      dependencies: [
        "Views",
    ]),
  ]
)
