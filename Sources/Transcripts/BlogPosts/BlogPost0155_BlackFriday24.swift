import Foundation

extension BlogPost {
  public static let post0155_BlackFriday2024 = Self(
    author: .pointfree,
    blurb: """
      This week we are running a rare holiday sale! Save 30% when you subscribe to Point-Free today!
      You will get instant access to hours of content covering advanced Swift topics, including
      concurrency, generics, SwiftUI, domain modeling, testing, and so much more!
      """,
    coverImage: nil,
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-11-29")!),
    hideFromSlackRSS: true,
    id: 155,
    publishedAt: yearMonthDayFormatter.date(from: "2024-11-27")!,
    title: "Learn advanced Swift and save 30%"
  )
}
