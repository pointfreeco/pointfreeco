import Foundation

extension Episode {
  static let ep80_theCombineFrameworkAndEffects_pt1 = Episode(
    blurb: """
      Let's explore the Combine framework and its correspondence with the Effect type. Combine introduces several concepts that overlap with how we model effects in our composable architecture. Let's get an understanding of how they work together and compare them to our humble Effect type.
      """,
    codeSampleDirectory: "0080-combine-and-effects-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 269_920_178,
      downloadUrls: .s3(
        hd1080: "0080-1080p-fb5b81a69c09492f88d11c1084de0308",
        hd720: "0080-720p-c9f731bd943c49dc9c22bba9a3c41039",
        sd540: "0080-540p-9616648f9cf644ecb30bf9dd674e974e"
      ),
      vimeoId: 371_024_746
    ),
    id: 80,
    length: 25 * 60 + 10,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_573_452_000),
    references: [
      .combineFramework,
      .reactiveSwift,
      .rxSwift,
      .reactiveStreams,
      .deferredPublishers,
      .lazyEvaluation,
      .whyFunctionalProgrammingMatters,
      .promisesAreNotNeutralEnough,
    ],
    sequence: 80,
    title: "The Combine Framework and Effects: Part 1",
    trailerVideo: .init(
      bytesLength: 58_885_115,
      downloadUrls: .s3(
        hd1080: "0080-trailer-1080p-e6b2f035dcb6418f822f35ba75a46df2",
        hd720: "0080-trailer-720p-cd0b3121c4e14a6a8b86bf1f6c6de2b5",
        sd540: "0080-trailer-540p-fe1f91bc1bcc49eea0942b73784dbb71"
      ),
      vimeoId: 371_024_665
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      The current version of `Effect` is "lazy": it is only evaluated the moment the `run` functions is called. Define an "eager" version of the `Effect` type that is evaluated the moment it is constructed.

      If you have any trouble defining such a type, consider the fact that in being eager, the work should be executed immediately, but call(s) to `run` may happen before _or_ after the work completes. This means:

      - A value must be set at some later time. Value types can only be mutated within a local, in-out scope, so you may need to reach for a class instead of a struct.

      - Because this value is being stored, you can cache it. This means the work only needs to be performed once.

      - There may be multiple requests for the value of a single effect. Ensure that both calls to `run` before the work has completed, as well as calls to `run` after the work has completed, feed the value to the callback. Keeping track of these calls may require introducing additional state.
      """#,
    solution: #"""
      ```swift
      class Effect<A> {
        var callbacks: [(A) -> Void] = []
        var value: A?

        init(run: @escaping (@escaping (A) -> Void) -> Void) {
          run { value in
            self.callbacks.forEach { callback in callback(value) }
            self.value = value
          }
        }

        func run(_ callback: @escaping (A) -> Void) {
          if let value = self.value {
            callback(value)
          }
          self.callbacks.append(callback)
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Continuing the previous exercise, improve the eager effect by making things thread-safe. To optimize for performance, you could use `os_unfair_lock` to protect access to the mutable storage that manages the resulting value and requests for it, but be wary of recursive calls to the lock by running the callbacks _outside_ of the lock.

      You could also use `NSRecursiveLock` to simplify this logic at the cost of some performance.
      """#,
    solution: #"""
      An example of `os_unfair_lock` is below. It synchronizes reads and writes to storage, and runs callbacks _outside_ of the lock in order to prevent recursive deadlocks.

      ```swift
      import Darwin

      class Effect<A> {
        var callbacks: [(A) -> Void] = []
        var value: A?
        var lock = os_unfair_lock()

        init(run: @escaping (@escaping (A) -> Void) -> Void) {
          run { value in
            let callbacks: [(A) -> Void]
            os_unfair_lock_lock(&self.lock)
            self.value = value
            callbacks = self.callbacks
            os_unfair_lock_unlock(&self.lock)
            callbacks.forEach { callback in callback(value) }
          }
        }

        func run(_ callback: @escaping (A) -> Void) {
          let value: A?
          os_unfair_lock_lock(&self.lock)
          if let aValue = self.value {
            value = aValue
          } else {
            value = nil
          }
          self.callbacks.append(callback)
          os_unfair_lock_unlock(&self.lock)
          if let value = value {
            callback(value)
          }
        }
      }
      ```
      """#
  ),
]

private let _transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: #"Introduction"#,
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      In the past few weeks we finally uncovered how we want to think about side effects in the architecture that we have been developing ([part 1](/episodes/ep76-effectful-state-management-synchronous-effects), [part 2](/episodes/ep77-effectful-state-management-unidirectional-effects), [part 3](/episodes/ep78-effectful-state-management-asynchronous-effects), [part 4](/episodes/ep79-effectful-state-management-the-point)). It was probably our most requested episode, and what we discovered is that if you want to model your application's architecture in terms of reducers, then a side effect is nothing more than returning a value that encapsulates a unit of work which is then executed by the store. This allows our reducers to be nice and understandable, and delegates the messy execution of effects to the store, where it interprets them at runtime.
      """#,
    timestamp: (0 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The value that is returned from our reducer was called `Effect`, and it was really just a renaming of a type that we had encountered many times on Point-Free, previously called `Parallel`. It's simply a struct that wraps a function which takes a function as its first argument, sometimes called a "callback", and then just returns void. This allows us to represent a unit of asynchronous work as a value, for example a network request could be represented as an `Effect` value which invokes the callback when a `URLSession` data task finishes. We also saw that this `Effect` type supports a `map` operation, which gives us a lightweight way to transform effects, and we saw that this allowed us to greatly clean up the effectful code in our application.
      """#,
    timestamp: (0 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, there was something a little strange about how we ended that series of episodes. There is something in the iOS community, and even directly in the Apple ecosystem, that looks a lot like the `Effect` type. There are many names for this type, but the root idea is sometimes known as "reactive streams", and there are implementations of this idea in many open source libraries, such as [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) and [RxSwift](https://github.com/ReactiveX/RxSwift), and most recently Apple threw their hat into the ring with their [Combine framework](https://developer.apple.com/documentation/combine).
      """#,
    timestamp: (0 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So in this episode we want to leverage all of that great work from these communities to show how we don't have to maintain our own reactive effect library for our architecture. We truly can replace our `Effect` type with any of these libraries, and things should hum along just fine. But, for the purpose of this episode we need choose one, and we will choose `Combine` for simplicity since we don't need to bring in a dependency. I want to stress that everything that happens in this episode would work equally well for ReactiveSwift and RxSwift, and we highly encourage you to port the reactive library of your choice into the architecture to prove it.
      """#,
    timestamp: (1 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"The Effect type: a quick recap"#,
    timestamp: (2 * 60 + 18),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's begin by exploring the Combine API a bit so that we can see how it compares with the `Effect` type we previously designed.
      """#,
    timestamp: (2 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We've discussed the shape of the `Effect` type many times on Point-Free, first in our exploration to understand the `map` function, then in trying to understand contravariance, then again when trying to understand the properties of `zip` and `flatMap`, and then yet again when we needed to refactor our snapshot testing library to work with asynchronous values. Most recently we gave this shape the name `Effect`, and here it is in all its glory:
      """#,
    timestamp: (2 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public struct Effect<A> {
        public let run: (@escaping (A) -> Void) -> Void

        public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
          return Effect<B> { callback in self.run { a in callback(f(a)) } }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is an extremely simple type. It expresses the idea of a type has the power to deliver values to you whenever it wants. This is perfect for asynchrony. For example:
      """#,
    timestamp: (2 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      import Dispatch

      let anIntInTwoSeconds = Effect<Int> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          callback(42)
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This value represents an integer that can be delivered at a later time, whenever the value wants to be delivered. No work is done immediately. It only does work when we decide to run the value:
      """#,
    timestamp: (2 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      anIntInTwoSeconds.run { int in print(int) }
      // 42
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this will print after 2 seconds.
      """#,
    timestamp: (3 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This property, of not doing work immediately, is known as "laziness". The work is done only when requested. The opposite of this is known as "eager", and there are some small changes we could make to the `Effect` type so that the moment it is created it begins doing its work. This will be an important distinction for us to understand soon.
      """#,
    timestamp: (3 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      `Effect` also supports a `map` operation, which gives us a very simple way to transform the value that is held inside:
      """#,
    timestamp: (4 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let squared = anIntInTwoSeconds.map { $0 * $0 }
      // Effect<Int>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's the basics of the `Effect` type, but we could say much, much more. For example, this type definitely supports a `zip` operation for running many effects in parallel and then gathering their values together into one value, and it supports a `flatMap` operation, which allows you to sequence asynchronous values together. And we could consider more complex "higher-order effects", which are functions that take effects as input and return effects as output. There are lots of things you can implement with such things, like cancellation and debouncing.
      """#,
    timestamp: (4 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But, at its core the `Effect` type is quite simple. So, if you are comfortable with that material, then it doesn't take too much work to gain a basic understanding of Combine. Combine is like a supercharged, beefed-up `Effect` on steroids. It expresses everything that the `Effect` type can express, but also a ton more.
      """#,
    timestamp: (5 * 60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"The Combine-Effect Correspondence"#,
    timestamp: (5 * 60 + 15),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      At its root, the Combine framework has two concepts: publishers and subscribers. Publishers are types that can deliver values to anyone who is interested. This is exactly what `Effect` is, but Combine's publishers come with more bells and whistles. Subscribers are types that can receive values. We don't have a name for this concept in our `Effect` type world, but the closest concept is when we invoke the `run` method on an effect in order to make the effect do its work. Combine dedicates a type to the concept subscriber because they support a lot more, including cancellation and demand. Cancellation allows you to stop a subscriber from getting any future values, and demand allows subscribers to communicate to publishers how many values they want to receive.
      """#,
    timestamp: (5 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      That right there is the basic correspondence between Combine and our `Effect` type. When we say "publisher" just think of our `Effect` type, and when we say "subscriber" just think of us hitting `run` on an effect.
      """#,
    timestamp: (5 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Publishers"#,
    timestamp: (5 * 60 + 54),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      But let's get our hands a little dirtier now and show how to actually create publishers and subscribers, and see how the API relates to our `Effect` type.
      """#,
    timestamp: (5 * 60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's start simple. Over in the effect world we very easily created a value that was delivered after a small delay:
      """#,
    timestamp: (5 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let anIntInTwoSeconds = Effect<Int> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          callback(42)
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      How can we accomplish this with Combine? There are high level operators that will do this for us quickly, but let's start from first principles. How can we construct a publisher?
      """#,
    timestamp: (6 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      import Combine

      Publisher.init
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Protocol 'Publisher' can only be used as a generic constraint because it has Self or associated type requirements
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Well, this brings us to our first lesson when it comes to Combine: most concepts are expressed as protocols rather than concrete types. The `Publisher` type is in fact a protocol, and it even has associated types, and so we won't be dealing directly with the `Publisher` type directly very often.
      """#,
    timestamp: (6 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Because of this deficiency of protocols with associated types, Combine gives us a concrete implementation of the `Publisher` protocol, called `AnyPublisher`. It is very popular to provide "any" wrappers (also known as "type erased" wrappers) for protocols so that you can easily instantiate instances of the protocol without having to make a custom conformance yourself. So, let's see how we can create an `AnyPublisher`:
      """#,
    timestamp: (6 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      AnyPublisher.init(<#publisher: Publisher#>)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Hmmm, it only has one single initializer, which just takes a publisher. So this doesn't help us right now. We are specifically looking for ways to create publishers without needing to conform a whole new type to the `Publisher` protocol.
      """#,
    timestamp: (7 * 60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Sometimes when these "any" wrappers are provided there is a way to instantiate them with all the functionality of the underlying protocol.
      """#,
    timestamp: (7 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      For example, the `AnyIterator` wrapper for the `Iterator` protocol gives a simple way to create an iterator by providing a closure that represents computing the next value in an iteration:
      """#,
    timestamp: (7 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var count = 0
      let iterator = AnyIterator<Int>.init {
        count += 1
        return count
      }
      // AnyIterator<Int>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This represents an iterator that counts from 1 up until infinity, but we can take the first 10 values:
      """#,
    timestamp: (7 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Array(iterator.prefix(10))
      // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Unfortunately, `AnyPublisher` isn't giving us anything nice like this.
      """#,
    timestamp: (8 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, what else do we have at our disposal? Combine gives us another concrete implementation of `Publisher` called `Future`, and it comes with a callback-based initializer just like the `Effect` type:
      """#,
    timestamp: (8 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Future.init(<#attemptToFulfill: (@escaping (Result<_, _>) -> Void) -> Void#>)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This initializer gives you a callback that you can invoke with a result value. A result is used here because a future can either succeed with a value or it can fail. This means we need to specify these types before we can use this initializer. For now, let's just use `Never` for the failure generic to represent a publisher that can never fail:
      """#,
    timestamp: (8 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Future<Int, Never>.init { callback in
        <#code#>
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now we can just invoke this callback once we have some data. For example:
      """#,
    timestamp: (9 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Future<Int, Never> { callback in
        callback(.success(42))
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can also add a delay to our future value to make its delivery later:
      """#,
    timestamp: (9 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let aFutureInt = Future<Int, Never> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          callback(.success(42))
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so now creating this future value is starting to look a lot like how we created values of our `Effect` type. We just open a closure, we are handed a callback, and then we can invoke that callback with our data whenever we want.
      """#,
    timestamp: (9 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Subscribers"#,
    timestamp: (10 * 60 + 22),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      To get the value out of this future we have to subscribe. This is analogous to when we `run` our effect values, but instead we can `subscribe`. We have a bunch of choices when subscribing.
      """#,
    timestamp: (10 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The one we are actually interested in takes a subscriber:
      """#,
    timestamp: (10 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .subscribe(<#subscriber: Subscriber#>)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The others are more about which dispatch queue or run loop the publisher is subscribed on.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Recall that at its core Combine is primarily concerned with publishers and subscribers. A publisher, like our `Future` value here, is a type that can deliver values to anyone interested, and a subscriber is a type that can receive values. So, providing a `Subscriber` here somehow allows us to receive the value from the future and then do something with that value, like print it. So, how do we create a subscriber?
      """#,
    timestamp: (10 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Subscriber.init
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Protocol 'Subscriber' can only be used as a generic constraint because it has Self or associated type requirements
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Welp, again Combine abstracted this concept to be behind a protocol. And it has associated types. So, we can't really deal with `Subscriber`'s directly.
      """#,
    timestamp: (11 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But, luckily Combine gives an `AnySubscriber` wrapper type, and unlike `AnyPublisher` it is actually useful for our situation. It has 4 initializers.
      """#,
    timestamp: (11 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And the first listed here is particularly interesting for us:
      """#,
    timestamp: (11 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      AnySubscriber.init(
        receiveSubscription: <#((Subscription) -> Void)?#>,
        receiveValue: <#((_) -> Subscribers.Demand)?#>,
        receiveCompletion: <#((Subscribers.Completion<_>) -> Void)?#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This allows us to tap into the 3 defining events for a subscription:
      """#,
    timestamp: (11 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - The moment the subscriber is attached to the publisher, which is represented by the fact that we are handed a `Subscription` object. It's like a receipt for the subscriber being connected. We can use the subscription object to signal how many values we want from the publisher.
      """#,
    timestamp: (11 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - The moment a publisher delivers a value, which allows us to do something with that value, like print it. It needs to return a `Demand` value, which allows us to tell the publisher how many more values we want from them. This is a powerful feature, especially for publishers that can send a firehose of data, but we don't need this power right now.
      """#,
    timestamp: (12 * 60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - And finally, the moment the publisher finishes, and it delivers a completion value, which indicates that it either finished successfully or that it finished with a failure.
      """#,
    timestamp: (12 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, let's fill in these closures so that we can create our subscription:
      """#,
    timestamp: (12 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      aFutureInt.subscribe(
        AnySubscriber<Int, Never>(
          receiveSubscription: { subscription in
            print("subscription")
            subscription.request(.unlimited)
        },
          receiveValue: { value in
            print("value", value)
            return .unlimited
        },
          receiveCompletion: { completion in
            print("completion", completion)
        })
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And we can now run it.
      """#,
    timestamp: (13 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      // subscription
      // value 42
      // completion finished
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But also, it seems like a lot, certainly a lot more than just hitting `run` on an effect. But also this is packing a bigger punch. For one it has the concept of demand built in, which is powerful but is also not needed right now. It also has the ability to cancel, which can be done with the `cancel` method on the subscription:
      """#,
    timestamp: (14 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      subscription.cancel()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Again, can be powerful, but we don't exactly need it right now.
      """#,
    timestamp: (14 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Luckily, there is a more convenient way to subscribe to a publisher for when you don't need the full power of demanding subscribers. There are two methods on publishers called `sink`.
      """#,
    timestamp: (14 * 60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      They allow you to subscribe to a publisher by tapping only into the `receiveValue` and `receiveCompletion` events. You don't get access to the actual subscription and you don't get to control the demand. It assumes unlimited demand.
      """#,
    timestamp: (14 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's very easy to use this method, it basically looks just like `run` for effects:
      """#,
    timestamp: (14 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      aFutureInt.sink { int in
        print(int)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, when we do this nothing prints. This is because `sink` actually returns something, whereas `subscribe` did not, and the return value is what allows us to cancel future values from being delivered to our sink. And since we are not holding onto that value it is getting deallocated immediately, and that cancels the subscription.
      """#,
    timestamp: (15 * 60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The type of the return value is called an `AnyCancellable`, yet another one of those "any" wrappers but this time for the `Cancellable` protocol, and if we hold onto it we will finally get our value delivered after 2 seconds:
      """#,
    timestamp: (15 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let cancellable = aFutureInt.sink { int
        in print(int)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can even cancel this `cancellable` value to prevent the value from being delivered to our sink:
      """#,
    timestamp: (15 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      cancellable.cancel()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now this is starting to look a lot more similar to what we do when we run effects. We can just invoke one method and we get the ability to tap into any value that is delivered from the publisher. It's worth noting that the playground has some implicit behavior here that is keeping this `cancellable` value alive for a long time, which is what allows our value to be delivered. In a real application you would need to hold onto this value yourself, like stored in the instance variable of a view controller or something.
      """#,
    timestamp: (15 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Eagerness vs. laziness"#,
    timestamp: (16 * 60 + 18),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're starting to see the correspondence between the `Effect` type and the Combine framework, which might lead us to believe that we could relieve our old pal `Effect` from their duties in our architecture and instead start leaning on the Combine framework more. Maybe we just replace all instances of `Effect`  with `Future` and all instances of `run` with `sink`.
      """#,
    timestamp: (16 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Unfortunately, this isn't quite true right now. There is a subtle problem with our code right now, so let's address that.
      """#,
    timestamp: (16 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      To see the first problem, let's add a print statement inside our future:
      """#,
    timestamp: (16 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let aFutureInt = Future<Int, Never> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          print("Hello from inside the future!")
          callback(.success(42))
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      If we run this code we get a print statement even though the future was cancelled.
      """#,
    timestamp: (16 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can even comment the entire sink out.
      """#,
    timestamp: (17 * 60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      //let cancellable = aFutureInt.sink { int in
      //  print(int)
      //}
      //cancellable.cancel()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We still get the print statement, even though no one even references the future anymore.
      """#,
    timestamp: (17 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is happening because the `Future` type is eager, which means that it starts doing its work the moment its created, not when it is subscribed to.
      """#,
    timestamp: (17 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is a pretty big gotcha, and certainly not something we want in our reducers. The beauty of our reducers is that they are pure functions for changing the current state of the application given some user action, and then they returned an array of effects that would be later run by the store. If instead we used these `Future` types then we would start executing this the moment the reducer is invoked. This would be especially surprising in a test if we wanted to just test how a reducer changes some state, but secretly behind the scenes effects are firing off!
      """#,
    timestamp: (17 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Luckily there's a pretty easy way to turn an eager publisher into a lazy one in Combine. We can simply wrap it in a `Deferred` publisher, which has an initializer that takes a closure that returns a publisher:
      """#,
    timestamp: (18 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let aFutureInt = Deferred {
        Future<Int, Never> { callback in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from inside the future!")
            callback(.success(42))
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This makes it so that the future does not run immediately, but if we create a sink it will fire up:
      """#,
    timestamp: (18 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let cancellable = aFutureInt.sink { int in
        print(int)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      OK, that fixes the eagerness problem, and also makes for an important lesson when dealing with Combine: sometimes things in Combine are eager, but we never want eager things in our architecture. Luckily there is a nice way to turn eager publishers into lazy publishers, but it would also be nice if Combine's architecture clearly called out publishers that are eager.
      """#,
    timestamp: (18 * 60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Subjects"#,
    timestamp: (19 * 60 + 14),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next problem with our use of `Future` is that it's actually only meant to represent a single value that can be delivered at a later time. It can't deliver multiple values:
      """#,
    timestamp: (19 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let aFutureInt = Deferred {
        Future<Int, Never> { callback in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from inside the future!")
            callback(.success(42))
            callback(.success(1729))
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      When this runs we only we only get 42 delivered to our sink. Once the `Future` receives a value it instantly completes, and no other values will be emitted.
      """#,
    timestamp: (19 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this is `Future`'s intended design. We could definitely have effects that need to deliver multiple values. For example, what if we had an effect that represented a socket connection. We would want all of the values from that socket connection to be delivered to our reducer. We could also have an effect that represents reachability, and each time the reachability state of the app changes we could emit a value so that our reducer can react to those events.
      """#,
    timestamp: (19 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Our effect type doesn't have this limitation:
      """#,
    timestamp: (20 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let twoIntsInTwoSeconds = Effect<Int> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          callback(42)
          callback(1729)
        }
      }

      twoIntsInTwoSeconds.run { print($0) }
      // 42
      // 1729
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, although the initializer of `Future` looks a lot like our `Effect` type, it isn't quite the same. It seems that there just is no publisher in the Combine framework that allows you to initialize it with a closure that takes a callback so that you can feed it as many values as you want, whenever you want.
      """#,
    timestamp: (20 * 60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Fortunately, there's another concept in Combine for when we need the capability of sending multiple values to a publisher, which can in turn notify its subscribers. It's known as a "subject", and it's not a concept that we had to deal with for our simple `Effect` type, but it's very useful for bridging non-Combine worlds to the Combine world.
      """#,
    timestamp: (20 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Subjects are represented by the `Subject` type, which if we try to initialize:
      """#,
    timestamp: (21 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Subject.init
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      `Subject`, like `Publisher` and `Subscriber` is also protocol and so not super useful on its own.
      """#,
    timestamp: (21 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Luckily Combine comes with two concrete implementations of the `Subject` protocol, called passthrough and current value subjects:
      """#,
    timestamp: (21 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let passthrough = PassthroughSubject<Int, Never>()
      let currentValue = CurrentValueSubject<Int, Never>(value: 1)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The primary difference between these is that with the `CurrentValueSubject` you can access the most recent value that was emitted (which is why we have to provide an explicit value when creating it), whereas values in passthrough subjects can only be accessed by subscribing.
      """#,
    timestamp: (22 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can subscribe to a subject just like a publisher, either using the `subscriber` method or the `sink` method, and in order to get this later value we need to hold onto a cancellable so that our subscription stays alive:
      """#,
    timestamp: (22 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let c1 = passthrough.sink { x in print("passthrough", x) }
      let c2 = currentValue.sink { x in print("currentValue", x) }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      When we run this, we immediately get a current value, but the passthrough subject remains idle.
      """#,
    timestamp: (22 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      // currentValue 2
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then we can send values directly to the subject, which is generally not possible with publishers:
      """#,
    timestamp: (23 * 60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      passthrough.send(42)
      currentValue.send(1729)
      // passthrough 42
      // currentValue 1729
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're free to send as many values as we want, unlike the `Future` type.
      """#,
    timestamp: (23 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      passthrough.send(42)
      currentValue.send(1729)
      passthrough.send(42)
      currentValue.send(1729)
      // passthrough 42
      // currentValue 1729
      // passthrough 42
      // currentValue 1729
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This certainly isn't as easy as it was for the `Effect` type, but nonetheless Combine does give us the ability to create a publisher that we can send many values so that it publishes those values to its subscribers.
      """#,
    timestamp: (23 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Next time: refactoring the architecture"#,
    timestamp: (23 * 60 + 48),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      So that's the basics of the Combine framework. There is a ton more to say, but we've learned just enough to be dangerous. And we've learned the correspondence between Combine and the Effect type.
      """#,
    timestamp: (23 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      To recap: in the Combine world we have publishers and in the Effect world we have `Effect`, and in the Combine world we have subscribers, and in the Effect world we have `run`. Luckily, Combine comes with a bunch of bells and whistles, though, like `sink`, which works just like `run` on `Effect`. And further, Combine comes with `Future`, which are created a lot like `Effect`s, but with the caveats that they are eager and need to be wrapped in a `Deferred` publisher, and that they can only receive a single value, which means we must use another Combine concept, subjects, to simply set up more long-living event streams.
      """#,
    timestamp: (24 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's the basic correspondence, so the question is can we refactor the Composable Architecture that we have been building to leverage Combine's functionality rather than building it ourselves from scratch?
      """#,
    timestamp: (24 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's refactor away the `Effect` type so that we can leverage Combine and avoid reinventing the wheel...next time!
      """#,
    timestamp: (24 * 60 + 58),
    type: .paragraph
  ),
]
