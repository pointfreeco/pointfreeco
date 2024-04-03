import Foundation

extension Episode {
  public static let ep275_sharedState = Episode(
    blurb: """
      While user defaults is convenient for persisting simple bits of state, more complex data \
      types should be saved to the file system. This can be tricky to get right, and so we take \
      the time to properly handle all of the edge cases.
      """,
    codeSampleDirectory: "0275-shared-state-pt8",
    exercises: _exercises,
    id: 275,
    length: 30 * 60 + 59,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-15")!,
    references: [
      // TODO
    ],
    sequence: 275,
    subtitle: "File Storage, Part 1",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 61_800_000,
      downloadUrls: .s3(
        hd1080: "0275-trailer-1080p-0eba22f6cb7d4fb28792bb728576fba6",
        hd720: "0275-trailer-720p-98ce0ae6e6a04f019fcbcded39dc44e9",
        sd540: "0275-trailer-540p-36732e5fbfcc4642a78c875cd79b15e4"
      ),
      vimeoId: 924_721_287
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
