## Introduction

@T(00:00:05)
It has now been over a month since WWDC ended where a ton of new interesting technologies were introduced. Perhaps the most exciting is Swift’s new concurrency model, where the lightweight syntax of async/await coupled with the actor model can help give us very strong guarantees on how asynchronous code executes in our programs. We are going to have a lot to say about these tools someday in the future on Point-Free, but this week we want to start by focusing on some simpler things.

@T(00:00:32)
We got a lot of questions from viewers on how certain new, shiny features of SwiftUI fit into the Composable Architecture, and we want to take a moment to explore some of these new APIs. This gives us an opportunity to show of a few fun things:

@T(00:00:44)
- First, we get to make use of the new fancy SwiftUI APIs in the Composable Architecture, which is a library we like to use to build large, complex applications.

@T(00:00:53)
- Further, we get to explore ways to make these new APIs more testable. Testing is a huge part of the Composable Architecture, perhaps one of the most important parts, and so whenever we adopt a new SwiftUI feature we like to make sure we are not sacrificing testability.

@T(00:01:08)
- And finally, we get to show one of the core tenets of how we design the Composable Architecture, which is to make the library as extensible as possible from the outside. Ideally no changes need to be made to the core library to embrace these new APIs, which means the community can step up if we don’t as library maintainers.

@T(00:01:35)
We are going to explore these topics in the context of three specific SwiftUI features that were announced at WWDC: the `.refreshable` view modifier that allows you to add pull-to-refresh to any view, the `@FocusState` property wrapper that allows you to control the focus of controls, and the `.searchable` API that allows you to layer on search onto any SwiftUI view. All of these features are powerful, but it’s not immediately clear how to take advantage of them in the Composable Architecture.

## The refreshable API

@T(00:02:01)
Let’s start with the new refreshable API in SwiftUI. This one is interesting because it is built on Swift’s new async/await tools, which currently the Composable Architecture has no support for. So it’s not exactly clear how to bridge these two worlds.

@T(00:02:14)
Let’s start by building a quick prototype in just vanilla SwiftUI so that we can get some understanding of how the refreshable API works with async/await. It’s worth nothing that we are using Xcode beta 3 to record this episode, and so certain things we do may change slightly by the time the final release of Xcode 13 comes out, but hopefully not too much.

@T(00:02:36)
We will build our prototype as a Composable Architecture case study, so let’s open the library’s work space and add a new file to the case studies target. We will put this case study in the effects section since it deals with executing effects in an async/await environment.

@T(00:03:11)
The case study will be quite simple. We will have a little counter on the screen for counting up and down, and when you pull down to “refresh” we will load a fact about that number from a public API. This is similar to some of our other case studies dealing with effects, but instead of tapping on buttons to fire effects we want to trigger it from the new `.refreshable` API.

@T(00:03:35)
Let’s start by getting a view into place. We need to put our counter into a `List` so that we get automatic pull-to-refresh support, but it’s also possible to create custom refresh experiences by leveraging the new `refresh` environment value.

```swift
import SwiftUI

struct VanillaPullToRefreshView: View {
  var body: some View {
    List {
      HStack {
        Button("-") { }
        Text("0")
        Button("+") { }
      }
      .buttonStyle(.plain)

      Text("0 is a good number.")
    }
  }
}

struct VanillaPullToRefreshView_Previews: PreviewProvider {
  static var previews: some View {
    VanillaPullToRefreshView()
  }
}
```

@T(00:03:41)
Running this preview we already see a list with one row.

@T(00:03:54)
In order to tap into the pull-to-refresh functionality, all we have to do is add the `.refreshable` view modifier to the list, which takes a closure that is invoked when a user pulls to refresh.

```swift
List {
  …
}
.refreshable {

}
```

@T(00:04:08)
And now running the preview we can see that a loading indicator appears when pulling down on the list.

@T(00:04:19)
Now we need to implement the action closures for these buttons and the refresh action. We could just use some `@State` and do everything right in the view because it's easy, but whenever logic becomes decently complex, especially when effects are involved, it’s best to handle the logic in a proper observable object. So, let’s sketch one out real quick that holds onto a `count` and `fact`, and has endpoints for incrementing, decrementing and fetching a fact:

```swift
class PullToRefreshViewModel: ObservableObject {
  @Published var count = 0
  @Published var fact: String? = nil

  func incrementButtonTapped() {
    self.count += 1
  }

  func decrementButtonTapped() {
    self.count -= 1
  }

  func getFact() {
    <#???#>
  }
}
```

