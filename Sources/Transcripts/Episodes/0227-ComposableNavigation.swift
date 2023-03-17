import Foundation

extension Episode {
  public static let ep227_composableNavigation = Episode(
    blurb: """
      We have a single navigation API powering alerts, dialogs, sheets, popovers, and full screen covers, but what about the prototypical form of navigation, the one that everyone thinks of when they hear "navigation"? It's time to tackle links.
      """,
    codeSampleDirectory: "0227-composable-navigation-pt6",
    exercises: _exercises,
    id: 227,
    length: .init(.timestamp(minutes: 31, seconds: 21)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-03-20")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 227,
    subtitle: "Links",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 65_100_000,
      downloadUrls: .s3(
        hd1080: "0227-trailer-1080p-302873819f2b4d2ea3701907e0cd442c",
        hd720: "0227-trailer-720p-3371a5ba9f33418489df87242086c17f",
        sd540: "0227-trailer-540p-120fa15802044474b3355e9c362f360f"
      ),
      vimeoId: 806923759
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
