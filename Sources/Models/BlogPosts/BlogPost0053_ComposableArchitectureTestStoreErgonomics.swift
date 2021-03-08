import Foundation

public let post0053_composableArchitectureTestStoreErgonomics = BlogPost(
  author: .pointfree,
  blurb: """
Composable Architecture 0.16.0 comes with significant improvements to its testing capabilities for tracking down effect-related failures.
""",
  contentBlocks: [
    .init(
      content: #"""
Today we've shipped a [brand new version](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.16.0) of [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) with improvements to its test helpers.

One of the primary focuses of the Composable Architecture is testability, which is why it ships with a tool that makes it easy (and dare we say fun?) to write comprehensive tests for applications written in the Composable Architecture.

The primary means for testing in the Composable Architecture is via the `TestStore` class. You can create a test store for your feature and write a test via the `assert` method, which is fed a step-by-step list of user actions to be sent to the store, and expected mutations to state and effects received back into the system!

These tests provide very strong guarantees for how data and even side effects flow through your application, and even determine if you have exhaustively tested any side effects a feature may have kicked off. This means a test will fail if you've kicked off an effect that hasn't completed!

For example, in the [Todos demo application](https://github.com/pointfreeco/swift-composable-architecture/blob/main/Examples/Todos/README.md) that ships with the Composable Architecture, we have the following test, that asserts that when we check off a todo item, not only does its state mutate to be in a completed state, but a second later we receive an effect back into the system that sorts the completed todo to the bottom of the list!

```swift
let store = TestStore(
  initialState: state,
  reducer: appReducer,
  environment: AppEnvironment(
    mainQueue: self.scheduler.eraseToAnyScheduler(),
    uuid: UUID.incrementing
  )
)

store.assert(
  .send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
    $0.todos[0].isComplete = true
  },
  .do { self.scheduler.advance(by: 1) },
  .receive(.sortCompletedTodos) {
    $0.todos = [
      $0.todos[1],
      $0.todos[0],
    ]
  }
)
```

This is a short test and it's packing a punch! If we forgot about the sorting effect, we might have simply written an assertion against the initial mutation:

```swift
store.assert(
  .send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
    $0.todos[0].isComplete = true
  }
)
```

But this test will fail with an error!

> 🛑 Some effects are still running. All effects must complete by the end of the assertion.

These failures can be extremely helpful in tracking down bugs in complex effects and ensure that we remember to test the entire lifecycle of a feature.

Up until today, however, this error has rendered at the beginning of the assertion:
"""#,
      type: .paragraph
    ),
    .init(
      content: "Before:",
      timestamp: nil,
      type: .image(src: "https://user-images.githubusercontent.com/658/110347127-4de1da80-7ffe-11eb-846e-5bd9e4c16beb.png")
    ),
    .init(
      content: #"""
Every unfinished effect would aggregate here. As helpful as this information was, it did not always make it clear where the effects came from and how exactly to track them back to their origin.

Today we are excited to release an improved test store that addresses this problem. It will now render any effect failures in line with the originating action:
"""#,
      type: .paragraph
    ),
    .init(
      content: "After:",
      timestamp: nil,
      type: .image(src: "https://user-images.githubusercontent.com/658/110347138-51756180-7ffe-11eb-9dbd-b6f8915a475f.png")
    ),
    .init(
      content: #"""

🥳 Much better! This gives us much more fine-grained information at a glance and it is _very_ clear which action triggered a long-living effect.

We hope this improvement will make it easier to track down test failures so that you can spend more time on the things that matter.

## Track down your test failures more quickly, today!

You can grab [version 0.16.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.16.0) of the Composable Architecture today and take advantage of these debugging improvements immediately. [Let us know](https://twitter.com/pointfreeco) what you think!
"""#,
      type: .paragraph
    ),
  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0053-tca-ergonomics/poster.png",
  id: 53,
  publishedAt: Date(timeIntervalSince1970: 1615219200),
  title: "Composable Architecture Test Store Improvements"
)
