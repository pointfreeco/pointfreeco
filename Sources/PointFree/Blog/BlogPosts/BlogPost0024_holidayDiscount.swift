import Foundation

let post0024_holidayDiscount = BlogPost(
  author: .pointfree,
  blurb: """
Save 30% on a Point-Free subscription for a limited time only!
""",
  contentBlocks: [
    .init(
      content: """
To end 2018 on a high note we're offering a 30% discount to new subscribers for their first year. Just
[follow this link](/discounts/point-free-2018) and sign up for an individual subscription plan using the pre-filled code. The discount will be applied automatically.

If you're interested in learning more about what you'll gain access too, see our [2018 Year In Review](/blog/25-2018-year-in-review)!

We hope you'll [join us](/discounts/point-free-2018) for all of the great material we have planned for 2019.
""",
      timestamp: nil,
      type: .paragraph
    )
    ],
  coverImage: Current.assets.emailHeaderImgSrc,
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1545210000),
  title: "Save 30% on Point-Free"
)
