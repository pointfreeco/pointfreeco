// swift-tools-version:5.3

import Foundation
import PackageDescription

var package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v11),
  ],
  products: [
    .executable(name: "Runner", targets: ["Runner"]),
    .executable(name: "Server", targets: ["Server"]),
    .library(name: "Database", targets: ["Database"]),
    .library(name: "DatabaseTestSupport", targets: ["DatabaseTestSupport"]),
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
    .library(name: "WebPreview", targets: ["WebPreview"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/ianpartridge/swift-backtrace.git", .exact("1.1.0")),
    .package(name: "Html", url: "https://github.com/pointfreeco/swift-html.git", .revision("f016529")),
    .package(
      name: "Overture", url: "https://github.com/pointfreeco/swift-overture.git", .exact("0.5.0")),
    .package(name: "Prelude", url: "https://github.com/pointfreeco/swift-prelude.git", .revision("9240a1f")),
    .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.2"),
    .package(name: "Tagged", url: "https://github.com/pointfreeco/swift-tagged.git", .revision("fde36b6")),
    .package(name: "Web", url: "https://github.com/pointfreeco/swift-web.git", .revision("2e23f76")),
    .package(name: "PostgreSQL", url: "https://github.com/vapor-community/postgresql.git", .exact("2.1.2")),
  ],
  targets: [

    .systemLibrary(
      name: "Ccmark",
      pkgConfig: "libcmark",
      providers: [
        .apt(["cmark"]),
        .brew(["cmark"]),
      ]
    ),

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
      ]
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
      ]
    ),

    .target(
      name: "DecodableRequest",
      dependencies: [
        .product(name: "Tagged", package: "Tagged"),
      ]
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "Tagged"),
      ]
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ]
    ),

    .target(
      name: "FunctionalCss",
      dependencies: [
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "Prelude", package: "Prelude")
      ]
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
      ]
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
      ]
    ),

    .target(
      name: "GitHubTestSupport",
      dependencies: [
        "GitHub",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Prelude", package: "Prelude"),
      ]
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
      ]
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
      ]
    ),

    .target(
      name: "Models",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Stripe",
        .product(name: "Overture", package: "Overture"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedTime", package: "Tagged"),
      ],
      exclude: [
        "Transcripts/README.md",
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
        .product(name: "Prelude", package: "Prelude"),
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
      ]
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
      ]
    ),

    .target(
      name: "PointFreeRouter",
      dependencies: [
        "EmailAddress",
        "Models",
        "PointFreePrelude",
        .product(name: "ApplicativeRouter", package: "Web"),
        .product(name: "HttpPipeline", package: "Web"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "UrlFormEncoding", package: "Web"),
      ]
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
        .product(name: "UrlFormEncoding", package: "Web")
      ]
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
        .product(name: "Either", package: "Prelude"),
        .product(name: "HttpPipelineTestSupport", package: "Web"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ]
    ),

    .target(
      name: "Runner",
      dependencies: [
        "PointFree",
      ]
    ),

    .target(
      name: "Server",
      dependencies: [
        "PointFree",
      ]
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
      ]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "PointFreePrelude",
        "Stripe",
        .product(name: "Either", package: "Prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "Prelude"),
      ]
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
      ]
    ),

    .target(
      name: "Styleguide",
      dependencies: [
        "FunctionalCss",
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "HtmlCssSupport", package: "Web"),
        .product(name: "Prelude", package: "Prelude"),
      ]
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
      ]
    ),

    .target(
      name: "Syndication",
      dependencies: [
        "Models",
        .product(name: "Html", package: "Html")
      ]
    ),

    .target(
      name: "Views",
      dependencies: [
        "Ccmark",
        "EmailAddress",
        "FunctionalCss",
        "PointFreeRouter",
        "Styleguide",
        "WebPreview",
        .product(name: "Css", package: "Web"),
        .product(name: "Html", package: "Html"),
        .product(name: "Prelude", package: "Prelude"),
        .product(name: "Tagged", package: "Tagged"),
        .product(name: "TaggedTime", package: "Tagged"),
      ]
    ),

    .target(
      name: "WebPreview"
    ),

  ]
)

let isOss = !FileManager.default.fileExists(
  atPath: URL(fileURLWithPath: #filePath)
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

for index in package.targets.indices {
  if package.targets[index].type != .system {
    package.targets[index].swiftSettings = .pointFreeSettings
  }
}
