import Foundation

extension Episode {
  public static let ep147_derivedBehavior = Episode(
    blurb: """
Let's rebuild last week's moderately complex SwiftUI app in the Composable Architecture to explore its built-in solution for breaking larger domains down into smaller ones using the `scope` operator. We'll then explore a few examples of `scope` in the wild.
""",
    codeSampleDirectory: "0147-derived-behavior-pt2",
    exercises: _exercises,
    id: 147,
    length: 45*60 + 17,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1621832400),
    references: [
      // TODO
    ],
    sequence: 147,
    subtitle: "Composable Architecture",
    title: "Derived Behavior",
    trailerVideo: .init(
      bytesLength: 75752962,
      downloadUrls: .s3(
        hd1080: "0147-trailer-1080p-043ead40912440c597750885f5cad11b",
        hd720: "0147-trailer-720p-dbef0232b90d4c998fc76ae0e5276e88",
        sd540: "0147-trailer-540p-d195abdbd11c4b6cbc8295a6f8ed8c08"
      ),
      vimeoId: 549286918
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
