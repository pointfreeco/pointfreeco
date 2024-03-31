import Foundation

extension Episode {
  public static let ep273_sharedState = Episode(
    blurb: """
      We have solved a lot of limitations of reference types with the `@Shared` property wrapper, and we could stop here with an incredibly useful tool. But let's take things one step further. Sometimes we want shared state to be local and explicit, but there are other times we want shared state to be ubiquitous throughout our application. Let's beef up our property wrapper to do just that.
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
    subtitle: "Ubiquity & Persistence",
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
