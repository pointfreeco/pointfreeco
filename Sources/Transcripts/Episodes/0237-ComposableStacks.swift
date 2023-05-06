import Foundation

extension Episode {
  public static let ep237_composableStacks = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0237-composable-navigation-pt16",
    exercises: _exercises,
    id: 237,
    length: .init(.timestamp(hours: 1, minutes: 6, seconds: 29)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-30")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 237,
    subtitle: "Testing",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 53_200_000,
      downloadUrls: .s3(
        hd1080: "0237-trailer-1080p-610472473edb485bb75cc5120486d597",
        hd720: "0237-trailer-720p-704fc100b39a46289edb392732bb69ea",
        sd540: "0237-trailer-540p-0cfa52a6c6d04c4caeea35b8b4e2b005"
      ),
      vimeoId: 823_575_610
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
