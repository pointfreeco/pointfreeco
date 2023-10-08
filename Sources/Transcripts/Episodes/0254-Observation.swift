import Foundation

extension Episode {
  public static let ep254_observation = Episode(
    blurb: """
      While the `@Observable` macro improves upon nearly every aspect of the `@State` and `@ObservedObject` property wrappers, it is not without its pitfalls. We will explore several gotchas that you should be aware of when adopting observation in your applications.
      """,
    codeSampleDirectory: "0254-observation-pt3",
    exercises: _exercises,
    id: 254,
    length: 49 * 60 + 44,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-10-23")!,
    references: [
      // TODO
    ],
    sequence: 254,
    subtitle: "The Gotchas",
    title: "Observation",
    trailerVideo: .init(
      bytesLength: 33_900_000,
      downloadUrls: .s3(
        hd1080: "0254-trailer-1080p-25d566ff1edb4693bcef58ca02ea5ee3",
        hd720: "0254-trailer-720p-ae470a0337c047f98e29f55aa365d05a",
        sd540: "0254-trailer-540p-c9ccc67fc5c8413997f935ca6e2f7932"
      ),
      vimeoId: 872121166
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
