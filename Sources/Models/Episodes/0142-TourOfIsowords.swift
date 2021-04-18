import Foundation

extension Episode {
  public static let ep142_tourOfIsowords = Episode(
    blurb: """
In past episodes we took a peek behind the curtains of our iOS game, [isowords](https://www.isowords.xyz). Now it's time to draw them wide and dive deep! We will show how to check out and run the project and explore how the Composable Architecture powers the entire application.
""",
    codeSampleDirectory: "0142-tour-of-isowords-pt1",
    exercises: _exercises,
    id: 142,
    image: "https://i.vimeocdn.com/video/TODO.jpg",
    length: 37*60 + 18,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1618808400),
    references: [
      .isowords,
      .isowordsGitHub,
      .theComposableArchitecture,
    ],
    sequence: 142,
    subtitle: "Part 1",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 33101299,
      vimeoId: 537523006,
      vimeoSecret: "e3fa21aea9227b89b563189109a851e6f6de8415"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
