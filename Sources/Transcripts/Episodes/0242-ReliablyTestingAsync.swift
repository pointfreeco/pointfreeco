import Foundation

extension Episode {
  public static let ep242_reliablyTestingAsync = Episode(
    blurb: """
      What's the point of the work we did to make async testing reliable and deterministic, and are
      we even testing reality anymore? We conclude our series by rewriting our feature and tests
      using Combine instead of async-await, and comparing both approaches.
      """,
    codeSampleDirectory: "0242-reliably-testing-async-pt5",
    exercises: _exercises,
    id: 242,
    length: .init(.timestamp(minutes: 40, seconds: 30)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-07-17")!,
    references: [
      .reliablyTestingAsync
    ],
    sequence: 242,
    subtitle: "The Point",
    title: "Reliable Async Tests",
    trailerVideo: .init(
      bytesLength: 70_300_000,
      downloadUrls: .s3(
        hd1080: "0242-trailer-1080p-736a56a8227a4950bc53e1611c5ccfa1",
        hd720: "0242-trailer-720p-2aee6f46daf44b78969bda0dabc3976f",
        sd540: "0242-trailer-540p-78f8b7c88bda4c24bed675b41139cace"
      ),
      vimeoId: 840641055
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
