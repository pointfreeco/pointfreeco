import Foundation

extension Episode {
  public static let ep224_composableNavigation = Episode(
    blurb: """
      We tackle a more complex form of navigation: sheets! We'll start with the tools the Composable
      Architecture ships today before greatly simplifying them, taking inspiration from the tools we
      built for alerts and dialogs.
      """,
    codeSampleDirectory: "0224-composable-navigation-pt3",
    exercises: _exercises,
    id: 224,
    length: .init(.timestamp(hours: 1, minutes: 14, seconds: 12)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-27")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 224,
    subtitle: "Sheets",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 103_700_000,
      downloadUrls: .s3(
        hd1080: "0224-trailer-1080p-8205937b61ec4905bff1002ccdc3c849",
        hd720: "0224-trailer-720p-4adae7837b7a4a6ea70a75f70b8e6df1",
        sd540: "0224-trailer-540p-97fb9845e53e42f782b6c7d4546b8395"
      ),
      vimeoId: 800_922_183
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
