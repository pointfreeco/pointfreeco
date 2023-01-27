import Foundation

public let post0101_Anniversary = BlogPost(
  author: .pointfree,
  blurb: """
    We are officially live with our first ever livestream. We will be discussing SwiftUI navigation,
    our new Dependencies library, and maybe even some testing. Oh, also, it's our 5 year
    anniversary! 🥳
    """,
  contentBlocks: [
    .init(
      content: ###"""
        We are officially live with our first ever livestream. We will be discussing SwiftUI
        navigation, our new Dependencies library, and maybe even some testing.

        Oh, also, it's our [5 year anniversary](/blog/posts/100-5-years-of-point-free)! 🥳

        Join now and bring your questions!
        """###,
      type: .paragraph
    ),
    .init(
      content: "Join livestream",
      type: .button(href: "/live")
    ),
  ],
  coverImage: nil,
  id: 101,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-01")!,
  title: "We’re live!"
)