@T(00:05:02)
We’re not sure what we are going to put into the `getFact` method yet, but we can at least introduce this view model to our view and call out to the endpoints from the various action closures:

```swift
struct VanillaPullToRefreshView: View {
  @ObservedObject var viewModel: PullToRefreshViewModel

  var body: some View {
    List {
      HStack {
        Button("-") { self.viewModel.decrementButtonTapped() }
        Text("\(self.viewModel.count)")
        Button("+") { self.viewModel.incrementButtonTapped() }
      }
      .buttonStyle(.plain)

      if let fact = self.viewModel.fact {
        Text(fact)
      }
    }
    .refreshable {
      self.viewModel.getFact()
    }
  }
}

struct VanillaPullToRefreshView_Previews: PreviewProvider {
  static var previews: some View {
    VanillaPullToRefreshView(viewModel: .init())
  }
}
```

@T(00:05:43)
So, the question is, how do we implement the `getFact` method?

@T(00:05:46)
We want to reach out to an external API service, which means we need to do a little bit of asynchronous work. This sounds like a perfect opportunity to try out Swift’s new async/await machinery.

@T(00:05:56)
There is a new `.data(from:)` method on `URLSession` that allows you to asynchronously make a network request, and get the data and response back right inline, without the need for callback closures, or sinking on publishers and dealing with cancellables:

```swift
let (data, _) = try await URLSession.shared.data(
  from: .init(
    string: "http://numbersapi.com/\(self.count)/trivia"
  )!
)
```

@T(00:06:36)
But, now that we are trying to `await` some asynchronous code we need to make our `getFact` method `async`:

```swift
func getFact() async {
  …
}
```

@T(00:06:47)
And now the compiler is complaining about not handling errors from the `.data` method, so let’s wrap this in a `do`/`catch`:

```swift
func getFact() async {
  do {
    let (data, _) = try await URLSession.shared.data(
      from: .init(
        string: "http://numbersapi.com/\(self.count)/trivia"
      )!
    )
  } catch {
    // TODO: do some error handling
  }
}
```

@T(00:07:01)
It’s honestly pretty fantastic.

@T(00:07:15)
And once we do that we need to `await` its invocation down in the view:

```swift
.refreshable {
  await self.viewModel.getFact()
}
```

@T(00:07:22)
And this is only possible because the `.refreshable` view modifier specifically accepts an action closure that is `async`:

```swift
.refreshable(action: <#() async -> Void#>)
```

@T(00:07:35)
So SwiftUI is providing us an asynchronous context to work in. Further, the refreshing indicator, which is the little spinner at the top, will automatically appear and disappear with the lifecycle of this asynchronous task. As soon as our network request finishes the loading indicator will animate away.

@T(00:07:54)
Back up in the view model, once we’ve loaded the data from the API we can turn it into the string and assign it to the `fact` field. We also need to do some `do`/`catch`ing because the API request can error, but we won’t do any error handling right now:

```swift
do {
  let (data, _) = try await URLSession.shared.data(
    from: .init(
      string: "http://numbersapi.com/\(self.count)/trivia"
    )!
  )
  self.fact = String(decoding: data, as: UTF8.self)
} catch {
  // TODO: do some error handling
}
```

@T(00:08:24)
If we run this in the preview it seems to be working. We can pull down to fetch a new fact about the number we’ve counted too. But, the loading animation happens really quickly and is hard to see because of how quickly the API responds. Let’s do a few things to make this a little nicer.

@T(00:08:57)
We’ll start by forcing a small delay in the API request so that we can simulate what it looks like for the async work to take a bit longer. There’s a method called `Task.sleep` that allows you to suspend the current task for an amount of time, measured in nanoseconds:

```swift
func getFact() async {
  Task.sleep(2 * NSEC_PER_SEC)

  …
}
```

> Error: Expression is 'async' but is not marked with 'await'

@T(00:09:25)
However, this method is asynchronous, just like our `getFact` method, and so we must `await` it:

```swift
await Task.sleep(2 * NSEC_PER_SEC)
```

@T(00:09:37)
Now when we pull to refresh we see a 2 second delay before getting the data. Let’s also clear out the previous fact while we are loading the new one:

```swift
func getFact() async {
  self.fact = nil

  …
}
```

@T(00:09:45)
Also the UI is a little jumpy though because there’s no animation, so let’s also wrap our state mutations in a `withAnimation`:

