// swift-tools-version:5.7

import Foundation
import PackageDescription

var package = Package(
  name: "PointFree",
  platforms: [
    .macOS(.v12)
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
    .library(name: "LoggingDependencies", targets: ["LoggingDependencies"]),
    .library(name: "Mailgun", targets: ["Mailgun"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "ModelsTestSupport", targets: ["ModelsTestSupport"]),
    .library(name: "NIODependencies", targets: ["NIODependencies"]),
    .library(name: "PointFree", targets: ["PointFree"]),
    .library(name: "PointFreeDependencies", targets: ["PointFreeDependencies"]),
    .library(name: "PointFreePrelude", targets: ["PointFreePrelude"]),
    .library(name: "PointFreeRouter", targets: ["PointFreeRouter"]),
    .library(name: "PointFreeTestSupport", targets: ["PointFreeTestSupport"]),
    .library(name: "Stripe", targets: ["Stripe"]),
    .library(name: "StripeTestSupport", targets: ["StripeTestSupport"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "Syndication", targets: ["Syndication"]),
    .library(name: "TranscriptParser", targets: ["TranscriptParser"]),
    .library(name: "Transcripts", targets: ["Transcripts"]),
    .library(name: "PrivateTranscripts", targets: ["PrivateTranscripts"]),
    .library(name: "Views", targets: ["Views"]),
    .library(name: "VimeoClient", targets: ["VimeoClient"]),
    .library(name: "WebPreview", targets: ["WebPreview"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/ianpartridge/swift-backtrace", exact: "1.3.1"),
    .package(url: "https://github.com/swift-server/async-http-client", from: "1.13.2"),
    .package(url: "https://github.com/vapor/postgres-kit", exact: "2.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.7.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.3"),
    .package(url: "https://github.com/pointfreeco/swift-html", revision: "14d01d1"),
    .package(url: "https://github.com/pointfreeco/swift-overture", revision: "ac1cd0f"),
    .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.12.0"),
    .package(url: "https://github.com/pointfreeco/swift-prelude", revision: "55969fa"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", branch: "async"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-web", revision: "3fa0e16"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.8.1"),
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "PostgresKit", package: "postgres-kit"),
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
        .product(name: "Tagged", package: "swift-tagged")
      ]
    ),

    .target(
      name: "EmailAddress",
      dependencies: [
        .product(name: "Tagged", package: "swift-tagged")
      ]
    ),

    .target(
      name: "FoundationPrelude",
      dependencies: [
        "LoggingDependencies",
        "NIODependencies",
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "Dependencies", package: "swift-dependencies"),
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
        .product(name: "Prelude", package: "swift-prelude"),
      ]
    ),

    .testTarget(
      name: "FunctionalCssTests",
      dependencies: [
        "FunctionalCss",
        "PointFreeTestSupport",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__"
      ]
    ),

    .target(
      name: "GitHub",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        "PointFreePrelude",
        .product(name: "Dependencies", package: "swift-dependencies"),
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
        "PointFreeTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__"
      ]
    ),

    .target(
      name: "LoggingDependencies",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
      ]
    ),

    .target(
      name: "Mailgun",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        "LoggingDependencies",
        "Models",
        "PointFreePrelude",
        .product(name: "Dependencies", package: "swift-dependencies"),
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
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Overture", package: "swift-overture"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedTime", package: "swift-tagged"),
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
        "PointFreeTestSupport",
      ]
    ),

    .target(
      name: "NIODependencies",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOEmbedded", package: "swift-nio"),
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
        "NIODependencies",
        "PointFreeDependencies",
        "PointFreeRouter",
        "PointFreePrelude",
        "PrivateTranscripts",
        "Stripe",
        "Styleguide",
        "Syndication",
        "Views",
        "VimeoClient",
        .product(name: "Backtrace", package: "swift-backtrace"),
        .product(name: "Css", package: "swift-web"),
        .product(name: "CssReset", package: "swift-web"),
        .product(name: "Dependencies", package: "swift-dependencies"),
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

    .target(
      name: "PointFreeDependencies",
      dependencies: [
        "Models",
        "PointFreeRouter",
        .product(name: "Dependencies", package: "swift-dependencies"),
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
      name: "PointFreeRouter",
      dependencies: [
        "EmailAddress",
        "Models",
        "VimeoClient",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "TaggedMoney", package: "swift-tagged"),
        .product(name: "UrlFormEncoding", package: "swift-web"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),

    .testTarget(
      name: "PointFreeRouterTests",
      dependencies: [
        "Models",
        "PointFreeRouter",
        "PointFreeTestSupport",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Overture", package: "swift-overture"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
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
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Either", package: "swift-prelude"),
        .product(name: "HttpPipelineTestSupport", package: "swift-web"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),

    .executableTarget(
      name: "Runner",
      dependencies: [
        "PointFree"
      ]
    ),

    .executableTarget(
      name: "Server",
      dependencies: [
        "PointFree"
      ]
    ),

    .target(
      name: "Stripe",
      dependencies: [
        "DecodableRequest",
        "EmailAddress",
        "FoundationPrelude",
        "LoggingDependencies",
        "PointFreePrelude",
        .product(name: "Dependencies", package: "swift-dependencies"),
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
        "PointFreeTestSupport",
        "Stripe",
        "StripeTestSupport",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__"
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
        "PointFreeTestSupport",
        "Styleguide",
        .product(name: "CssTestSupport", package: "swift-web"),
        .product(name: "HtmlSnapshotTesting", package: "swift-html"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__"
      ]
    ),

    .target(
      name: "Syndication",
      dependencies: [
        "Models",
        .product(name: "Html", package: "swift-html"),
      ]
    ),

    .target(
      name: "TranscriptParser",
      dependencies: [
        "Models",
        .product(name: "Parsing", package: "swift-parsing"),
      ]
    ),

    .testTarget(
      name: "TranscriptParserTests",
      dependencies: [
        "TranscriptParser",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),

    .target(
      name: "Transcripts",
      dependencies: [
        "PrivateTranscripts",
        "TranscriptParser",
      ],
      resources: transcripts()
    ),

    .testTarget(
      name: "TranscriptsTests",
      dependencies: [
        "Transcripts",
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),

    .target(
      name: "PrivateTranscripts",
      dependencies: [
        "Models",
        "TranscriptParser",
      ],
      exclude: [".git", ".gitignore"],
      resources: privateTranscripts()
    ),

    .target(
      name: "VimeoClient",
      dependencies: [
        "DecodableRequest",
        "FoundationPrelude",
        .product(name: "Tagged", package: "swift-tagged"),
      ]
    ),

    .target(
      name: "Views",
      dependencies: [
        "Ccmark",
        "EmailAddress",
        "FunctionalCss",
        "PointFreeDependencies",
        "PointFreeRouter",
        "Styleguide",
        "Transcripts",
        "VimeoClient",
        "WebPreview",
        .product(name: "Css", package: "swift-web"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Html", package: "swift-html"),
        .product(name: "HttpPipeline", package: "swift-web"),
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
    .appendingPathComponent("PrivateTranscripts")
    .appendingPathComponent(".git")
    .path
)

extension SwiftSetting {
  static let warnLongExpressionTypeChecking = unsafeFlags(
    [
      //      "-Xfrontend", "-warn-long-expression-type-checking=200",
      //      "-Xfrontend", "-warn-long-function-bodies=200",
    ],
    .when(configuration: .debug)
  )
}

extension Array where Element == SwiftSetting {
  static let pointFreeSettings: Array =
    isOss
    ? [.define("OSS"), .warnLongExpressionTypeChecking]
    : [.warnLongExpressionTypeChecking]
}

for index in package.targets.indices {
  if package.targets[index].type != .system {
    package.targets[index].swiftSettings = .pointFreeSettings
  }
}

func transcripts() -> [Resource] {
  let transcriptsDirectoryPath = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("Sources")
    .appendingPathComponent("Transcripts")
    .appendingPathComponent("Resources")
    .path

  return try! FileManager.default.contentsOfDirectory(atPath: transcriptsDirectoryPath)
    .map { .copy("Resources/\($0)") }
}

func privateTranscripts() -> [Resource] {
  let transcriptsDirectoryPath = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("Sources")
    .appendingPathComponent("PrivateTranscripts")
    .appendingPathComponent("Resources")
    .path

  return try! FileManager.default.contentsOfDirectory(atPath: transcriptsDirectoryPath)
    .map { .copy("Resources/\($0)") }
}
