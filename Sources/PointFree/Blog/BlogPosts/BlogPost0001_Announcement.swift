import Foundation

let post0001_welcome = BlogPost(
  author: nil,
  blurb: """
Today we are excited to announcement launch of Point-Free Pointers, a blog to supplement our video
series for all the content we couldn’t fit in. Expect to find regularly postings here that dive
even deeper into functional programming, showing real world use cases and more!
""",
  contentBlocks: [
    .init(
      content: """
      It's hard to believe it's been nearly 3 months since we launched [Point-Free](\(url(to: .home))), but
      here we are! We have been having a lot of fun planning out episodes, crafting story
      arcs that connect episodes in interesting ways, and coming up with challenging exercises
      so that viewers can continue exploring concepts on their own. The reception has also been
      amazing to see, and we're excited that so many Swift developers are excited about
      functional programming.

      However, there's only so much material we can fit in an episode. We try to keep
      them down to 20-30 minutes so that more people will watch the full episode,
      and hopefully it's more digestible. Often there is more we want to include
      in an episode, but we have to make cuts in the interest of time.

      So, that is why we are happy to announce the launch of
      [Point-Free Pointers](\(url(to: .blog(.index))))! A
      supplementary blog for [Point-Free](\(url(to: .home))) where we will be diving
      even deeper into topics covered in our episodes. Keep up-to-date on new posts by add the
      [RSS feed](\(url(to: .blog(.feed)))) to your reader of choice, follow us on
      [Twitter](\(twitterUrl(to: .pointfreeco))), or sign up for our
      [newsletter](\(url(to: .login(redirect: url(to: .account(.index)))))).

      To kick things off, we have a [post](\(url(to: .blog(.show(post0002_episodeCredits))))) about applying
      the ideas from [algebraic data types](\(url(to: .episode(.left("ep4-algebraic-data-types"))))) to a
      real world problem. You can read it [here](\(url(to: .blog(.show(post0002_episodeCredits)))))!

      Your hosts,

      [Brandon Williams](\(twitterUrl(to: .mbrandonw))) & [Stephen Celis](\(twitterUrl(to: .stephencelis)))
      """,
      timestamp: nil,
      type: .paragraph
    ),
    ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
  id: 1,
  publishedAt: .init(timeIntervalSince1970: 1_524_456_062),
  title: "Announcing Point-Free Pointers!"
)
