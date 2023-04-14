import Foundation

extension Episode {
  public static let ep231_composableStacks = Episode(
    blurb: """
      It's finally time to tackle navigation stacks in the Composable Architecture! They are a powerful, new tool in SwiftUI and stray a bit from all the other forms tree-based of navigation we've explored. Let's compare the two styles
      """,
    codeSampleDirectory: "0231-composable-navigation-pt10",
    exercises: _exercises,
    id: 231,
    length: .init(.timestamp(minutes: 45, seconds: 54)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-04-17")!,
    references: [
      .composableNavigationBetaDiscussion,
    ],
    sequence: 231,
    subtitle: "vs Trees",
    title: "Composable Stacks",
    trailerVideo: .init(
      bytesLength: 61_700_000,
      downloadUrls: .s3(
        hd1080: "0231-trailer-1080p-2239cd08cbb94ba6a8a11511eee86641",
        hd720: "0231-trailer-720p-c6037fb3c20e4a148989f8b6729e69cf",
        sd540: "0231-trailer-540p-b5fe7df9b8d644f889dff71c3c1b99ec"
      ),
      vimeoId: 817_042_538
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
