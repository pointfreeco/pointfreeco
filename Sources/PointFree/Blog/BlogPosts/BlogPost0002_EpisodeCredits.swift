import Foundation

let post0002_episodeCredits = BlogPost(
  blurb: """
TODO
""",
  contentBlocks: [



    .init(
      content: "",
      timestamp: nil,
      type: .video(
        poster: "https://d1hf1soyumxcgv.cloudfront.net/0003-styling-with-functions/0003-poster.jpg",
        sources: [
          "https://d1hf1soyumxcgv.cloudfront.net/0003-styling-with-functions/hls-now-were-stylin.m3u8"
        ]
      )
    ),



    .init(
      content: """
      In our episode on [algebraic data types](/episodes/ep4-algebraic-data-types) we showed how there is
      algebra lurking in the Swift type system, and then used that knowledge to refactor our data types so
      that the invalid states are unrepresentable by the compiler. You simply were not allowed to construct
      invalid values, and it was proven to us by the compiler!

      In today's Point-Free Pointer we are going to apply this to a real world problem. In fact, we are going
      to analyze a data type that I made for a feature on this very site. I did it completely wrong the first
      time, and it held lots of values that were just completely nonsensical. I convinced myself that it
      wasn't going to be a problem, and just rolled with it for awhile. But, I kept finding myself adding
      lil `if let`s here and lil `guard let`s there, until finally I said enough is enough, it's time to
      refactor. The amazing part is that I literally used algebra to do this refactoring, and so today I want
      to walk you through exactly how I dissected this problem.
      """,
      timestamp: nil,
      type: .paragraph
    ),


    .init(
      content: "Episode Credits",
      timestamp: nil,
      type: .title
    ),


    .init(
      content: """
      While most of our episodes are for subscribers only, we wanted to give people the opportunity to see a
      video of their choosing for free. All they had to do was sign up for our newsletter, and they would get
      a credit that could be used on any subscriber-only episode.

      Now, when a user is on the episode page, we have this lil module to callout that users can subscriber
      to our series or sign up to get a credit. The messaging in that box depends on quite a few states. It
      could potentially depend on whether or not you are logged in, or if you are a subscriber already or not,
      or if you've already used your credit for this episode, and finally if this episode is free to the
      public or subscriber only. Naively this would be `2^4 = 16` states, many of which don't make any sense.
      Like, you can't be logged out and a subscriber. We want to omit those states, so let's use algebra!
      """,
      timestamp: nil,
      type: .paragraph
    ),


    .init(
      content: "First Attempt",
      timestamp: nil,
      type: .title
    ),



    .init(
      content: """
      Here is what I first started with:
      """,
      timestamp: nil,
      type: .paragraph
    ),


    .init(
      content: """
      struct EpisodePermission {
        let hasUsedCredit: Bool
        let isLoggedIn: Bool
        let isSubscriber: Bool
        let isSubscriberOnly: Bool
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      This was totally fine for me to work with for awhile. It got me making progress on the feature quickly
      and it was easy to understand. But soon I was having to guard against states that I knew were not
      possible. Let's break this down algebraically and see if we can whittle away the invalid states.
      """,
      timestamp: nil,
      type: .paragraph
    ),



    ],
  coverImage: "", // todo
  id: 2,
  publishedAt: .init(timeIntervalSince1970: 1_523_872_623 + 60*60*24*7), // TODO
  title: "Case Study: Algebraic Data Types", // todo
  video: nil
)
