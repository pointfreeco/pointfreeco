import Foundation

extension Episode {
  public static let ep154_asyncRefreshableTCA = Episode(
    blurb: """
The Composable Architecture does not yet support any of the fancy new concurrency features from WWDC this year, so is it possible to interact with async/await APIs like `.refreshable`? Not only is it possible, but it can be done without any changes to the core library.
""",
    codeSampleDirectory: "0154-refreshable-pt2",
    exercises: _exercises,
    id: 154,
    image: "https://i.vimeocdn.com/video/1198344826-243b025fa91dcc87c0f3f111b0aa273b8f5d91258f511f8e8858fff6a73e45a6-d?mw=1900&mh=1069&q=70",
    length: 34*60 + 52,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1627275600),
    references: [
      Episode.Reference(
        author: "Matt Ricketson and Taylor Kelly",
        blurb: #"""
A WWDC session covering what's new in SwiftUI this year, including the `refreshable` API.
"""#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10018/",
        publishedAt: referenceDateFormatter.date(from: "2021-06-08"),
        title: "What's new in SwiftUI"
      ),
      .pullToRefreshInSwiftUIWithRefreshable,
      Episode.Reference(
        author: nil,
        blurb: #"""
Documentation for `refreshable`.
"""#,
        link: "https://developer.apple.com/documentation/swiftui/view/refreshable(action:)/",
        publishedAt: nil,
        title: "`refreshable(action:)`"
      ),
    ],
    sequence: 154,
    subtitle: "Composable Architecture",
    title: "Async Refreshable",
    trailerVideo: .init(
      bytesLength: 26817157,
      vimeoId: 577131488,
      vimeoSecret: "681d437aeeb23fe8048e79aa5eee6320d7556c2f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Use `withTaskCancellationHandler` to allow the async version of `ViewStore.send(_:while:)` to be cancelled. Ensure that the task can be cancelled _before_ the publisher assigns the cancellable.
"""#,
    solution: #"""
Introducing `withTaskCancellationHandler` and invoking the cancellable's `cancel` method in the handler will allow the handler to cancel the underlying Combine publisher. To handle cancellation that occurs before the operation is invoked, we can call `Task.checkCancellation()` at the beginning of the operation, and again in the continuation. Because continuation closures are not throwing, we must handle cancellation through the continuation's `resume(throwing:)` method instead.

```swift
extension ViewStore {
  func send(
    _ action: Action,
    `while` isInFlight: @escaping (State) -> Bool
  ) async {
    self.send(action)

    var cancellable: Cancellable?
    try? await withTaskCancellationHandler(
      handler: { [cancellable] in cancellable?.cancel() },
      operation: {
        try Task.checkCancellation()
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
          guard !Task.isCancelled else {
            continuation.resume(throwing: CancellationError())
            return
          }
          cancellable = self.publisher
            .filter { !predicate($0) }
            .prefix(1)
            .sink { _ in
              continuation.resume()
              _ = cancellable
            }
        }
      }
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Introduce a `ViewStore.send(_:animation:while:)` overload with the following signature:

```swift
extension ViewStore {
  func send(
    _ action: Action,
    animation: Animation?,
    while predicate: @escaping (State) -> Bool
  ) async {
    fatalError("unimplemented")
  }
}
```

Where `animation` animates the synchronous mutation to state caused by `action`.

Is it possible to implement in terms of `ViewStore.send(_:while:)`? If not, why not, and what are some ways of sharing the original implementation?
"""#,
    solution: #"""
At this time, it does not appear to be possible to implement this overload in terms of the original, because the mutation happens in the asynchronous context of the upstream `ViewStore.send(_:while:)`, and `withAnimation` can not capture asynchronous work.

We can instead generalize with another helper that simply suspends a view store till some state holds true:

```swift
extension ViewStore {
  func suspend(while predicate: @escaping (State) -> Bool) async {
    var cancellable: Cancellable?
    try? await withTaskCancellationHandler(
      handler: { [cancellable] in cancellable?.cancel() },
      operation: {
        try Task.checkCancellation()
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
          guard !Task.isCancelled else {
            continuation.resume(throwing: CancellationError())
            return
          }
          cancellable = self.publisher
            .filter { !predicate($0) }
            .prefix(1)
            .sink { _ in
              continuation.resume()
              _ = cancellable
            }
        }
      }
    )
  }
}
```

And then, both `send` helpers can utilize this shared code:

```swift
extension ViewStore {
  func send(
    _ action: Action,
    while predicate: @escaping (State) -> Bool
  ) async {
    self.send(action)
    await self.suspend(while: predicate)
  }

  func send(
    _ action: Action,
    animation: Animation?,
    while predicate: @escaping (State) -> Bool
  ) async {
    withAnimation(animation) { self.send(action) }
    await self.suspend(while: predicate)
  }
}
```
"""#
  ),
  .init(
    problem: #"""
The `ViewStore.publisher` property is a handy way of getting a publisher of state to use in Combine. Let's define another property that bridges things to Swift's new concurrency APIs, specifically `AsyncSequence`, by implementing the following:

```swift
extension ViewStore {
  var stream: AsyncStream<State> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension ViewStore {
  var stream: AsyncStream<State> {
    AsyncStream { continuation in
      var cancellable: Cancellable?
      cancellable = self.publisher.sink(
        receiveCompletion: { _ in
          continuation.finish()
          _ = cancellable
        },
        receiveValue: { continuation.yield($0) }
      )
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Rewrite `ViewStore.suspend(while:)` in terms of the `ViewStore.stream` property, implemented in the previous exercise.
"""#,
    solution: #"""
```swift
extension ViewStore {
  func suspend(while predicate: @escaping (State) -> Bool) async {
    _ = await self.stream
      .filter { !predicate($0) }
      .first(where: { _ in true })
  }
}
```
"""#
  )
]

extension Episode.Video {
  public static let ep154_asyncRefreshableTCA = Self(
    bytesLength: 364471160,
    vimeoId: 577131493,
    vimeoSecret: "939af99002f6c8f60bfb30b2527e20822949a8b3"
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep154_asyncRefreshableTCA: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
So, that’s a quick introduction to the new `.refreshable` view modifier in SwiftUI, along with a small dose of `async`/`await`. There’s still so much more to say Swift’s concurrency model, but we’re glad that the new `.refreshable` API gave us an excuse to dive in some of the more advanced topics, such as tasks, cancellation and testing.
"""#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Now let’s see what all of this looks like in the Composable Architecture. We’re going to rebuild this feature using our library, and we’ll see that we can still leverage the `.refreshable` view modifier even though the Composable Architecture has no direct support for `async`/`await`. Even better, we can support this `.refreshable` API without making any changes whatsoever to the core library. This means you wouldn’t even have to wait for us to release a new version of the library to test out this functionality. You could have implemented it yourself.
"""#,
      timestamp: 24,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, let’s begin.
"""#,
      timestamp: 54,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Refreshing and the Composable Architecture"#,
      timestamp: (1*60 + 4),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
In the Composable Architecture we often like to begin with a little bit of a domain modeling exercise. It’s certainly not the only way to start a feature. Alternatively we could build out the view and then let that guide us to do the domain modeling.
"""#,
      timestamp: (1*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But right now it’s clear that our state consists of an integer count and a fact represented by an optional string:
"""#,
      timestamp: (1*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshState: Equatable {
  var count = 0
  var fact: String?
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we model the actions that can occur in the feature. The most straightforward actions to model are what the user does in the application, such as tapping the increment and decrement buttons, tapping the cancel button, or activating the refresh action:
"""#,
      timestamp: (1*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum PullToRefreshAction: Equatable {
  case cancelButtonTapped
  case decrementButtonTapped
  case incrementButtonTapped
  case refresh
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Incidentally, these are also all the methods we had on our view model, which we invoked from the view.
"""#,
      timestamp: (1*60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, in the Composable Architecture there is another set of actions that are explicitly modeled that we don’t have to think about when building an observable object in vanilla SwiftUI, and that’s actions that are emitted by effects. We do this in the Composable Architecture because it helps us separate the simple, pure logical transformation of state from interactions with the messy outside world.
"""#,
      timestamp: (1*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Right now we only have a single effect that needs to be tied to an action, and that is when we execute the fact API request, it wants to feed its data back into the system. We can model this with a single case that holds a result type that contains a fact or an error:
"""#,
      timestamp: (2*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case factResponse(Result<String, Error>)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we model the environment of dependencies that this feature needs to do its job. At a bare minimum we need some kind of client for making the API request for the number fact. We actually already have this dependency in the project because there are lots of case studies that need to make this kind of API request:
"""#,
      timestamp: (2*60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshEnvironment {
  var fact: FactClient
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we want to go a little above and beyond and control even more of the environment that our feature operates in we can also control the scheduler that we will use for delivering events from the API request back to the main queue:
"""#,
      timestamp: (2*60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshEnvironment {
  var fact: FactClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We do this because we can’t assume that the fact client delivers its events on the main queue, but also if we don’t control the queue used for the delivery of data then we will have to sprinkle in `XCTExpectation`s all of over our tests in order to make sure that we wait enough time for a thread hop to occur and for us to get data from the dependency. This little bit of upfront work will make our tests much simpler to write.
"""#,
      timestamp: (3*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we implement the logic for our feature by creating a reducer that describes how to evolve the state when an action comes in, as well as how to execute side effects and feed their data back into the system:
"""#,
      timestamp: (3*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let pullToRefreshReducer = Reducer<
  PullToRefreshState,
  PullToRefreshAction,
  PullToRefreshEnvironment
> { state, action, environment in
  switch action {
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We just need to implement the logic for each of the cases of the `PullToRefreshAction`.
"""#,
      timestamp: (3*60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For example, tapping the increment or decrement button is quite simple to handle:
"""#,
      timestamp: (4*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .decrementButtonTapped:
  state.count -= 1
  return .none

case .incrementButtonTapped:
  state.count += 1
  return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next, handling the fact response is as simple as storing the loaded fact in the state:
"""#,
      timestamp: (4*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case let .factResponse(.success(fact)):
  state.fact = fact
  return .none

case .factResponse(.failure):
  // TODO: do some error handling
  return .none
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then the `.refresh` action is responsible for kicking off an effect, which can be done by using the `FactClient` in the environment, receiving the output on the main queue, and then transforming the response into an action that can be fed back into the system:
"""#,
      timestamp: (4*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Here is where we get to build in some of the cancellation logic. We can mark this effect as being cancellable so that we can then cancel it from another action:
"""#,
      timestamp: (6*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: "refresh")
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
You can use any `Hashable` value for the cancellation id. Then, over in the `.cancelButtonTapped` action we can return an effect that will cancel the fetch effect:
"""#,
      timestamp: (6*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .cancelButtonTapped:
  return .cancel(id: "refresh")
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We can also strengthen this cancellation identifier a bit by defining a dedicated type to represent it rather than using a string. We can even scope the type to the inside of the reducer function, which means that no one outside that scope is even capable of messing with our cancellation logic:
"""#,
      timestamp: (6*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct CancelId: Hashable {}

switch action {
case .cancelButtonTapped:
  return .cancel(id: CancelId())

...

case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The final step to implementing this feature is to implement the view. The view will hold onto a `Store` of the feature domain rather than a view model:
"""#,
      timestamp: (6*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshView: View {
  let store: Store<PullToRefreshState, PullToRefreshAction>

  var body: some View {
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
In the body of the view we will observe state changes in the store by constructing a `ViewStore` via the `WithViewStore` view helper:
"""#,
      timestamp: (7*60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
WithViewStore(self.store) { viewStore in
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But this helper requires that state is equatable, so that it can de-dupe updates and minimize calls to evaluate its body.
"""#,
      timestamp: (7*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshState: Equatable {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Inside the scope of the `WithViewStore` we are free to read state and send actions. For example, we can construct a `List` to hold an `Stack` for the increment and decrement buttons and the count:
"""#,
      timestamp: (7*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
List {
  HStack {
    Button("-") { viewStore.send(.decrementButtonTapped) }
    Text("\(viewStore.count)")
    Button("+") { viewStore.send(.incrementButtonTapped) }
  }
  .buttonStyle(.plain)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Directly below the counter UI we can show a text view for the fact if it’s present:
"""#,
      timestamp: (7*60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
if let fact = viewStore.fact {
  Text(fact)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And then we can tack on a `.refreshable` on the `List` view in order to tap into the moment the user tries to pull down to refresh:
"""#,
      timestamp: (8*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.refreshable {
  viewStore.send(.refresh)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
It’s a little strange that we don’t have to `await` any of the work in this refreshable closure. Remember that the closure we hand to `.refreshable` is marked as `async`, which means we are allowed to do asynchronous work inside there. But we’re not. We only sending an action to the store, which is a completely synchronous operation.
"""#,
      timestamp: (8*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
But nonetheless, we should have a functioning application now. We can put in an Xcode preview just to make sure:
"""#,
      timestamp: (8*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefresh_Previews: PreviewProvider {
  static var previews: some View {
    PullToRefreshView(
      store: .init(
        initialState: .init(),
        reducer: pullToRefreshReducer,
        environment: PullToRefreshEnvironment(
          fact: .live,
          mainQueue: .main
        )
      )
    )
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And things do work… for the most part. If we pull to refresh we will see that the loading indicator goes away immediately, even if the API request is still in flight.
"""#,
      timestamp: (8*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To make this apparent, let’s insert a small delay into the API effect, just like we did in the vanilla SwiftUI application:
"""#,
      timestamp: (9*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .refresh:
  return environment.fact.fetch(state.count)
//    .receive(on: environment.mainQueue)
    .delay(for: 2, scheduler: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"Async/await and the view store"#,
      timestamp: (9*60 + 28),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we can clearly see the problem. The loading indicator goes away immediately even though the API request is still loading.
"""#,
      timestamp: (9*60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This shouldn’t be too surprising because as we mentioned earlier, the way `.refreshable` works is that the loading indicator sticks around for as long as asynchronous work is being performed in the closure provided. In the vanilla SwiftUI application this was automatically handled for us because we awaited the `getFact` method on the view model, and when it finished it automatically caused the loading indicator to go away.
"""#,
      timestamp: (9*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, in the Composable Architecture version of the application we are sending an action, which is a completely synchronous operation and so therefore doesn’t need to be awaited:
"""#,
      timestamp: (10*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.refreshable {
  viewStore.send(.refresh)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
But that also means there’s no way for us to communicate to SwiftUI that the refreshing work is ongoing and so therefore the loading indicator shouldn’t go away immediately.
"""#,
      timestamp: (10*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to somehow introduce a way to send an action into the store and then `await` until some occurrence. We can even take some inspiration from the vanilla SwiftUI application we built.
"""#,
      timestamp: (10*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Recall that in the view model we held onto some state tracking a task on the asynchronous work:
"""#,
      timestamp: (10*60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
@Published private var task: Task<String, Error>?
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We then had to manage this state a little bit in the view model. For example, we had to remember to `nil`-out the handle when the API request finished:
"""#,
      timestamp: (11*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
defer { self.task = nil }
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And we had to remember to `nil`-out the handle when cancelling the work:
"""#,
      timestamp: (11*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func cancelButtonTapped() {
  self.task?.cancel()
  self.task = nil
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We had to do this because on the side we are using the `handle` variable to publicly expose to others when the view model is in a loading state or not:
"""#,
      timestamp: (11*60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
var isLoading: Bool {
  self.task != nil
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to do something similar with the Composable Architecture version of this application. What if we added some `isLoading` state to our feature’s domain:
"""#,
      timestamp: (11*60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
struct PullToRefreshState: Equatable {
  var count = 0
  var fact: String?
  var isLoading = false
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we can flip this boolean to be `true` or `false` in various parts of the reducer to make sure that it is only true when the network request is inflight:
"""#,
      timestamp: (11*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
switch action {
case .cancelButtonTapped:
  state.isLoading = false
  return .cancel(id: CancelId())

case let .factResponse(.success(fact)):
  state.fact = fact
  state.isLoading = false
  return .none

case .factResponse(.failure):
  state.isLoading = false
  // TODO: do some error handling
  return .none

...

case .refresh:
  state.isLoading = true
  return environment.fact.fetch(state.count)
    .delay(for: 2, scheduler: environment.mainQueue.animation())
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then, what if we could cook up and `async` version of `.send` that waits until the `isLoading` state flips to false before continuing:
"""#,
      timestamp: (12*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.refreshable {
  await viewStore.send(.refresh, while: \.isLoading)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This would allow us to communicate to SwiftUI that the refresh work is being done and let the `List` view know once the work is done.
"""#,
      timestamp: (12*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, can we implement this method?
"""#,
      timestamp: (12*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Turns out not only can we do it, but we can even do it outside the main library. It doesn’t require access to any of the internal implementation details. We can write down an implementation in the case studies target, which is completely separate from the Composable Architecture target.
"""#,
      timestamp: (12*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s start by getting a signature in place:
"""#,
      timestamp: (13*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
extension ViewStore {
  func send(_ action: Action, `while`: (State) -> Bool) async {
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
The first thing we want to do in this method is send the action, because that’s what kicks off the entire process that we then want to wait on:
"""#,
      timestamp: (13*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.send(action)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Next we want to somehow wait until the `while` predicate evaluates to `false` on the current state of the view store. Luckily for us the view store exposes the entire stream of states to us publicly, which can be accessed via the `.publisher` property:
"""#,
      timestamp: (13*60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.publisher
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
We want to listen to all emissions of this publisher until we find an emissions for which the `while` predicate evaluates to `false`:
"""#,
      timestamp: (14*60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.publisher
  .filter { !`while`($0) }
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Which means `while` must be `@escaping`, and maybe we could rename the local parameter to `isInFlight`.
"""#,
      timestamp: (14*60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func send(
  _ action: Action,
  `while` isInFlight: @escaping (State) -> Bool
) async {
  self.send(action)
  self.publisher
    .filter { !isInFlight($0) }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And further we only care about the first emission of this publisher:
"""#,
      timestamp: (14*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.publisher
  .filter { !isInFlight($0) }
  .prefix(1)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
If we sink on this publisher we will be notified of the exact moment that the `isLoading` property flips to `false`:
"""#,
      timestamp: (14*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
self.publisher
  .filter { !isInFlight($0) }
  .prefix(1)
  .sink { _ in
  }
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
There’s a few things not quite right about this yet. First of all, we are getting a warning from the compiler because `.sink` returns a cancellable that we are not handling yet. We will need to somehow keep this cancellable alive for as long as the publisher needs to do its job.
"""#,
      timestamp: (15*60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, we need to somehow construct an asynchronous task that can be awaited until the publisher emits. Our `.send(_:while:)` method is marked as `async`, so luckily we already have a context to perform asynchronous work. We just need a bridge that allows us to convert non-async/await code into async/await code.
"""#,
      timestamp: (15*60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Swift comes with such a tool, and it’s known as `withUnsafeContinuation`.
"""#,
      timestamp: (15*60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
withUnsafeContinuation(<#(UnsafeContinuation<T, Never>) -> Void#>)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This function turns non-async/await code into async/await code. It does this by requiring you to provide a closure, and in that closure is where you perform your asynchronous work that is not able to leverage async/await. If you do that, then what you get back is something that is async/await compatible, and therefore must be awaited in order to be invoked.
"""#,
      timestamp: (16*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
For example, we could use `withUnsafeContinuation` to immediately provide an integer:
"""#,
      timestamp: (16*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let number = await withUnsafeContinuation { continuation in
  continuation.resume(returning: 42)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Of course that is completely synchronous work, so nothing to special there.
"""#,
      timestamp: (17*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, with a small tweak we can leverage `DispatchQueue` in order to deliver that integer 10 seconds later:
"""#,
      timestamp: (17*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
let number = await withUnsafeContinuation { continuation in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    continuation.resume(returning: 42)
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
So, this is showing how we bridge non-async/await code like `DispatchQueue.main.asyncAfter` with code that can properly interface with async/await, such as the closure provided to `.refreshable`.
"""#,
      timestamp: (17*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We can use this bridge to create an awaitable task that suspends until the Combine publisher we constructed emits. We’ll just wrap the Combine work inside `withUnsafeContinuation` and resume the continuation once the publisher emits its first value, which is also its only value since we have a `.prefix(1)` on the publisher chain:
"""#,
      timestamp: (17*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
await withUnsafeContinuation { continuation in
  self.publisher
    .filter { !isInFlight($0) }
    .prefix(1)
    .sink { _ in
      continuation.resume()
    }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Ok, so that fixes one of our problems, that of bridging this Combine code to the `async`/`await` world. Next we have to figure out what to do about the cancellable returned to us from the `.sink` method because Swift is still warning us that the value is unused.
"""#,
      timestamp: (18*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We need to keep the cancellable alive for as long as the publisher is alive. We can do this by declaring an optional cancellable outside the scope of the `.sink`, and then strongly capturing the cancellable inside the `.sink`:
"""#,
      timestamp: (18*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
await withUnsafeContinuation { continuation in
  var cancellable: Cancellable?
  cancellable = self.publisher
    .filter { !isInFlight($0) }
    .prefix(1)
    .sink { _ in
      continuation.resume(returning: ())
      _ = cancellable
    }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Generic parameter 'T' could not be inferred

But now that we have a multi-line closure Swift does not infer the type of continuation, so we can add an explicit annotation:
"""#,
      timestamp: (19*60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
This will guarantee that the subscription lives until its first emission.
"""#,
      timestamp: (19*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
And this completes the basics of the new `.send` helper that is `async`/`await` aware. We can already use it. The code we sketched out earlier is now compiling:
"""#,
      timestamp: (19*60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.refreshable {
  await viewStore.send(.refresh, while: \.isLoading)
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now when we run the application we will see it behaves just like the vanilla SwiftUI version. If we pull down to refresh we will see the loading indicator for a few seconds, and then it will go away and the fact will appear.
"""#,
      timestamp: (19*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let's quickly get the cancellation button in to make sure that's working as well. First, we'll add the button to the view:
"""#,
      timestamp: (20*60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
if viewStore.isLoading {
  Button("Cancel") {
    viewStore.send(.cancelButtonTapped)
  }
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And to make things behave like the vanilla SwiftUI version, let's be sure to `nil` out the fact when the refresh button is invoked.
"""#,
      timestamp: (20*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
case .refresh:
  state.fact = nil
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now when we run the preview we can see that cancellation works as expected. The interaction is a bit harsher than it is in vanilla SwiftUI, which animates these actions. We can do the same by using an [animated scheduler](/episodes/ep136-swiftui-animation-the-basics), from our [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library, and add a view store animation:
"""#,
      timestamp: (20*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
.delay(for: 2, scheduler: environment.mainQueue.animation())

...

viewStore.send(.cancelButtonTapped, animation: .default)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now things are looking pretty good, and operate exactly as they did in the vanilla SwiftUI version.
"""#,
      timestamp: (21*60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So this is pretty awesome. We were able to support a fancy new async/await feature in the Composable Architecture without overhauling the entire library to use async/await and without even needing access to the internals of the library. This new async `.send` method could have just as easily be written by anyone without waiting for us to bring this feature to the library.
"""#,
      timestamp: (21*60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
There are two important things we want to point out:
"""#,
      timestamp: (22*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- First, with the Composable Architecture we do have to manage state a little more than we did in the vanilla SwiftUI version. With the observable object we got a 1-to-1 correspondence between the work being executed for refreshing and the `isLoading` boolean. In the Composable Architecture we have to manage that state ourselves.

    However, even in the vanilla SwiftUI version there is a little bit of state management you have to keep up with. You have to remember to mark the handle variable as `@Published` so its changes trigger SwiftUI view updates, and you have to remember to `nil` out that state in order to clean things up when work is completed or cancelled.
"""#,
      timestamp: (22*60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
- Second, our new async `.send` method isn’t fully correct just yet. There is a possibility that SwiftUI may want to cancel the work happening inside the closure handed to the `.refreshable` method. We’re not aware of any concrete examples of this, but ostensibly it’s possible. So, we need to do a little bit of extra work to tap into that moment of cancellation, which we can do with something known as `withTaskCancellationHandler`, but we will leave that as an exercise for the viewer, which you can find at the bottom of the episode page.
"""#,
      timestamp: (23*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Testing and the Composable Architecture"#,
      timestamp: (23*60 + 46),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Ok, so we’ve accomplished what we set out to do, but let’s do one more thing. Let’s write some tests! Perhaps the most important feature of the Composable Architecture is its comprehensive testing tools. We want absolutely everything to be testable in the architecture, from the execution of effects and how they feed data back into the system to the glue code that combines lots of disparate features into one big feature. We want it all to be capable of being tested, and done so in a simple, ergonomic way.
"""#,
      timestamp: (23*60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So let's explore what it takes to test this feature.
"""#,
      timestamp: (24*60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We can start the test by constructing a `TestStore`, which gives us a runtime that tracks how actions are fed into the system and how the state changes over time, and forces us to assert on every little thing that takes place on the inside. In order to construct the test store we have to provide the environment of dependencies, and we can provide dependencies that perform their work immediately and synchronously:
"""#,
      timestamp: (24*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
import ComposableArchitecture
...
func testTca() {
  let store = TestStore(
    initialState: .init(),
    reducer: pullToRefreshReducer,
    environment: .init(
      fact: .init { .init(value: "\($0) is a good number.") },
      mainQueue: .immediate
    )
  )
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now we can start sending actions to the test store, like say emulating the action of the user tapping the increment button:
"""#,
      timestamp: (25*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.incrementButtonTapped)
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 State change does not match expectation: …
>
>       PullToRefreshState(
>     −   count: 0,
>     +   count: 1,
>         fact: nil,
>         isLoading: false
>       )
>
> (Expected: −, Actual: +)

That leads to a test failure because along with every action sent to the store we have to assert on exactly how the state changed. To do that we open up a trailing closure on the `.send` method and mutate `$0` to describe exactly how state changed:
"""#,
      timestamp: (26*60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.incrementButtonTapped) {
  $0.count = 1
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the test is passing.
"""#,
      timestamp: (26*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s test something a little more complicated. Let’s emulate what happens when the user pulls the list down to refresh the fact. We know that the `isLoading` state should flip to `true`, so we can describe that state change:
"""#,
      timestamp: (26*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.refresh) {
  $0.isLoading = true
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 The store received 1 unexpected action after this one: …
>
> Unhandled actions: [
>   PullToRefreshAction.factResponse(
>     Result<String, Error>.success(
>       "1 is a good number."
>     )
>   ),
> ]

But running tests results in another test failure. This time the library is telling us that an effect executed and caused an action to be fed back into the system, and we haven’t yet asserted on that. This is a great failure to have because it forces you to describe everything happening in the application, including how effects execute.
"""#,
      timestamp: (26*60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
To get a passing test we need to tell the test store that we expect to receive an action, which is the `.factResponse` action with a successful payload:
"""#,
      timestamp: (27*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.receive(.factResponse(.success("1 is a good number.")))
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 Referencing instance method 'receive(_:_:)' on 'TestStore' requires that 'PullToRefreshAction' conform to 'Equatable'

Asserting on effects received by the test store requires that actions be equatable, as well, so let's add a conformance:
"""#,
      timestamp: (27*60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
enum PullToRefreshAction: Equatable {
  ...
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Further, when this action is received some state mutates:
"""#,
      timestamp: (27*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.receive(.factResponse(.success("1 is a good number."))) {
  $0.isLoading = false
  $0.fact = "1 is a good number."
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And now the test passes.
"""#,
      timestamp: (28*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It’s worth comparing this test to what we did in the vanilla SwiftUI test. When testing the observable object we had to resort to hacks in order to get coverage on the `isLoading` boolean flipping to `true` and then `false`. And we sadly were not able to exhaustively test how the entire state of the observable object changed, we could only assert on individual fields.
"""#,
      timestamp: (28*60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, with the Composable Architecture we can easily tap into every little moment before and after effects are executed and can assert on how the state changes in those subtle flows. We also are forced to exhaustively assert on how every little piece of state changed. If we forget something, or if new fields are added to state later we will instantly be notified with a test failure. For example, suppose we forgot to flip `isLoading` back to `true` in the test when we receive the fact response:
"""#,
      timestamp: (28*60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.receive(.factResponse(.success("1 is a good number."))) {
//  $0.isLoading = false
  $0.fact = "1 is a good number."
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then we immediately get a test failure showing us exactly what went wrong:
"""#,
      timestamp: (28*60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 State change does not match expectation: …
>
>       PullToRefreshState(
>         count: 1,
>         fact: "1 is a good number.",
>     −   isLoading: true
>     +   isLoading: false
>       )
>
> (Expected: −, Actual: +)

So that’s pretty great, and as we’ve said many times, the testing infrastructure of the Composable Architecture is one of the most important features of the library.
"""#,
      timestamp: (29*60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Let’s push things a little further by testing the flow where the user cancels the inflight fact request. Recall that we couldn’t figure out how to test that flow in the vanilla SwiftUI version. We have a feeling we know how it should be accomplished, but it doesn’t yet work, either due to bugs in the Xcode beta or perhaps we need to make use of custom executors, which just landed in beta 3.
"""#,
      timestamp: (29*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Either way, testing this flow in the Composable Architecture is a breeze. In order to get access to the brief moment that exists between refreshing and receiving a fact response, we need to use a different kind of scheduler for the main queue. For the test we just wrote we used an immediate scheduler because we didn’t need access to those moments and so it was ok to squash all of time into a single moment and force our effects to produce a value immediately.
"""#,
      timestamp: (29*60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
However, now we do care, and so we have to use a scheduler known as a `TestScheduler`. This scheduler does not allow time to move forward until we tell it to. This is perfect for getting inside those tricky moments between asynchronous effects executing. So, let’s create a test store, but this time use a test scheduler:
"""#,
      timestamp: (30*60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
func testTca_Cancellation() {
  let mainQueue = DispatchQueue.test

  let store = TestStore(
    initialState: .init(),
    reducer: pullToRefreshReducer,
    environment: .init(
      fact: .init { .init(value: "\($0) is a good number.") },
      mainQueue: mainQueue.eraseToAnyScheduler()
    )
  )
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Then, to test the flow of invoking the refresh action and cancelling while it is inflight we just need to send two actions to the test store:
"""#,
      timestamp: (30*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.refresh) {
  $0.isLoading = true
}
store.send(.cancelButtonTapped) {
  $0.isLoading = false
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
And just like that the test passes.
"""#,
      timestamp: (31*60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This may seem too good to be true though. How can we be sure that it is actually testing cancellation of an inflight effect?
"""#,
      timestamp: (31*60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Well, we can be sure because the test store forces us to exhaustively describe everything that happens in the system. This not only includes state changes and receiving data from effects as we have seen before, but also forces that every effect be completed by the time the test is finished. If the fact effect was still in flight by the time the test finished executing then we would have gotten a failure. The mere fact this test passes proves that it's impossible for any effects to later feed data back into the system.
"""#,
      timestamp: (31*60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
We can see this for ourselves by commenting out the `.send` that emulates tapping the cancel button:
"""#,
      timestamp: (31*60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.refresh) {
  $0.isLoading = true
}
//store.send(.cancelButtonTapped) {
//  $0.isLoading = false
//}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 An effect returned for this action is still running. It must complete before the end of the test. …
>
> To fix, inspect any effects the reducer returns for this action and ensure that all of them complete by the end of the test. There are a few reasons why an effect may not have completed:
>
> • If an effect uses a scheduler (via "receive(on:)", "delay", "debounce", etc.), make sure that you wait enough time for the scheduler to perform the effect. If you are using a test scheduler, advance the scheduler so that the effects may complete, or consider using an immediate scheduler to immediately perform the effect instead.
>
> • If you are returning a long-living effect (timers, notifications, subjects, etc.), then make sure those effects are torn down by marking the effect ".cancellable" and returning a corresponding cancellation effect ("Effect.cancel") from another action, or, if your effect is driven by a Combine subject, send it a completion.

The test now fails because it has detected that there is an effect in flight.
"""#,
      timestamp: (31*60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
If the library did not fail on this situation then it would mean you could have effects still executing when the test finished, which means there’s the potential for new actions to be fed into the system and change state, all without you making any assertions. That can either hide actual bugs or hide new logic that should be tested, but if the test didn’t loudly complain you may forget to add test coverage.
"""#,
      timestamp: (32*60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
One thing we can do to make the test complete is advance the scheduler a tick, causing the effect to emit and feed its data back into the system:
"""#,
      timestamp: (32*60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.refresh) {
  $0.isLoading = true
}
// store.send(.cancelButtonTapped) {
//   $0.isLoading = false
// }
...
mainQueue.advance(by: .seconds(2))
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
> 🛑 The store received 1 unexpected action after this one: …
>
> Unhandled actions: [
>   PullToRefreshAction.factResponse(
>     Result<String, Error>.success(
>       "0 is a good number."
>     )
>   ),
> ]

But now we get a different error, similar to one we saw before, where an action was fed into the system but we didn’t explicitly assert on it by calling the `.receive` method.
"""#,
      timestamp: (33*60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
So, this is showing what it means for the Composable Architecture to be exhaustive in testing. You really do need to describe everything that is happening in the system, from state mutations to effect executions. Let’s get back into a passing state by bringing back the `.cancelButtonTapped` action:
"""#,
      timestamp: (33*60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
store.send(.refresh) {
  $0.isLoading = true
}
store.send(.cancelButtonTapped) {
  $0.isLoading = false
}
"""#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
Now the test passes, and so this really is proving that the fact effect cancellation works as we expect.
"""#,
      timestamp: (33*60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
This is great. We are able to hook into a brand new SwiftUI feature in the Composable Architecture with very little work. It even uses `async`/`await`, which the Composable Architecture doesn’t even have official support for (yet), but we were still able to build the tools necessary for bridging these worlds. Even better, we were able to accomplish all of this without making a single change to the internals of the library, which means all of our viewers could have introduced this to their code bases without waiting for us.
"""#,
      timestamp: (33*60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
It’s also pretty cool how easy it was to test everything we did, but to be fair we also think that someday Swift’s standard library will have more tools for us to better test asynchronous code, probably via executors.
"""#,
      timestamp: (34*60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: SwiftUI focus state"#,
      timestamp: (34*60 + 22),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
Next week we will discuss another new, fancy feature announced at WWDC: focus state. Like `.refreshable` it isn’t exactly clear how it adapts to the Composable Architecture, but it’s totally possible and it exploring that even shows how to work with focus state in observable objects too.
"""#,
      timestamp: (34*60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
Till next time!
"""#,
      timestamp: (34*60 + 48),
      type: .paragraph
    ),
  ]
}
