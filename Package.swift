// swift-tools-version:5.1

import PackageDescription

extension SwiftSetting {
  static let warnLongExpressionTypeChecking = unsafeFlags(
    [
      "-Xfrontend", "-warn-long-expression-type-checking=200",
      "-Xfrontend", "-warn-long-function-bodies=200",
    ],
    .when(configuration: .debug)
  )
}

let package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Database", targets: ["Database"]),
    .library(name: "DecodableRequest", targets: ["DecodableRequest"]),
    .library(name: "EmailAddress", targets: ["EmailAddress"]),
    .library(name: "FoundationPrelude", targets: ["FoundationPrelude"]),
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
        "EmailAddress",
        "GitHub",
        "Models",
        "Stripe",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
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
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "DecodableRequest",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "FoundationPreludeTests",
      dependencies: [
        "FoundationPrelude",
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude")
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "FunctionalCss",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        .product(name: "Either", package: "swift-prelude"),
        "FoundationPrelude",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "GitHub",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Mailgun",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        .product(name: "HttpPipeline", package: "swift-web"),
        "Models",
        .product(name: "Either", package: "swift-prelude"),
        "FoundationPrelude",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Models",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Stripe",
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
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
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "ModelsTests",
      dependencies: [
        "Models",
        "ModelsTestSupport",
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "PointFree",
      dependencies: [
        "Database",
        "EmailAddress",
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
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "EmailAddress",
        "PointFree",
        "PointFreeTestSupport",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "PointFreeRouter",
      dependencies: [
        "EmailAddress",
        "Models",
        .product(name: "ApplicativeRouter", package: "swift-web"),
        .product(name: "HttpPipeline", package: "swift-web"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "UrlFormEncoding", package: "swift-web")
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "PointFreePrelude",
      dependencies: [
        "FoundationPrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
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
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Runner",
      dependencies: [
        "PointFree",
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Server",
      dependencies: [
        "PointFree",
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Stripe",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "PointFreePrelude",
        "Stripe",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "Stripe",
        "StripeTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Styleguide",
      dependencies: [
        "FunctionalCss",
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "HtmlCssSupport", package: "swift-web"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "Styleguide",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Syndication",
      dependencies: [
        .product(name: "Html", package: "swift-html")
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .testTarget(
      name: "SyndicationTests",
      dependencies: [
        "Syndication",
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),

    .target(
      name: "Views",
      dependencies: [
        "EmailAddress",
        "FunctionalCss",
        "PointFreeRouter",
        "Styleguide",
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: [.warnLongExpressionTypeChecking]
    ),
  ]
)
