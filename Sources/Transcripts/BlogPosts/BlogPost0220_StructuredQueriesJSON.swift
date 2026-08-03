import Foundation

extension BlogPost {
  public static let post0220_structuredQueriesJSON = Self(
    author: .pointfree,
    blurb: """
      StructuredQueries 0.35.0 introduces full support for JSON and JSONB in SQLite queries. Store \
      complex data types in your tables and query for values held in JSON in a type-safe and \
      schema-safe API.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f98e9205-4e50-482b-9ccc-0f246a987c00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 220,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-03")!,
    title: "Type-safe JSON and JSONB in StructuredQueries"
  )
}
