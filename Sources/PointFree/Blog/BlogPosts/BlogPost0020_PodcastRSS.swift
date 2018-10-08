import Foundation

let post0020_PodcastRSS = BlogPost(
  author: .brandon,
  blurb: """
Follow along with the newest Point-Free episodes using your favorite podcast app. We now support
podcast-friendly RSS feeds for viewing all of our videos.
""",
  contentBlocks: [
    .init(
      content: """
> Follow along with the newest Point-Free episodes using your favorite podcast app. We now support
podcast-friendly RSS feeds for viewing all of our videos.

---

We hope that everyone has enjoyed watching episodes on the [Point-Free](/) website, but we understand
that watching long-form videos in a browser is not always ideal. That's why today we are excited to
announce that we are supporting podcast-friendly RSS feeds so that viewers can watch along in their
favorite podcast app!

### Public Episodes Feed

We have one feed that is open to the public, and you can find it [here](\(path(to: .feed(.episodes)))).
Plug that into any podcast app and you should have up-to-date access to all of our videos. You will
get access to full videos of all our free episodes (currently 9 of em) and trailers for the subscriber-only
episodes. If you find any of our content enticing, then you may want to consider a
[subscription](\(path(to: .pricing(nil, expand: nil)))) 😃.

### Private Episode Feed

If you are a subscriber, then we have one more additional RSS feed for you, and you'll find it on your
[account](\(path(to: .account(.index)))) page. This gives you full access to _every_ episode on Point-Free
as they are released. We ask that you please do not share this URL with anyone, as it is private and tied
directly to your account.

### Functional Programming Everywhere

We hope that this feature allows our viewers to more freely view our videos in a manner that suits them
best. We have even more features coming in the future for viewing our videos, but more on that later...

---

> Hey, did you know that the entire codebase that runs this site is written in Swift _and_
[open source](https://github.com/pointfreeco/pointfreeco)? That means you can actually see the work that
went into building this feature ([here](https://github.com/pointfreeco/pointfreeco/pull/312) and
[here](https://github.com/pointfreeco/pointfreeco/pull/317)). Everything from routing and rendering the RSS
feed, to protecting the private feeds with encryption and unit testing the whole feature. We hope you find
it interesting!
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg", 
  id: 20,
  publishedAt: .init(timeIntervalSince1970: 1_538_980_176),
  title: "Watch episodes in your favorite podcast app!"
)
