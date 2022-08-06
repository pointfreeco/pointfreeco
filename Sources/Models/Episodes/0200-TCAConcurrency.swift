import Foundation

extension Episode {
  public static let ep200_tcaConcurrency = Episode(
    blurb: """
      This week we are releasing the biggest update to the Composable Architecture since its first
      release over 2 years ago, bringing more of Swift's modern concurrency tools to the library.
      To celebrate we will demonstrate how these tools can massively simplify a few real-world
      applications.
      """,
    codeSampleDirectory: "TODO",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 0, // TODO
      downloadUrls: .s3(
        hd1080: "TODO",
        hd720: "TODO",
        sd540: "TODO"
      ),
      vimeoId: 0 // TODO
    ),
    id: 200,
    length: 65 * 60 + 28,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1659934800),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
    ],
    sequence: 200,
    subtitle: nil,
    title: "Async Composable Architecture in Practice",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "TODO",
        hd720: "TODO",
        sd540: "TODO"
      ),
      vimeoId: 0  // TODO
    ),
    transcriptBlocks: .ep200_tcaConcurrency
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Array where Element == Episode.TranscriptBlock {
  public static let ep200_tcaConcurrency: Self = [
    // TODO
  ]
}
