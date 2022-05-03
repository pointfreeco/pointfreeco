import Foundation

extension Episode {
  public static let ep104_combineSchedulers_testingTime = Episode(
    blurb: """
      Combine is a powerful framework and is the de facto way to power SwiftUI applications, but how does one test reactive code? We will build a view model from scratch that involves asynchrony and time-based effects and explore what it takes to exhaustively test its functionality.
      """,
    codeSampleDirectory: "0104-combine-schedulers-pt1",
    exercises: _exercises,
    id: 104,
    length: 49 * 60 + 37,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_591_246_800),
    references: [
      .combineSchedulers
    ],
    sequence: 104,
    subtitle: "Testing Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 60_243_999,
      downloadUrls: .s3(
        hd1080: "0104-trailer-1080p-a9fb8cbf9e194c4db0edf4a694b7ec7f",
        hd720: "0104-trailer-720p-391ffeb5d0ff4e0bbf9beb13faa71d26",
        sd540: "0104-trailer-540p-331eea43afeb4b178b0e79befb260b8c"
      ),
      vimeoId: 425_874_948
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
