import Foundation

extension Episode {
  public static let ep235_composableStacks = Episode(
    blurb: """
      We introduce a complementary `StackState` wrapper to our navigation tools to solve a few
      issues that came from repurposing the identified array type. Once implemented and integrated,
      we will put these tools' superpowers to work by implementing two new features.
      """,
    codeSampleDirectory: "0235-composable-navigation-pt14",
    exercises: _exercises,
    id: 235,
    length: .init(.timestamp(minutes: 59, seconds: 33)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-05-15")!,
    references: [
      .composableNavigationBetaDiscussion
    ],
    sequence: 235,
    subtitle: "State Ergonomics",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 84_500_000,
      downloadUrls: .s3(
        hd1080: "0235-trailer-1080p-8a66c7c40488484dbe7ac29ef711776f",
        hd720: "0235-trailer-720p-e94a84b7e0414c99bd4fe1944fbb2033",
        sd540: "0235-trailer-540p-ca44b21b3e664edfa56d09fddc6a89f9"
      ),
      vimeoId: 823_144_946
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
