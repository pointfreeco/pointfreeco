import Foundation

extension Episode {
  public static let ep143_tourOfIsowords = Episode(
    blurb: """
Let's dive deeper into the [isowords](https://www.isowords.xyz) code base. We'll explore how the Composable Architecture and modularization unlocked many things, including the ability to add an onboarding experience without any changes to feature code, an App Clip, and even App Store assets.
""",
    codeSampleDirectory: "0143-tour-of-isowords-pt2",
    exercises: _exercises,
    id: 143,
    image: "https://i.vimeocdn.com/video/1114888815.jpg",
    length: 57*60 + 1,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1618808400),
    references: [
      .isowords,
      .isowordsGitHub,
      .theComposableArchitecture,
      reference(
        forCollection: .composableArchitecture,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/composable-architecture"
      )
    ],
    sequence: 143,
    subtitle: "Part 2",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 75022146,
      vimeoId: 538473438,
      vimeoSecret: "eb1165ac1b8d25a2f6119dfeabe1f1e71a0a5c32"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
