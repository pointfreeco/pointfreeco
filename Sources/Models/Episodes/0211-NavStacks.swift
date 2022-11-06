import Foundation

extension Episode {
  public static let ep211_navStacks = Episode(
    blurb: """
      A year ago we dove deep into the topic of navigation through SwiftUI’s tool. Then this WWDC Apple deprecated many of them, replacing them with a brand new suite. To make sense of these changes, let's recap what we built over those many episodes, and why.
      """,
    codeSampleDirectory: "0211-navigation-stacks-pt1",
    exercises: _exercises,
    id: 211,
    length: 49 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_667_800_800),
    references: [
      .swiftUINav
    ],
    sequence: 211,
    subtitle: "Recap",
    title: "Navigation Stacks",
    trailerVideo: .init(
      bytesLength: 76_500_000,
      downloadUrls: .s3(
        hd1080: "0211-trailer-1080p-2fd0e1ef8b8d4f7f9a79bfd9180146d7",
        hd720: "0211-trailer-720p-3786b076ae6246ddb3dcc77c1677c87b",
        sd540: "0211-trailer-540p-753a0c197f3740fe93d767bd902ce9c7"
      ),
      vimeoId: 767_694_109
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
  // 1. Better model and control the use of user defaults in `FeatureModel.task`
]
