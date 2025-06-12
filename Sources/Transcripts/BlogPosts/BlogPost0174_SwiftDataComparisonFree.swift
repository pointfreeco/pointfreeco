import Foundation

extension BlogPost {
  public static let post0174_SwiftDataComparisonFree = Self(
    author: .pointfree,
    blurb: """
      We've made our most recent episode free for all to watch! We begin with a deep dive \
      comparison in how SwiftData's querying tools stack up against ours.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/c4c6b6aa-ae8c-482b-39b0-aebad9fc7f00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 174,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-12")!,
    title: "Free Episode: SwiftData versus SQL Query Builder"
  )
}
