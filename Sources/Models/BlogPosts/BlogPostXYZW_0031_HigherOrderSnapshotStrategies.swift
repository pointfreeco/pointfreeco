import Foundation

public let post0031_HigherOrderSnapshotStrategies = BlogPost(
  author: .brandon,
  blurb: """
How to enrich snapshot testing strategies with additional behavior using higher-order constructions.
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://s3.amazonaws.com/pointfreeco-blog/posts/0031-higher-order-snapshot-testing/poster.jpg")
    ),

    .init(
      content: """
 ---

We love higher-order constructions here on Point-Free. For the uninitiated, if you have some construction in Swift, say a generic type `F<A>`, then a _higher-order_ version of it is simply a function `(F<A>) -> F<B>`. That is, a function that takes your construction as input and returns it as output. Considering such higher-order constructions instantly allows you to enrich your code with very little work.

We've considered higher-order constructions quite a bit on Point-Free:

* A higher-order [function](https://www.pointfree.co/episodes/ep5-higher-order-functions) is a function that takes a function as input and returns a function as output.
* A higher-order [random number generator](https://www.pointfree.co/episodes/ep30-composable-randomness) is a function that takes an RNG as input and returns an RNG as output. This, for example, allows you to construct randomly sized arrays of random elements given more basic generators.
* A higher-order [parser](https://www.pointfree.co/episodes/ep62-parser-combinators-part-1) is a function that takes a parser as input and returns a parser as output. This, for example, allows you to parse any number of values from a string given a way to parse a single value.
* A higher-order [reducer](https://www.pointfree.co/episodes/ep71-composable-state-management-higher-order-reducers) is a function that takes a reducer as input and returns a reducer as output. This, for example, allows you to add logging abilities to any reducer.

We'd like to describe yet another application of higher-order ideas: enhancing [snapshot testing](https://github.com/pointfreeco/swift-snapshot-testing) strategies!

## Snapshot Testing

Snapshot testing is a form of testing that saves a snapshot of a value you want to assert against, so that when you perform the assertion you compare the current value against a value saved to disk. The most popular form of snapshot testing is screenshot testing, in which you snapshot some kind of view into an image so that a single pixel difference can be caught if needed.

We first discussed snapshot testing in order to explore alternatives to protocol-oriented programming. We started by building the entire library in the protocol-oriented style ([part 1](https://www.pointfree.co/episodes/ep37-protocol-oriented-library-design-part-1), [part 2](https://www.pointfree.co/episodes/ep38-protocol-oriented-library-design-part-2)), and although it worked just fine, there were definitely some drawbacks. It wasn't capable of snapshotting types in multiple ways, and it was quite inert and rigid.

So, we [scrapped the protocols](https://www.pointfree.co/episodes/ep39-witness-oriented-library-design) and tried using simple, concrete data types to express the abstraction of snapshotting, and amazing things happened! Not only could we define multiple snapshot strategies for a single type, but snapshot strategies became a transformable thing. In particular, we defined a [`pullback`](https://www.pointfree.co/blog/posts/22-some-news-about-contramap) operation that allows one to pullback snapshot strategies on "smaller" types to strategies on "larger" types. For example, we can _pullback_ the image snapshotting strategy on `UIView` _back_ to an image snapshotting strategy on `UIViewController` via the function `{ $0.view }`.

These types of transformations were completely hidden from us when dealing with protocols. If you are interested in seeing how to use our library in a real world code base, you may be interested in our 🆓 [tour of snapshot testing](https://www.pointfree.co/episodes/ep41-a-tour-of-snapshot-testing).

## Waiting for Strategies

But what we didn't discuss too much in our snapshot testing episodes is the concept of "higher-order snapshot strategies", that is, functions that transform existing strategies into new strategies. Of course, the `pullback` operation is an example of such an operation, but there is so much more to explore.

A higher-order snapshot strategy allows you to enhance an existing strategy with behavior that it doesn't need to know anything about. As a concrete example, many times when snapshotting a value we need to wait a little to give it time to prepare itself. Views may be animating, controllers may be pushing/popping, and alerts may be appearing. Unfortunately we do not have easy hooks into those lifecycle events, and so we really have no choice but to wait for a little bit of time.

The standard way to allow for this behavior in `XCTestCase` is using expectations:

```swift
func testController() {
  let vc = // create your view controller

  // Wait a little bit of time using expectations
  let expectation = self.expectation(description: "wait")
  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    expectation.fulfill()
  }
  self.wait(for: [expectation], timeout: 2)

  // Assert the snapshot after waiting...
  assertSnapshot(matching: vc, as: .image)
}
```

It's not terrible, a little bit of boilerplate, and maybe we could even hide that in a helper on `XCTestCase`. Perhaps better would be to bake it directly into the `assertSnapshot` helper so that we could allow anyone snapshotting to easily wait for some time:

```swift
func testController() {
  let vc = // create your view controller

  // Assert the snapshot after waiting...
  assertSnapshot(matching: vc, as: .image, wait: 1)
}
```

That's quite a bit nicer. However, the `assertSnapshot` function is quite complicated ([here's](https://github.com/pointfreeco/swift-snapshot-testing/blob/219085ad5fbf0725b685a95da84623b187c6ae55/Sources/SnapshotTesting/AssertSnapshot.swift#L155-L285) the helper that powers it). In fact, it's already a bit too long for comfort, and adding this additional waiting logic comes at a serious cost.

Luckily for us, we can allow any snapshot strategy to be enriched with this functionality without needing special helpers on `XCTestCase` or ballooning the `assertSnapshot` API. And the tool we will use is none other than higher-order snapshot strategies!

We want to transform an existing strategy such that when we invoke its `snapshot` function we will automatically bake in the waiting logic. We can start by getting the signature of such a transformation in place:

```swift
extension Snapshotting {
  static func waiting(
    for duration: TimeInterval,
    on strategy: Snapshotting
  ) -> Snapshotting {
    fatalError("Unimplemented")
  }
}
```

We chose to define this as a static function so that at the call site in a test it would look like this:

```swift
func testController() {
  let vc = // create your view controller

  // Assert the snapshot after waiting...
  assertSnapshot(matching: vc, as: .waiting(for: 1, on: .image))
}
```

The first thing we need to do in this unimplemented method is return a new `Snapshotting` instance. We could call its initializer, which requires a `pathExtension`, a `diffing` strategy, and an `snapshot` function.

```swift
extension Snapshotting {
  static func waiting(
    for duration: TimeInterval,
    on strategy: Snapshotting
  ) -> Snapshotting {
    return Snapshotting(
      pathExtension: strategy.pathExtension,
      diffing: strategy.diffing,
      snapshot: { value in
        fatalError("Unimplemented")
    })
  }
}
```

But because these arguments are just passthroughs, and we are purely concerned with transforming how we snapshot the value, we can leverage `pullback` instead:

```swift
extension Snapshotting {
  static func waiting(
    for duration: TimeInterval,
    on strategy: Snapshotting
  ) -> Snapshotting {
    return self.pullback { value in
      fatalError("Unimplemented")
    }
  }
}
```

Inside the pullback we can finally do our expectation work. It will look almost exactly like the expectation work we did previously, except this time since we are operating outside an `XCTestCase`, so we need to use `XCTestExpectation` and `XCTWaiter` directly:

```swift
extension Snapshotting {
  static func waiting(
    for duration: TimeInterval,
    on strategy: Snapshotting
  ) -> Snapshotting {
    return strategy.pullback { value in
      let expectation = XCTestExpectation(description: "Wait")
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        expectation.fulfill()
      }
      _ = XCTWaiter.wait(for: [expectation], timeout: duration + 1)
      return value
    }
  }
}
```

And just like that we have the ability to transform any snapshot strategy into one that can wait for a bit of time before it performs its snapshot work!

## Conclusion

We have now shown that higher-order snapshot strategies allow us to add the functionality of waiting before taking snapshots without making any changes to the core library. All of the code we wrote could live outside the library, and that is the power of having a transformable and composable API. It allows you to enrich the functionality of a construction without needing to bake that functionality directly into the library.

Incidentally, we have also added this higher-order snapshot strategy to our open source library 😀. Check out the PR that adds the wait functionality [here](https://github.com/pointfreeco/swift-snapshot-testing/pull/268)!
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "https://s3.amazonaws.com/pointfreeco-blog/posts/0031-higher-order-snapshot-testing/poster.jpg",
  id: 31,
  publishedAt: Date(timeIntervalSince1970: 1573106400),
  title: "Higher-Order Snapshot Testing"
)
