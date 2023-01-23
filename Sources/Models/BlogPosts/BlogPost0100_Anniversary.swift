import Foundation

public let post0100_Anniversary = BlogPost(
  author: .pointfree,
  blurb: """
    We launched Point-Free 5 years ago today! There's still so much more we want to do, but we'll
    start with something that many people have asked for: livestreams!
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Five years ago, to the day, we launched Point-Free with a pair of episodes (
        [functions](/episodes/ep1-functions) and [side-effects](/episodes/ep2-side-effects)),
        and since then have released 220 episodes, 132 hours of video, and have had nearly half a
        million visitors to the site.

        In some ways we are only just getting started. We still haven't released the 1.0 of
        the Composable Architecture, we still haven't talked about one of our favorite subjects
        (the deep connection between math and programming), and there's still so much more to say
        about Swift concurrency.

        All of that will come in due time, but in the meantime there's something happening later
        this week that people have been asking for a long time:

        ## Livestreams

        We are extremely excited to announce our first ever livestream. Everyone can access this
        livestream, whether you are a [subscriber](/pricing) or not, and it will begin at 9am PST
        (5pm GMT) this Wednesday, Feburary 1st:

        """###,
      type: .paragraph
    ),
    .init(
      content: "Watch Feb 1 @ 9am PST / 5pm GMT",
      type: .button(href: "/live/2809055")
    ),
    .init(
      content: ###"""
        We will be discussing [modern SwiftUI](/collections/swiftui-modern-swiftui) techniques,
        our new [Dependencies library](http://github.com/pointfreeco/swift-dependencies), as well
        as taking questions from our viewers. Please join us, and bring any questions you might have.

        We have plans for a lot more livestreams in the future, especially in tandem with new
        library releases and new episodic releases. Some will be free for all, and some will be
        for subscribers only, so consider [subscribing today](/pricing). 😁
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 100,  
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-29")!,
  title: "5 years of Point-Free"
)

/*
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
        We will be discussing [modern SwiftUI](/collections/swiftui-modern-swiftui) techniques,
        our new [Dependencies](http://github.com/pointfreeco/swift-dependencies), as well as taking
        questions for our viewers. Please join us, and bring any questions you might have.

        We have plans for a lot more livestreams in the future, especially in tandem with new
        library releases and new episodic releases. Some will be free for all, and some will be
        for subscribers only, so consider [subscribing today](/pricing). 😁
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 101,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-01")!,
  title: "Point-Free Live"
)
*/
