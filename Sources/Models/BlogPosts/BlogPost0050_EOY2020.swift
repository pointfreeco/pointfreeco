import Foundation

public let post0050_EOY2020 = BlogPost(
  author: .pointfree,
  blurb: """
The Composable Architecture, dependency management, parsers, Combine schedulers and more! Join us for a review of everything we accomplished in 2020!
""",
  contentBlocks: [
    .init(
      content: #"""
It’s the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we produced for 2020, so join us for a quick review of some of our favorite highlights.

We are also offering [25% off](/discounts/2020-is-over) the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

# Highlights

At a high-level, this year we saw:

* **44** episodes released for a total of **26** hours of video.
* **50k** unique users.
* Open sourced **4** new libraries: ([swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture), [swift-case-paths](https://github.com/pointfreeco/swift-case-paths), [combine-schedulers](https://github.com/pointfreeco/combine-schedulers), [swift-parsing](https://github.com/pointfreeco/swift-parsing).

But these high-level stats don't scratch the surface of what we covered in 2020:

## The Composable Architecture

In May we finally concluded the core [series](/collections/composable-architecture) of episodes (17 hours of video!) that introduce a holistic approach to application architecture, known as [The Composable Architecture](https://www.github.com/pointfreeco/swift-composable-architecture). We highlighted 5 core problems any architecture must solve, and showed how to solve them: state management, composability, modularity, side effects, and testing.

To celebrate the end of the core series of episodes we [open sourced](https://github.com/pointfreeco/swift-composable-architecture) a library for making it easy to adopt the ideas of the Composable Architecture in your application. In only 8 months the library has over 2,700 stars, merged more than 200 pull requests, and believe it or not, there's still more to come in 2021 😀.

## Dependencies

We tackled dependencies head on in a [5-part series](/collections/dependencies) where we precisely describe what dependencies are and why the make our code complex, and then show what to do about it. We build a moderately complex application from scratch, one that uses API requests, network connectivity APIs, and location manager APIs, and show how to wrangle those dependencies into something simple, flexible, and testable.

If you've ever reached for a protocol to control a dependency, then this is the series for you.

## Parsing

We picked up [parsing](/collections/parsing) again this year after having first covered it more than a year ago. This time we focused our attention on two main things. First, we [generalized](/collections/parsing/generalization) the parser library so that it can parse _any_ kind of input into _any_ kind of output. This allows to use the same code to parse many different things, including strings, binary data, URL requests and more. Then we turned our attention to [performance](/collections/parsing/performance). We showed that parser combinators can be extremely performant, nearly as performant as highly-tuned, hand-written, ad-hoc parsers.

And all of this culminated into the release of 0.1.0 of [Parsing](https://github.com/pointfreeco/swift-parsing), a parsing library with a focus on composability, generality and performance.

## Combine Schedulers

Apple's Combine framework is incredibly powerful, and there are lots of great resources out there for learning the core concepts behind the framework. However, a topic that doesn't get a lot of attention is schedulers. We devoted an entire [series](/collections/combine/schedulers) of episodes to understanding schedulers in depth, and then open sourced a [library](https://www.github.com/pointfreeco/combine-schedulers) for making better use of schedulers in Combine.

## Case Paths

Continuing [a long tradition](/collections/enums-and-structs) of asking "if structs have it, then why don't enums too?" we explore what it would mean if enums had something like key paths defined for them. We show that such a concept can be naturally defined for enums, but we called them [case paths](/collections/enums-and-structs/case-paths). They turn out to be the perfect tool for transforming the actions of reducers, and even [SwiftUI bindings](/collections/enums-and-structs/composable-swiftui-bindings) that hold onto enum-based state.

# New project: isowords

We ended the year by announcing a brand new project: [isowords](https://www.isowords.xyz). It's a game built in Swift (even the backend is Swift!), and it makes use of nearly every concept discussed on Point-Free, such as [the Composable Architecture](/collections/composable-architecture), [dependencies](/collections/dependencies), [parsers](/collections/parsing), [random number generators](/collections/randomness), [algebraic data types](/collections/algebraic-data-types), and more. We will be releasing the game early next year, and we'll have a lot more to say about how it was built soon (we also have a few beta spots open, [contact us](mailto:support@pointfree.co) if you're interested!).

# 🎉 2021 🎉

We're thankful to all of our subscribers for supporting us and helping us create this content. To celebrate the end of the year we are also offering [25% off](todo) the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

See you in 2021!
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 50,
  publishedAt: Date(timeIntervalSince1970: 1608703200),
  title: "2020 Year-in-review"
)
