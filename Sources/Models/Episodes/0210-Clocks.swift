import Foundation

extension Episode {
  public static let ep210_clocks = Episode(
    blurb: """
      With "immediate" and "unimplemented" conformances of the Clock protocol under our belt, let's build something more complicated: a "test" clock that can tell time when and how to flow. We'll explore why we'd ever need such a thing and what it unlocks.
      """,
    codeSampleDirectory: "0210-clocks-pt2",
    exercises: _exercises,
    id: 210,
    length: 41 * 60 + 56,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1666587600),
    references: [
      .se0329_clockInstantDuration,
      .init(
        author: "Brandon Williams and Stephen Celis",
        blurb: """
          A Swift forum post in which we highlight a problem with testing Swift concurrency with the tools that ship today.
          """,
        link: "https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304",
        publishedAt: referenceDateFormatter.date(from: "2022-05-13"),
        title: "Reliably testing code that adopts Swift Concurrency"
      )
    ],
    sequence: 210,
    subtitle: "Controlling Time",
    title: "Clocks",
    trailerVideo: .init(
      bytesLength: 58_500_000,
      downloadUrls: .s3(
        hd1080: "0210-trailer-1080p-47acf5fa036048eb97ee3e93b615d4a6",
        hd720: "0210-trailer-720p-3ffcc4f611d6407db63e8486c519f6e8",
        sd540: "0210-trailer-540p-8fc46012a00c4ad6a38131a1f51046d7"
      ),
      vimeoId: 756541991
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
  // 1. Better model and control the use of user defaults in `FeatureModel.task`
]
