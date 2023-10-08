import Foundation

extension Episode {
  public static let ep252_observation = Episode(
    blurb: """
      It's time to dive deep into Swift's new observation tools. But to start we will take a look at the tools SwiftUI historically provided, including the `@State` and `@ObservedObject` property wrappers, how they behave and where they fall short, so that we can compare them to the new `@Observable` macro.
      """,
    codeSampleDirectory: "0252-observation-pt1",
    exercises: _exercises,
    id: 252,
    length: 42 * 60 + 5,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-10-09")!,
    references: [
      // TODO
    ],
    sequence: 252,
    subtitle: "The Past",
    title: "Observation",
    trailerVideo: .init(
      bytesLength: 137_100_000,
      downloadUrls: .s3(
        hd1080: "0252-trailer-1080p-fb7ba5f102e040bba63e588c2c03f6e6",
        hd720: "0252-trailer-720p-4a9443c9d79647debd1dc23114f3b263",
        sd540: "0252-trailer-540p-b716783e165240bf88437e71efe7c2b8"
      ),
      vimeoId: 872_023_591
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
