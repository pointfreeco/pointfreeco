import Foundation

extension BlogPost {
  public static let post0168_SharingGRDB = Self(
    alternateSlug: "sharinggrdb-a-swiftdata-alternative",
    author: .pointfree,
    blurb: """
      We are excited to announce a new open source library that can serve as a SwiftData \
      alternative for many types of apps out there today. It provides tools that work in SwiftUI \
      views, @Observable models, UIKit view controllers, and gives direct access to SQLite.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 168,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-14")!
      .addingTimeInterval(60 * 60 * 17),  // 5:00pm GMT
    title: "SQLiteData: A SwiftData Alternative"
  )
}
