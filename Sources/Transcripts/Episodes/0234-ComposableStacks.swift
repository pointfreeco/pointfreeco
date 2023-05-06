import Foundation

extension Episode {
  public static let ep234_composableStacks = Episode(
    blurb: """
      We begin designing brand new navigation stack tools for the Composable Architecture to solve \
      *all* of the problems we encountered when shoehorning stack navigation into the existing \
      tools, and more.
      """,
    codeSampleDirectory: "0234-composable-navigation-pt13",
    exercises: _exercises,
    id: 234,
    length: .init(.timestamp(minutes: 38, seconds: 20)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-08")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 234,
    subtitle: "Action Ergonomics",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 32_300_000,
      downloadUrls: .s3(
        hd1080: "0234-trailer-1080p-766502a2d4b749e4b25d38b84286fa09",
        hd720: "0234-trailer-720p-469e2dd2b34642fda233b16ebe451820",
        sd540: "0234-trailer-540p-f774e4e966c3409fa23dde177453f3c7"
      ),
      vimeoId: 822988109
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
