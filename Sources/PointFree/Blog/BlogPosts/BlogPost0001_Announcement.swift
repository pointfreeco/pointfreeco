import Foundation

let post0001_welcome = BlogPost(
  blurb: """
""",
  contentBlocks: [
    .init(
      content: """
      It's hard to believe it's already been X (TODO) months since we launched Point-Free, but
      here we are! We have been having a lot of fun planning out episodes, crafting story
      arcs that connect episodes in interesting ways, and coming up with challenging exercises
      so that viewers can continue exploring concepts on their own. The reception has also been
      amazing to see, and we're excited that so many Swift developers are excited about
      functional programming.

      However, there's only so much material we can fit in an episode. We try to keep
      them down to 20-30 minutes so that more people will watch the full episode,
      and hopefully it's more digestible. Often there is so much more we want to include
      in an episode, but we have to cut in the interest of time.

      So, that is why we are happy to announce the launch of Point-Free Pointers! A
      supplementary blog for [Point-Free](\(url(to: .home))) where we will be diving
      even deeper into topics covered in our episodes. Keep up-to-date on new posts by add the
      [RSS feed](\(url(to: .blog(.feed(.atom))))) to your reader of choice, follow us on
      [Twitter](\(twitterUrl(to: .pointfreeco))), or sign up for our
      [newsletter](\(url(to: .login(redirect: url(to: .account(.index)))))).
      """,
      timestamp: nil,
      type: .paragraph
    ),
    ],
  id: 1,
  publishedAt: .init(timeIntervalSince1970: 1_523_872_623),
  title: "Announcing Point-Free Pointers!",
  video: nil
)
