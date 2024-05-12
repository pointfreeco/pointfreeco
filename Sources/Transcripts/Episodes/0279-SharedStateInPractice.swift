import Foundation

extension Episode {
  public static let ep279_sharedStateInPractice = Episode(
    blurb: """
      Let's apply the Composable Architecture's new state sharing tools to something even more \
      real world: our open source word game, isowords. It currently models its user settings as a \
      cumbersome dependency that requires a lot of code to keep features in sync when settings \
      change. We should be able to greatly simplify things with the `@Shared` property wrapper.
      """,
    codeSampleDirectory: "0279-shared-state-in-practice-pt3",
    exercises: _exercises,
    id: 279,
    length: 25 * 60 + 39,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-05-13")!,
    references: [
      // TODO
    ],
    sequence: 279,
    subtitle: "isowords, Part 1",
    title: "Shared State in Practice",
    trailerVideo: .init(
      bytesLength: 86_800_000,
      downloadUrls: .s3(
        hd1080: "0279-trailer-1080p-2defb305270943d799380fa564ff1e11",
        hd720: "0279-trailer-720p-e39db49437bb466082d835584832e417",
        sd540: "0279-trailer-540p-b40e76c2e9354f2b8319f0f0bac4344b"
      ),
      vimeoId: 939_366_699
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
