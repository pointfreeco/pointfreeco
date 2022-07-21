import Foundation

extension Episode {
  public static let ep198_tcaConcurrency = Episode(
    blurb: """
      A big piece is missing from our asynchronous effects story for the Composable Architecture: effects that need to send multiple actions back into the system. This week we will introduce another helper to the `Effect` type that does all that and more, all without sacrificing testability.
      """,
    codeSampleDirectory: "0198-tca-concurrency-pt4",
    exercises: _exercises,
    id: 198,
    length: 41*60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1658725200),
    references: [
      // TODO
    ],
    sequence: 198,
    subtitle: "Streams",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 41_700_000,
      downloadUrls: .s3(
        hd1080: "0198-trailer-1080p-1976151d826447de861707935479c93f",
        hd720: "0198-trailer-720p-6d231f67b4b94ac79015edd39de730a7",
        sd540: "0198-trailer-540p-7ed9c1742c9d46f59e879796fe74659b"
      ),
      vimeoId: 730055480
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
