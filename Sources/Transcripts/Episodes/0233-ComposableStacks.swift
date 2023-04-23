import Foundation

extension Episode {
  public static let ep233_composableStacks = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0233-composable-navigation-pt12",
    exercises: _exercises,
    id: 233,
    length: .init(.timestamp(minutes: 30, seconds: 19)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-01")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 233,
    subtitle: "Multiple Destinations",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 32_200_000,
      downloadUrls: .s3(
        hd1080: "0233-trailer-1080p-0f01482baeaf4acea089212ed6e017fc",
        hd720: "0233-trailer-720p-4cd453f63561413f9a621633dac7df47",
        sd540: "0233-trailer-540p-cc0ab20937e74e9c9d7537fc9aa0e467"
      ),
      vimeoId: 820132515
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
