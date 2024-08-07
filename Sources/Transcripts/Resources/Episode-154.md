## Introduction

@T(00:00:05)
So, that’s a quick introduction to the new `.refreshable` view modifier in SwiftUI, along with a small dose of `async`/`await`. There’s still so much more to say Swift’s concurrency model, but we’re glad that the new `.refreshable` API gave us an excuse to dive in some of the more advanced topics, such as tasks, cancellation and testing.

@T(00:00:24)
Now let’s see what all of this looks like in the Composable Architecture. We’re going to rebuild this feature using our library, and we’ll see that we can still leverage the `.refreshable` view modifier even though the Composable Architecture has no direct support for `async`/`await`. Even better, we can support this `.refreshable` API without making any changes whatsoever to the core library. This means you wouldn’t even have to wait for us to release a new version of the library to test out this functionality. You could have implemented it yourself.

@T(00:00:54)
So, let’s begin.

## Refreshing and the Composable Architecture

@T(00:01:04)
In the Composable Architecture we often like to begin with a little bit of a domain modeling exercise. It’s certainly not the only way to start a feature. Alternatively we could build out the view and then let that guide us to do the domain modeling.

@T(00:01:16)
But right now it’s clear that our state consists of an integer count and a fact represented by an optional string:

```swift
struct PullToRefreshState: Equatable {
  var count = 0
  var fact: String?
}
```

@T(00:01:32)
Next we model the actions that can occur in the feature. The most straightforward actions to model are what the user does in the application, such as tapping the increment and decrement buttons, tapping the cancel button, or activating the refresh action:

```swift
enum PullToRefreshAction: Equatable {
  case cancelButtonTapped
  case decrementButtonTapped
  case incrementButtonTapped
  case refresh
}
```

@T(00:01:41)
Incidentally, these are also all the methods we had on our view model, which we invoked from the view.

@T(00:01:46)
However, in the Composable Architecture there is another set of actions that are explicitly modeled that we don’t have to think about when building an observable object in vanilla SwiftUI, and that’s actions that are emitted by effects. We do this in the Composable Architecture because it helps us separate the simple, pure logical transformation of state from interactions with the messy outside world.

@T(00:02:04)
Right now we only have a single effect that needs to be tied to an action, and that is when we execute the fact API request, it wants to feed its data back into the system. We can model this with a single case that holds a result type that contains a fact or an error:

```swift
case factResponse(Result<String, Error>)
```

@T(00:02:24)
Next we model the environment of dependencies that this feature needs to do its job. At a bare minimum we need some kind of client for making the API request for the number fact. We actually already have this dependency in the project because there are lots of case studies that need to make this kind of API request:

```swift
struct PullToRefreshEnvironment {
  var fact: FactClient
}
```

@T(00:02:48)
If we want to go a little above and beyond and control even more of the environment that our feature operates in we can also control the scheduler that we will use for delivering events from the API request back to the main queue:

```swift
struct PullToRefreshEnvironment {
  var fact: FactClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}
```

@T(00:03:16)
We do this because we can’t assume that the fact client delivers its events on the main queue, but also if we don’t control the queue used for the delivery of data then we will have to sprinkle in `XCTExpectation`s all of over our tests in order to make sure that we wait enough time for a thread hop to occur and for us to get data from the dependency. This little bit of upfront work will make our tests much simpler to write.

@T(00:03:39)
Next we implement the logic for our feature by creating a reducer that describes how to evolve the state when an action comes in, as well as how to execute side effects and feed their data back into the system:

```swift
let pullToRefreshReducer = Reducer<
  PullToRefreshState,
  PullToRefreshAction,
  PullToRefreshEnvironment
> { state, action, environment in
  switch action {
  }
}
```

@T(00:03:53)
We just need to implement the logic for each of the cases of the `PullToRefreshAction`.

@T(00:04:03)
For example, tapping the increment or decrement button is quite simple to handle:

```swift
case .decrementButtonTapped:
  state.count -= 1
  return .none

case .incrementButtonTapped:
  state.count += 1
  return .none
```

