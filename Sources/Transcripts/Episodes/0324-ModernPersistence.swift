import Foundation

extension Episode {
  public static let ep324_modernPersistence = Episode(
    blurb: """
      We tackle the first screen in our Reminders app rewrite: the reminders lists view. We will \
      take the `@FetchAll` property wrapper for a spin, which is like SwiftData's `@Query` macro, \
      but unlike `@Query` it can be used from both the view _and_ observable models. And we will \
      even get some end-to-end, snapshot test coverage of our feature in place.
      """,
    codeSampleDirectory: "0324-modern-persistence-pt2",
    exercises: _exercises,
    id: 324,
    length: 44 * 60 + 10,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-05-12")!,
    references: [
      .init(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sharing-grdb",
        title: "SharingGRDB"
      ),
      .init(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 324,
    subtitle: "Reminders Lists, Part 1",
    title: "Modern Persistence",
    trailerVideo: .init(
      bytesLength: 78_400_000,
      downloadUrls: .s3(
        hd1080: "0324-trailer-1080p-41a449caa8764275aaa8712c7ab542c8",
        hd720: "0324-trailer-720p-fe81405c1ebb4a8a852d1b715dfa32a5",
        sd540: "0324-trailer-540p-b37837cea51f4acc9ebbe6ab1d649949"
      ),
      vimeoId: 1082678124
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
