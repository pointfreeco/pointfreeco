import Foundation

extension Episode {
  public static let ep273_sharedState = Episode(
    alternateSlug: "shared-state-ubiquity-persistence",
    blurb: """
      Let's enhance the `@Shared` property wrapper with the concept of persistence. We will begin \
      with user defaults, which is the simplest form of persistence on Apple's platforms, and \
      that will set the stage for more complex forms of persistence in the future.
      """,
    codeSampleDirectory: "0273-shared-state-pt6",
    exercises: _exercises,
    id: 273,
    length: 41 * 60 + 10,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-01")!,
    references: [
      // TODO
    ],
    sequence: 273,
    subtitle: "User Defaults, Part 1",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 83_800_000,
      downloadUrls: .s3(
        hd1080: "0273-trailer-1080p-65968d162a3b4aceadc12536ac480ffb",
        hd720: "0273-trailer-720p-cf662cf56df54c439192568118d27a30",
        sd540: "0273-trailer-540p-ccf24d44f8d9400898427e903631f06b"
      ),
      vimeoId: 924_700_451
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
