import Foundation

extension Episode {
  public static let ep233_composableStacks = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0233-composable-navigation-pt11",
    exercises: _exercises,
    id: 233,
    length: .init(.timestamp(minutes: 0, seconds: 0)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-01")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 233,
    subtitle: "Multiple Destinations",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0233-trailer-1080p-TODO",
        hd720: "0233-trailer-720p-TODO",
        sd540: "0233-trailer-540p-TODO"
      ),
      vimeoId: 0
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
