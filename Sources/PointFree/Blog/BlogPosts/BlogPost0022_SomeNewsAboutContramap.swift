import Foundation

let post0022_someNewsAboutContramap = BlogPost(
  author: .brandon,
  blurb: """
We've seen that contramap is a powerful operation, but the name isn't fantastic. We propose a much
more intuitive name for this operation, and in doing so make our code much easier to read.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .video(
        poster: "https://d1iqsrac68iyd8.cloudfront.net/posts/0022-some-news-about-contramap/poster.png",
        sources: [
          "https://d1iqsrac68iyd8.cloudfront.net/posts/0022-some-news-about-contramap/0022-pullback.m3u8",
        ]
      )
    ),

    .init(
      content: """
---

> We've seen that `contramap` is a powerful operation, but the name isn't fantastic. We propose a much
more intuitive name for this operation, and in doing so make our code much easier to read.

---

A few months ago we introduced the idea of [contravariance](/episodes/ep14-contravriance), and showed that
it’s a very natural idea hidden in a very counterintuitive package. It’s like the
[`map`](/episodes/ep13-the-many-faces-of-map) we all know and love on arrays and optionals, but it goes in
the opposite direction. We applied it to the idea of predicate sets, and showed that it helps us see a form
of composition that we may not have looked for otherwise.

Then, [last week](/episodes/ep34-protocol-witnesses-part-2), in a very unexpected way, we showed that
contramap surfaced when discussing how to convert protocols into concrete datatypes. That was very surprising,
and powerful, because it allowed us to transform witnesses to a protocol into all new witnesses,
which is something completely hidden from us when dealing with only protocols.

We hope that we have convinced you that `contramap` is a very powerful tool for composition, even though
it seems counterintuitive and can be hard to grasp at first. So that’s why it might seem surprising that we
are…

## Saying goodbye to `contramap`, hello `pullback`!

However, the name `contramap` isn’t fantastic. In one way it’s nice because it is indeed the
contravariant version of `map`. It has basically the same shape as map, it’s just that the arrow flips the
other direction. Even so, the term may seem a little overly-jargony and may turn people off to the idea
entirely, and that would be a real shame.

Luckily, there’s a concept in math that is far more general than the idea of contravariance, and in the case
of functions is precisely `contramap`. And even better it has a great name. It’s called the
[pullback](https://en.wikipedia.org/wiki/Pullback_(category_theory)). Intuitively it expresses the idea of
pulling a structure back along a function to another structure. Let’s see why this is a really
great name for this operation.

## Taking `pullback` for a spin

[Recall](/episodes/ep14-contravriance) that we previously defined a `PredicateSet` type that simply wrapped
a function that returns boolean values.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
struct Predicate<A> {
  let contains: (A) -> Bool
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This allows us to express sets that potentially hold infinitely many values, which Swift's `Set` is not
capable of.

And we could create predicate sets easily enough. For example, one that holds all integers less than 10:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let isLessThan10 = PredicateSet { $0 < 10 }

isLessThan10.contains(5)  // true
isLessThan10.contains(11) // false
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This is neat, but not particularly interesting. But then we discovered that `PredicateSet` supports a
`contramap` operation, which is precisely what you need to transform predicate sets. We were able to
define it like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension PredicateSet {
  func contramap<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
    return Predicate<B> { self.contains(f($0)) }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We could then use this operation to transform our `isLessThan10` predicate into a predicate on strings:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let shortStrings = isLessThan10.contramap { (s: String) in s.count }

shortStrings.contains("Blob")          // true
shortStrings.contains("Blobby McBlob") // false
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Take careful note that there is no "less than 10" logic in the body of the `contramap` transformation.
All of that is inside the `isLessThan10` predicate. Instead, we are transforming a predicate set of
integers into a predicate set of strings by simply plucking out the character count of a string. This is what
allows you to build lots of small units and piece them together to create more complex units.

Even better, if you use our open source library of function composition helpers,
[Overture](http://github.com/pointfreeco/swift-overture), you can write this in a truly short and
expressive manner:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let shortStrings = isLessThan10.contramap(get(\\String.count))

shortStrings.contains("Blob")          // true
shortStrings.contains("Blobby McBlob") // false
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now let's rename `contramap` to `pullback`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension PredicateSet {
  func pullback<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
    return Predicate<B> { self.contains(f($0)) }
  }
}

import Overture

let shortStrings = isLessThan10.pullback(get(\\String.count))

shortStrings.contains("Blob")          // true
shortStrings.contains("Blobby McBlob") // false
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Simple enough. But now when we read this code it is far more intuitive. We take our `isLessThan10` predicate
and "pull it back" to work on strings by simply getting the string's character count.

Let's look at another example. In [this week's](/episodes/ep35-advanced-protocol-witnesses-part-1) episode
we showed how to convert the `Equatable` protocol into a concrete datatype, and one can define a `pullback`
operation on it:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
struct Equating<A> {
  let equals: (A, A) -> Bool

  func pullback<B>(_ f: @escaping (B) -> A) -> Equating<B> {
    return Predicate<B> { self.equals(f($0), f($1)) }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Using the `pullback` operation we can induce a notion of equating on, say, a `User` value by only knowing
how to equate integers:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

struct User { let id: Int, name: String }

let int = Equating<Int> { $0 == $1 }
let user = int.contramap(get(\\User.id))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This shows just how flexible and transformable concrete types with `pullback` are. Types can only conform
to a protocol in a single way, but often it is completely valid to conform in multiple ways, as seen above.
But when working with concrete datatypes we get to pullback conformances on one type to conformances on
completely unrelated types.

## Naming is hard

Although it’s unfortunate to rename such a fundamental concept after having learned it many months ago,
we think it’s worth it. This name reads well and has a lot of great intuition, and we’re going to use it
going forward on this series. We still think the `contramap` name is still important, mostly because the
`contra`- prefix allows us to transform any concept into its contravariant dual concept, and it will be
creeping into some future episodes, but from now we will be mostly using pullback.
""",
      timestamp: nil,
      type: .paragraph
    ),

    ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0022-some-news-about-contramap/poster.png",
  id: 22,
  publishedAt: .init(timeIntervalSince1970: 1_540_803_600),
  title: "Some news about contramap"
)
