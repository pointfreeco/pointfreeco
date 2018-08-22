import Foundation

let post0010_studentDiscounts = BlogPost(
  author: .brandon,
  blurb: """
Get 50% off your Point-Free subscription with proof of enrollment at a university or coding school.
""",
  contentBlocks: [

    .init(
      content: """
We're happy to announce that we now offer a 50% discount on individual subscriptions for students that are
currently enrolled in a university or coding school. All you have to do is
[email us](mailto:support@pointfree.co?subject=Student%20Discount) proof of your enrollment, such as a
scanned photo of your student ID or a proof of enrollment from the organization, and we'll give you a
discount code that can be used on the [individual](\(url(to: .pricing(nil, expand: nil)))) subscription
plan, both monthly and yearly.

Some may think that our material isn't exactly beginner friendly, and although there is some truth to that,
we also believe that the ideas of functional programming are best introduced during the formative period
of one's life in programming. Most introductory education materials put too much of an emphasis
on getting things up on a screen and too little time on the fundamentals of where complexity lies in
our applications and what tools help control it.

Please feel free to [reach out](mailto:support@pointfree.co?subject=Student%20Discount) to us if you have
any questions!
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
  id: 10,
  publishedAt: Date(timeIntervalSince1970: 1_532_930_223 + 604_800),
  title: "Announcing Student Discounts"
)
