import Foundation

extension Episode {
  public static let ep379_wwdc26 = Episode(
    blurb: """
      We explore the problems not solved by the `@State` macro, why we think they _should_ be, and \
      how they were technically solved already (but with a tool you probably don't and shouldn't \
      reach for), and how a `@LazyState` macro can close the gap without introducing any \
      non-SwiftUI APIs.
      """,
    codeSampleDirectory: "0379-wwdc26-pt10",
    exercises: _exercises,
    id: 379,
    length: 25 * 60 + 53,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-31")!,
    references: [
      Episode.Reference(
        blurb: """
          A technote that covers SwiftUI's backwards compatible migration from `@State` property \
          wrapper to macro.
          """,
        link: "https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder",
        publishedAt: yearMonthDayFormatter.date(from: "2026-06-08"),
        title: "TN3211: Resolving SwiftUI source incompatibilities for State and ContentBuilder"
      )
    ],
    sequence: 379,
    socialImage: nil,
    subtitle: "The @LazyState Macro",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 34_400_000,
      downloadUrls: .s3(
        hd1080: "0379-trailer-1080p-c6fc36badc4d4c09bcd96d58f151d926",
        hd720: "0379-trailer-1080p-c6fc36badc4d4c09bcd96d58f151d926",
        sd540: "0379-trailer-1080p-c6fc36badc4d4c09bcd96d58f151d926"
      ),
      id: "0fcaf67bc0282651c2d8c9140b4b5cf4"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
