import Foundation

extension Episode {
  public static let ep274_sharedState = Episode(
    blurb: """
      We can now persist simple bits of state to user defaults using the `@Shared` property \
      wrapper, but there is more work to be done. We need to observe changes to user defaults in \
      order to play those changes back to `@Shared`, and we need to put in a bit of extra work to \
      make everything testable.
      """,
    codeSampleDirectory: "0274-shared-state-pt7",
    exercises: _exercises,
    id: 274,
    length: 26 * 60 + 32,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-04-08")!,
    references: [
      // TODO
    ],
    sequence: 274,
    subtitle: "User Defaults, Part 2",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 31_300_000,
      downloadUrls: .s3(
        hd1080: "0274-trailer-1080p-4e9584f227904ff4a375f0cfbd993f59",
        hd720: "0274-trailer-720p-a9dda8abff6842c69fb51adaf799f8e3",
        sd540: "0274-trailer-540p-78749e99c0604f8fb17b38ca4d572179"
      ),
      id: "afb1cc6b8a64832b122892c20c994745"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
