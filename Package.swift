// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "PointFree",
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Blog", targets: ["Blog"]),
    .library(name: "Database", targets: ["Database"]),
    .library(name: "GitHub", targets: ["GitHub"]),
    .library(name: "Logger", targets: ["Logger"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreePrelude", targets: ["PointFreePrelude"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    .library(name: "Stripe", targets: ["Stripe"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "Syndication", targets: ["Syndication"]),
    ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", .revision("8cbc934")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.2.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-web.git", .revision("ad19b2d")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("master")),
    .package(url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
    ],
  targets: [

    .target(
      name: "Blog",
      dependencies: [
        "ApplicativeRouter",
        "Either",
        "Tagged",
        ]
    ),

    .testTarget(
      name: "BlogTests",
      dependencies: [
        "Blog",
        "SnapshotTesting",
        ]
    ),



    .target(
      name: "Models",
      dependencies: [
        "Tagged",
        ]
    ),

    .testTarget(
      name: "ModelsTests",
      dependencies: [
        "Models",
        ]
    ),






    .target(
      name: "Database",
      dependencies: [
        "Either",
        "GitHub",
        "PostgreSQL",
        "Prelude",
        "Stripe",
        ]
    ),

    .testTarget(
      name: "DatabaseTests",
      dependencies: [
        "Database",
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

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
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
      name: "PointFree",
      dependencies: [
        "ApplicativeRouter",
        "ApplicativeRouterHttpPipelineSupport",
        "Css",
        "CssReset",
        "Either",
        "GitHub",
        "Html",
        "HtmlCssSupport",
        "HtmlPlainTextPrint",
        "HttpPipeline",
        "HttpPipelineHtmlSupport",
        "Models",
        "Optics",
        "PointFreePrelude",
        "PostgreSQL",
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
        "Either",
        "GitHub",
        "HttpPipelineTestSupport",
        "Logger",
        "PointFree",
        "PointFreePrelude",
        "Prelude",
        "SnapshotTesting",
        "Stripe",
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
        "Optics",
        "PointFreePrelude",
        "Prelude",
        ]
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "SnapshotTesting",
        "Stripe",
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
