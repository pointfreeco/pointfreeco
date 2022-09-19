import Foundation

extension Episode {
  public static let ep205_reducerProtocol = Episode(
    blurb: """
      We begin to flesh out a new story for dependencies in the Composable Architecture, taking inspiration from SwiftUI. We will examine SwiftUI's environment and build a faithful reproduction that provides many of the same great benefits.
      """,
    codeSampleDirectory: "0205-reducer-protocol-pt5",
    exercises: _exercises,
    id: 205,
    length: 36 * 60 + 9,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_663_563_600),
    references: [
      // TODO
    ],
    sequence: 205,
    subtitle: "Dependencies, Part 1",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 83_200_000,
      downloadUrls: .s3(
        hd1080: "0205-trailer-1080p-33d80b119bb34fe7bc0b6d1a97c250d7",
        hd720: "0205-trailer-720p-fa3130e47265433bab7f4d5bc3e0d49d",
        sd540: "0205-trailer-540p-5149697b441644b7850a4be470509504"
      ),
      vimeoId: 747_451_051
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
