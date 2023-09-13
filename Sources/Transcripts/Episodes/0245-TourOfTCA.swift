import Foundation

extension Episode {
  public static let ep245_tourOfTCA = Episode(
    alternateSlug: "tour-of-the-composable-architecture-1-0-navigation",
    blurb: """
      With the standups list and standup form features ready, it's time to integrate them together using the Composable Architecture's navigation tools. We will make it so you can add and edit standups via a sheet, and write comprehensive unit tests for this integration.
      """,
    codeSampleDirectory: "0245-tca-tour-pt3",
    exercises: _exercises,
    id: 245,
    length: .init(.timestamp(minutes: 50, seconds: 19)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-08-14")!,
    references: [
      .theComposableArchitecture,
      .scrumdinger,
      .swiftCasePaths,
    ],
    sequence: 245,
    subtitle: "Navigation",
    title: "Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 33_300_000,
      downloadUrls: .s3(
        hd1080: "0245-trailer-1080p-e3d64fc14dd24fe3bad929b99f9b42cc",
        hd720: "0245-trailer-720p-8a4391f6f32c4bf0a3ea233668e755c2",
        sd540: "0245-trailer-540p-e4eb2368e5dd430089e02711ef31dd91"
      ),
      vimeoId: 852_441_253
    )
  )
}

private let _exercises: [Episode.Exercise] = []
