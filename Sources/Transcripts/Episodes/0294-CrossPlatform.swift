import Foundation

extension Episode {
  public static let ep294_crossPlatform = Episode(
    blurb: """
      We will introduce UI controls and focus logic to our SwiftWasm application by leveraging a
      binding type inspired by SwiftUI, and we will see how similar even our view logic can look
      across many platforms.
      """,
    codeSampleDirectory: "0294-cross-platform-pt5",
    exercises: _exercises,
    id: 294,
    length: 36 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-09-09")!,
    references: [
      // TODO
    ],
    sequence: 294,
    subtitle: "UI Controls",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 37_900_000,
      downloadUrls: .s3(
        hd1080: "0294-trailer-1080p-e37b63c9be864057ba60394bd495df0d",
        hd720: "0294-trailer-720p-31316e0f6ca24243ac0fcf1652980fba",
        sd540: "0294-trailer-540p-9220a04b3b494932afa74b975a7d092b"
      ),
      vimeoId: 1005991847
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
