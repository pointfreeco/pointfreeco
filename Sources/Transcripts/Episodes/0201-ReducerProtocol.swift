import Foundation

extension Episode {
  public static let ep201_reducerProtocol = Episode(
    blurb: """
      The Composable Architecture was first released over two years ago, and the core ergonomics haven't changed much since then. It's time to change that: we are going to improve the ergonomics of nearly every facet of creating a feature with the library, and make all new patterns possible.
      """,
    codeSampleDirectory: "0201-reducer-protocol-pt1",
    exercises: _exercises,
    id: 201,
    length: 39 * 60 + 53,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_661_144_400),
    references: [
      // TODO
    ],
    sequence: 201,
    subtitle: "The Problem",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 101_300_000,
      downloadUrls: .s3(
        hd1080: "0201-trailer-1080p-1d183f8801624cc8a5b6eef34802f030",
        hd720: "0201-trailer-720p-0f909c5fb9494f8493694f7569b401bb",
        sd540: "0201-trailer-540p-459b52d3fbe0464e95b5d8d7a2dfb9d0"
      ),
      vimeoId: 740_853_246
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 201)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep201_reducerProtocol = Self(
    bytesLength: 503_500_000,
    downloadUrls: .s3(
      hd1080: "0201-1080p-6b25542568b94969877d1ab818b83fa9",
      hd720: "0201-720p-7f0085c2954d43808ca6b7dbd5185355",
      sd540: "0201-540p-c8307966c81b41ddb4f210fb32bfbf7e"
    ),
    vimeoId: 740_853_322
  )
}
