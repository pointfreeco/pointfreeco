import Foundation

extension Episode {
  public static let ep266_observableArchitecture = Episode(
    blurb: """
      So what's the point of observation in the Composable Architecture? While we have seemingly
      simplified nearly every inch of the library as it interfaces with SwiftUI, let's zoom out a
      bit, explore how some integration tests that benchmark certain aspects of the library have
      changed, and migrate the Todos application we built in the very first tour of this library to
      the new tools.
      """,
    codeSampleDirectory: "0266-observable-architecture-pt8",
    exercises: _exercises,
    id: 266,
    length: 27 * 60 + 30,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-01-29")!,
    references: [
      // TODO
    ],
    sequence: 266,
    subtitle: "The Point",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 38_800_000,
      downloadUrls: .s3(
        hd1080: "0266-trailer-1080p-39bb991d521d4c79a466a4b10a91e32d",
        hd720: "0266-trailer-720p-d6f17e484e5a46e1be0d5c7031a35f1c",
        sd540: "0266-trailer-540p-39c065a02c104f3693f2296aaf9994a3"
      ),
      vimeoId: 894_667_484
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
