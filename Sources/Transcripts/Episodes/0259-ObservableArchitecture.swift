import Foundation

extension Episode {
  public static let ep259_observableArchitecture = Episode(
    blurb: """
      We're about to completely revolutionize the Composable Architecture with Swift's new
      Observation framework! But first, a sneak peek: we'll take the public beta (available today!)
      for a spin to see how the concept of a "view store" completely vanishes when using the new
      tools.
      """,
    codeSampleDirectory: "0259-observable-architecture-pt1",
    exercises: _exercises,
    id: 259,
    length: 22 * 60 + 9,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-27")!,
    references: [
      // TODO
    ],
    sequence: 259,
    subtitle: "Sneak Peek",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 145_100_000,
      downloadUrls: .s3(
        hd1080: "0259-trailer-1080p-9d75b9bddf524178a3cad870e10f90a9",
        hd720: "0259-trailer-720p-7c1a228f8a1f4d3d8e33acc016a86bdd",
        sd540: "0259-trailer-540p-0f8f9de6079541c599819af4458faf5c"
      ),
      vimeoId: 887_062_088
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
