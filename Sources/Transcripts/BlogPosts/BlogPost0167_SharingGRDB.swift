import Foundation

extension BlogPost {
  public static let post0167_SharingGRDB = Self(
    author: .pointfree, 
    blurb: """
      We are excited to announce a new open source library that can serve as a SwiftData \
      alternative for many types of apps out there today. It provides tools that work in SwiftUI \
      views, @Observable models, UIKit view controllers, and gives direct access to SQLite.
      """,
    coverImage: nil,  
    hidden: .no,
    hideFromSlackRSS: false,
    id: 167,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-14")!
      .addingTimeInterval(60 * 60 * 17),  // 5:00pm GMT
    title: "SharingGRDB: A SwiftData Alternative"
  )
}
