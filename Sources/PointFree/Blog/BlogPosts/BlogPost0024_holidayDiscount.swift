import Foundation

let post0024_holidayDiscount = BlogPost(
  author: .stephen,
  blurb: """
This holiday season we're offering a rare special: 50% savings on a Point-Free subscription.
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "") // TODO
    ),

    .init(
      content: """
---

> This holiday season we're offering a rare special: 50% savings on a Point-Free subscription.

---

We've teamed up with [Paul Hudson](https://twitter.com/twostraws) of [Hacking with Swift](https://www.hackingwithswift.com) to offer a surprise gift on [day seven](https://www.hackingwithswift.com/articles/143/build-a-simon-game-for-watchos) of his [Advent of Swiftmas 2018](https://www.hackingwithswift.com/articles/137/advent-of-swiftmas-2018) series: 50%-off the first year of an individual Point-Free subscription!

New subscribers will get access to Point-Free for $8.50 per month, or $85 per year for the first year. This promotion won't be available for long, so (subscribe today)[\(url(to: .discounts(code: "advent-2018")))]!

You can access this discount by [reading Paul's article](https://www.hackingwithswift.com/articles/143/build-a-simon-game-for-watchos) or by following (this festive link)[\(url(to: .discounts(code: "advent-2018")))].
""",
      timestamp: nil,
      type: .paragraph
    )

    ],
  coverImage: "", // TODO
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1544432400),
  title: "Holiday Special: Save 50% on Point-Free"
)
