import Foundation

extension Episode {
  static let ep81_theCombineFrameworkAndEffects_pt2 = Episode(
    blurb: """
      Now that we've explored the Combine framework and identified its correspondence with the `Effect` type, let's refactor our architecture to take full advantage of it.
      """,
    codeSampleDirectory: "0081-combine-and-effects-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 405_330_619,
      downloadUrls: .s3(
        hd1080: "0081-1080p-45d5a00e9a1346c0bf925c5c87e582b9",
        hd720: "0081-720p-0860db0f98b44d029f1dba499e054014",
        sd540: "0081-540p-b2f91fc2906541ba9f9ed62c34e79992"
      ),
      vimeoId: 371_023_664
    ),
    id: 81,
    length: 38 * 60 + 46,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_574_056_800),
    references: [
      .combineFramework,
      .reactiveSwift,
      .rxSwift,
      .reactiveStreams,
      .deferredPublishers,
    ],
    sequence: 81,
    title: "The Combine Framework and Effects: Part 2",
    trailerVideo: .init(
      bytesLength: 34_771_162,
      downloadUrls: .s3(
        hd1080: "0081-trailer-1080p-c388a5bf16e54f6c8c2511afc89cd845",
        hd720: "0081-trailer-720p-b28dc87560624239ac6ed659b86e9a53",
        sd540: "0081-trailer-540p-8ed927070d6f497bb3c53899086c6e78"
      ),
      vimeoId: 371_019_239
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      We added a `sync` helper to our `Effect` publisher, which takes a block of work that synchronously returns a value and ultimately returned an effect. It was a composition of the `Deferred` and `Just` publishers.

      Taking inspiration from this, introduce an `async` helper to `Effect` that, given a callback block, asynchronously accepts a value.

      ```swift
      extension Effect {
        static func async(
          work: @escaping (@escaping (Output) -> Void) -> Void
        ) -> Effect {
          fatalError("Unimplemented")
        }
      }
      ```

      This function is easiest to implement if you assume the effect is only allowed to emit at most one value. If you want the effect to be able to emit multiple values it will take a lot more work and a deeper understanding of Combine's concepts.
      """#,
    solution: #"""
      ```swift
      extension Effect {
        static func async(
          work: @escaping (@escaping (Output) -> Void) -> Void
        ) -> Effect {
          return Deferred {
            Future { callback in
              work { output in
                callback(.success(output))
              }
            }
          }.eraseToEffect()
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      When translating our Wolfram Alpha effect to Combine, we took several steps to handle any errors by effectively ignoring them. Simplify this reusable logic with an `Effect` helper dedicated to ignoring a publisher's errors.

      ```swift
      extension Publisher {
        func hush() -> Effect<Output> {
          fatalError("Unimplemented")
        }
      }
      ```
      """#,
    solution: #"""
      ```swift
      extension Publisher {
        func hush() -> Effect<Output> {
          return self
            .map(Optional.some)
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToEffect()
        }
      }
      ```
      """#
  ),
  .init(
    problem: """
      Refactor the Composable Architecture and app to use a `Reducer` of the form:

      ```swift
      typealias Reducer<Value, Action> = (inout Value, Action) -> Effect<Action>
      ```

      Note that we are returning a single `Effect<Action>`, not an array.

      What Combine operator can you use for the times that you need to return multiple effects? What should you use for when you do not need to return any effects at all?
      """),
  Episode.Exercise(
    problem: #"""
      In the episode we note that while we chose to refactor the architecture with the Combine framework, we could have just as easily refactored it to work with [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) or [RxSwift](https://github.com/ReactiveX/RxSwift)

      Pick your framework of choice (or both!) and refactor the Composable Architecture accordingly. If using ReactiveSwift you will need to decide between `Signal` and `SignalProducer` for your effect type.
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
      So that's the basics of the Combine framework. There is a ton more to say, but we've learned just enough to be dangerous. And we've learned the correspondence between Combine and the Effect type.
      """#,
    timestamp: (0 * 60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      To recap: in the Combine world we have publishers and in the Effect world we have `Effect`, and in the Combine world we have subscribers, and in the Effect world we have `run`. Luckily, Combine comes with a bunch of bells and whistles, though, like `sink`, which works just like `run` on `Effect`. And further, Combine comes with `Future`, which are created a lot like `Effect`s, but with the caveats that they are eager and need to be wrapped in a `Deferred` publisher, and that they can only receive a single value, which means we must use another Combine concept, subjects, to simply set up more long-living event streams.
      """#,
    timestamp: (0 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's the basic correspondence, so the question is can we refactor the Composable Architecture that we have been building to leverage Combine's functionality rather than building it ourselves from scratch?
      """#,
    timestamp: (1 * 60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's refactor away the `Effect` type so that we can leverage Combine and avoid reinventing the wheel.
      """#,
    timestamp: (1 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Effect as a Combine publisher"#,
    timestamp: (1 * 60 + 27),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      The refactor is pretty straightforward, with only a few twists and turns along the way. Perhaps the simplest way to start is to simply comment out our `Effect` type and replace it with a type alias pointing to a publisher. However, since `Publisher` is a protocol we can't use it directly, we have to actually pick a concrete publisher conformance. We could use the `AnyPublisher` concrete conformance that Apple gives us, but it will be handy to have our own named type so that we can add effect-specific helpers and extensions to it without polluting `AnyPublisher`.
      """#,
    timestamp: (1 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, let's try to create a publisher conformance from scratch:
      """#,
    timestamp: (1 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public struct Effect: Publisher {
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Type 'Effect' does not conform to protocol 'Publisher'
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We need to implement some conformances, so let's see what's required:
      """#,
    timestamp: (2 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public struct Effect: Publisher {
        public typealias Output = <#type#>
        public typealias Failure = <#type#>

      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We need an `Output` and `Failure` type. Remember that an effect's only purpose is to ultimately produce an action that is fed back into the store. Even if the effect errors in some way, like a network request when the device is offline, it still needs to produce an action. So the effect could put a `Result` value inside an action to denote the failure, but the effect publisher itself cannot fail. This means we should use `Never` for the publisher's `Failure` type:
      """#,
    timestamp: (2 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public struct Effect: Publisher {
        public typealias Output = <#type#>
        public typealias Failure = Never

      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The output on the other hand is something that users of this type need to determine, so it should be a generic:
      """#,
    timestamp: (2 * 60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public struct Effect<Output>: Publisher {
        public typealias Failure = Never

      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      With that done there's one more requirement:
      """#,
    timestamp: (2 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      public func receive<S>(
        subscriber: S
      ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        <#code#>
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is called when a subscriber attaches to this publisher, and this is where we need to do our work to send this subscriber values. However, we don't actually want to do any custom work inside here. We just want to serve as a wrapper around publishers, much like `AnyPublisher` is.
      """#,
    timestamp: (3 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So let's just hold onto an `AnyPublisher` under the hood and delegate to it:
      """#,
    timestamp: (3 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let publisher: AnyPublisher<Output, Failure>

      public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Right now the `Effect` publisher is really no different from the `AnyPublisher`, other than its failure has been specialized to `Never`. However, by having our own type we are going to have more control over how it's transformed, which is something we will see very soon.
      """#,
    timestamp: (3 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This has created a number of compiler errors, the first of which is:
      """#,
    timestamp: (4 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      effect.run(self.send)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Value of type 'Effect<Action>' has no member 'run'
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Instead of running our effect we need to call `sink` on it, and we can still pass the `send` method to the receive block:
      """#,
    timestamp: (4 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      effect.sink(receiveValue: self.send)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now we have a warning:
      """#,
    timestamp: (4 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      > ⚠️ Result of call to 'sink(receiveValue:)' is unused
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We technically already have an instance variable for a cancellable in our store:
      """#,
    timestamp: (4 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var cancellable: Cancellable?
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We added this back in our episodes on modularity when we discussed the concept of viewing a store. We showed that it's possible to transform a store that operates on global state and actions into a store that operates on local state and actions. However, in order for changes to the global store to be reflected in the local store we had to subscribe to the global store and replay those changes in the local store.
      """#,
    timestamp: (4 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So we don't want to repurpose this cancellable value, it has a very important responsibility right now. In fact, maybe we should go ahead and rename it to better reflect its purpose:
      """#,
    timestamp: (4 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var viewCancellable: Cancellable?
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We need to keep track of these effect cancellables separately from this view cancellable. We could introduce a new instance variable:
      """#,
    timestamp: (5 * 60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var effectCancellable: Cancellable?
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But really we need a bunch of cancellables. Each reducer can return an array of effects, and so we could potentially be dealing with many effects each time we send an action. So, let's upgrade to an array:
      """#,
    timestamp: (5 * 60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var effectCancellables: [Cancellable] = []
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we just need to retain the cancellable from calling `sink` so that it lives long for our effect to do its job:
      """#,
    timestamp: (5 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      effectCancellables.append(
        effect.sink(receiveValue: self.send)
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, this isn't quite right. This `effectCancellables` array is going to continue to grow as the application progresses. We are never removing cancellables from this array. So, we need some way to know when an effect finishes and then we should remove its cancellable from the array.
      """#,
    timestamp: (5 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is possible using a different overload of `sink` that allows us to tap into the completion event of the publisher:
      """#,
    timestamp: (6 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      effectCancellables.append(
        effect.sink(
          receiveCompletion: { _ in
            <#code#>
          },
          receiveValue: self.send
        )
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Inside this `receiveCompletion` we could try to remove the cancellable from the array, but we don't actually have access to it here. We have a bit of a chicken-and-egg problem, where the cancellable is created by calling `sink` but we need access to the cancellable from inside one of the closures that defines the sink.
      """#,
    timestamp: (6 * 60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      To work around this we need to extract out the cancellable into an implicitly unwrapped optional, which allows us to get a variable for a type before it holds a value, and then later we get to assign the variable.
      """#,
    timestamp: (6 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It looks like this:
      """#,
    timestamp: (6 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var effectCancellable: Cancellable!
      effectCancellable = effect.sink(
        receiveCompletion: { _ in

      },
        receiveValue: self.send
      )
      self.effectCancellables.append(
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now we have access to the array of cancellables inside `receiveCompletion`, and so we can try to remove the cancellable when the publisher finishes. There are many ways to remove a value from an array, such as removing the first or last or at a particular index, but to remove a particular value from an array we have to search the entire array and find the ones we want to remove:
      """#,
    timestamp: (6 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      self.effectCancellables.removeAll(where: { $0 == effectCancellable })
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But this won't work because the `Cancellable` protocol does not inherit from the `Equatable` protocol, and so we cannot do this equality check. However, the `AnyCancellable` wrapper is a class, and so is equatable thanks to object identity.
      """#,
    timestamp: (7 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So let's upgrade everything to `AnyCancellable`. The property:
      """#,
    timestamp: (7 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var effectCancellables: [AnyCancellable] = []

      // …
      func send(_ action: Action) {
        // …
        var effectCancellable: AnyCancellable!
        effectCancellable = effect.sink(
          receiveCompletion: { _ in
            self.effectCancellables.removeAll(where: { $0 == effectCancellable })
        },
          receiveValue: self.send
        )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally append that cancellable to our array.
      """#,
    timestamp: (7 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      self.effectCancellables.append(effectCancellable)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      One small gotcha is that we have retained `self` in the cancellable's completion handler, and the cancellable is being retained on `self`:
      """#,
    timestamp: (7 * 60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      effectCancellable = effect.sink(
        receiveCompletion: { _ in
          self.effectCancellables.removeAll(where: { $0 == effectCancellable })
      },
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This means we have a retain cycle, which we can break by using weak `self` instead:
      """#,
    timestamp: (7 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      receiveCompletion: { [weak self] _ in
        self?.effectCancellables.removeAll(where: { $0 == effectCancellable })
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And that technically fixes this portion of our architecture. However, there's a quick improvement we can make to this. The `AnyCancellable` class conforms to the `Hashable` protocol, which means we can use them in a set, which will give us a very easy way to remove them:
      """#,
    timestamp: (8 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private var effectCancellables: Set<AnyCancellable> = []

      // …
      func send(_ action: Action) {
        // …
        var effectCancellable: AnyCancellable!
        effectCancellable = effect.sink(
          receiveCompletion: { [weak self] _ in
            self?.effectCancellables.remove(effectCancellable)
          },
          receiveValue: self.send
        )
        effectCancellables.insert(effectCancellable)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"Pulling back reducers with publishers"#,
    timestamp: (8 * 60 + 31),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      We have now introduced our own publisher for our architecture, called `Effect`. And we have upgraded the `Store` to handle these effects in its `send` method, including all of the complexities around handling their associated cancellables and completion.
      """#,
    timestamp: (8 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next error is in the `pullback` method, so let's remind ourselves what this does. It takes reducers that work on very local state and actions and can pull them back to work on more global state and actions. Where effects fit into this is when a local reducer produces a local effect, we need to transform that into a more global effect. A local effect can return a local action back into the store, so we need to wrap that local action in a more global one.
      """#,
    timestamp: (8 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So let's see what that work looks like using our new publisher.
      """#,
    timestamp: (9 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `pullback` function currently has a compile error.
      """#,
    timestamp: (9 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return localEffects.map { localEffect in
        Effect { callback in
          localEffect.run { localAction in // 🛑
            var globalAction = globalAction
            globalAction[keyPath: action] = localAction
            callback(globalAction)
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Value of type 'Effect<LocalAction>' has no member 'run'
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We are trying to call the `run` method, which existed on our old effect type, but no longer exists on our publisher. Technically, we could call `sink` here instead:
      """#,
    timestamp: (9 * 60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return localEffects.map { localEffect in
        Effect { callback in
          localEffect.sink { localAction in // 🛑
            var globalAction = globalAction
            globalAction[keyPath: action] = localAction
            callback(globalAction)
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But `sink` returns an `AnyCancellable`, which is something we'd need to track, and it's not even clear how we would do so because we are in a `pullback`, which is in pure function reducer world with no `Store` in sight to manage these details.
      """#,
    timestamp: (9 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're also trying to create an `Effect` with a callback closure, and we no longer have that interface at our disposal.
      """#,
    timestamp: (10 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      If we think about what this code is really doing, it simply trying to transform an effect that can produce local actions into an effect that can produce global actions. This is precisely what the `map` operation allows us to do on generic types, and lucky for us the `Publisher` type supports a `map` operation!
      """#,
    timestamp: (10 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can take advantage of the fact that publishers have `map` by replacing all of this manual effect conversion code with a simple `map`:
      """#,
    timestamp: (10 * 60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      localEffect.map { localAction in
        var globalAction = globalAction
        globalAction[keyPath: action] = localAction
        callback(globalAction)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, instead of feeding the `globalAction` to the `callback` we can now simply return that value to the map:
      """#,
    timestamp: (10 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      localEffect.map { localAction in
        var globalAction = globalAction
        globalAction[keyPath: action] = localAction
        return globalAction
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now this is basically right, but it's not compiling. The error message isn't great, but if we add a return type to our closure it will get a little better:
      """#,
    timestamp: (11 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      localEffect.map { localAction -> GlobalAction in
        var globalAction = globalAction
        globalAction[keyPath: action] = localAction
        return globalAction
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Cannot convert value of type 'Publishers.Map<Effect<LocalAction>, GlobalAction>' to closure result type 'Effect<GlobalAction>'
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is a long error message, but it is correctly describing what is wrong. We expect that the type returned from the `map` is an `Effect<GlobalAction>` since we need to return an array of those things from this function. But it didn't find that type, instead it found this strange `Publishers.Map<Effect<LocalAction>, GlobalAction>` type, which is a mouthful to say.
      """#,
    timestamp: (11 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This brings us to yet another important lesson when dealing with the Combine framework. Publishers come with many operations, things like `map`, `zip`, `flatMap`, `filter` and more. But they don't return the exact same type of publisher they acted upon, they only return something conforming to the `Publisher` protocol. This is due to a limitation of Swift's type system, which although powerful it cannot express the idea of the `map` operation on a publisher returning a publisher of the same type, such as `map` on `Effect` returning another `Effect`.
      """#,
    timestamp: (11 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The type returned by the `map` operation is something known as a `Map` publisher.
      """#,
    timestamp: (12 * 60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Publishers.Map<Effect<LocalAction>, GlobalAction>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The first generic refers to the publisher that we are mapping on and the second generic refers to the new value that the mapped publisher can emit. So this says that we have mapped on an `Effect` to transform its values of `LocalAction`s into `GlobalAction`s.
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We somehow need to convert this publisher into a plain old `Effect`.
      """#,
    timestamp: (12 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is the exact same problem that Combine's `AnyPublisher` has, and the way they deal with it is that they allow any publisher to transform itself into an `AnyPublisher`:
      """#,
    timestamp: (12 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .eraseToAnyPublisher()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We basically want this functionality, but for our `Effect` type instead. It is possible to make an `eraseToEffect` method. It is expressed as an extension on the `Publisher` protocol so that any publisher can be erased, but it should only work on publishers that can't fail:
      """#,
    timestamp: (13 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Publisher where Failure == Never {
        public func eraseToEffect() -> Effect<Output> {

        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      To implement this method all we have to do is erase ourselves to the `AnyPublisher` and then wrap that it in the effect type:
      """#,
    timestamp: (14 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Publisher where Failure == Never {
        public func eraseToEffect() -> Effect<Output> {
          return Effect(publisher: self.eraseToAnyPublisher())
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      That's all there is to it, but also it seems strange to do so much wrapping in eraser types. We aren't doing this for no reason, it will be handy soon, but for now just take our word for it.
      """#,
    timestamp: (14 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Going back to our `pullback` operation, we can now erase the `Map` publisher to be the `Effect` publisher:
      """#,
    timestamp: (14 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      localEffect.map { localAction -> GlobalAction in
        var globalAction = globalAction
        globalAction[keyPath: action] = localAction
        return globalAction
      }
      .eraseToEffect()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this finally makes the compiler happy.
      """#,
    timestamp: (14 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This `eraseToEffect` dance is unfortunately going to be common practice when it comes to dealing with Combine. Since our reducers are defined in terms of `Effect`, and any time you transform it you get something that is not an `Effect`, we are many times going to have to invoke `eraseToEffect` on our effects before returning them. It's annoying, but necessary.
      """#,
    timestamp: (14 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's pretty cool, though, that publishers have a `map` operation. We first talked about `map` on just [the 13th episode of Point-Free](/episodes/ep13-the-many-faces-of-map)...seems so long ago! But in that episode we showed that the `map` operation is a very universal thing, and there isn't a lot of choice when it comes to defining it. Back them we remarked how the Swift standard library comes with two maps: one defined on arrays and one on optionals. Since then the `Result` type was introduced and it also has a `map` operation. And now we even have a `map` operation in the Combine framework. This means that in the Apple ecosystem alone there are 4 distinct `map` operations!
      """#,
    timestamp: (15 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Finishing the architecture refactor"#,
    timestamp: (15 * 60 + 57),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next error we have in this file is in our logging higher-order reducer. Here we are trying to return an effect that wraps a few print statements.
      """#,
    timestamp: (15 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [Effect { _ in // 🛑
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
      }] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Cannot convert value of type '(_) -> ()' to expected argument type 'AnyPublisher<_, Never>'
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We no longer have the callback closure-based initializer on `Effect`, but we have previously encountered a similar solution in the world of Combine.
      """#,
    timestamp: (16 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We want to return a publisher that encapsulates the execution of the work passed in, but we want to make sure that we don't run that work until the publisher is subscribed to. As we saw before, a simple way to do this is to wrap it in a `Deferred` publisher:
      """#,
    timestamp: (16 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [Deferred { _ in // 🛑
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
      }] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      > 🛑 Contextual closure type '() -> _' expects 0 arguments, but 1 was used in closure body
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now the `Deferred` requires us to return a publisher, but we don't want to actually do anything since this is a fire-and-forget effect. Luckily there's a special publisher called `Empty` that simply never emits any values, and we can even make it complete immediately:
      """#,
    timestamp: (16 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [Deferred { _ in
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
        return Empty(completeImmediately: true)
      }] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This isn't compiling because Swift needs a little help with type inference:
      """#,
    timestamp: (17 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [Deferred { () -> Empty<Action, Never> in
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
        return Empty(completeImmediately: true)
      }] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we're getting a much better error message.

      > 🛑 Cannot convert value of type 'Deferred<Empty<Action, Never>>' to expected element type 'Effect<Action>'
      """#,
    timestamp: (17 * 60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So we need to erase this to the `Effect` type:
      """#,
    timestamp: (17 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [Deferred { () -> Empty<Action, Never> in
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
        return Empty(completeImmediately: true)
      }.eraseToEffect()] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The compiler is happy, but the work we needed to do was a little gross. Let's introduce a helper that does this same work but in a nicer way. We will create it as a static function on effect that takes a void-to-void closure and returns an effect:
      """#,
    timestamp: (17 * 60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And we can capture that work we did in our helper.
      """#,
    timestamp: (18 * 60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func fireAndForget(work: @escaping () -> Void) -> Effect {
          return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
          }
          .eraseToEffect()
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now this is perfect to use for our printing effect:
      """#,
    timestamp: (18 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [.fireAndForget {
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
      }] + effects
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is the main reason we introduced the custom `Effect` publisher conformance instead of just relying on `AnyPublisher`. It will give us opportunities to make transforming publishers a bit nicer at the call site.
      """#,
    timestamp: (18 * 60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `ComposableArchitecture` module still isn't compiling yet because we have this file of effects that we extracted out last time. It contains some handy base effects for network requests, JSON decoding, and forcing values to be delivered on a particular queue.
      """#,
    timestamp: (19 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      All of these effects are great, but the Combine framework actually provides API's that accomplish all of these tasks. We even named our methods after the Combine framework's names.
      """#,
    timestamp: (19 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So we don't actually need to fix these compile errors, we are simply going to comment everything out because we can just lean on Combine for these effects instead of recreating them ourselves.
      """#,
    timestamp: (19 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now the `ComposableArchitecture` module is compiling.
      """#,
    timestamp: (19 * 60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Refactoring synchronous effects"#,
    timestamp: (19 * 60 + 43),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now that the `ComposableArchitecture` module is finally building, we are set up to start refactoring our application to use this new style of side effects. We have a few modules to get building, so let's see how that goes.
      """#,
    timestamp: (19 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's attack them one at a time.
      """#,
    timestamp: (20 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can start with the simplest one, `PrimeModal`. If we switch to that target and build we see that magically everything still builds. This is because the `primeModalReducer` doesn't do any side effects, and so it doesn't care if we change the definition of the effect type.
      """#,
    timestamp: (20 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next simplest module is the `FavoritePrimes` module, and it fails to compile since we construct some effects for saving and loading favorite primes.
      """#,
    timestamp: (20 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `saveEffect` is a fire-and-forget effect that is currently using our old callback-style effect. We can simply swap this out for our new `fireAndForget` helper to get this part compiling:
      """#,
    timestamp: (20 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
        return .fireAndForget {
          …
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `loadEffect` is a synchronous effect that needs to feed a result back into the system, and it is also currently using the old callback-style effect. Similar to how we created the `fireAndForget` helper on `Effect` we can create a synchronous effect helper.
      """#,
    timestamp: (21 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's just a function that takes some work that produces an action, and we want to return an effect that wraps that work.
      """#,
    timestamp: (21 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func sync(work: @escaping () -> Output) -> Effect {
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Again we want to wrap the work in a `Deferred` so that we don't execute the work until a subscription is made:
      """#,
    timestamp: (22 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func sync(work: @escaping () -> Output) -> Effect {
          return Deferred {
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then in here we want to return a publisher that holds the result of the work. Luckily there's yet another concrete publisher that Combine gives us that represents an emission of a single value, and it's called `Just`:
      """#,
    timestamp: (22 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func sync(work: @escaping () -> Output) -> Effect {
          return Deferred {
            Just(work())
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And of course we always need to erase it to the `Effect` type:
      """#,
    timestamp: (22 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      extension Effect {
        public static func sync(work: @escaping () -> Output?) -> Effect {
          return Deferred {
            Just(work())
          }
          .eraseToEffect()
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this finally gets us into compiling order. And we can now use it to define our `loadEffect`:
      """#,
    timestamp: (22 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private let loadEffect = Effect<FavoritePrimesAction>.sync {
        guard …
        else { return }
        return .loadedFavoritePrimes(favoritePrimes)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This isn't quite right because the `Effect<FavoritePrimesAction>.sync` closure must return an actual `FavoritePrimesAction`, but here we are returning an optional. We are returning `nil` in the guard because something failed, and we just don't want the effect to emit in that situation. One thing we could do is change this to an `Effect<FavoritePrimesAction?>`.
      """#,
    timestamp: (23 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      private let loadEffect = Effect<FavoritePrimesAction?>.sync {
        guard …
        else { return nil }
        return .loadedFavoritePrimes(favoritePrimes)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But our reducer can't yet use `loadEffect` directly because it needs to work with effects that return non-optional actions. In order to get rid of the `nil` values we can use `compactMap`:
      """#,
    timestamp: (23 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return [
        loadEffect
          .compactMap { $0 }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally, we need to re-erase to an effect.
      """#,
    timestamp: (23 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .compactMap { $0 }
      .eraseToEffect()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This `compactMap` operators works on publishers just like it does on arrays, it simply filters out the `nil` values leaving behind only the honest ones.
      """#,
    timestamp: (24 * 60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And just like that the `FavoritePrimes` module is building. Now unfortunately our entire application still isn't building, but fortunately due to our efforts in modularizing this app we have a playground that allows us to run this screen in full isolation before we even get everything else building. Let's hop over and give it a spin.
      """#,
    timestamp: (24 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can delete a favorite prime and save the change...

      > Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value: file PrimeTime/ComposableArchitecture/ComposableArchitecture.swift, line 80

      Ouch! Looks we have a crash in our `ComposableArchitecture` module. We must have overlooked something. If we go to line 53 we will see that we are crashing on this line:
      """#,
    timestamp: (24 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      self?.effectCancellables.remove(effectCancellable)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This can only crash if `effectCancellable` is `nil` because we are using an implicitly unwrapped optional, which always means we have the possibility of crashing no matter how careful we are.
      """#,
    timestamp: (25 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The problem here is that we were assuming that `sink` will return before any of these closures were invoked so that we could get a hold of the cancellable. It turns out that for publishers that complete immediately the closures are invoked right away, before `sink` even returns, and that is why we are crashing. One thing we could do is make `effectCancellable` an optional so that we could safely handle it:
      """#,
    timestamp: (25 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var effectCancellable: AnyCancellable?
      effectCancellable = effect.sink(
        receiveCompletion: { [weak self] _ in
          guard let effectCancellable = effectCancellable else { return }
          self?.effectCancellables.remove(effectCancellable)
        },
        receiveValue: self.send
      )
      if let effectCancellable = effectCancellable {
        effectCancellables.insert(effectCancellable)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now we just need to check if `effectCancellable` is present before removing it from the set and before inserting it into the set. However, this isn't going to be correct. If a publisher completes immediately it will be inserted into the set, but we'll never get the chance to remove it because the `receiveCompletion` was already executed, before we even inserted.
      """#,
    timestamp: (25 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, we need to be able to understand if the `receiveCompletion` closure was already called by the time we get to the `insert` line so that we can just skip it. To do that we yet another mutable variable to track that state:
      """#,
    timestamp: (26 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var effectCancellable: AnyCancellable?
      var didComplete = false
      effectCancellable = effect.sink(
        receiveCompletion: { [weak self] _ in
          didComplete = true
          guard let effectCancellable = effectCancellable else { return }
          self?.effectCancellables.remove(effectCancellable)
        },
        receiveValue: self.send
      )
      if !didComplete, let effectCancellable = effectCancellable {
        effectCancellables.insert(effectCancellable)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we will only insert the cancellable into the set if the publisher does not complete immediately. If we hop back over to our playground we will see that now everything works again.
      """#,
    timestamp: (26 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Refactoring asynchronous effects"#,
    timestamp: (26 * 60 + 54),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Alright, both `FavoritePrimes` module effects are now fully powered by combine.
      """#,
    timestamp: (26 * 60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We even got a couple of helpers out of it, including `fireAndForget` and `sync`.
      """#,
    timestamp: (27 * 60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's also cool to see our modularization efforts pay off: we didn't have to get the entire application building in order to run this screen in isolation. This is the power of modularization! We are free to do broad refactors incrementally with feedback along the way for each screen.
      """#,
    timestamp: (27 * 60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We have one more screen, though: the `Counter` module, which has the complicated async effect which makes an API request. Let's see what all needs to change to upgrade this to Combine.
      """#,
    timestamp: (27 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The first error we will look at is in the `wolframAlpha` function, which currently is using some of the effect helpers we built last time, like this `dataTask` and `decode` helper:
      """#,
    timestamp: (27 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return dataTask(with: components.url(relativeTo: nil)!)
        .decode(as: WolframAlphaResult.self)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Fortunately Combine provides all of these helpers for us, but unfortunately it also takes a bit more work to make use of them. We can start by using Foundation's new `dataTaskPublisher` method on `URLSession` to get a publisher that represents a network request:
      """#,
    timestamp: (28 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's assign this to a temporary variable so that we can understand what its type looks like:
      """#,
    timestamp: (29 * 60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let tmp = URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Its type is `URLSession.DataTaskPublisher`, which is some concrete publisher defined in Foundation. If we check its `Output` and `Failure`, we'll find the following type aliases.
      """#,
    timestamp: (29 * 60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      typealias Output = (data: Data, response: URLResponse)
      // …
      typealias Failure = URLError
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Remember that ultimately we need to return an `Effect` from this method, and so if we hit this with the `eraseToAnyPublisher` method we will get a better view into its actual type:
      """#,
    timestamp: (29 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let tmp = URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .eraseToAnyPublisher()
      // AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We want to decode this data into our `WolframAlphaResult` model, and luckily Combine comes with a nice decoding helper:
      """#,
    timestamp: (30 * 60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let tmp = URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .decode(type: WolframAlphaResult.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, this won't compile because the `.decode` method is only defined on publishers whose output matches the thing we are trying to decode, which in this case is `Data`. So, before we can invoke `decode` we must map on the publisher to pluck out just the data from the tuple:
      """#,
    timestamp: (30 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let tmp = URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .map { data, _ in data }
        .decode(type: WolframAlphaResult.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now the type of our publisher is:
      """#,
    timestamp: (30 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      // AnyPublisher<WolframAlphaResult, Publishers.Decode<Upstream, Output, Coder>.Failure>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is getting close. The main problem here is that our publisher can error, but our effect must return a publisher whose error type is `Never`, which means it can never error. The easiest way to transform a publisher that can error into one that can never error is using the `replaceError` method, which allows you to simply replace any error that occurs with an output value:
      """#,
    timestamp: (31 * 60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .replaceError(with: <#T##WolframAlphaResult#>)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The problem here is that we need to replace the error with an honest `WolframAlphaResult`, but we don't have such a value. We would rather just use `nil` to represent that we couldn't construct a `WolframAlphaResult`, but in order for that to our our publisher needs to have an output of an optional `WolframAlphaResult`.
      """#,
    timestamp: (31 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The easiest way to do that is to instead decode an optional result and replace the error with `nil`:
      """#,
    timestamp: (31 * 60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .decode(type: WolframAlphaResult?.self, decoder: JSONDecoder())
      .replaceError(with: nil)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally our chain of transformations has given us a publisher of type:
      """#,
    timestamp: (31 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      AnyPublisher<WolframAlphaResult?, Publishers.ReplaceError<Upstream>.Failure>
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This failure is difficult to read, but if we follow it along to its definition, it is `Never`, which is exactly what we need it to be to erase to an `Effect` and return it.
      """#,
    timestamp: (32 * 60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      return URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .map { data, _ in data }
        .decode(type: WolframAlphaResult.self, decoder: JSONDecoder())
        .map(Optional.some)
        .replaceError(with: nil)
        .eraseToEffect()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now this effect is building. It's intense, but at least the Combine framework gave us all the tools to get the job done.
      """#,
    timestamp: (32 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next error is in `nthPrime`, which is calling the `wolframAlpha` effect, but then mapping on it. As we've seen before, mapping on a publisher changes its type, and so we have to erase that change:
      """#,
    timestamp: (32 * 60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .eraseToEffect()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now this function is happy. The only compiler error left is in our counter reducer where we use this effect. Since we are mapping on this publisher we yet again have to hit it with `eraseToEffect`:
      """#,
    timestamp: (33 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      nthPrime(state.count)
        .map(CounterAction.nthPrimeResponse)
        .receive(on: .main)
        .eraseToEffect()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, it looks like things still aren't building. The error message isn't great, but the problem is here:
      """#,
    timestamp: (33 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .receive(on: .main)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `receive(on:)` method takes a `Scheduler`:
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .receive(on: <#T##Scheduler#>)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Which is a protocol, not a concrete type. Both `DispatchQueue`s and `RunLoop`s conform to this protocol, so we just have to be more explicit with the type to use it:
      """#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .receive(on: DispatchQueue.main)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now the module is finally building. Even better, the entire app target is building, which means we can run our app yet again. If we give it a spin we will see that everything still works the same, but now it's running off of Combine instead of our own custom effect type. I don't know about you, but the app just feels nicer now that I know Combine is powering it under the hood 😄.
      """#,
    timestamp: (34 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"What’s the point?"#,
    timestamp: (35 * 60 + 12),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      So that completes our Combine framework refactor of the toy application we have been building for the past many weeks. It was pretty straightforward once we had some knowledge of how Combine works.
      """#,
    timestamp: (35 * 60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We like to end every episode on Point-Free by asking "what's the point?!", which is our time to bring things down the earth and discuss why these ideas are important. However, this episode was pretty practical from the outset. We noticed that the `Effect` type looked eerily similar to what a lot of reactive programming libraries give us, such as ReactiveSwift, RxSwift and most recently Combine from Apple. So, we wondered if maybe we could lean on one of the frameworks instead of rolling our own type, and indeed we could. The most important qualities of our `Effect` type was that it could represent asynchronous work and that it was transformable. Well, all of these reactive libraries provide exactly this too, so might as well take advantage.
      """#,
    timestamp: (35 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But perhaps the "meta-point" of this episode is that by having a very simple, focused type for accomplishing one thing, and doing so in a transformable way, you can later be open to lots of nice refactors in the future. The fact that we were able to completely swap our our effects type for another type, and everything continued to just work is pretty amazing. So amazing in fact that you might ask why can't we abstract over the shape of effects so that a user of this library could bring their own effect type? Maybe they want to use ReactiveSwift or RxSwift instead of Combine, and maybe they want to just roll their own simple type.
      """#,
    timestamp: (36 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Unfortunately Swift's type system is not powerful enough to express this idea, but at least we can see the shape of such an abstraction and try to use it as inspiration for how we build our library.
      """#,
    timestamp: (37 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, that's it for this episode. We took a little detour from our episodes building out the Composable Architecture so that we could address the strangeness of the `Effect` type from last time. But next week we pick up where we left off last time: testing! We want to show how testable this architecture is, even when effects are involved.
      """#,
    timestamp: (37 * 60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Until next time!
      """#,
    timestamp: (38 * 60 + 41),
    type: .paragraph
  ),
]
