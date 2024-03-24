import Foundation

extension Episode {
  public static let ep272_sharedState = Episode(
    blurb: """
      We will employ `@Shared`'s new testing capabilities in a complex scenario: a sign up flow. We
      will see how a deeply nested integration of features all sharing the same state can be tested
      simply, and we will see how we can leverage the same tricks employed by the test store to add
      debug tools to reducers using shared state.
      """,
    codeSampleDirectory: "0272-shared-state-pt5",
    exercises: _exercises,
    id: 272,
    length: 32 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-03-25")!,
    references: [
      // TODO
    ],
    sequence: 272,
    subtitle: "Testing, Part 2",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 28_900_000,
      downloadUrls: .s3(
        hd1080: "0272-trailer-1080p-738d0a2077b44f698985601159d5b279",
        hd720: "0272-trailer-720p-e5b66985081348b589c4486a498fe4c9",
        sd540: "0272-trailer-540p-0666101e2dfb4df7b5a257112c19766e"
      ),
      vimeoId: 922_991_093
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
