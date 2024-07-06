import Foundation

extension BlogPost {
  public static let post0099_ModernSwiftUIConclusion = Self(
    author: .pointfree,
    blurb: """
      A call to action: how would *you* rebuild Apple's "Scrumdinger" application? We've shown our \
      take on modern SwiftUI, but we would love to see how you tackle the same problems. Don't \
      like to use a observable objects for each screen? Prefer to use @StateObject instead of \
      @ObservedObject? Want to use an architectural pattern such as VIPER? Have a different way of \
      handling dependencies? Please show us!
      """,
    coverImage: nil,
    hidden: .no,
    id: 99,
    publishedAt: yearMonthDayFormatter.date(from: "2023-01-27")!,
    title: "Modern SwiftUI"
  )
}
