import Foundation

public let post0101_Livestream = BlogPost(
  author: .pointfree,
  blurb: """
    We’re excited to announce our first ever livestream. We will be discussing our latest open
    source release, Dependencies, as well as answering questions from our viewers.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        We are extremely excited to announce our first ever livestream. Everyone can access this
        livestream, whether you are a [subscriber](/pricing) or not, and it will begin at 9AM PST
        (5PM GMT):
        """###,
      type: .paragraph
    ),
    .init(
      content: "Watch here",
      type: .button(href: "/live/2809055")
    ),
    .init(
      content: ###"""
        Please join us, and bring any questions you might have.

        We have plans for a lot more of these, especially in tandem with new library releases
        and new episodic releases. Some will be free for all, and some will be for subscribers only,
        so consider [subscribing today](/pricing). 😁
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 101,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-01")!,
  title: "Point-Free Live"
)
