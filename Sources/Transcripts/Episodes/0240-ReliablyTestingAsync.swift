import Foundation

extension Episode {
  public static let ep240_reliablyTestingAsync = Episode(
    blurb: """
      We dive into Apple's Async Algorithms package to explore some advanced usages of Swift's concurrency runtime, including a particular tool we can leverage to bend the will of async code to our advantage in tests.
      """,
    codeSampleDirectory: "0240-reliably-testing-async-pt3",
    exercises: _exercises,
    id: 240,
    length: .init(.timestamp(minutes: 23, seconds: 42)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-03")!,
    references: [
      .swiftAsyncAlgorithms,
      .reliablyTestingAsync,
    ],
    sequence: 240,
    subtitle: "😳",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 87_200_000,
      downloadUrls: .s3(
        hd1080: "0240-trailer-1080p-6960af241cce4368bfbecd8406f30964",
        hd720: "0240-trailer-720p-77deee29ebd24081bad1cf0d20880c2c",
        sd540: "0240-trailer-540p-51e5b69c0cbf478bba9315d6f32ee351"
      ),
      vimeoId: 840142804
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
