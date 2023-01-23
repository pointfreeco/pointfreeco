import Foundation

public let post0100_Anniversary = BlogPost(
  author: .pointfree,
  blurb: """
    We launched Point-Free 5 years ago today, and there's still so much more we want to cover.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        TODO

        """###,
      type: .paragraph
    ),
    .init(
      content: "Watch at 9AM PST / 5PM GMT",
      type: .button(href: "/live/2809055")
    ),
  ],
  coverImage: nil,
  id: 100,  
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-30")!,
  title: "5 years of Point-Free"
)

// todo: mention live stream, share link
// /live/2809055
