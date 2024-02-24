import Foundation

extension Episode {
  public static let ep268_sharedState = Episode(
    blurb: """
      We tackle one of the biggest problems when it comes to "single source of truth" applications,
      and that is: how do you share state? Let's begin by analyzing the problem, and truly
      understanding what vague mantras like "single source of truth" even mean, and then we will
      be in a good position to provide a wonderful solution.
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
      vimeoId: 916_142_780
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