@T(00:04:20)
Next, handling the fact response is as simple as storing the loaded fact in the state:

```swift
case let .factResponse(.success(fact)):
  state.fact = fact
  return .none

case .factResponse(.failure):
  // TODO: do some error handling
  return .none
```

@T(00:04:51)
And then the `.refresh` action is responsible for kicking off an effect, which can be done by using the `FactClient` in the environment, receiving the output on the main queue, and then transforming the response into an action that can be fed back into the system:

```swift
case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
```

@T(00:06:03)
Here is where we get to build in some of the cancellation logic. We can mark this effect as being cancellable so that we can then cancel it from another action:

```swift
case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: "refresh")
```

@T(00:06:21)
You can use any `Hashable` value for the cancellation id. Then, over in the `.cancelButtonTapped` action we can return an effect that will cancel the fetch effect:

```swift
case .cancelButtonTapped:
  return .cancel(id: "refresh")
```

@T(00:06:30)
We can also strengthen this cancellation identifier a bit by defining a dedicated type to represent it rather than using a string. We can even scope the type to the inside of the reducer function, which means that no one outside that scope is even capable of messing with our cancellation logic:

```swift
struct CancelId: Hashable {}

switch action {
case .cancelButtonTapped:
  return .cancel(id: CancelId())

…

case .refresh:
  return environment.fact.fetch(state.count)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
}
```

@T(00:06:57)
The final step to implementing this feature is to implement the view. The view will hold onto a `Store` of the feature domain rather than a view model:

```swift
struct PullToRefreshView: View {
  let store: Store<PullToRefreshState, PullToRefreshAction>

  var body: some View {
  }
}
```

@T(00:07:14)
In the body of the view we will observe state changes in the store by constructing a `ViewStore` via the `WithViewStore` view helper:

```swift
WithViewStore(self.store) { viewStore in
}
```

@T(00:07:29)
But this helper requires that state is equatable, so that it can de-dupe updates and minimize calls to evaluate its body.

```swift
struct PullToRefreshState: Equatable {
  …
}
```

@T(00:07:45)
Inside the scope of the `WithViewStore` we are free to read state and send actions. For example, we can construct a `List` to hold an `Stack` for the increment and decrement buttons and the count:

```swift
List {
  HStack {
    Button("-") { viewStore.send(.decrementButtonTapped) }
    Text("\(viewStore.count)")
    Button("+") { viewStore.send(.incrementButtonTapped) }
  }
  .buttonStyle(.plain)
}
```

@T(00:07:57)
Directly below the counter UI we can show a text view for the fact if it’s present:

```swift
if let fact = viewStore.fact {
  Text(fact)
}
```

@T(00:08:07)
And then we can tack on a `.refreshable` on the `List` view in order to tap into the moment the user tries to pull down to refresh:

```swift
.refreshable {
  viewStore.send(.refresh)
}
```

@T(00:08:16)
It’s a little strange that we don’t have to `await` any of the work in this refreshable closure. Remember that the closure we hand to `.refreshable` is marked as `async`, which means we are allowed to do asynchronous work inside there. But we’re not. We only sending an action to the store, which is a completely synchronous operation.

@T(00:08:31)
But nonetheless, we should have a functioning application now. We can put in an Xcode preview just to make sure:

```swift
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
```

@T(00:08:46)
And things do work… for the most part. If we pull to refresh we will see that the loading indicator goes away immediately, even if the API request is still in flight.

@T(00:09:03)
To make this apparent, let’s insert a small delay into the API effect, just like we did in the vanilla SwiftUI application:

```swift
case .refresh:
  return environment.fact.fetch(state.count)
    // .receive(on: environment.mainQueue)
    .delay(for: 2, scheduler: environment.mainQueue)
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
```

## Async/await and the view store

@T(00:09:28)
Now we can clearly see the problem. The loading indicator goes away immediately even though the API request is still loading.

