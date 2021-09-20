import Foundation

extension Episode {
  public static let ep145_tourOfIsowords = Episode(
    blurb: """
We wrap up our tour of [isowords](https://www.isowords.xyz) by showing off two powerful ways the iOS client and Swift server share code. Not only does the same code that routes server requests simultaneously power the API client, but we can write integration tests that exercise the full client–server lifecycle.
""",
    codeSampleDirectory: "0145-tour-of-isowords-pt4",
    exercises: _exercises,
    id: 145,
    image: "https://i.vimeocdn.com/video/1127151555-69917231a1926e009f296880e0b2e6c59a9cd2b215fe9f44f70d2b99ff709384-d?mw=1900&mh=1069&q=70",
    length: 53*60 + 54,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1620622800),
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
    sequence: 145,
    subtitle: "Part 4",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 40625547,
      vimeoId: 542946808,
      vimeoSecret: "35cf692ff5a3b4f6802489258c922191f8df2033"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
