import Foundation

extension Episode {
  public static let ep95_adaptiveStateManagement_pt2 = Episode(
    blurb: """
      There's a potential performance problem lurking in the Composable Architecture, and it's time to finally solve it. But, in doing so, we will stumble upon a wonderful way to make the architecture adaptive to many more situations.
      """,
    codeSampleDirectory: "0095-adaptive-state-management-pt2",
    exercises: _exercises,
    id: 95,
    length: 40 * 60 + 25,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_584_939_600),
    references: [
      // TODO
    ],
    sequence: 95,
    subtitle: "State",
    title: "Adaptive State Management",
    trailerVideo: .init(
      bytesLength: 42_191_494,
      downloadUrls: .s3(
        hd1080: "0095-trailer-1080p-eb6c859692234de584a80838c56060d9",
        hd720: "0095-trailer-720p-64de6a8390684f699bac3c884268b475",
        sd540: "0095-trailer-540p-e2c9a1982523463bac4540d60b4a96d3"
      ),
      vimeoId: 399_723_100
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
  // TODO: Exercise for computed property state
]
