// swift-tools-version:5.3

import Foundation
import PackageDescription

let isOss = !FileManager.default.fileExists(
  atPath: URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("Sources")
    .appendingPathComponent("Models")
    .appendingPathComponent("Transcripts")
    .appendingPathComponent(".git")
    .path
)

extension SwiftSetting {
  static let warnLongExpressionTypeChecking = unsafeFlags(
    [
      "-Xfrontend", "-warn-long-expression-type-checking=200",
      "-Xfrontend", "-warn-long-function-bodies=200",
    ],
    .when(configuration: .debug)
  )
}

extension Array where Element == SwiftSetting {
  static let pointFreeSettings: Array = isOss
    ? [.define("OSS"), .warnLongExpressionTypeChecking]
    : [.warnLongExpressionTypeChecking]
}

let package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v10_16),
  ],
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/ianpartridge/swift-backtrace.git", .exact("1.1.0")),
    .package(url: "https://github.com/pointfreeco/Ccmark.git", .branch("main")),
    .package(name: "Html", url: "https://github.com/pointfreeco/swift-html.git", .revision("3a1b7e4")),
    .package(name: "Prelude", url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")),
    .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.1"),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged.git", .revision("fde36b6")),
    .package(name: "Web", url: "https://github.com/pointfreeco/swift-web.git", .revision("148acf4")),
    .package(name: "PostgreSQL", url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
  ],
  targets: [

    .target(
      name: "Database",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Models",
        "PointFreePrelude",
        "Stripe",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "PostgreSQL", package: "PostgreSQL"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "DatabaseTestSupport",
      dependencies: [
        "Database",
        "Models",
        "ModelsTestSupport",
        "PointFreePrelude",
        .product(name: "Either", package: "Prelude"),
        .product(name: "PostgreSQL", package: "PostgreSQL"),
        .product(name: "Prelude", package: "Prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "DecodableRequest",
      dependencies: [
        .product(name: "Tagged", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "Prelude", package: "Prelude")
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "FunctionalCss",
        .product(name: "CssTestSupport", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "GitHub",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Prelude", package: "Prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Mailgun",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        "Models",
        .product(name: "HttpPipeline", package: "Web"),
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Models",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Stripe",
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedTime", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
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
        .product(name: "Prelude", package: "Prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "ModelsTests",
      dependencies: [
        "Models",
        "ModelsTestSupport",
      ],
      swiftSettings: .pointFreeSettings
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
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "ApplicativeRouterHttpPipelineSupport", package: "Web"),
        .product(name: "Backtrace", package: "swift-backtrace"),
        .product(name: "Css", package: "Web"),
        .product(name: "CssReset", package: "Web"),
        .product(name: "Either", package: "Prelude"),
        .product(name: "Html", package: "Html"),
        .product(name: "HtmlCssSupport", package: "Web"),
        .product(name: "HtmlPlainTextPrint", package: "Web"),
        .product(name: "HttpPipeline", package: "Web"),
        .product(name: "HttpPipelineHtmlSupport", package: "Web"),
        .product(name: "PostgreSQL", package: "PostgreSQL"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedMoney", package: "Tagged"),
        .product(name: "TaggedTime", package: "Tagged"),
        .product(name: "Tuple", package: "Prelude"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "EmailAddress",
        "PointFree",
        "PointFreeTestSupport",
        .product(name: "CssTestSupport", package: "Web"),
        .product(name: "HtmlSnapshotTesting", package: "Html"),
        .product(name: "HttpPipelineTestSupport", package: "Web"),
      ],
      exclude: [
        "__Snapshots__",
        "AccountTests/__Snapshots__",
        "EmailTests/__Snapshots__",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "PointFreeRouter",
      dependencies: [
        "EmailAddress",
        "Models",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "HttpPipeline", package: "Web"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
        .product(name: "UrlFormEncoding", package: "Web")
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "PointFreePrelude",
      dependencies: [
        "FoundationPrelude",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "Tuple", package: "Prelude"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ],
      swiftSettings: .pointFreeSettings
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
        .product(name: "Either", package: "Prelude"),
        .product(name: "HttpPipelineTestSupport", package: "Web"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Runner",
      dependencies: [
        "PointFree",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Server",
      dependencies: [
        "PointFree",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Stripe",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedMoney", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "PointFreePrelude",
        "Stripe",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "Prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "Stripe",
        "StripeTestSupport",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Styleguide",
      dependencies: [
        "FunctionalCss",
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "HtmlCssSupport", package: "Web"),
        .product(name: "Prelude", package: "Prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "Styleguide",
        .product(name: "CssTestSupport", package: "Web"),
        .product(name: "HtmlSnapshotTesting", package: "Html"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ],
      exclude: [
        "__Snapshots__",
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Syndication",
      dependencies: [
        "Models",
        .product(name: "Html", package: "Html")
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Views",
      dependencies: [
        "EmailAddress",
        "FunctionalCss",
        "PointFreeRouter",
        "Styleguide",
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedTime", package: "Tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),
  ]
)
