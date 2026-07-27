import Foundation

extension BlogPost {
  public static let post0219_sqliteDataSectioning = Self(
    author: .pointfree,
    blurb: """
      SQLiteData 1.8.0 introduces a concise tool for grouping query results into sections, \
      providing parity with SwiftData 27, and much more.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/c3f4fac6-f526-47b8-6334-d8f1233b4e00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 219,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-27")!,
    title: "New in SQLiteData: Sectioned queries"
  )
}
