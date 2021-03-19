import Foundation

public let post0056_BetterTestingBonanza = BlogPost(
  author: .pointfree, // todo
  blurb: """
We're open sourcing a library that makes it easier to be more exhaustive in writing tests.
""",
  contentBlocks: [
  .init(
    content: """
This week on Point-Free we showed how write tests that exhaustively describe which dependencies are necessary to exercise a feature, and we did so in an ergnomic way. If a dependency is unexpectedly used in a test case then it fails the test suite and even points to the exact step of the assertion that caused the dependency to be invoked. This makes it possible to be instantly notified when a part of your feature starts accessing dependencies that you don't expect, and it was awesome to see.

However, the ability to leverage this awesome capability hinges on being able to creating "failing" versions of dependencies, that is, instances of the dependency that simply invoke `XCTFail` under the hood rather than doing their actual work. And unfortunately, the moment you import `XCTest` into a non-test target your application will fail to build with inscrutable errors. This lead us to develop a library that dynamically loads `XCTFail` so that it can be used in any context, not just test targets.

So, without further ado, we are open sourcing [`XCTDynamicOverlay`](https://github.com/pointfreeco/xctest-dynamic-overlay) today, along with updates to both the Composable Architecture and Combine Schedulers to take advantage of this new library.

## `XCTestDynamicOverlay`

It is very common to write test support code for libraries and applications. This often comes in the form of little domain-specific functions or helpers that make it easier for users of your code to formulate assertions on behavior.

Currently there are only two options for writing test support code:

* Put it in a test target, but then you can't access it from multiple other test targets. For whatever reason test targets cannot be imported, and so the test support code will only be available in that one single test target.
* Create a dedicated test support module that ships just the test-specific code. Then you can import this module into as many test targets as you want, while never letting the module interact with your regular, production code.

Neither of these options is ideal. In the first case you cannot share your test support, and the second case will lead you to a proliferation of modules. For each feature you potentially need 3 modules: `MyFeature`, `MyFeatureTests` and `MyFeatureTestSupport`. SPM makes managing this quite easy, but it's still a burden.

It would be far better if we could ship the test support code right along side or actual library or application code. Afterall, they are intimately related. You can even fence off the test support code in `#if DEBUG ... #endif` if you are worried about leaking test code into production.

However, as soon as you add `import XCTest` to a source file in your application or a library it loads, the target becomes unbuildable:

```swift
import XCTest
```

> 🛑 ld: warning: Could not find or use auto-linked library 'XCTestSwiftSupport'
> 🛑 ld: warning: Could not find or use auto-linked framework 'XCTest'

This is due to a confluence of problems, including test header search paths, linker issues, and more. XCTest just doesn't seem to be built to be loaded alongside your application or library code.

### Solution

That doesn't mean we can't try! XCTest Dynamic Overlay is a microlibrary that exposes an `XCTFail` function that can be invoked from anywhere. It dynamically loads XCTest functionality at runtime, which means your code will continue to compile just fine.

```swift
import XCTestDynamicOverlay // ✅
```

### Example

A real world example of using this is in our library, the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). That library vends a `TestStore` type whose purpose is to make it easy to write tests for your application's logic. The `TestStore` uses `XCTFail` internally, and so that forces us to move the code to a dedicated test support module. However, due to how SPM works you cannot currently have that module in the same package as the main module, and so we would be forced to extract it to a separate _repo_. By loading `XCTFail` dynamically we can keep the code where it belongs.

As another example, let's say you have an analytics dependency that is used all over your application:

```swift
struct AnalyticsClient {
  var track: (Event) -> Void

  struct Event: Equatable {
    var name: String
    var properties: [String: String]
  }
}
```

If you are disciplined about injecting dependencies, you probably have a lot of objects that take an analytics client as an argument (or maybe some other fancy form of DI):

```swift
class LoginViewModel: ObservableObject {
  ...

  init(analytics: AnalyticsClient) {
    ...
  }

  ...
}
```

When testing this view model you will need to provide an analytics client. Typically this means you will construct some kind of "test" analytics client that buffers events into an array, rather than sending live events to a server, so that you can assert on what events were tracked during a test:

```swift
func testLogin() {
  var events: [AnalyticsClient.Event] = []
  let viewModel = LoginViewModel(
    analytics: .test { events.append($0) }
  )

  ...

  XCTAssertEqual(events, [.init(name: "Login Success")])
}
```

This works really well, and it's a great way to get test coverage on something that is notoriously difficult to test.

However, some tests may not use analytics at all. It would make the test suite stronger if the tests that don't use the client could prove that it's never used. This would mean when new events are tracked you could be instantly notified of which test cases need to be updated.

One way to do this is to create an instance of the `AnalyticsClient` type that simply performs an `XCTFail` inside the `track` endpoint:

```swift
import XCTest

extension AnalyticsClient {
  static let failing = Self(
    track: { _ in XCTFail("AnalyticsClient.track is unimplemented.") }
  )
}
```

With this you can write a test that proves analytics are never tracked, and even better you don't have to worry about buffering events into an array anymore:

```swift
func testValidation() {
  let viewModel = LoginViewModel(
    analytics: .failing
  )

  ...
}
```

However, you cannot ship this code with the target that defines `AnalyticsClient`. You either need to extract it out to a test support module (which means `AnalyticsClient` must also be extracted), or the code must be confined to a test target and thus not shareable.

However, with `XCTestDynamicOverlay` we can have our cake and eat it too 😋. We can define both the client type and the failing instance right next to each in application code without needing to extract out needless modules or targets:

```swift
struct AnalyticsClient {
  var track: (Event) -> Void

  struct Event: Equatable {
    var name: String
    var properties: [String: String]
  }
}

import XCTestDynamicOverlay

extension AnalyticsClient {
  static let failing = Self(
    track: { _ in XCTFail("AnalyticsClient.track is unimplemented.") }
  )
}
```

## Composable Architecture 0.17.0

Currently the Composable Architecture dynamically loads [`XCTFail`](https://github.com/pointfreeco/swift-composable-architecture/blob/f967d1a9fb9bafef685fddd54fd686514b058780/Sources/ComposableArchitecture/TestSupport/TestStore.swift#L625-L643) so that it can provide the functionality of the `TestStore`, which is a test helper that allows you to assert how state changes when actions are sent. We can now remove this ad hoc code and replace it with the more robust `XCTestDynamicOverlay` library.

In addition to this there are two new improvements to some core library types:

### `Effect.failing`

The `Effect` type now vends a `.failing` static constructor. It's an effect that will immediately invoke `XCTFail` when it is subscribed to. This is perfect for stubbing in dependency endpoints that should not be invoked during tests, giving you better guarantees about which dependencies are used and which are not.

### `TestStore`

The `TestStore` has a new way of making assertions. Currently one makes assertions by calling the `.assert` method on `TestStore` and feeding it a sequence of steps that simulataneously describe a user action _and_ how the state should have changed after that action:

```swift
store.assert(
  .send(.incrementButtonTapped) {
    $0.count = 1
  },
  .send(.numberFactButtonTapped) {
    $0.isNumberFactRequestInFlight = true
  },
  .do { self.scheduler.advance() },
  .receive(.numberFactResponse(.success("1 is a good number Brent"))) {
    $0.isNumberFactRequestInFlight = false
    $0.numberFact = "1 is a good number Brent"
  }
)
```

Thanks to some recent infrastructure work we have done on the `TestStore` we can now flatten this code by getting rid of the surrounding `store.assert(...)` and calling `.send` and `.receive` directly on the store:

```swift
store.send(.incrementButtonTapped) {
  $0.count = 1
}

store.send(.numberFactButtonTapped) {
  $0.isNumberFactRequestInFlight = true
}

self.scheduler.advance()

store.receive(.numberFactResponse(.success("1 is a good number Brent"))) {
  $0.isNumberFactRequestInFlight = false
  $0.numberFact = "1 is a good number Brent"
}
```

All the same guarantees are made, such as exhaustive checking of effect lifetimes, but now with less nesting and in fewer lines of code. Further, flattening the code in this way allows Xcode 12 to better track test failures to the `.send` line that caused the failure.

This change is 100% backwards compatible with the current `.assert(...)` method, so no need to immediately switch over, but we think there are a lot of benefits to doing so.

## Combine Schedulers 0.4.0

And finally (😅) we are leveraging our new `XCTestDynamicOverlay` library in [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) to provide a `FailingScheduler` type, which is a scheduler that immediately invokes `XCTFail` whenever it is asked to schedule work. This is great for testing code that requires a scheduler to be provided but for which you do not expect any asychrony to actually take place. Just stick in a `.failing` instance for your scheduler and you can be sure there is no shenanigans happening internally:

```swift
func testCountUpAndDown() {
  let store = TestStore(
    initialState: EffectsBasicsState(),
    reducer: effectsBasicsReducer,
    environment: EffectsBasicsEnvironment(
      mainQueue: .failing()
      numberFact: { _ in .failing() }
    )
  )

  store.assert(
    .send(.incrementButtonTapped) {
      $0.count = 1
    },
    .send(.decrementButtonTapped) {
      $0.count = 0
    }
  )
}
```

If this test passes it means definitively that there was no asynchrony involved and the `numberFact` effect was not executed. This greatly strengthens what this test is capturing with very little additional work.

## Try it out today!

Be sure to check out [`XCTestDynamicOverlay`](https://github.com/pointfreeco/xctest-dynamic-overlay) today, and update your dependencies on Composable Architecture and/or Combine Schedulers. We think these tools will greatly strengthen your tests and their ergonomics.
""",
    type: .paragraph
  )
  ],
  coverImage: nil,
  id: 56,
  publishedAt: .init(timeIntervalSince1970: 1616389200),
  title: "Better Testing Bonanza"
)
