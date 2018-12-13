import Foundation

let post0024_holidayDiscount = BlogPost(
  author: .stephen,
  blurb: """
We're rounding out 2018 with some of our favorite episodes, and giving out a rare special: 30% savings
on a Point-Free subscription.
""",
  contentBlocks: [
    .init(
      content: """
We launched on January 29 of this year, and so we've been live for just under a year. In that time we have
released 41 episodes with over 19 hours of [video](\(url(to: .home))), published 24
[blog posts](\(url(to: .blog(.index)))), had 57 thousand unique visitors, more than 600 subscriptions, and
[open sourced](\(gitHubUrl(to: .organization))) 8 (!) libraries from the topics covered in our episodes.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
## Episodes



## Open Source

We open sourced many libraries from the content in our episodes, 8 libraries in total. Each of these libraries
aims to solve a single problem in the simplest way possible in order to minimize the cost of bringing
the dependency into your project.

### `swift-snapshot-testing`

Our [most recently](todo) open sourced library, [`swift-snapshot-testing`](todo), take snapshot testing to the
next level. It allows you to snapshot test any kind of data type into any kind of format. For example, you
can snapshot test `UIView`'s and `UIViewController`'s into an image format, which is typical of these
kinds of libraries, but you can also snapshot those objects into a textual format so that you can see the
whole view hiearchy.

The design of this library was covered in a whopping 9 episodes

* Protocol Witnesses: Part 1, Part 2
* Advanced Protocol Witnesses: Part 1, Part 2
* Protocol-Oriented Library Design: Part 1, Part 2
* Witness-Oriented Library Design
* Async Snapshot Testing
* A Tour of Snapshot Testing (free)

---

### `swift-html`

Server-side Swift is in its nascent stages, but there have been some promising developments in the field,
such as the [Swift NIO](todo) project. Currently the most popular way to render HTML pages in server-side
Swift is with templating languages, but there are a lot of [problems](todo) with templates. The
[`swift-html`](todo) library aims to remedy these problems by providing a first-class data type to represent



 We open sourced [`swift-html`](todo)

### `swift-html-kitura`, `swift-html-vapure`

### `swift-nonempty`

### `swift-validated`

### `swift-overture`

### `swift-tagged`

## Here's to 2019!
""",
      timestamp: nil,
      type: .paragraph
    )
    ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.",
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1544432400),
  title: "2018 Year-in-Review"
)

//  ---
//
//  > This holiday season we're offering a rare special: 50% savings on a Point-Free subscription.
//
//    ---
//
//Act now and you can save 50% on the first year of an individual Point-Free subscription!
//
//New subscribers will get access to Point-Free for $8.50 per month, or $85 per year for the first year. This promotion won't be available for long, so (subscribe today)[\(url(to: .discounts(code: "advent-2018")))]!
//
//You can access this discount by following (this festive link)[\(url(to: .discounts(code: "advent-2018")))].
