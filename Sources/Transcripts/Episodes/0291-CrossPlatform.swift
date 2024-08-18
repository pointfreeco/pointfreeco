import Foundation

extension Episode {
  public static let ep291_crossPlatform = Episode(
    blurb: """
      We are going to take a Swift feature _into the browser_. We will set up a WebAssembly application from scratch, show how to run and debug it, and even set up some basic UI. And then we will integrate our existing model into it, all powered by the magic of Swift's Observation framework.
      """,
    codeSampleDirectory: "0291-cross-platform-pt2",
    exercises: _exercises,
    id: 291,
    length: 32 * 60 + 15,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-08-19")!,
    references: [
      // TODO
    ],
    sequence: 291,
    subtitle: "WebAssembly",
    title: "Cross-Platform Swift",
    trailerVideo: .init(
      bytesLength: 65_600_000,
      downloadUrls: .s3(
        hd1080: "0291-trailer-1080p-6f4603f3e083440bb6973c9ea68dc4a6",
        hd720: "0291-trailer-720p-180b489a1a504ac2b30c08f413b9a36d",
        sd540: "0291-trailer-540p-b879c1b9600442da8f20f4c56dbf5c9f"
      ),
      vimeoId: 996_298_554
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
