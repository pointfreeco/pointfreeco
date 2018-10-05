import Foundation

let post00XY_PodcastRSS = BlogPost(
  author: .brandon,
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: """
> Follow along with the newest Point-Free episodes using your favorite podcast app. We now support
RSS feeds for viewing all of our videos.

---

We hope that everyone has enjoyed watching episodes on the [Point-Free](/) website, but we understand
that watching long-form videos in a browser is not always ideal. That's why today we are excited to
announce that we are supporting podcast-friendly RSS feeds so that viewers can watch along in their
favorite podcast app!

## Public Episodes Feed

We have one feed that is open to the public, and you can find it [here](\(url(to: .feed(.episodes)))).
Plug that into any podcast app and

## Private Episode Feed

If you are a subscriber, then we have one more additional RSS feed for you, and you'll find it on your
[account](\(url(to: .account(.index)))) page. This gives you access to

## Functional Programming Everywhere



""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "", // todo
  id: 20, // todo
  publishedAt: .init(timeIntervalSince1970: 1539152976),
  title: "Watch episodes in your favorite podcast app!"
)
