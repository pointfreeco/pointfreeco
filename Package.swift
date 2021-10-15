// swift-tools-version:5.5

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
    .package(url: "https://github.com/vapor/postgres-kit", .exact("2.2.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-html", from: "0.4.0"),
    .package(url: "https://github.com/pointfreeco/swift-overture", .revision("ac1cd0f")),
    .package(url: "https://github.com/pointfreeco/swift-prelude", .revision("7ff9911")),
    .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.2"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-web", .revision("8cbec70")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0"),
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
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "PostgresKit", package: "postgres-kit"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "PostgresKit", package: "postgres-kit"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .target(
      name: "DecodableRequest",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
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
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        "PointFreePrelude",
        .product(name: "HttpPipeline", package: "swift-web"),
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .target(
      name: "Models",
      dependencies: [
        "EmailAddress",
        "GitHub",
        "Stripe",
        .product(name: "Overture", package: "swift-overture"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedTime", package: "swift-tagged"),
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
        .product(name: "Overture", package: "swift-overture"),
        .product(name: "PostgresKit", package: "postgres-kit"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
        .product(name: "TaggedTime", package: "swift-tagged"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .testTarget(
      name: "PointFreeTests",
      dependencies: [
        "EmailAddress",
        "PointFree",
        "PointFreeTestSupport",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
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
        .product(name: "Overture", package: "swift-overture"),
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
        .product(name: "UrlFormEncoding", package: "swift-web")
      ]
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
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
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
        .product(name: "SnapshotTesting", package: "SnapshotTesting"),
      ]
    ),

    .executableTarget(
      name: "Runner",
      dependencies: [
        "PointFree",
      ]
    ),

    .executableTarget(
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
        "PointFreePrelude",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .target(
      name: "StripeTestSupport",
      dependencies: [
        "Stripe",
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
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
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "HtmlCssSupport", package: "swift-web"),
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .testTarget(
      name: "StyleguideTests",
      dependencies: [
        "Styleguide",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
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
        .product(name: "Html", package: "swift-html")
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
        .product(name: "Css", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedTime", package: "swift-tagged"),
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
