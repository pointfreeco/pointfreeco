// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "PointFreeRouter", targets: ["PointFreeRouter"]),
    .library(name: "Database", targets: ["Database"]),
    .library(name: "DatabaseTestSupport", targets: ["DatabaseTestSupport"]),
    .library(name: "GitHub", targets: ["GitHub"]),
    .library(name: "GitHubTestSupport", targets: ["GitHubTestSupport"]),
    .library(name: "Logger", targets: ["Logger"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ModelsTestSupport", targets: ["ModelsTestSupport"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreePrelude", targets: ["PointFreePrelude"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    .library(name: "Stripe", targets: ["Stripe"]),
    .library(name: "StripeTestSupport", targets: ["StripeTestSupport"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "Syndication", targets: ["Syndication"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("8cbc934")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.2.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", .revision("73620f3")),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("a968110")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
    ],
  targets: [

    .target(
      name: "Database",
      dependencies: [
        "Either",
        "GitHub",
        "Logger",
        "Models",
        "PostgreSQL",
        "Prelude",
        "Stripe",
        ]
    ),

    .target(
      name: "DatabaseTestSupport",
      dependencies: [
        "Database",
        "Either",
        "Models",
        "ModelsTestSupport",
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
        "SnapshotTesting",
        ]
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "Either",
        "Logger",
        "Optics",
        "PointFreePrelude",
        "Prelude",
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
      name: "Logger",
      dependencies: [
        "Either",
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
        "Css",
        "CssReset",
        "Database",
        "Either",
        "GitHub",
        "Html",
        "HtmlCssSupport",
        "HtmlPlainTextPrint",
        "HttpPipeline",
        "HttpPipelineHtmlSupport",
        "Models",
        "Optics",
        "PointFreeRouter",
        "PointFreePrelude",
        "PostgreSQL",
        "Stripe",
        "Styleguide",
        "Syndication",
        "Tuple",
        "UrlFormEncoding",
        "View",
        ]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "CssTestSupport",
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
        "PointFreeRouter",
        "UrlFormEncoding"
      ]
    ),

    .target(
      name: "PointFreePrelude",
      dependencies: [
        "Either",
        "Logger",
        "Optics",
        "Prelude",
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
        "Logger",
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
        "Logger",
        "PointFreePrelude",
        "Prelude",
        "TaggedMoney"
        ]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "Either",
        "Logger",
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
        "Html",
        ]),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "CssTestSupport",
        "PointFreeTestSupport",
        "Styleguide",
        ]),

    .target(
      name: "Syndication",
      dependencies: [
        "Html",
        "View",
        ]),

    .testTarget(
      name: "SyndicationTests",
      dependencies: [
        "Syndication",
        ]),
    ]
)
