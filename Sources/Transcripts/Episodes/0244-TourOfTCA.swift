import Foundation

extension Episode {
  public static let ep244_tourOfTCA = Episode(
    alternateSlug: "tour-of-the-composable-architecture-1-0-standups-part-1",
    blurb: """
      We continue our tour of the Composable Architecture 1.0 by rebuilding one of Apple's most
      complex sample projects: [Scrumdinger](https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger).
      We will create our own "Standups" app using the tools of the Composable Architecture.
      """,
    codeSampleDirectory: "0244-tca-tour-pt2",
    exercises: _exercises,
    id: 244,
    length: .init(.timestamp(minutes: 50, seconds: 30)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-08-07")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
    ],
    sequence: 244,
    subtitle: "Introducing Standups",
    title: "Tour of the Composable Architecture 1.0",
    trailerVideo: .init(
      bytesLength: 38_300_000,
      downloadUrls: .s3(
        hd1080: "0244-trailer-1080p-e39da59d11524279927eb83190c0e569",
        hd720: "0244-trailer-720p-cae7ab3c332e49e2a7c7758682815ac4",
        sd540: "0244-trailer-540p-aa03c1a4f09d40408b39ab2a10ae5c31"
      ),
      vimeoId: 851_986_054
    )
  )
}

private let _exercises: [Episode.Exercise] = []