```swift
func getFact() async {
  self.fact = nil

  do {
    try await Task.sleep(2 * NSEC_PER_SEC)

    let (data, _) = try await URLSession.shared.data(
      from: .init(
        string: "http://numbersapi.com/\(self.count)/trivia"
      )!
    )
    withAnimation {
      self.fact = String(decoding: data, as: UTF8.self)
    }
  } catch {
    // TODO: do some error handling
  }
}
```

@T(00:10:04)
OK, now it’s looking good.

## Cancelling async tasks

@T(00:10:27)
Let’s add one more layer of complication. Let’s have it so that when the API request is in flight we show a cancel button, and when you tap that button we cancel the request. This should also make the loading indicator animate away and the cancel button go away.

@T(00:10:47)
To do this we need to get access to the actual asynchronous task being performed in the view model. So let’s see what that looks like

@T(00:10:56)
Currently the `getFact` method executes a bunch of asynchronous work, but does so by just awaiting the work right in the method. We do this so that we can go step-by-step from top-to-bottom to accomplish all of our tasks: clear the `fact` field, execute the work, set the `fact` string.

@T(00:11:13)
However, if we want to capture the asynchronous task being performed in a variable so that we can cancel it at a later time we need to explicitly create a `Task` value:

```swift
let task = Task {
}
```

@T(00:11:31)
Most importantly it has a method on it that can cancel the work being performed inside:

```swift
task.cancel()
```

@T(00:11:42)
So, this seems to be exactly what we need.

@T(00:11:45)
However, it’s worth mentioning that this brand new asynchronous context that is separate from the one provided to us by marking the `getFact` method as `async`. In a sense this is us leaving the “structured” concurrency world since we are detaching from the asynchronous context provided to us.

@T(00:12:04)
However, that’s ok. We can put just our asynchronous work inside the task:

```swift
let task = Task {
  await Task.sleep(2 * NSEC_PER_SEC)

  let (data, _) = try await URLSession.shared.data(
    from: .init(
      string: "http://numbersapi.com/\(self.count)/trivia"
    )!
  )

  return String(decoding: data, as: UTF8.self)
}
```

@T(00:12:25)
This won’t currently type check because Swift can’t figure out the generics for `Task`, which represent the value returned from the task and the potential error, if any, that can happen. So let’s specify those generics:

```swift
let task = Task<String, Error> {
  …
}
```

@T(00:12:42)
This moves the work into another task, but we are no longer `await`ing its result. The work will be executed, but we haven’t bridged our new unstructured asynchronous task with the world of the structured.

@T(00:12:55)
To do that we need to grab the value out of the task:

```swift
self.fact = task.value
```

@T(00:13:03)
But to do that we have to explicitly `try` and `await` the work:

```swift
self.fact = try await task.value
```

@T(00:13:09)
And `withAnimation` is a synchronous context, so we need to pull this work out to a local variable.

```swift
let fact = try await task.value
withAnimation {
  self.fact = fact
}
```

@T(00:13:24)
So, that’s how we spin off an unstructured task so that we can get a reference to it, and then bring it back into the structured world. That means we can update our `do`/`catch` code to just use the value from the task:

@T(00:13:31)
So, now the preview should run exactly as it did before, but now we’ve got a reference to the asynchronous work that loads a fact for a number.

@T(00:13:43)
Now we can cancel this work when a “Cancel” button is tapped in the UI. Let’s hold onto the task as an optional in the view model so that we can use it at any time:

```swift
var task: Task<String, Error>?
```

@T(00:14:06)
And assign it in the `getFact` method:

```swift
self.task = Task {
  …
}
```

@T(00:14:10)
Now we are able to introduce a new endpoint to the view model that cancels the inflight task:

```swift
func cancelButtonTapped() {
  self.task?.cancel()
}
```

@T(00:14:22)
And we can easily add a button to the view that allows us to cancel the inflight task:

```swift
if let fact = self.viewModel.fact {
  Text(fact)
}

Button("Cancel") {
  self.viewModel.cancelButtonTapped()
}
```

@T(00:14:34)
However, we need to do a bit more work because we don’t want to show this button all the time. Only when the task is inflight. The presence of the task field does indicate whether or not the task is inflight, but only if we manage the state a bit more. We need to explicitly clear out the task in the `cancelButtonTapped` method:

```swift
self.task?.cancel()
self.task = nil
```

