import Foundation

extension BlogPost {
  public static let post0219_sqliteDataSectioning = Self(
    author: .pointfree,
    blurb: """
      SQLiteData 1.8.0 introduces a concise tool for grouping query results into sections, \
      providing parity with SwiftData 27, and much more.
      """,
    coverImage: nil,  // TODO
    hidden: .no,
    hideFromSlackRSS: false,
    id: 219,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-27")!,  // TODO
    title: "New in SQLiteData: Sectioned queries"
  )
}
