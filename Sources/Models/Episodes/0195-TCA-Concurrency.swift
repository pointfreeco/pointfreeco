import Foundation

extension Episode {
  public static let ep195_tcaConcurrency = Episode(
    blurb: """
      Swift's concurrency tools were introduced relatively recently, well after the Composable Architecture was first designed, and while a few async-friendly helpers have made their way into the library, they are slightly superficial. It's time to change that, but first, let's see what can go wrong when we try to use async/await in an existing application.
      """,
    codeSampleDirectory: "0195-tca-concurrency-pt1",
    exercises: _exercises,
    fullVideo: nil,  // TODO: Make free
    id: 195,
    length: 40 * 60 + 40,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_656_910_800),
    references: [
      // TODO
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
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
