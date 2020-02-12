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
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("148acf4")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
  ],
  targets: [

    .target(
      name: "Database",
      dependencies: [
        "GitHub",
        "Models",
        "Stripe",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "DatabaseTestSupport",
      dependencies: [
        "Database",
        "Models",
        "ModelsTestSupport",
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude")
      ]
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "FunctionalCss",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "GitHub",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),

    .target(
      name: "Mailgun",
      dependencies: [
        .product(name: "HttpPipeline", package: "swift-web"),
        "Models",
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ]
    ),

    .target(
      name: "Models",
      dependencies: [
        "GitHub",
        "PointFreePrelude",
        "Stripe",
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "ModelsTestSupport",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        "Models",
        "PointFreePrelude",
        "Stripe",
        "StripeTestSupport",
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
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
        "Database",
        "GitHub",
        "Mailgun",
        "Models",
        "PointFreeRouter",
        "PointFreePrelude",
        "Stripe",
        "Styleguide",
        "Syndication",
        "Views",
        .product(name: "ApplicativeRouter", package: "swift-web"),
        .product(name: "ApplicativeRouterHttpPipelineSupport", package: "swift-web"),
        .product(name: "Backtrace", package: "swift-backtrace"),
        .product(name: "Css", package: "swift-web"),
        .product(name: "CssReset", package: "swift-web"),
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "HtmlCssSupport", package: "swift-web"),
        .product(name: "HtmlPlainTextPrint", package: "swift-web"),
        .product(name: "HttpPipeline", package: "swift-web"),
        .product(name: "HttpPipelineHtmlSupport", package: "swift-web"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "PointFree",
        "PointFreeTestSupport",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
      ]
    ),

    .target(
      name: "PointFreeRouter",
      dependencies: [
        "Models",
        .product(name: "ApplicativeRouter", package: "swift-web"),
        .product(name: "HttpPipeline", package: "swift-web"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ]
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "UrlFormEncoding", package: "swift-web")
      ]
    ),

    .target(
      name: "PointFreePrelude",
      dependencies: [
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ]
    ),

    .target(
      name: "PointFreeTestSupport",
      dependencies: [
        "Database",
        "DatabaseTestSupport",
        "GitHub",
        "GitHubTestSupport",
        "Models",
        "ModelsTestSupport",
        "PointFree",
        "PointFreePrelude",
        "Stripe",
        "StripeTestSupport",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "PointFreePrelude",
        "Stripe",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Optics", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "Stripe",
        "StripeTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),

    .target(
      name: "Styleguide",
      dependencies: [
        "FunctionalCss",
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "HtmlCssSupport", package: "swift-web"),
        .product(name: "Prelude", package: "swift-prelude"),
    ]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "Styleguide",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
    ]),

    .target(
      name: "Syndication",
      dependencies: [
        .product(name: "Html", package: "swift-html")
    ]),

    .testTarget(
      name: "SyndicationTests",
      dependencies: [
        "Syndication",
    ]),

    .target(
      name: "Views",
      dependencies: [
        "FunctionalCss",
        "PointFreeRouter",
        "Styleguide",
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
    ]),

    .testTarget(
      name: "ViewsTests",
      dependencies: [
        "Views",
    ]),

  ]
)
