import Foundation

public let post0027_openSourcingGen = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open sourcing Gen: a lightweight wrapper around Swift's randomness API's that makes randomess more composable, transformable and controllable!
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://s3.amazonaws.com/pointfreeco-blog/posts/0027-open-sourcing-gen/cover.jpg ")
    ),

    .init(
      content: """
---

> Today we are open sourcing [Gen](https://github.com/pointfreeco-swift-gen): a lightweight wrapper around Swift's randomness API's that makes randomess more composable, transformable and controllable!

---

We are excited to announce the 0.1.0 release of [Gen](https://github.com/pointfreeco-swift-gen), a new API for expressing randomness in Swift. Its focus is on composability (combining multiple forms of randomness into new forms of randomness), transformability (applying functions to randomness), and controllability (deterministic pseudo-randomness for times we need it). With these three features you can break down large, complex forms of randomness into smaller, simpler pieces, _and_ you can write tests for it!

## Motivation

Swift’s randomness API is powerful and simple to use. It allows us to create random values from many basic types, such as booleans and numeric types, and it allows us to randomly shuffle arrays and pluck random elements from collections.

However, it does not make it easy for us to extend the randomness API. For example, while it may gives us ways of generating random booleans, numeric values, and even ways to shuffle arrays and pluck random elements from arrays, it says nothing about creating random strings, random collections of values, or random values from our own data types.

Further, the API is not very composable, which would allow us to create complex types of randomness from simpler pieces. One primarily uses the API by calling static `random` functions on types, such as `Int.random(in: 0...9)`, but there is no guidance on how to generate new types of randomness from existing randomness.

## `Gen`

`Gen` is a lightweight wrapper over Swift’s randomness APIs that makes it easy to build custom generators of any kind of value. Most often you will reach for one of the static variables inside `Gen` to get access to a `Gen` value:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
Gen.bool // Gen<Bool>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Rather than immediately producing a random value, `Gen` describes a random value that can be produced by calling its `run` method:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let myGen = Gen.bool // Gen<Bool>

myGen.run() // true
myGen.run() // true
myGen.run() // false
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Every random function that comes with Swift is also available as a static function on `Gen`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// Swift's API
Int.random(in: 0...9) // 4

// Gen's API
Gen.int(in: 0...9).run() // 6
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The reason it is powerful to wrap randomness in the `Gen` type is that we can make the `Gen` type composable. For example, a generator of integers can be turned into a generator of numeric strings with a simple application of the `map` function:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let digit = Gen.int(in: 0...9)           // Gen<Int>
let stringDigit = digit.map(String.init) // Gen<String>

stringDigit.run() // "7"
stringDigit.run() // "1"
stringDigit.run() // "3"
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Already this is a form of randomness that Swift's API's do not provide out of the box.

Gen provides many operators for generating new types of randomness, such as `map`, `flatMap` and `zip`, as well as helper functions for generating random arrays, sets, dictionaries, string, distributions and more!

But composability isn't the only reason the `Gen` type shines. By delaying the creation of random values until the `run` method is invoked, we allow ourselves to control randomness in circumstances where we need determinism, such as tests. The `run` method has an overload that takes a `RandomNumberGenerator` value, which is Swift's protocol that powers their randomness API. By default it uses the `SystemRandomNumberGenerator`, which is a good source of randomness, but we can also provide a seedable "pseudo" random number generator, so that we can get predictable results in tests:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
var lcrng = LCRNG(seed: 0)
Gen.int(in: 0...9).run(using: &lcrng) // "8"
Gen.int(in: 0...9).run(using: &lcrng) // "1"
Gen.int(in: 0...9).run(using: &lcrng) // "7"

lcrng.seed = 0
Gen.int(in: 0...9).run(using: &lcrng) // "8"
Gen.int(in: 0...9).run(using: &lcrng) // "1"
Gen.int(in: 0...9).run(using: &lcrng) // "7"
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This means you don't have to sacrifice testability when leveraging randomness in your application.

## Learn more

The `Gen` type has been explored on [Point-Free](https://www.pointfree.com) numerous times. We [began](https://www.pointfree.co/episodes/ep30-composable-randomness) by showing that randomness can be made composable by expressiong it as a function. This allowed us to define `map`, `flatMap` and `zip` operations on randomness, which helped us create very complex forms of randomness for just a few small, simple pieces.

In order to show just how powerful composable randomness is, we wrote a [blog post](https://www.pointfree.co/blog/posts/19-random-zalgo-generator) demonstrating how to create a [Zalgo text](http://www.eeemo.net) generator. This consisted of defining small generators that do a specific thing, such as generating special unicode characters, and the piecing them together to finally give us the generator that allows us to create bizarre strings such as: P̵̙̬̬̝̹̰̜ͧ̿o̎ĩͪͪ͗n͓̪̝̓t̊̏̾̊̆-̦̲̥͉F̠͖͈̮̾́ͨ͐͝r̸͋̆̅̅ͪ̚ë̝͑ͣ̒̏̈́̉e̟̺̪͕̹͆ͩͯ̑ͣ͂̉.

Then we showed how randomness can be made controllable ([part 1](https://www.pointfree.co/episodes/ep47-predictable-randomness-part-1) and [part 2](https://www.pointfree.co/episodes/ep48-predictable-randomness-part-2)) by slightly tweaking `Gen` definition so that it took a `RandomNumberGenerator`, which is the Swift protocol that powers all of Swift's randomness API's. This allowed us to keep all of `Gen`'s nice compositional properties while also allowing us to plug in our own random number generators. In particular, we can use a deterministic, seedable, pseudo-random number generator in tests so that we can still test code that invokes randomness API's.



<!--
For more examples of using Gen to build complex randomness, see our [blog post](https://www.pointfree.co/blog/posts/19-random-zalgo-generator) on creating a Zalgo generator and our two-part video series ([part 1](https://www.pointfree.co/episodes/ep49-generative-art-part-1) and [part 2](https://www.pointfree.co/episodes/ep50-generative-art-part-2)) on creating generative art.
-->

## Try it out today!

The official 0.1.0 release of [Gen](http://github.com/pointfreeco/swift-gen) is on GitHub now, and we have more improvements and refinements coming soon. We hope that Gen will help you control the complexity in your applications that arises from randomness, both by making the randomness simpler to understand _and_ easier to test.
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://s3.amazonaws.com/pointfreeco-blog/posts/0027-open-sourcing-gen/cover.jpg",
  id: 27,
  publishedAt: .init(timeIntervalSince1970: 1552888800),
  title: "Open Sourcing Gen"
)
