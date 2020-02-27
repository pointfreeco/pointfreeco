// swift-tools-version:5.1

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

let oss = FileManager.default.fileExists(atPath: "Sources/Models/Transcripts/.git")

let package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
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
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "DatabaseTestSupport",
      dependencies: [
        "Database",
        "Models",
        "ModelsTestSupport",
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "DecodableRequest",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude")
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "FunctionalCss",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "GitHub",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "GitHubTests",
      dependencies: [
        "GitHub",
        "GitHubTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        .product(name: "HttpPipeline", package: "swift-web"),
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Models",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Stripe",
        .product(name: "Tagged", package: "swift-tagged"),
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
        .product(name: "Prelude", package: "swift-prelude"),
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
        .product(name: "PostgreSQL", package: "postgresql"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
      ],
      swiftSettings: .pointFreeSettings
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
      swiftSettings: .pointFreeSettings
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
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "UrlFormEncoding", package: "swift-web")
      ],
      swiftSettings: .pointFreeSettings
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
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
      ],
      swiftSettings: .pointFreeSettings
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
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "StripeTests",
      dependencies: [
        "Stripe",
        "StripeTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: .pointFreeSettings
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
      swiftSettings: .pointFreeSettings
    ),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "Styleguide",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      swiftSettings: .pointFreeSettings
    ),

    .target(
      name: "Syndication",
      dependencies: [
        "Models",
        .product(name: "Html", package: "swift-html")
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
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
      ],
      swiftSettings: .pointFreeSettings
    ),
  ]
)
