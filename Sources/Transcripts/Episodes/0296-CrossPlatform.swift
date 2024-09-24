import Foundation

extension Episode {
  public static let ep296_crossPlatform = Episode(
    blurb: """
      We round out our series with one more feature: the ability for our users to manage a list of their favorite facts. It will allow us to explore a complex side effect, persistence, and show how the same Swift code can save and load data across iOS app launches _and_ web page refreshes.
      """,
    codeSampleDirectory: "0296-cross-platform-pt7",
    exercises: _exercises,
    id: 296,
    length: 53 * 60 + 1,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-09-23")!,
    references: [
      // TODO
    ],
    sequence: 296,
    subtitle: "Persistence",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 44_400_000,
      downloadUrls: .s3(
        hd1080: "0296-trailer-1080p-98b0c243a1f6441bbdca67402e8d8f27",
        hd720: "0296-trailer-720p-f32600f3d47b429ea4ba150a219be32c",
        sd540: "0296-trailer-540p-219859211b64401085aefd6ae44a6b2a"
      ),
      vimeoId: 1_006_155_298
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
