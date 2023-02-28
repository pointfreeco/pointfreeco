import Foundation

extension Episode {
  public static let ep195_tcaConcurrency = Episode(
    blurb: """
      The Composable Architecture's fundamental unit of effect is modeled on Combine publishers because it was the simplest and most modern asynchrony tool available at the time. Now Swift has native concurrency tools, and so we want to make use of those tools in the library. But first, let's see what can go wrong if we try to naively use async/await in an existing application.
      """,
    codeSampleDirectory: "0195-tca-concurrency-pt1",
    exercises: _exercises,
    fullVideo: .ep195_tcaConcurrency,
    id: 195,
    length: 40 * 60 + 40,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_656_910_800),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
    ],
    sequence: 195,
    subtitle: "The Problem",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 75_900_000,
      downloadUrls: .s3(
        hd1080: "0195-trailer-1080p-ffad0c87c51448018313bc66e146e106",
        hd720: "0195-trailer-720p-a457f5a6becc4d85978883eb03fad7b4",
        sd540: "0195-trailer-540p-512c522b100c41c1ad7da8abd650f9ea"
      ),
      vimeoId: 726_095_967
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 195)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep195_tcaConcurrency = Self(
    bytesLength: 399_300_000,
    downloadUrls: .s3(
      hd1080: "0195-1080p-55916e2ebde441f2b0eb84bd4032ac94",
      hd720: "0195-720p-c0cad256734040feb82d4fb5f4f126e6",
      sd540: "0195-540p-f3063a73e05d43819c615860a5012daa"
    ),
    vimeoId: 726_096_095
  )
}
