import Foundation

let post0002_episodeCredits = BlogPost(
  author: .brandon,
  blurb: """
Let’s look at a real world use for algebraic data types. We will refactor a data type that is used in the
code on this very site so that the invalid states are unrepresentable by the compiler.
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .video(
        poster: "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/poster.jpg",
        sources: [
          "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/hls-playlist.m3u8",
          "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/webm.webm"
        ]
      )
    ),

    .init(
      content: """
      ---

      In our episode on [algebraic data types](\(url(to: .episode(.left("ep4-algebraic-data-types"))))) we
      showed how there is algebra lurking in the Swift type system, and then used that knowledge to refactor
      our data types so that the invalid states are unrepresentable by the compiler. You simply were not
      allowed to construct invalid values, and it was proven to us by the compiler!

      In today's [Point-Free Pointer](\(url(to: .blog(.index)))) we are going to apply this to a real world
      problem. In fact, we are going to analyze a data type that I made for a feature on this very site. I
      did it completely wrong the first time, and it held lots of values that were just completely
      nonsensical. I convinced myself that it wasn't going to be a problem, and just rolled with it for
      awhile. But, I kept finding myself adding lil `if let`s here and lil `guard let`s there, until finally
      I said enough is enough, it's time to refactor. The amazing part is that I literally used algebra to do
      this refactoring, and so today I want to walk you through exactly how I dissected this problem.
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
      But first, let me describe the feature I was working on.

      While most of our episodes are for subscribers only, we wanted to give people the opportunity to see a
      video of their choosing for free. All they had to do was sign up for our newsletter, and they would get
      a credit that could be used on any subscriber-only episode.

      Now, when a user is on the episode page, we have this lil module to callout that users can subscriber
      to our series or sign up to get a credit. The messaging in that box depends on quite a few states.

      ---
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/credits-feature.jpg")
    ),

    .init(
      content: """
      ---

      It can change depending on whether or not you are logged in, or if you are a subscriber already or not,
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
      It's just a simple struct with four fields of `Bool` values for each of the conditions that can
      affect the messaging in the box.

      This worked great for awhile. It got me making progress on the feature quickly and it was easy to
      understand. But soon I was having to guard against states that I knew were not possible. Let's break
      this down algebraically and see if we can whittle away the invalid states.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Using Algebra",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
      Here is our type algebraically:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      // (Is/Not)LoggedIn
      //   * (Is/Not)Subscriber
      //   * (Has/Not)UsedCredit
      //   * (Is/Not)SubscriberOnly (16)
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      Our type is a struct, which is a product type, so we have used `*` to denote that we are multplying
      the fields together. Written this way it is clear there are 16 states.

      Let’s take this one step at a time. I first want to consider what states make sense when the user is
      not logged in:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      // NotLoggedIn
      //   * (Is/Not)Subscriber
      //   * (Has/Not)UsedCredit
      //   * (Is/Not)SubscriberOnly (8)
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      There are 8 states because `2 * 2 * 2 = 8`. Which of these are reasonable? Well, you can’t be logged out
      and a subscriber. You also can’t be logged out and have used a credit. It _is_ possible to be logged out
      and for an episode to be subscriber only, those things are completely independent.

      So, we've just eliminated 6 states from the full set of 16:
      """,
      timestamp: nil,
      type: .paragraph
    ),


    .init(
      content: """
// Valid states:
// NotLoggedIn * NotSubscriber * NotUsedCredit * (Is/Not)SubscriberOnly (2)

// Invalid states:
// NotLoggedIn * IsSubscriber  * HasUsedCredit * IsSubscriberOnly  (1)
// NotLoggedIn * NotSubscriber * HasUsedCredit * IsSubscriberOnly  (1)
// NotLoggedIn * IsSubscriber  * NotUsedCredit * IsSubscriberOnly  (1)
// NotLoggedIn * IsSubscriber  * HasUsedCredit * NotSubscriberOnly (1)
// NotLoggedIn * NotSubscriber * HasUsedCredit * NotSubscriberOnly (1)
// NotLoggedIn * IsSubscriber  * NotUsedCredit * NotSubscriberOnly (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That's pretty nice, with just a lil bit of work we've whittled the 16 states down to 10. But, we haven't even
considered the logged in case yet. Let's look at that:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// LoggedIn
//   * (Is/Not)Subscriber
//   * (Has/Not)UsedCredit
//   * (Is/Not)SubscriberOnly (8)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now, all of these states are technically possible, but some are redundant when it comes to what we want to
message to the user. For example, If you are a subscriber, it doesn't really matter if you had previously
used a credit on this episode (which you may have done before you became a subscriber), and it doesn't matter
if the episode is subscriber only or not. Let's list them all our so that we can chip away at them one-by-one:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// LoggedIn * IsSubscriber  * HasUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * NotSubscriber * HasUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * IsSubscriber  * NotUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * IsSubscriber  * HasUsedCredit * NotSubscriberOnly (1)
// LoggedIn * NotSubscriber * HasUsedCredit * NotSubscriberOnly (1)
// LoggedIn * IsSubscriber  * NotUsedCredit * NotSubscriberOnly (1)
// LoggedIn * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
So, as we just explained, when you are a subscriber all of the other states don't matter. So all states that
have `IsSubscriber` should really just constitute one state:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// LoggedIn
//   * IsSubscriber
//   * (Has/Not)UsedCredit
//   * (Is/Not)SubscriberOnly (4)
// ⬇️
// LoggedIn
//   * IsSubscriber
//   * Void
//   * Void                   (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
So we've now gotten rid of 3 invalid states, which means we have just 7 from the original 16.

We still have 4 more states to consider, the case where you are logged in but not a subscriber.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// LoggedIn * NotSubscriber * HasUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * NotSubscriber * HasUsedCredit * NotSubscriberOnly (1)
// LoggedIn * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
There are two states here that are kind of redundant. For, if you have used a credit to see this particular
episode, then it does not matter if the episode was originally subscriber only or not. In particular these
two states represent just one that we are actually interested in:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// LoggedIn * NotSubscriber * HasUsedCredit * IsSubscriberOnly  (1)
// LoggedIn * NotSubscriber * HasUsedCredit * NotSubscriberOnly (1)
// ⬇️
// LoggedIn * NotSubscriber * HasUsedCredit * Void              (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
So we have reduced those two states to one, which brings our original 16 down to just 6! A more than 60%
reduction in states! Let's gather all the states we are actually interested in:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
NotLoggedIn * NotSubscriber * NotUsedCredit * (Is/Not)SubscriberOnly (2)
LoggedIn    * IsSubscriber  * Void          * Void                   (1)
LoggedIn    * NotSubscriber * NotUsedCredit * IsSubscriberOnly       (1)
LoggedIn    * NotSubscriber * NotUsedCredit * NotSubscriberOnly      (1)
LoggedIn    * NotSubscriber * HasUsedCredit * Void                   (1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: "Translate into Swift",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
Ok, this has been fun, but we've been entirely working in comments and pseudocode. It's now our job to
translate this to a Swift data type. Well, we want the sum of all these states, so I'm thinking at the root
level we want an enum. We can see that it splits first at the question of logged in or not logged in.
So let's start there!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  // LoggedIn    * IsSubscriber    * Void             * Void         (1)
  // LoggedIn    * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
  // LoggedIn    * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
  // LoggedIn    * NotSubscriber * HasUsedCredit    * Void           (1)
  case loggedIn

  // NotLoggedIn * NotSubscriber * NotUsedCredit * (Is/Not)SubscriberOnly (2)
  case loggedOut
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The `loggedOut` case seems to be the simplest because we don't know anything about subscriber state or credit
state, we only care about whether or not the episode is for subscribers only. So we can fill that in with a
boolean:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  // LoggedIn    * IsSubscriber    * Void             * Void         (1)
  // LoggedIn    * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
  // LoggedIn    * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
  // LoggedIn    * NotSubscriber * HasUsedCredit    * Void           (1)
  case loggedIn

  case loggedOut(isEpisodeSubscriberOnly: Bool)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In the `loggedIn` state we can see that we next split on the question of whether or not the user is a
subscriber. Sounds like we can introduce a nested enum for that:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  case loggedIn(subscriberPermission: SubscriberPermission)

  enum SubscriberPermission {
    // LoggedIn * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
    // LoggedIn * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
    // LoggedIn * NotSubscriber * HasUsedCredit  * Void             (1)
    case isNotSubscriber

    // LoggedIn * IsSubscriber * Void * Void (1)
    case isSubscriber
  }

  case loggedOut(isEpisodeSubscriberOnly: Bool)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Looks like the `isSubscriber` case is already done, no other data to put there. The `isNotSubscriber` state,
however, has a few more choices in it. Looks like we split on the question of whether or not the user has
used a credit for this episode. Sounds like a job for yet another nested enum!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  case loggedIn(subscriberPermission: SubscriberPermission)

  enum SubscriberPermission {
    case isNotSubscriber(creditPermission)

    enum CreditPermission {
      // LoggedIn * NotSubscriber * NotUsedCredit * NotSubscriberOnly (1)
      // LoggedIn * NotSubscriber * HasUsedCredit * Void              (1)
      case hasNotUsedCredit

      // LoggedIn * NotSubscriber * NotUsedCredit * IsSubscriberOnly  (1)
      case hasUsedCredit
    }

    case isSubscriber
  }

  case loggedOut(isEpisodeSubscriberOnly: Bool)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Ok we're so close! The `hasUsedCredit` is finished, no extra data is needed, but the `hasNotUsedCredit` needs
to further know if the episode is for subscribers only. A simple boolean will solve that:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  case loggedIn(subscriberPermission: SubscriberPermission)

  enum SubscriberPermission {
    case isNotSubscriber(creditPermission)

    enum CreditPermission {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit
    }

    case isSubscriber
  }

  case loggedOut(isEpisodeSubscriberOnly: Bool)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And we are done! This is a bit messy, so let's clean up real quick by grouping the cases together and
putting the nested enums last:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum EpisodePermission {
  case loggedIn(subscriberPermission: SubscriberPermission)
  case loggedOut(isEpisodeSubscriberOnly: Bool)

  enum SubscriberPermission {
    case isNotSubscriber(creditPermission)
    case isSubscriber

    enum CreditPermission {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      // todo: link to open source
      content: """
That is so simple! And this is precisely the data type we use in the code on this site! It cleaned up the
code that dealt with this permissions type a lot. I was able to delete let's of `guard`ing and `if let`ing
and instead just focus on the states I knew were valid.

So, that's it for this Point-Free Pointer. I hope you can see how understanding algebra in the Swift type
system can greatly simplify the types we work with. Also, the code for this entire website, including
everything we discussed today, is fully open sourced on GitHub. If you are curious about this technique,
and any of the other things we do on Point-Free, feel free to poke around and ask us questions on
[Twitter](\(twitterUrl(to: .pointfreeco)))!
""",
      timestamp: nil,
      type: .paragraph
    ),
    ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0002-case-study-adt/poster.jpg",
  id: 2,
  publishedAt: .init(timeIntervalSince1970: 1_524_477_423),
  title: "Case Study: Algebraic Data Types"
)
