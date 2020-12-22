import Foundation

public let post0050_EOY2020 = BlogPost(
  author: .pointfree, // todo
  blurb: """

---

Random number generators, parsers, SwiftUI, composable architecture and more! Join us for a review of everything we accomplished in 2019!
""",
  contentBlocks: [
    .init(
      content: #"""
It’s the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we produced for 2020, so join us for a quick review of some of our favorite highlights.

We are also offering [30% off](todo) the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

# Highlights

At a high-level, this year we saw:

* **44** episodes released for a total of **26** hours of video.
* **50k** unique users.
* Open sourced **4** new libraries ([swift-composable-architecture](todo), [swift-case-paths](todo), [combine-schedulers](todo), [swift-parsers](todo).

But these high-level stats don't even begin to scratch the surface of what we covered in 2020.

## The Composable Architecture

In May we finally concluded the core series of episodes (17 hours of video!) that introduce a holistic approach to application architecture, known as [The Composable Architecture](todo). We highlighted 5 core problems any architecture must solve, and showed how to solve them: state management, composability, modularity, side effects and testing.

To celebrate the end of the core series of episodes we [open sourced](todo) a library for making it easy to adopt the ideas of the Composable Architecture in your application. In only 8 months the library has over 2,700 stars, merged more than 200 pull requests, and believe it or not, there's still more to come in 2021 😀.

## Dependencies

We tackled dependencies head on in a [4-part series](todo) where we precisely describe what dependencies are and why the make our code complex, and then showing what to do about it. We build a moderately complex application from scratch, one that uses API requests, network connectivity APIs, and location manager APIs, and show how to wrangle those dependencies into something simple, flexible and testable.

If you've ever reached for a protocol to control a dependency, then [this](todo) is the series for you.

## Parsing

## Combine Schedulers

## Case Paths

Continuing a long tradition of asking "if structs have it, then why don't enums too?" we explore what it would mean if enums had something like key paths defined for them. We show that such a concept can be naturally defined for enums, but we called them [case paths](todo). They turn out to be the perfect tool for transforming the actions of reducers, and even [SwiftUI bindings](todo) that hold onto enum-based state.

# New project: isowords

We ended the year by announcing a brand new project: [isowords](https://www.isowords.xyz). It's a game built in Swift (even the backend is Swift!), and it makes use of nearly ever concept discussed on Point-Free, such as the Composable Architecture, dependencies, parsers, [random number generators](todo), [algebraic data types](todo), and more. We will be releasing the game early next year, and we'll have a lot more to say about how it was built soon.

# 🎉 2021 🎉

It was an incredible year, and thanks to all of our subscribers for supporting us and helping us create this content. We have a lot of great things planned for 2020: we have a few more things to discuss about the Composable Architecture, we have a few more advanced parser topics we want to cover, as well as some completely new topics and an exciting new project to announce!

To celebrate the end of the year we are also offering 30% off the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

See you in 2021!
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 50,
  publishedAt: Date(timeIntervalSince1970: 1609135200),
  title: "2020 Year-in-review"
)