@T(00:14:52)
Now, technically we can check if a task is inflight by checking if the `task` field is non-`nil`, and we can even chain that onto the `if let` statement we have for unwrapping the `fact` field:

```swift
if let fact = self.viewModel.fact {
  Text(fact)
} else if self.viewModel.task != nil {
  Button("Cancel") {
    self.viewModel.cancelButtonTapped()
  }
}
```

@T(00:15:05)
It’s probably not a good idea to expose the task so publicly. This would allow anyone with access to the view model to cancel the task, so it would be best to encapsulate all of that logic into the view model alone. So instead we can make the task private and expose a computed property:

```swift
private var task: Task<String, Error>?

…

var isLoading: Bool {
  self.task != nil
}

…

if let fact = self.viewModel.fact {
  Text(fact)
} else if self.viewModel.isLoading {
  Button("Cancel") {
    self.viewModel.cancelButtonTapped()
  }
}
```

@T(00:15:40)
So, that was pretty straightforward, but unfortunately it’s not quite right yet. There are a few rough edges to smooth out.

@T(00:15:48)
If we run the preview and pull-to-refresh we will see that the “Cancel” button does appear and disappear while the fact request is inflight. However, tapping the cancel button doesn’t seem to stop the refresh activity.

@T(00:16:16)
This actually seems to be a bug in SwiftUI and `Task` as far as we can tell. The task is definitely being cancelled, but SwiftUI isn’t cleaning up its state after the task finishes. We can give it a little kick by marking the `task` property as `@Published` so that the view gets a chance to re-compute its body and clean up its state:

```swift
@Published private var task: Task<String, Error>?
```

@T(00:16:40)
So, now if we run the preview it will work as expected. We can cancel an inflight request.

@T(00:16:51)
However, even if SwiftUI and `Task` did not have this bug, we would still want to mark `task` as a `@Published` property. This is because we are using the `isLoading` computed property in the view, and if we want the view to re-render itself anytime `isLoading` changes, we will have to make sure every field used inside its implementation is marked as `@Published`.

@T(00:17:11)
This is just a general gotcha of using computed properties on view models. if you want to observe changes to the computed property then every field used inside must be marked `@Published`.

@T(00:17:21)
It’s also worth noting that the data modeling in our observable object isn’t ideal. We are holding onto two independent pieces of optional state:

```swift
@Published var fact: String? = nil
@Published private var handle: Task<(), Error>?
```

@T(00:17:34)
…to represent something that has only 3 states: you either have no fact, or you have a fact, or a request is being made to get a fact. The current data modeling allows for some weird states that should never happen, such as having a fact while a request is in flight. So, it might be better to re-model this as an enum that holds onto a fact string or a task handle someday.

@T(00:17:56)
And there’s still another subtle problem that unfortunately we can’t see from running in Xcode previews. Let’s quickly get this case study running in the simulator by swapping in this view in the entry point of the application. This case studies app is still using the old style entry point by using a scene delegate:

```swift
self.window?.rootViewController = UIHostingController(
  rootView: VanillaPullToRefreshView(viewModel: .init())
)
```

@T(00:18:22)
If we run the application in the simulator and load a fact, we will see a purple warning in our view model:

> Runtime Warning: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.

@T(00:18:39)
This is happening because when we `await` the `URLSession` work our method is suspended so that the network request can be made, and when our method is resumed we are on a non-main thread. Async/await does not necessarily resume your code on the same thread as before the `await`.

@T(00:18:58)
We could of course do the standard rigamarole to get us back on the main thread by using the main `DispatchQueue`, but we’d have to do it everywhere we are mutating state:

```swift
DispatchQueue.main.async {
  withAnimation {
    self.fact = fact
  }
}
```

@T(00:19:13)
However, Swift provides better tools for us. We can simply mark our method as a `@MainActor` to guarantee that all of its code will be executed on the main thread, even though we may be calling out to tasks that suspend and perform work on background threads:

```swift
@MainActor
func getFact() async {
  …
}
```

@T(00:19:38)
We can now run the app and refresh we will not get that warning.

## Testing asynchronous code

@T(00:20:05)
Even with all of the work we have put into this there are still a few subtle bugs hiding in this code. In order to explore those bugs let’s try writing some tests.

@T(00:20:26)
To make our code testable we need to do a better job of injecting its dependencies so that we’re not making live API requests in tests. We can introduce a new field to our view model that represents the work to fetch a fact for a number:

