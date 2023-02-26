import Foundation

extension Episode {
  public static let ep207_reducerProtocol = Episode(
    blurb: """
      Testing is a top priority in the Composable Architecture, so what does the reducer protocol
      and new dependency management system add to testing features? It allows us to codify a testing
      pattern directly into the library that makes our tests instantly stronger and more exhaustive.
      """,
    codeSampleDirectory: "0207-reducer-protocol-pt7",
    exercises: _exercises,
    id: 207,
    length: 31 * 60 + 48,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_664_773_200),
    references: [
      // TODO
    ],
    sequence: 207,
    subtitle: "Testing",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0207-trailer-1080p-7f15962b4cf647789bc38169daa0aa47",
        hd720: "0207-trailer-720p-f27b4f4c0d98438fb66cc94e36156ec0",
        sd540: "0207-trailer-540p-91429ad9910a4738b097e453ca95aa99"
      ),
      vimeoId: 747_649_741
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
