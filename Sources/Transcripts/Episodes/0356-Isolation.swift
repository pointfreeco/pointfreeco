import Foundation

extension Episode {
  public static let ep356_isolation = Episode(
    blurb: """
      We show off some superpowers unlocked by embracing isolation, noncopyable, and nonescapable \
      types by showing how they can be used to add incredible safety and performance to a legacy C \
      API, and we will bring everything together to see how these tools make testing an app that \
      uses Composable Architecture 2.0 and SQLiteData is like magic.
      """,
    codeSampleDirectory: "0356-beyond-basics-isolation-pt2",
    exercises: _exercises,
    id: 356,
    length: 29 * 60 + 08,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-03-02")!,
    references: [
      .se0390_noncopyable,
      .se0446_nonescapable,
      .sqliteData,
    ],
    sequence: 356,
    subtitle: "Superpowers",
    title: "Beyond Basics",
    trailerVideo: Video(
      bytesLength: 57_200_000,
      downloadUrls: .s3(
        hd1080: "0356-trailer-1080p-a283c81f4ab040f0b0e3badb2e13c286",
        hd720: "0356-trailer-1080p-a283c81f4ab040f0b0e3badb2e13c286",
        sd540: "0356-trailer-1080p-a283c81f4ab040f0b0e3badb2e13c286"
      ),
      id: "fed87963144a8defcbb0dcdf4aff3bb1"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
