import Foundation

extension Episode {
  public static let ep226_composableNavigation = Episode(
    blurb: """
      Let's prepare to delete a *lot* of code. The navigation APIs we've built so far to drive alerts, dialogs, and sheets all have more or less the same shape. We can unify them all in a single package that can also be applied to popovers, fullscreen covers, and more!
      """,
    codeSampleDirectory: "0226-composable-navigation-pt5",
    exercises: _exercises,
    id: 226,
    length: .init(.timestamp(minutes: 28, seconds: 27)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-03-13")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 226,
    subtitle: "Unification",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 56_400_000,
      downloadUrls: .s3(
        hd1080: "0226-trailer-1080p-8d5dc8598c4346e5854d98bee01e935f",
        hd720: "0226-trailer-720p-c70d44619b194a559dbcbed060fa0f02",
        sd540: "0226-trailer-540p-f1029ddcac8c466faed5c8f04df01518"
      ),
      vimeoId: 806_916_464
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
