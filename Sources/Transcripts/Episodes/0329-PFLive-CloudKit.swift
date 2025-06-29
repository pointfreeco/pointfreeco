import Foundation

extension Episode {
  public static let ep329_pfLive_modernPersistence = Episode(
    blurb: """
      We go live with our viewers to unveil our vision for modern persistence. We show just how \
      easy it is to seamlessly synchronize your app's data across many devices, including sharing \
      data with other iCloud users, and we answer your questions.
      """,
    codeSampleDirectory: "0329-pflive-modern-persistence",
    exercises: _exercises,
    format: .livestream,
    fullVideo: .init(
      bytesLength: 779_900_000,
      downloadUrls: .s3(
        hd1080: "0329-1080p-eebd10102c474631b713b39e20cfc946",
        hd720: "0329-1080p-eebd10102c474631b713b39e20cfc946",
        sd540: "0329-1080p-eebd10102c474631b713b39e20cfc946"
      ),
      id: "25def18e949b4e3783dde92472711dff"
    ),
    id: 329,
    length: 6549,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-30")!,
    questions: [],
    references: [],
    sequence: 329,
    subtitle: "A Vision for Modern Persistence",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 779_900_000,
      downloadUrls: .s3(
        hd1080: "0329-1080p-eebd10102c474631b713b39e20cfc946",
        hd720: "0329-1080p-eebd10102c474631b713b39e20cfc946",
        sd540: "0329-1080p-eebd10102c474631b713b39e20cfc946"
      ),
      id: "25def18e949b4e3783dde92472711dff"
    )
  )
}

private let _exercises: [Episode.Exercise] = []
