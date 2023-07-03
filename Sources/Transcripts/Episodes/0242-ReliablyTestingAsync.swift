import Foundation

extension Episode {
  public static let ep242_reliablyTestingAsync = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0242-reliably-testing-async-pt5",
    exercises: _exercises,
    id: 242,
    length: .init(.timestamp(minutes: 0, seconds: 0)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-17")!,
    references: [
      .reliablyTestingAsync
    ],
    sequence: 242,
    subtitle: "TODO",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 0,
      downloadUrls: .s3(
        hd1080: "0242-trailer-1080p-TODO",
        hd720: "0242-trailer-720p-TODO",
        sd540: "0242-trailer-540p-TODO"
      ),
      vimeoId: 0
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