@T(00:09:46)
This shouldn’t be too surprising because as we mentioned earlier, the way `.refreshable` works is that the loading indicator sticks around for as long as asynchronous work is being performed in the closure provided. In the vanilla SwiftUI application this was automatically handled for us because we awaited the `getFact` method on the view model, and when it finished it automatically caused the loading indicator to go away.

@T(00:10:09)
However, in the Composable Architecture version of the application we are sending an action, which is a completely synchronous operation and so therefore doesn’t need to be awaited:

```swift
.refreshable {
  viewStore.send(.refresh)
}
```

@T(00:10:22)
But that also means there’s no way for us to communicate to SwiftUI that the refreshing work is ongoing and so therefore the loading indicator shouldn’t go away immediately.

@T(00:10:32)
We need to somehow introduce a way to send an action into the store and then `await` until some occurrence. We can even take some inspiration from the vanilla SwiftUI application we built.

@T(00:10:55)
Recall that in the view model we held onto some state tracking a task on the asynchronous work:

```swift
@Published private var task: Task<String, Error>?
```

@T(00:11:09)
We then had to manage this state a little bit in the view model. For example, we had to remember to `nil`-out the handle when the API request finished:

```swift
defer { self.task = nil }
```

@T(00:11:16)
And we had to remember to `nil`-out the handle when cancelling the work:

```swift
func cancelButtonTapped() {
  self.task?.cancel()
  self.task = nil
}
```

@T(00:11:20)
We had to do this because on the side we are using the `handle` variable to publicly expose to others when the view model is in a loading state or not:

```swift
var isLoading: Bool {
  self.task != nil
}
```

@T(00:11:33)
We need to do something similar with the Composable Architecture version of this application. What if we added some `isLoading` state to our feature’s domain:

```swift
struct PullToRefreshState: Equatable {
  var count = 0
  var fact: String?
  var isLoading = false
}
```

@T(00:11:46)
Then we can flip this boolean to be `true` or `false` in various parts of the reducer to make sure that it is only true when the network request is inflight:

```swift
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

…

case .refresh:
  state.isLoading = true
  return environment.fact.fetch(state.count)
    .delay(for: 2, scheduler: environment.mainQueue.animation())
    .catchToEffect()
    .map(PullToRefreshAction.factResponse)
    .cancellable(id: CancelId())
```

@T(00:12:09)
Then, what if we could cook up and `async` version of `.send` that waits until the `isLoading` state flips to false before continuing:

```swift
.refreshable {
  await viewStore.send(.refresh, while: \.isLoading)
}
```

@T(00:12:21)
This would allow us to communicate to SwiftUI that the refresh work is being done and let the `List` view know once the work is done.

@T(00:12:34)
So, can we implement this method?

@T(00:12:36)
Turns out not only can we do it, but we can even do it outside the main library. It doesn’t require access to any of the internal implementation details. We can write down an implementation in the case studies target, which is completely separate from the Composable Architecture target.

@T(00:13:00)
Let’s start by getting a signature in place:

```swift
extension ViewStore {
  func send(_ action: Action, `while`: (State) -> Bool) async {
  }
}
```

@T(00:13:32)
The first thing we want to do in this method is send the action, because that’s what kicks off the entire process that we then want to wait on:

```swift
self.send(action)
```

@T(00:13:43)
Next we want to somehow wait until the `while` predicate evaluates to `false` on the current state of the view store. Luckily for us the view store exposes the entire stream of states to us publicly, which can be accessed via the `.publisher` property:

```swift
self.publisher
```

@T(00:14:19)
We want to listen to all emissions of this publisher until we find an emissions for which the `while` predicate evaluates to `false`:

```swift
self.publisher
  .filter { !`while`($0) }
```

@T(00:14:32)
Which means `while` must be `@escaping`, and maybe we could rename the local parameter to `isInFlight`.

```swift
func send(
  _ action: Action,
  `while` isInFlight: @escaping (State) -> Bool
) async {
  self.send(action)
  self.publisher
    .filter { !isInFlight($0) }
}
```

@T(00:14:49)
And further we only care about the first emission of this publisher:

