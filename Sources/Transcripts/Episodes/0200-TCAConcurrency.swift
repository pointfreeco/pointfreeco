import Foundation

extension Episode {
  public static let ep200_tcaConcurrency = Episode(
    blurb: """
      This week we are releasing the biggest update to the Composable Architecture since its first
      release over 2 years ago, bringing more of Swift's modern concurrency tools to the library.
      To celebrate we will demonstrate how these tools can massively simplify a few real-world
      applications.
      """,
    codeSampleDirectory: "0200-tca-concurrency-pt6",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 598_500_000,
      downloadUrls: .s3(
        hd1080: "0200-1080p-92184c1d7852447094e38657d2e67183",
        hd720: "0200-720p-fb6dd4f34f4c406d800a6fd5041eac6a",
        sd540: "0200-540p-4c983a502e4c44f6acf385fb1d794ee9"
      ),
      vimeoId: 737_127_469
    ),
    id: 200,
    length: 65 * 60 + 26,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_659_934_800),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://www.pointfree.co/collections/concurrency"
      )
    ],
    sequence: 200,
    subtitle: nil,
    title: "Async Composable Architecture in Practice",
    trailerVideo: .init(
      bytesLength: 75_900_000,
      downloadUrls: .s3(
        hd1080: "0200-trailer-1080p-f1ef450884f74196bb8640c6e70d7bb9",
        hd720: "0200-trailer-720p-a2c63c789e4c4aaf947a44f3f1baf4b0",
        sd540: "0200-trailer-540p-37498ce18af14942bab166deff255ce3"
      ),
      vimeoId: 737_127_443
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 200)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
