import Foundation

extension Episode {
  public static let ep104_combineSchedulers_testingTime = Episode(
    blurb: """
Combine is a powerful framework and is the de facto way to power SwiftUI applications, but how does one test reactive code? We will build a view model from scratch that involves asynchrony and time-based effects and explore what it takes to exhaustively test its functionality.
""",
    codeSampleDirectory: "0104-combine-schedulers-pt1",
    exercises: _exercises,
    id: 104,
    image: "https://i.vimeocdn.com/video/903757923.jpg",
    length: 49*60 + 37,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1591246800),
    references: [
      // TODO
    ],
    sequence: 104,
    subtitle: "Testing Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 60_243_999,
      vimeoId: 425874948,
      vimeoSecret: "5c4965bc5e6a62890641051e26384fdf85c370b2"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
