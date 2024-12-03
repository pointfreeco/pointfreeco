import Foundation

extension BlogPost {
  public static let post0159_Sharing = Self(
    author: .pointfree,
    blurb: """
      We are excited to announce a brand new open-source library: Sharing. Instantly share state 
      among your app's features and external persistence layers, including user defaults, the file 
      system, and more.
      """,
    coverImage: "https://pointfreeco-blog.s3.amazonaws.com/posts/0159-sharing/sharing-poster.png",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 159,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-02")!,
    title: "Simple state sharing and persistence in Swift"
  )
}
