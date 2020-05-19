import Foundation

extension Episode {
  static let ep83_testableStateManagement_effects = Episode(
    blurb: """
Side effects are by far the hardest thing to test in an application. They speak to the outside world and they tend to be sprinkled around to get the job done. However, we can get broad test coverage of our reducer's effects with very little work, and it will all be thanks to a simple technique we covered in the past.
""",
    codeSampleDirectory: "0083-testable-state-management-effects",
    exercises: _exercises,
    id: 83,
    image: "https://i.vimeocdn.com/video/831975769.jpg",
    length: 50*60 + 15,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1575266400),
    references: [
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: """
We first introduced the `Environment` concept for controlling dependencies in this episode.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      reference(
        forEpisode: .ep18_dependencyInjectionMadeComfortable,
        additionalBlurb: """
Our second episode on the `Environment` introduces some patterns around building test data and builds intuitions around identifying the side effects that sneak into our applications.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep18-dependency-injection-made-comfortable"
      ),
      .howToControlTheWorld,
      .structureAndInterpretationOfSwiftPrograms,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 83,
    subtitle: "Effects",
    title: "Testable State Management",
    trailerVideo: .init(
      bytesLength: 59383233,
      downloadUrl: "https://player.vimeo.com/external/373753492.hd.mp4?s=29f6a1816d8a8f35f7c2d70a1cacc5d8423ef9c8&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/373753492"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
In the episode, we asserted against `testSaveButtonTapped`'s save effect by [introducing a `didSave` boolean variable](#t1545), which initializes `false` and toggles to `true` in the environment-controlled effect.

While this tests that the effect executes, it does _not_ test that the proper data was fed into the effect in the first place. In fact, it ignores this argument entirely!

Strengthen this test so that it asserts that the correct data was sent to the effect. This will give us test coverage on the JSON encoding logic that is currently in the reducer.
"""#,
    solution: #"""
```swift
func testSaveButtonTapped() {
  Current = .mock
  var encodedPrimes: Data?
  Current.fileClient.save = { _, data in
    .fireAndForget {
      encodedPrimes = data
    }
  }

  var state = [2, 3, 5, 7]
  let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)

  XCTAssertEqual(state, [2, 3, 5, 7])
  XCTAssertEqual(effects.count, 1)

  effects[0].sink { _ in XCTFail() }

  XCTAssertEqual(encodedPrimes, try JSONEncoder().encode([2, 3, 5, 7]))
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Our `testLoadButtonTapped` passed even [when we fed multiple actions](#t2198) back from a single effect.

Strengthen this test to ensure that only a single action is ever fed back into the reducer.
"""#,
    solution: #"""
There are many ways of asserting that only a single value is received, including introducing a mutable tally of how many times `receivedValue` was called. A simple solution, though, is to introduce a `receivedValue` expectation and fulfill it in the `receivedValue` block:

```swift
func testLoadFavoritePrimesFlow() {
  Current.fileClient.load = { _ in .sync { try! JSONEncoder().encode([2, 31]) } }

  var state = [2, 3, 5, 7]
  var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

  XCTAssertEqual(state, [2, 3, 5, 7])
  XCTAssertEqual(effects.count, 1)

  var nextAction: FavoritePrimesAction!
  let receivedCompletion = self.expectation(description: "receivedCompletion")
  let receivedValue = self.expectation(description: "receivedValue")
  effects[0].sink(
    receiveCompletion: { _ in
      receivedCompletion.fulfill()
  },
    receiveValue: { action in
      receivedValue.fulfill()
      XCTAssertEqual(action, .loadedFavoritePrimes([2, 31]))
      nextAction = action
  })
  self.wait(for: [receivedValue, receivedCompletion], timeout: 0)

  effects = favoritePrimesReducer(state: &state, action: nextAction)

  XCTAssertEqual(state, [2, 31])
  XCTAssert(effects.isEmpty)
}
```

If `receivedValue` is fulfilled more than once, it will cause the test to fail.
"""#
  ),
  Episode.Exercise(
    problem: #"""
Create an alternative instance of `FileClient` that saves its data to `UserDefaults` instead of the file system.
"""#,
    solution: #"""
```swift
extension FileClient {
  static let userDefaults = FileClient(
    load: { fileName -> Effect<Data?> in
      .sync {
        UserDefaults.standard.data(forKey: "FileClient:\(fileName)")
      }
  },
    save: { fileName, data in
      return .fireAndForget {
        UserDefaults.standard.set(data, forKey: "FileClient:\(fileName)")
      }
  })
}
```
"""#),
  Episode.Exercise(
    problem: #"""
One problem with using an environment struct in each module is that it does not play nicely with sharing dependencies across module boundaries. For example, suppose another module needed a `FileClient`. You would have no choice but to have two `FileClients` alive in your application, one for each module, which means you would need to remember to mock _both_ when you want to write tests.

One way to fix this is to bake the notion of "ennvironment" directly into the reducer signature. Try this out by updating `Reducer` to be the following shape:

```swift
typealias Reducer<Value, Action, Environment> =
  (inout Value, Action, Environment) -> [Effect<Action>]
```

This gives you access to the environment in a reducer, which means you can use it to construct effects to be returned. However, this will cause a lot of compiler errors, and to get everything in working order here are some things to work through:

* The `pullback` operation needs to be updated to work with this new reducer signature. Is it necessary to pullback along key paths like was done for state and actions, or will a plain function suffice?
* The `Store` class needs to be updated since it holds onto a reducer and that has signature has changed. One way to fix this would be to introduce an `Environment` generic. However, the environment isn't actually use in its public API, which means maybe we can hide this detail from the type using type erasure.
* Update modules that use an environment to include their environment directly in the reducer and remove the `Current` globals.
"""#,
    solution: #"""
This will be a future Point-Free episode 😂.
"""#),
]
