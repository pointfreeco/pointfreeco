import Foundation

extension Episode {
  public static let ep374_wwdc26 = Episode(
    blurb: """
      SwiftData has a brand new `sectionBy` API, for grouping the results of a `@Query` into \
      sections. So what is SQLiteData's solution to this problem? Well it turns out SQLiteData's \
      tools supported sectioning from day one, and much more. We'll show just how far these tools \
      can take use before introducing an ergonomic API to match SwiftData's.
      """,
    codeSampleDirectory: "0374-wwdc26-pt5",
    exercises: _exercises,
    id: 374,
    length: 42 * 60 + 45,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-27")!,
    references: [
      .wwdc26WhatsNewInSwiftData,
      .sqliteData,
    ],
    sequence: 374,
    socialImage: nil,
    subtitle: "SQLiteData Sectioning",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 41_600_000,
      downloadUrls: .s3(
        hd1080: "0374-trailer-1080p-860fc7dd91ac4d9fa3aabf6cfd71bae6",
        hd720: "0374-trailer-1080p-860fc7dd91ac4d9fa3aabf6cfd71bae6",
        sd540: "0374-trailer-1080p-860fc7dd91ac4d9fa3aabf6cfd71bae6"
      ),
      id: "b9289d194ae87a6701209bec81451fba"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
