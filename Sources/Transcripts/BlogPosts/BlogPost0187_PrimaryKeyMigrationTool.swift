import Foundation

extension BlogPost {
  public static let post0187_primaryKeyMigrationTool = Self(
    author: .pointfree,
    blurb: """
      We have released a tool that will help you prepare your existing SQLite database for \
      CloudKit synchronization. It will convert existing integer primary keys to UUIDs and add \
      primary keys to tables that do not have one, all the while preserving foreign key integrity.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 187,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-08")!,
    title: "New in SQLiteData: Migration tool for CloudKit sync"
  )
}
