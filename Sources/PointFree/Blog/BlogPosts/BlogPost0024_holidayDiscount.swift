import Foundation

let post0024_holidayDiscount = BlogPost(
  author: .stephen,
  blurb: """
This holiday season we're offering a rare special: 50% savings on a Point-Free subscription.
""",
  contentBlocks: [
    .init(
      content: """
---

> This holiday season we're offering a rare special: 50% savings on a Point-Free subscription.

---

Act now and you can save 50% on the first year of an individual Point-Free subscription!

New subscribers will get access to Point-Free for $8.50 per month, or $85 per year for the first year. This promotion won't be available for long, so (subscribe today)[\(url(to: .discounts(code: "advent-2018")))]!

You can access this discount by following (this festive link)[\(url(to: .discounts(code: "advent-2018")))].
""",
      timestamp: nil,
      type: .paragraph
    )

    ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.",
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1544432400),
  title: "Holiday Special: Save 50% on Point-Free"
)
