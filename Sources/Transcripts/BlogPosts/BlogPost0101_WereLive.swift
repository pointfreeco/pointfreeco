import Foundation

public let post0101_WereLive = BlogPost(
  author: .pointfree,
  blurb: """
    We are officially live with our first ever livestream. We will be discussing SwiftUI navigation,
    our new Dependencies library, and maybe even some testing. Oh, also, it's our 5 year
    anniversary! 🥳
    """,
  coverImage: nil,
  hidden: .yes,
  id: 101,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-01")!
    .addingTimeInterval(60 * 60 * 17 - 60 * 40),  // 4:20pm GMT
  title: "We’re live!"
)
