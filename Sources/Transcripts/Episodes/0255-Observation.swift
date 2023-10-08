import Foundation

extension Episode {
  public static let ep255_observation = Episode(
    blurb: """
      We've explored the present state of observation in Swift, so what's the future have in store? Currently, observation is restricted to classes, while one of Swift's most celebrated features, value types, is left out in the cold. Let's explore a future in which observation is extended to value types.
      """,
    codeSampleDirectory: "0255-observation-pt4",
    exercises: _exercises,
    id: 255,
    length: 30 * 60 + 33,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-10-30")!,
    references: [
      // TODO
    ],
    sequence: 255,
    subtitle: "The Future",
    title: "Observation",
    trailerVideo: .init(
      bytesLength: 93_900_000,
      downloadUrls: .s3(
        hd1080: "0255-trailer-1080p-f578bb4e76224e2d9f09a23e2c9836e1",
        hd720: "0255-trailer-720p-1258e1ff7b3f480e9db5f53dc12e072d",
        sd540: "0255-trailer-540p-bc2c5d2640d54c3b86b3131e9b1e51e6"
      ),
      vimeoId: 872124788
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