```swift
self.publisher
  .filter { !isInFlight($0) }
  .prefix(1)
```

@T(00:14:58)
If we sink on this publisher we will be notified of the exact moment that the `isLoading` property flips to `false`:

```swift
self.publisher
  .filter { !isInFlight($0) }
  .prefix(1)
  .sink { _ in
  }
```

@T(00:15:16)
There’s a few things not quite right about this yet. First of all, we are getting a warning from the compiler because `.sink` returns a cancellable that we are not handling yet. We will need to somehow keep this cancellable alive for as long as the publisher needs to do its job.

@T(00:15:35)
Further, we need to somehow construct an asynchronous task that can be awaited until the publisher emits. Our `.send(_:while:)` method is marked as `async`, so luckily we already have a context to perform asynchronous work. We just need a bridge that allows us to convert non-async/await code into async/await code.

@T(00:15:58)
Swift comes with such a tool, and it’s known as `withUnsafeContinuation`.

```swift
withUnsafeContinuation(<#(UnsafeContinuation<T, Never>) -> Void#>)
```

@T(00:16:10)
This function turns non-async/await code into async/await code. It does this by requiring you to provide a closure, and in that closure is where you perform your asynchronous work that is not able to leverage async/await. If you do that, then what you get back is something that is async/await compatible, and therefore must be awaited in order to be invoked.

@T(00:16:36)
For example, we could use `withUnsafeContinuation` to immediately provide an integer:

```swift
let number = await withUnsafeContinuation { continuation in
  continuation.resume(returning: 42)
}
```

@T(00:17:01)
Of course that is completely synchronous work, so nothing to special there.

@T(00:17:07)
However, with a small tweak we can leverage `DispatchQueue` in order to deliver that integer 10 seconds later:

```swift
let number = await withUnsafeContinuation { continuation in
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    continuation.resume(returning: 42)
  }
}
```

@T(00:17:34)
So, this is showing how we bridge non-async/await code like `DispatchQueue.main.asyncAfter` with code that can properly interface with async/await, such as the closure provided to `.refreshable`.

@T(00:17:51)
We can use this bridge to create an awaitable task that suspends until the Combine publisher we constructed emits. We’ll just wrap the Combine work inside `withUnsafeContinuation` and resume the continuation once the publisher emits its first value, which is also its only value since we have a `.prefix(1)` on the publisher chain:

```swift
await withUnsafeContinuation { continuation in
  self.publisher
    .filter { !isInFlight($0) }
    .prefix(1)
    .sink { _ in
      continuation.resume()
    }
}
```

@T(00:18:22)
OK, so that fixes one of our problems, that of bridging this Combine code to the `async`/`await` world. Next we have to figure out what to do about the cancellable returned to us from the `.sink` method because Swift is still warning us that the value is unused.

@T(00:18:45)
We need to keep the cancellable alive for as long as the publisher is alive. We can do this by declaring an optional cancellable outside the scope of the `.sink`, and then strongly capturing the cancellable inside the `.sink`:

```swift
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
```

> Error: Generic parameter 'T' could not be inferred

@T(00:19:06)
But now that we have a multi-line closure Swift does not infer the type of continuation, so we can add an explicit annotation:

```swift
await withUnsafeContinuation {
  (continuation: UnsafeContinuation<Void, Never>) in
```

@T(00:19:29)
This will guarantee that the subscription lives until its first emission.

@T(00:19:39)
And this completes the basics of the new `.send` helper that is `async`/`await` aware. We can already use it. The code we sketched out earlier is now compiling:

```swift
.refreshable {
  await viewStore.send(.refresh, while: \.isLoading)
}
```

@T(00:19:51)
Now when we run the application we will see it behaves just like the vanilla SwiftUI version. If we pull down to refresh we will see the loading indicator for a few seconds, and then it will go away and the fact will appear.

@T(00:20:15)
Let's quickly get the cancellation button in to make sure that's working as well. First, we'll add the button to the view:

