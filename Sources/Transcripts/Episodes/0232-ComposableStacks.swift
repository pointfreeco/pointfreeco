import Foundation

extension Episode {
  public static let ep232_composableStacks = Episode(
    blurb: """
      We enhance our navigation stack with a bit more complexity by adding the ability to drill down multiple layers in multiple ways: using the new navigation link API, and programmatically. We also prepare a new feature to add to the stack.
      """,
    codeSampleDirectory: "0232-composable-navigation-pt11",
    exercises: _exercises,
    id: 232,
    length: .init(.timestamp(minutes: 24, seconds: 0)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-24")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 232,
    subtitle: "Multiple Layers",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 25_900_000,
      downloadUrls: .s3(
        hd1080: "0232-trailer-1080p-9ed8e01f77894def96ada62775a01ddf",
        hd720: "0232-trailer-720p-98494062b7c6487eb179cd0c4dc05a70",
        sd540: "0232-trailer-540p-324671e42af64fbc88728a51c036ea8b"
      ),
      vimeoId: 820127290
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
