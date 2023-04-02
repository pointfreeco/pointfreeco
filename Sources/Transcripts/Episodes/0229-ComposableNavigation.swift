import Foundation

extension Episode {
  public static let ep229_composableNavigation = Episode(
    blurb: """
      We now support many different forms of navigation in the Composable Architecture, but if used naively, they open us up to invalid states, like being navigated to several screens at a time. We’ll correct this with the help of Swift's enums.
      """,
    codeSampleDirectory: "0229-composable-navigation-pt8",
    exercises: _exercises,
    id: 229,
    length: .init(.timestamp(hours: 1, minutes: 9, seconds: 56)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-03")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 229,
    subtitle: "Correctness",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 107_900_000,
      downloadUrls: .s3(
        hd1080: "0229-trailer-1080p-18766bb912394d458b26e8859c1f96c2",
        hd720: "0229-trailer-720p-43c4b25c41a946b2908943390d6e4a2b",
        sd540: "0229-trailer-540p-1ff107eb3ac84ec1b3ce04772d8cb63e"
      ),
      vimeoId: 813602202
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
