import Foundation

extension Episode {
  static let ep84_testableStateManagement_ergonomics = Episode(
    blurb: """
We not only want our architecture to be testable, but we want it to be super easy to write tests, and perhaps even a joy to write tests! Right now there is a bit of ceremony involved in writing tests, so we will show how to hide away those details behind a nice, ergonomic API.
""",
    codeSampleDirectory: "0084-testable-state-management-ergonomics",
    exercises: _exercises,
    id: 84,
    image: "https://i.vimeocdn.com/video/837834964.jpg",
    length: 42*60 + 35,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 83,
    publishedAt: Date(timeIntervalSince1970: 1575871200),
    references: [
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
      // todo
    ],
    sequence: 84,
    title: "Testable State Management: Ergonomics",
    trailerVideo: .init(
      bytesLength: 39298144,
      downloadUrl: "https://player.vimeo.com/external/378096709.hd.mp4?s=bd1f389fcc025df919d5b35550c1a1fa23673581&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/378096709"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Extract the `assert` helper to a `ComposableArchitectureTestSupport` module that can be imported in all of the test modules.
"""#,
    solution: #"""
1. Create a new iOS framework.
2. Move the test support file into the module's group (and double check that the file is included in the test support framework target.
3. If you try to build the test support module, it will fail when it tries to link to XCTest. It's not well-documented, but with some internet sleuthing you may come across a solution, which is to add `-weak-lswiftXCTest` as a linker flag to the test module's build settings.
4. Add `ComposableArchitectureTestSupport` as a dependency to all of the test modules that need it.

You may also need to add the following framework search paths:

```
$(DEVELOPER_FRAMEWORKS_DIR) $(PLATFORM_DIR)/Developer/Library/Frameworks
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the prime modal tests to use the `assert` helper.
"""#,
    solution: #"""
`PrimeModalState` is a tuple, and incompatible with the `assert` helper because tuples are non-nominal types that cannot conform to protocols, like `Equatable`. While we could write an overload of `assert` that supports tuples of state, let's instead take the opportunity to upgrade the module's root state value to a proper struct that conforms to `Equatable`. This requires a little boilerplate of a public initializer.

```swift
public struct PrimeModalState: Equatable {
  public var count: Int
  public var favoritePrimes: [Int]

  public init(
    count: Int,
    favoritePrimes: [Int]
  ) {
    self.count = count
    self.favoritePrimes = favoritePrimes
  }
}
```

This is enough to write some tests, but let's make sure the app still builds by fixing the counter module.

First, we must update `CounterViewState`'s `primeModal` property to work with a struct instead of a tuple.

```swift
var primeModal: PrimeModalState {
  get { PrimeModalState(count: self.count, favoritePrimes: self.favoritePrimes) }
  set { (self.count, self.favoritePrimes) = (newValue.count, newValue.favoritePrimes) }
}
```

Second, we should delegate to this property when projecting into this state for the view.

```swift
IsPrimeModalView(
  store: self.store
    .view(
      value: { $0.primeModal },
      action: { .primeModal($0) }
  )
)
```

We're finally ready to upgrade our tests! We can even combine them into a single test that exercises saving and removing at once.

```swift
func testSaveAndRemoveFavoritesPrimesTapped() {
  assert(
    initialValue: PrimeModalState(count: 2, favoritePrimes: [3, 5]),
    reducer: primeModalReducer,
    steps:
    Step(.send, .saveFavoritePrimeTapped) {
      $0.favoritePrimes = [3, 5, 2]
    },
    Step(.send, .removeFavoritePrimeTapped) {
      $0.favoritePrimes = [3, 5]
    }
  )
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Let's start updating the favorite primes tests to use the `assert` helper. In this exercise, update `testDeleteFavoritePrimes`.
"""#,
    solution: #"""
```swift
func testDeleteFavoritePrimes() {
  assert(
    initialValue: [2, 3, 5, 7],
    reducer: favoritePrimesReducer,
    steps: Step(.send, .deleteFavoritePrimes([2])) {
      $0 = [2, 3, 7]
    }
  )
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update `testLoadFavoritePrimesFlow` to use the `assert` helper.
"""#,
    solution: #"""
```swift
func testLoadFavoritePrimesFlow() {
  Current.fileClient.load = { _ in .sync { try! JSONEncoder().encode([2, 31]) } }

  assert(
    initialValue: [2, 3, 5, 7],
    reducer: favoritePrimesReducer,
    steps:
    Step(.send, .loadButtonTapped) { _ in },
    Step(.receive, .loadedFavoritePrimes([2, 31])) {
      $0 = [2, 31]
    }
  )
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Try to update `testSaveButtonTapped` to use the `assert` helper. What goes wrong?
"""#,
    solution: #"""
We might try to update this test with the following:

```swift
func testSaveButtonTapped() {
  var didSave = false
  Current.fileClient.save = { _, data in
    .fireAndForget {
      didSave = true
    }
  }

  assert(
    initialValue: [2, 3, 5, 7],
    reducer: favoritePrimesReducer,
    steps:
    Step(.send(.saveButtonTapped) { _ in })
  )
  XCTAssert(didSave)
}
```

But when we run it, it fails:

> ❌ failed - Assertion failed to handle 1 pending effect(s)
> ❌ XCTAssertTrue failed

The `assert` helper only runs effects when it expects to receive an event from one, which means it's not equipped to handle fire-and-forget logic.
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the `assert` helper to support testing fire-and-forget effects (like the one on `testSaveButtonTapped`). This will involve changing the way `StepType` and `Step` look so that they can describe the idea of fire-and-forget effects that can be handled in `assert`.
"""#,
    solution: #"""
There are a few ways to account for fire-and-forget effects with our test helper. One thing we could do is upgrade `StepType` with the idea of a step that accounts for a `fireAndForget` effect.

```swift
enum StepType {
  case send
  case receive
  case fireAndForget
}
```

This makes `Step` a bit more complicated: it has a non-optional action and update function, but neither of these are relevant to fire-and-forget effects because they cannot feed actions back to the system and mutate state.

We could make the action optional and get things building, but that would allow us to describe some truly nonsensical steps, including:

- A `send` step with a `nil` action
- A `receive` step with a `nil` action
- A `fireAndForget` step with an action or a mutation (or both!)

Let's use some of the lessons of [Algebraic Data Types](/episodes/ep4-algebraic-data-types) to refactor `Step` and `StepType` to eliminate these impossible states.

Both `send` and `receive` care about the associated data of the action and mutation, while `fireAndForget` does not. We can push this data deeper into `StepType` as associated values, and we can nest `StepType` inside of `Step` so that it gets access to the `Value` and `Action` generics.

``` swift
struct Step<Value, Action> {
  enum StepType {
    case send(Action, (inout Value) -> Void)
    case receive(Action, (inout Value) -> Void)
    case fireAndForget
  }

  let type: StepType
  let file: StaticString
  let line: UInt

  init(
    _ type: StepType,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    self.type = type
    self.file = file
    self.line = line
  }
}
```

Now, we must update `assert` to extract these values and exhaustively switch on fire-and-forget effects.

```swift
func assert<Value: Equatable, Action: Equatable>(
  initialValue: Value,
  reducer: Reducer<Value, Action>,
  steps: Step<Value, Action>...,
  file: StaticString = #file,
  line: UInt = #line
) {
  var state = initialValue
  var effects: [Effect<Action>] = []

  steps.forEach { step in
    var expected = state

    switch step.type {
    case let .send(action, update):
      if !effects.isEmpty {
        XCTFail("Action sent before handling \(effects.count) pending effect(s)", file: step.file, line: step.line)
      }
      effects.append(contentsOf: reducer(&state, action))
      update(&expected)
      XCTAssertEqual(state, expected, file: step.file, line: step.line)
    case let .receive(expectedAction, update):
      guard !effects.isEmpty else {
        XCTFail("No pending effects to receive from", file: step.file, line: step.line)
        break
      }
      let effect = effects.removeFirst()
      var action: Action!
      let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
      _ = effect.sink(
        receiveCompletion: { _ in
          receivedCompletion.fulfill()
      },
        receiveValue: { action = $0 }
      )
      if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
        XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
      }
      XCTAssertEqual(action, expectedAction, file: step.file, line: step.line)
      effects.append(contentsOf: reducer(&state, action))
      update(&expected)
      XCTAssertEqual(state, expected, file: step.file, line: step.line)
    case .fireAndForget:
      guard !effects.isEmpty else {
        XCTFail("No pending effects to run", file: step.file, line: step.line)
        break
      }
      let effect = effects.removeFirst()
      let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
      _ = effect.sink(
        receiveCompletion: { _ in
          receivedCompletion.fulfill()
      },
        receiveValue: { _ in XCTFail() }
      )
      if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
        XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
      }
    }
  }
  if !effects.isEmpty {
    XCTFail("Assertion failed to handle \(effects.count) pending effect(s)", file: file, line: line)
  }
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Using the updated `assert` helper from the previous exercise, rewrite `testSaveButtonTapped`.
"""#,
    solution: #"""
```swift
func testSaveButtonTapped() {
  var didSave = false
  Current.fileClient.save = { _, data in
    .fireAndForget {
      didSave = true
    }
  }

  assert(
    initialValue: [2, 3, 5, 7],
    reducer: favoritePrimesReducer,
    steps:
    Step(.send(.saveButtonTapped) { _ in }),
    Step(.fireAndForget)
  )
  XCTAssert(didSave)
}
```
"""#
  ),
]