```swift
class PullToRefreshViewModel: ObservableObject {
  …

  let fetch: (Int) async throws -> String

  init(fetch: @escaping (Int) async throws -> String) {
    self.fetch = fetch
  }

  …
}
```

@T(00:21:24)
Then in the `getFact` method we can use this `self.fetch` endpoint instead of calling out to `URLSession` directly:

```swift
self.task = Task {
  try await self.fetch(self.count)
}
```

@T(00:21:41)
And we can update our preview and app entry point to pass along the live API request dependency:

```swift
VanillaPullToRefreshView(
  viewModel: .init(
    fetch: { count in
      await Task.sleep(2 * NSEC_PER_SEC)

      let (data, _) = try await URLSession.shared.data(
        from: .init(string: "http://numbersapi.com/\(count)/trivia")!
      )

      return String(decoding: data, as: UTF8.self)
    }
  )
)
```

@T(00:22:19)
We can now hop over to a test file, and get a basic stub of a test in place:

```swift
@testable import SwiftUICaseStudies
import XCTest

class RefreshableTests: XCTestCase {
  func testVanilla() {
  }
}
```

@T(00:22:38)
The thing we want to test is the view model, and in order to construct one we need to provide the `fetch` endpoint. Since we properly injected this dependency we now have the opportunity to supply a completely synchronous, stubbed out version of the dependency:

```swift
func testVanilla() {
  let viewModel = PullToRefreshViewModel(
    fetch: { count in
      "\(count) is a good number."
    }
  )
}
```

@T(00:23:04)
Notice that no asynchronous work is being performed in the endpoint at all. It just immediately returns a hard coded string.

@T(00:23:12)
To test this view model we can invoke some of its methods and then assert on what state changed on the inside. The simplest thing to test would be that the increment button works as expected:

```swift
viewModel.incrementButtonTapped()
XCTAssertEqual(viewModel.count, 1)
```

@T(00:23:54)
Something a little more complex would be to try to get a fact from the view model. If we invoke the method we get an error:

```swift
viewModel.getFact()
```

> Error: Expression is 'async' but is not marked with 'await'

@T(00:24:07)
But that just means we need to `await` it:

```swift
await viewModel.getFact()
```

> Error: 'async' call in a function that does not support concurrency

@T(00:24:14)
But in order for that to work we need to be in an asynchronous context. We can make use of the new `async` features of `XCTest` which allows you to write tests dealing with asynchronous code and the test runner will automatically take care of `await`ing the results so that you can make assertions:

```swift
func testVanilla() async {
  …
}
```

No more need to juggle test expectations, which is awesome.

@T(00:24:37)
However, it’s also a good idea to never use actual asynchronous code in tests. As we’ve seen many, many times on Point-Free, they lead to slow and unreliable tests. Instead, you should mock out all of your dependencies so that they provide synchronous endpoints that immediately returned data you are in control of, rather than reaching out into the real world to fetch data.

@T(00:25:08)
Once we have waited for the `getFact` method to finish we can now assert on what we expect to change in the view model:

```swift
XCTAssertEqual(viewModel.fact, "1 is a good number.")
```

@T(00:25:19)
And this test passes! It’s pretty incredible that we are able to test asynchronous code as if it was completely synchronous.

@T(00:25:28)
However, we’re not asserting on everything that could possible change in the view model. There is also the `isLoading` property, which drives the visibility of the cancel button. We expect this value to flip to `true` as soon as `getFact` is invoked, and then flip back to `false` once the request is finished.

@T(00:25:47)
The easiest part of this lifecycle to test is that when awaiting the `getFact` method finishes we should have that `isLoading` is `false` because that method has completely finished executing. There is no more asynchronous work happening at all:

```swift
XCTAssertEqual(viewModel.isLoading, false)
await viewModel.getFact()
…
XCTAssertEqual(viewModel.isLoading, false)
```

> Failed: XCTAssertEqual failed: ("true") is not equal to ("false")

@T(00:26:19)
Yet somehow that fails.

@T(00:26:36)
This is actually catching a serious bug in our logic. The reason `isLoading` is still true, even though the `getFact` method has completely finished executing and is not doing any asynchronous work whatsoever anymore, is because we forgot to `nil` out the `task` when the network request finished.

@T(00:27:02)
Now, forgetting to do this work hasn’t actually introduced a bug into our application. When we run it in the preview or simulator, everything seems to work just fine. However, in the future we may start adding new features to the view model or view that rely on `isLoading` reflecting the correct state of the behavior, and that could introduce some serious bugs.