```swift
if viewStore.isLoading {
  Button("Cancel") {
    viewStore.send(.cancelButtonTapped)
  }
}
```

@T(00:20:38)
And to make things behave like the vanilla SwiftUI version, let's be sure to `nil` out the fact when the refresh button is invoked.

```swift
case .refresh:
  state.fact = nil
```

@T(00:20:38)
Now when we run the preview we can see that cancellation works as expected. The interaction is a bit harsher than it is in vanilla SwiftUI, which animates these actions. We can do the same by using an [animated scheduler](/episodes/ep136-swiftui-animation-the-basics), from our [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library, and add a view store animation:

```swift
.delay(for: 2, scheduler: environment.mainQueue.animation())

…

viewStore.send(.cancelButtonTapped, animation: .default)
```

@T(00:21:49)
And now things are looking pretty good, and operate exactly as they did in the vanilla SwiftUI version.

@T(00:21:56)
So this is pretty awesome. We were able to support a fancy new async/await feature in the Composable Architecture without overhauling the entire library to use async/await and without even needing access to the internals of the library. This new async `.send` method could have just as easily be written by anyone without waiting for us to bring this feature to the library.

@T(00:22:18)
There are two important things we want to point out:

@T(00:22:21)
- First, with the Composable Architecture we do have to manage state a little more than we did in the vanilla SwiftUI version. With the observable object we got a 1-to-1 correspondence between the work being executed for refreshing and the `isLoading` boolean. In the Composable Architecture we have to manage that state ourselves.

    However, even in the vanilla SwiftUI version there is a little bit of state management you have to keep up with. You have to remember to mark the handle variable as `@Published` so its changes trigger SwiftUI view updates, and you have to remember to `nil` out that state in order to clean things up when work is completed or cancelled.

@T(00:23:01)
- Second, our new async `.send` method isn’t fully correct just yet. There is a possibility that SwiftUI may want to cancel the work happening inside the closure handed to the `.refreshable` method. We’re not aware of any concrete examples of this, but ostensibly it’s possible. So, we need to do a little bit of extra work to tap into that moment of cancellation, which we can do with something known as `withTaskCancellationHandler`, but we will leave that as an exercise for the viewer, which you can find at the bottom of the episode page.

## Testing and the Composable Architecture

@T(00:23:46)
OK, so we’ve accomplished what we set out to do, but let’s do one more thing. Let’s write some tests! Perhaps the most important feature of the Composable Architecture is its comprehensive testing tools. We want absolutely everything to be testable in the architecture, from the execution of effects and how they feed data back into the system to the glue code that combines lots of disparate features into one big feature. We want it all to be capable of being tested, and done so in a simple, ergonomic way.

@T(00:24:18)
So let's explore what it takes to test this feature.

@T(00:24:29)
We can start the test by constructing a `TestStore`, which gives us a runtime that tracks how actions are fed into the system and how the state changes over time, and forces us to assert on every little thing that takes place on the inside. In order to construct the test store we have to provide the environment of dependencies, and we can provide dependencies that perform their work immediately and synchronously:

```swift
import ComposableArchitecture
…
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
```

@T(00:25:51)
Now we can start sending actions to the test store, like say emulating the action of the user tapping the increment button:

```swift
store.send(.incrementButtonTapped)
```

> Failed: State change does not match expectation: …
>
> ```
>   PullToRefreshState(
> −   count: 0,
> +   count: 1,
>     fact: nil,
>     isLoading: false
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:26:00)
That leads to a test failure because along with every action sent to the store we have to assert on exactly how the state changed. To do that we open up a trailing closure on the `.send` method and mutate `$0` to describe exactly how state changed:

```swift
store.send(.incrementButtonTapped) {
  $0.count = 1
}
```

@T(00:26:31)
Now the test is passing.

@T(00:26:36)
Let’s test something a little more complicated. Let’s emulate what happens when the user pulls the list down to refresh the fact. We know that the `isLoading` state should flip to `true`, so we can describe that state change:

```swift
store.send(.refresh) {
  $0.isLoading = true
}
```

> Failed: The store received 1 unexpected action after this one: …
>
> ```
> Unhandled actions: [
>   PullToRefreshAction.factResponse(
>     Result<String, Error>.success(
>       "1 is a good number."
>     )
>   ),
> ]
> ```

@T(00:26:54)
But running tests results in another test failure. This time the library is telling us that an effect executed and caused an action to be fed back into the system, and we haven’t yet asserted on that. This is a great failure to have because it forces you to describe everything happening in the application, including how effects execute.

@T(00:27:12)
To get a passing test we need to tell the test store that we expect to receive an action, which is the `.factResponse` action with a successful payload:

```swift
store.receive(.factResponse(.success("1 is a good number.")))
```

> Error: Referencing instance method '`receive(_:_:)`' on 'TestStore' requires that 'PullToRefreshAction' conform to 'Equatable'

@T(00:27:30)
Asserting on effects received by the test store requires that actions be equatable, as well, so let's add a conformance:

```swift
enum PullToRefreshAction: Equatable {
  …
}
```

@T(00:27:45)
Further, when this action is received some state mutates:

```swift
store.receive(.factResponse(.success("1 is a good number."))) {
  $0.isLoading = false
  $0.fact = "1 is a good number."
}
```

@T(00:28:03)
And now the test passes.

@T(00:28:07)
It’s worth comparing this test to what we did in the vanilla SwiftUI test. When testing the observable object we had to resort to hacks in order to get coverage on the `isLoading` boolean flipping to `true` and then `false`. And we sadly were not able to exhaustively test how the entire state of the observable object changed, we could only assert on individual fields.

@T(00:28:31)
However, with the Composable Architecture we can easily tap into every little moment before and after effects are executed and can assert on how the state changes in those subtle flows. We also are forced to exhaustively assert on how every little piece of state changed. If we forget something, or if new fields are added to state later we will instantly be notified with a test failure. For example, suppose we forgot to flip `isLoading` back to `true` in the test when we receive the fact response:

```swift
store.receive(.factResponse(.success("1 is a good number."))) {
  // $0.isLoading = false
  $0.fact = "1 is a good number."
}
```

@T(00:28:59)
Then we immediately get a test failure showing us exactly what went wrong:

> Failed: State change does not match expectation: …
>
> ```
>   PullToRefreshState(
>     count: 1,
>     fact: "1 is a good number.",
> −   isLoading: true
> +   isLoading: false
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:29:05)
So that’s pretty great, and as we’ve said many times, the testing infrastructure of the Composable Architecture is one of the most important features of the library.

@T(00:29:17)
Let’s push things a little further by testing the flow where the user cancels the inflight fact request. Recall that we couldn’t figure out how to test that flow in the vanilla SwiftUI version. We have a feeling we know how it should be accomplished, but it doesn’t yet work, either due to bugs in the Xcode beta or perhaps we need to make use of custom executors, which just landed in beta 3.

@T(00:29:36)
Either way, testing this flow in the Composable Architecture is a breeze. In order to get access to the brief moment that exists between refreshing and receiving a fact response, we need to use a different kind of scheduler for the main queue. For the test we just wrote we used an immediate scheduler because we didn’t need access to those moments and so it was ok to squash all of time into a single moment and force our effects to produce a value immediately.

@T(00:30:01)
However, now we do care, and so we have to use a scheduler known as a `TestScheduler`. This scheduler does not allow time to move forward until we tell it to. This is perfect for getting inside those tricky moments between asynchronous effects executing. So, let’s create a test store, but this time use a test scheduler:

```swift
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
```

@T(00:30:45)
Then, to test the flow of invoking the refresh action and cancelling while it is inflight we just need to send two actions to the test store:

```swift
store.send(.refresh) {
  $0.isLoading = true
}
store.send(.cancelButtonTapped) {
  $0.isLoading = false
}
```

@T(00:31:03)
And just like that the test passes.

@T(00:31:10)
This may seem too good to be true though. How can we be sure that it is actually testing cancellation of an inflight effect?

@T(00:31:17)
Well, we can be sure because the test store forces us to exhaustively describe everything that happens in the system. This not only includes state changes and receiving data from effects as we have seen before, but also forces that every effect be completed by the time the test is finished. If the fact effect was still in flight by the time the test finished executing then we would have gotten a failure. The mere fact this test passes proves that it's impossible for any effects to later feed data back into the system.

@T(00:31:45)
We can see this for ourselves by commenting out the `.send` that emulates tapping the cancel button:

```swift
store.send(.refresh) {
  $0.isLoading = true
}
// store.send(.cancelButtonTapped) {
//   $0.isLoading = false
// }
```

> Failed: An effect returned for this action is still running. It must complete before the end of the test. …
>
> To fix, inspect any effects the reducer returns for this action and ensure that all of them complete by the end of the test. There are a few reasons why an effect may not have completed:
>
> • If an effect uses a scheduler (via "receive(on:)", "delay", "debounce", etc.), make sure that you wait enough time for the scheduler to perform the effect. If you are using a test scheduler, advance the scheduler so that the effects may complete, or consider using an immediate scheduler to immediately perform the effect instead.
>
> • If you are returning a long-living effect (timers, notifications, subjects, etc.), then make sure those effects are torn down by marking the effect ".cancellable" and returning a corresponding cancellation effect ("Effect.cancel") from another action, or, if your effect is driven by a Combine subject, send it a completion.

@T(00:31:51)
The test now fails because it has detected that there is an effect in flight.

@T(00:32:12)
If the library did not fail on this situation then it would mean you could have effects still executing when the test finished, which means there’s the potential for new actions to be fed into the system and change state, all without you making any assertions. That can either hide actual bugs or hide new logic that should be tested, but if the test didn’t loudly complain you may forget to add test coverage.

@T(00:32:34)
One thing we can do to make the test complete is advance the scheduler a tick, causing the effect to emit and feed its data back into the system:

```swift
store.send(.refresh) {
  $0.isLoading = true
}
// store.send(.cancelButtonTapped) {
//   $0.isLoading = false
// }
…
mainQueue.advance(by: .seconds(2))
```

> Failed: The store received 1 unexpected action after this one: …
>
> ```
> Unhandled actions: [
>   PullToRefreshAction.factResponse(
>     Result<String, Error>.success(
>       "0 is a good number."
>     )
>   ),
> ]
> ```

@T(00:33:04)
But now we get a different error, similar to one we saw before, where an action was fed into the system but we didn’t explicitly assert on it by calling the `.receive` method.

@T(00:33:08)
So, this is showing what it means for the Composable Architecture to be exhaustive in testing. You really do need to describe everything that is happening in the system, from state mutations to effect executions. Let’s get back into a passing state by bringing back the `.cancelButtonTapped` action:

```swift
store.send(.refresh) {
  $0.isLoading = true
}
store.send(.cancelButtonTapped) {
  $0.isLoading = false
}
```

@T(00:33:29)
Now the test passes, and so this really is proving that the fact effect cancellation works as we expect.

@T(00:33:38)
This is great. We are able to hook into a brand new SwiftUI feature in the Composable Architecture with very little work. It even uses `async`/`await`, which the Composable Architecture doesn’t even have official support for (yet), but we were still able to build the tools necessary for bridging these worlds. Even better, we were able to accomplish all of this without making a single change to the internals of the library, which means all of our viewers could have introduced this to their code bases without waiting for us.

@T(00:34:09)
It’s also pretty cool how easy it was to test everything we did, but to be fair we also think that someday Swift’s standard library will have more tools for us to better test asynchronous code, probably via executors.

## Next time: SwiftUI focus state

@T(00:34:22)
Next week we will discuss another new, fancy feature announced at WWDC: focus state. Like `.refreshable` it isn’t exactly clear how it adapts to the Composable Architecture, but it’s totally possible and it exploring that even shows how to work with focus state in observable objects too.

@T(00:34:48)
Till next time!
