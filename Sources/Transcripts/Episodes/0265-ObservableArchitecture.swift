import Foundation

extension Episode {
  public static let ep265_observableArchitecture = Episode(
    blurb: """
      We have iterated on how bindings work in the Composable Architecture many times, but have
      never been fully happy with the results. With Observation, that all changes. By eliminating
      view stores and observing store state directly, we are free to totally reimagine bindings in
      the Composable Architecture, and get rid of even more concepts in the process.
      """,
    codeSampleDirectory: "0265-observable-architecture-pt7",
    exercises: _exercises,
    id: 265,
    length: 19 * 60 + 7,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-01-22")!,
    references: [
      // TODO
    ],
    sequence: 265,
    subtitle: "Observing Bindings",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 56_100_000,
      downloadUrls: .s3(
        hd1080: "0265-trailer-1080p-078b4abf36e2484ea414d043cd4108f6",
        hd720: "0265-trailer-720p-b379813e96d4420392a16d36c7236f26",
        sd540: "0265-trailer-540p-d2c136b6f1da4d7b9fb4348787f673df"
      ),
      vimeoId: 894665032
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