@T(00:27:48)
So, we really do need to explicitly manage this state, which means `nil`-ing out the `task` once the `getFact` method is finished:

```swift
self.task = Task<String, Error> {
  try await self.fetch(self.count)
}
defer { self.task = nil }
```

@T(00:28:06)
Now the test passes.

@T(00:28:12)
We would also love if we could strengthen this test to further capture the moment the `isLoading` field flips to `true`. That happens right when the when the asynchronous work starts, so we need to tap into that somehow.

@T(00:28:35)
We can try to leverage task handles again. This allows us to start up the work and then later wait for its result. So, let’s wrap the `getFact` invocation in a task handler:

```swift
let task = Task {
  await viewModel.getFact()
}
```

@T(00:28:52)
And then we would hope that right after that starts up we could check that `isLoading` is `true`:

```swift
let task = Task {
  await viewModel.getFact()
}
XCTAssertEqual(viewModel.isLoading, true)
```

@T(00:29:01)
And then we can `await` the result, which should cause the `isLoading` field to go to `false`:

```swift
let task = Task {
  await viewModel.getFact()
}
XCTAssertEqual(viewModel.isLoading, true)
await task.value
XCTAssertEqual(viewModel.isLoading, false)
```

> Failed: XCTAssertEqual failed: ("false") is not equal to ("true")

@T(00:29:11)
This unfortunately does not pass. It appears that the `getFact` method hasn’t actually began executing and so the boolean is not yet `true`. We aren’t sure of the best way to handle this to be honest. There’s isn’t a ton of guidance on testing nuanced flows like this.

@T(00:29:32)
In the meantime we can technically turn to adding explicit sleeps to the tests to wedge ourselves between when the asynchronous work starts and finishes. We can do this by inserting a sleep into the `fetch` endpoint to force it to take some time. We don’t wait to sleep for too much time because that will slow down the test suite, so maybe we can just sleep for one microsecond:

```swift
let viewModel = PullToRefreshViewModel(
  fetch: {
    await Task.sleep(1_000)
    return "\($0) is a good number."
  }
)
```

@T(00:29:59)
And then we could sleep half that amount of time after we invoke the `getFact` method:

```swift:5:fail
let task = Task {
  await viewModel.getFact()
}
await Task.sleep(500)
XCTAssertEqual(viewModel.isLoading, true)
await task.value
XCTAssertEqual(viewModel.isLoading, false)
```

> Failed: XCTAssertEqual failed: ("false") is not equal to ("true")

@T(00:30:22)
Unfortunately this still fails. It seems that these amounts of times are too small. We can multiply the sleep times by a couple thousand in order to sleep for a couple milliseconds and a millisecond respectively.

@T(00:30:59)
And now we get a passing test. But also it’s a little flakey. If we run it enough times it will eventually fail. Seems like we should probably increase the times even more, but we’ll never feel fully confident in this test and it’s going to start slowing down our test suite, especially if we have dozens or hundreds of these kinds of tests.

@T(00:31:32)
There’s other behavior in this view model we’d like to test, such as the cancellation of inflight request. To be honest we’re not quite sure how to do this either. It could be that there are concurrency tools coming that will aid in this, such as the recently released executors, or there may be bugs in the current Swift implementation, or maybe we just don’t know how to do it.

## Next time: refreshing the Composable Architecture

@T(00:32:10)
So, that’s a quick introduction to the new `.refreshable` view modifier in SwiftUI, along with a small dose of `async`/`await`. There’s still so much more to say Swift’s concurrency model, but we’re glad that the new `.refreshable` API gave us an excuse to dive in some of the more advanced topics, such as tasks, cancellation and testing.

@T(00:32:29)
Now let’s see what all of this looks like in the Composable Architecture. We’re going to rebuild this feature using our library, and we’ll see that we can still leverage the `.refreshable` view modifier even though the Composable Architecture has no direct support for `async`/`await`. Even better, we can support this `.refreshable` API without making any changes whatsoever to the core library. This means you wouldn’t even have to wait for us to release a new version of the library to test out this functionality. You could have implemented it yourself.

@T(00:32:59)
So, let’s begin. In the Composable Architecture we often like to begin with a little bit of a domain modeling exercise. It’s certainly not the only way to start a feature. Alternatively we could build out the view and then let that guide us to do the domain modeling.
