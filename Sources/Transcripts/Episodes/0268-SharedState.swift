import Foundation

extension Episode {
  public static let ep268_sharedState = Episode(
    blurb: """
      Unidirectional architectures like the Composable Architecture often boast having a "single
      source of truth" for state, but this topic becomes surprisingly muddy when it comes to how to
      "share state" among many, independent features, and is one of the most common questions in the
      community. Let's explore the problem to better understand it before tackling a solution.
      """,
    codeSampleDirectory: "0268-shared-state-pt1",
    exercises: _exercises,
    id: 268,
    length: 48 * 60 + 32,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-02-26")!,
    references: [
      // TODO
    ],
    sequence: 268,
    subtitle: "The Problem",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 103_840_000,
      downloadUrls: .s3(
        hd1080: "0268-trailer-1080p-cbcbe57f992749febc36e461235a9951",
        hd720: "0268-trailer-720p-6c07239543524895832bf35f4dae6394",
        sd540: "0268-trailer-540p-1e2c3185537d44228751db9b130cc680"
      ),
      vimeoId: 916142780
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
