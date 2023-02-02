import Foundation

extension Episode {
  public static let ep221_pfLive_dependenciesStacks = Episode(
    blurb: """
      Our first live stream! We talk about a few new features that made it into our Dependencies
      library when we extracted it from the Composable Architecture, live code our way through a
      stack navigation refactor of our Standups app, and answer your questions along the way!
      """,
    codeSampleDirectory: "0221-pflive-dependencies-stacks",
    exercises: _exercises,
    format: .livestream,
    id: 221,
    length: 94 * 60 + 34,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1675663200),
    references: [
      // TODO
    ],
    sequence: 221,
    subtitle: "Dependencies & Stacks",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 44_200_000,
      downloadUrls: .s3(
        hd1080: "0221-trailer-1080p-8979f93a83ee49fcad7acb291c15264c",
        hd720: "0221-trailer-720p-b434d9a0fca44f14990171929136754f",
        sd540: "0221-trailer-540p-5cd5fcac05ed4dd288f1a56a6550d01b"
      ),
      vimeoId: 795051423
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
