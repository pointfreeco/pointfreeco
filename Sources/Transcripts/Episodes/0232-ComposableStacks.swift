import Foundation

extension Episode {
  public static let ep232_composableStacks = Episode(
    blurb: """
      We enhance our navigation stack with a bit more complexity by adding the ability to drill down multiple layers in multiple ways: using the new navigation link API, and programmatically. We also prepare a new feature to add to the stack.
      """,
    codeSampleDirectory: "0232-composable-navigation-pt11",
    exercises: _exercises,
    id: 232,
    length: .init(.timestamp(minutes: 0, seconds: 0)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-24")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 232,
    subtitle: "Multiple Layers",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0232-trailer-1080p-TODO",
        hd720: "0232-trailer-720p-TODO",
        sd540: "0232-trailer-540p-TODO"
      ),
      vimeoId: 0
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
