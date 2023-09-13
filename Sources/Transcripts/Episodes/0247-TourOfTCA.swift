import Foundation

extension Episode {
  public static let ep247_tourOfTCA = Episode(
    alternateSlug: "tour-of-the-composable-architecture-1-0-correctness",
    blurb: """
      We'll learn how to precisely model navigation in the Composable Architecture using an enum to eliminate impossible runtime states at compile time. And we'll begin to implement the app's most complex screen and most complex dependency: the record meeting view and the speech client.
      """,
    codeSampleDirectory: "0247-tca-tour-pt5",
    exercises: _exercises,
    id: 247,
    length: .init(.timestamp(minutes: 36, seconds: 0)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-08-28")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
    ],
    sequence: 247,
    subtitle: "Domain Modeling",
    title: "Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 42_700_000,
      downloadUrls: .s3(
        hd1080: "0247-trailer-1080p-766fed06310248629c83833a7cd30fed",
        hd720: "0247-trailer-720p-3bbdc3efc34843bbb9e1b72be66d4116",
        sd540: "0247-trailer-540p-6433bf5de13446b9a2b419b60f4517d0"
      ),
      vimeoId: 852_443_799
    )
  )
}

private let _exercises: [Episode.Exercise] = []
