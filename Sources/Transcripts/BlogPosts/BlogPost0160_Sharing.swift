import Foundation

extension BlogPost {
  public static let post0160_Sharing = Self(
    author: .pointfree,
    blurb: """
      We are excited to announce a brand new open-source library: Sharing. Instantly share state 
      among your app's features and external persistence layers, including user defaults, the file 
      system, and more.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 160,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-02")!,
    title: "Simple state sharing and persistence in Swift"
  )
}
