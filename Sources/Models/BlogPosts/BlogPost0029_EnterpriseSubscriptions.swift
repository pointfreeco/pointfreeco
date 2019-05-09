import Foundation

public let post0029_enterpriseSubscriptions = BlogPost(
  author: .pointfree, // todo
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://s3.amazonaws.com/pointfreeco-blog/posts/0029-enterprise-subscriptions/poster.png")
    ),
    .init(
      content: """
---

Today we are excited to announce support for enterprise subscriptions on Point-Free. This makes it super easy for a large organization to obtain a subscription to our video series and share it with everyone in the company.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: "How team subscriptions work",
      timestamp: nil,
      type: .title
    ),
    .init(
      content: """
Point-Free has supported team subscriptions from the day we launched. They allow a company to purchase multiple subscriptions at once for a discounted price. This works by specifying how many seats you want, and then you invite your colleagues to join your team. As owner of the subscription you get to add and remove teammates at anytime, and the billing rate will be adjusted accordingly.

This works great for smallish teams, but if your organization has a hundred engineers you probably don’t want to manually manage all of the seats on your team. It would be far better if everyone in your organization could simply get instant access to everything Point-Free has to offer. This is what inspired enterprise subscriptions!
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: "How enterprise subscriptions work",
      timestamp: nil,
      type: .title
    ),
    .init(
      content: """
If your organization is big enough where manually managing the seats of a team subscription is too cumbersome, then an enterprise subscription should help. After negotiating a yearly price with us, we will whitelist your company’s domain so that anyone with an email from your organization gets instant, full access to the site. You will get a white label landing page on our site, for example [pointfree.co/enterprise/blob.biz](https://www.pointfree.co/enterprise/blob.biz), and anyone in your company can get access to Point-Free as long as they are in possession of an email from your company.

This greatly reduces the administrative overhead of managing a team subscription for large companies. We will even automatically remove teammates from your enterprise subscription once they leave your company and their email has been deactivated!
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: "Interested?",
      timestamp: nil,
      type: .title
    ),
    .init(
      content: """
If any of this sounds interesting to you then please get [in touch](mailto:support@pointfree.co?subject=Enterprise%20Subscription) with us to get more information. We can negotiate a yearly price with you based on your organization’s size. And if you already have a team subscription with us we can discount your enterprise subscription based on how much time you have left in your team subscription’s billing cycle.
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "TODO",
  id: 29,
  publishedAt: .init(timeIntervalSince1970: 1557381600),
  title: "Enterprise Subscriptions"
)
