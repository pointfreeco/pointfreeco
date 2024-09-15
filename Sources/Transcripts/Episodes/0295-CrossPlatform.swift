import Foundation

extension Episode {
  public static let ep295_crossPlatform = Episode(
    blurb: """
      We've already covered a lot of ground and could have ended the series last week, but let's do a few more things to show just how powerful cross-platform domain modeling can be by adding a _new_ feature to our cross-platform application and see just how easy it is to integrate with SwiftUI, UIKit, _and_ WebAssembly.
      """,
    codeSampleDirectory: "0295-cross-platform-pt5",
    exercises: _exercises,
    id: 295,
    length: 27 * 60 + 3,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-09-16")!,
    references: [
      // TODO
    ],
    sequence: 295,
    subtitle: "New Features",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 68_000_000,
      downloadUrls: .s3(
        hd1080: "0295-trailer-1080p-a25ad84cc7a54f1eac307be2f0aae3c9",
        hd720: "0295-trailer-720p-a4cf4190de6645c5913404f9bd2c0549",
        sd540: "0295-trailer-540p-ae03607c03b8482f8cc408c59660ff3b"
      ),
      vimeoId: 1_006_154_596
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
