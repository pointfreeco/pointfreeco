import Foundation

public let post0102_OurFirstLivestream = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Last week we hosted our first ever livestream. In an hour and a half we discussed some
        of the tools that our [Dependencies](http://github.com/pointfreeco/swift-dependencies)
        library comes with that we didn't have time to discuss in episodes, and we live refactored
        our open-source [Standups](http://github.com/pointfreeco/standups) to use the new iOS 16
        `NavigationStack`. We also answered 18 viewer questions, and just have 94 more left in the
        queue. 😅

        We are now [hosting that recorded livestream](/episodes/ep221-point-free-live-dependencies-stacks)
        on our site, and it is available free for everyone to watch. We have taken the time to clean
        things up a bit and make it more digestibile for viewing in a non-live manner, including:

        * **1080p video**: The event was streamed live at 720p, but the recorded version can be
        watched at 1080p.
        * **Chapter markers:** Most of the big, important transitions of the livestream have been
        made available and you can start the video at any chapter.
        * **Fully searchable transcript:** We cleaned up a machine-generated transcript by hand,
        complete with speaker annotations and timestamps.
        * **Question & answers:** All questions and answers have been pulled out into their
        [own section](/episodes/ep221-point-free-live-dependencies-stacks#questions-and-answers),
        with timestamps. If you couldn't stay for the whole livestream your question may have been
        answered!
        """###,
      type: .paragraph
    ),
    .init(
      content: "Watch recorded livestream",
      type: .button(href: "/episodes/ep221-point-free-live-dependencies-stacks")
    ),
    .init(
      content: """
        Future livestreams will be for subscribers-only, so if you found this video interesting,
        be sure to [subscribe today](/pricing)!
        """,
      type: .paragraph
    )
  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/episodes/0221.jpeg",
  id: 102,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-06")!,
  title: "Watch our first ever livestream"
)
