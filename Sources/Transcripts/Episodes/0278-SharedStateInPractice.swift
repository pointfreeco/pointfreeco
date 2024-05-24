import Foundation

extension Episode {
  public static let ep278_sharedStateInPractice = Episode(
    blurb: """
      We finish refactoring the SyncUps application to use the Composable Architecture's all new \
      state sharing tools. We will see that we can delete hundreds of lines of boilerplate of \
      coordination between parent and child features, _and_ we won't have to sacrifice any \
      testability, including the _exhaustive_ testability provided by the library.
      """,
    codeSampleDirectory: "0278-shared-state-in-practice-pt2",
    exercises: _exercises,
    id: 278,
    length: 35 * 60 + 59,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-05-06")!,
    references: [
      // TODO
    ],
    sequence: 278,
    subtitle: "SyncUps: Part 2",
    title: "Shared State in Practice",
    trailerVideo: .init(
      bytesLength: 46_800_000,
      downloadUrls: .s3(
        hd1080: "0278-trailer-1080p-81c8843720d04adda66bcd6c2a3b3bf3",
        hd720: "0278-trailer-720p-7a252debfb33402caa99a080aff5b435",
        sd540: "0278-trailer-540p-0ce5013146784a9f863e131d9e2fe114"
      ),
      vimeoId: 939_327_578
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
