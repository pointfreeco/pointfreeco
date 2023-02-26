import Foundation

extension Episode {
  public static let ep148_derivedBehavior = Episode(
    blurb: """
      The Composable Architecture comes with several tools that aid in breaking large domains down into smaller ones, not just `pullback` and `scope`. This week we will see how it can take a small domain and embed it many times in a collection domain.
      """,
    codeSampleDirectory: "0148-derived-behavior-pt3",
    exercises: _exercises,
    id: 148,
    length: 43 * 60 + 7,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_622_437_200),
    references: [
      // TODO
    ],
    sequence: 148,
    subtitle: "Collections",
    title: "Derived Behavior",
    trailerVideo: .init(
      bytesLength: 45_849_562,
      downloadUrls: .s3(
        hd1080: "0148-trailer-1080p-681beaf7782a4f83a723df56ca93743e",
        hd720: "0148-trailer-720p-831e53eaf1ed4611ab252154d44e7346",
        sd540: "0148-trailer-540p-000d2d0aa2b8488db2fe5f4d7b2ae0ca"
      ),
      vimeoId: 556_172_803
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
