import Foundation

extension Episode {
  public static let ep230_composableNavigation = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0230-composable-navigation-pt8",
    exercises: _exercises,
    id: 230,
    length: .init(.timestamp(hours: 0, minutes: 0, seconds: 0)),  // TODO
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-10")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 230,
    subtitle: "Performance",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0230-trailer-1080p-TODO",
        hd720: "0230-trailer-720p-TODO",
        sd540: "0230-trailer-540p-TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
