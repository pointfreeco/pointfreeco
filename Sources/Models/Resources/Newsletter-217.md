> Preamble: This week we are running a Point-Free blog bonanza to highlight new things happening
> across our ecosystem.
> * [DebugSnapshots now logs SwiftUI bindings](/blog/posts/214-debugsnapshots-now-logs-swiftui-bindings)
> * [New macros for SwiftNavigation](/blog/posts/215-new-macros-for-swiftnavigation)
> * [“Trait-ifying” our libraries to reduce transitive dependencies](/blog/posts/216-trait-ifying-our-libraries-to-reduce-transitive-dependencies)
> * [**Proposing task-local test traits for Swift Testing**](/blog/posts/217-proposing-task-local-test-traits-for-swift-testing)
>
> Coming soon:
> * Shipping Xcode 27 support

Earlier this month we released a small but useful tool in [ConcurrencyExtras]:
a Swift Testing trait for overriding task locals in tests and suites. We wrote about it in
[here][task-local-post], and we have been very happy with how it reduces boilerplate.

And now we are proposing bringing this tool into Swift Testing via an [evolution pitch].

## The proposal

The proposal introduces a `.taskLocal` test trait for Swift Testing that allows binding a value
to any task local for the duration of a test or suite. Consider a feature flag task local like so:

```swift
enum FeatureFlags {
  @TaskLocal static var isEnabled = false
}
```

In order to bind a value to this task local for a test or suite, you would need to define a type
to conform to `TestTrati`, `SuiteTrait`, and `TestScoping`, along with a convenience static helper:

```swift
struct _IsEnabledTrait: SuiteTrait, TestScoping, TestTrait {
  let isEnabled: Bool
  let isRecursive = true
  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: () async throws -> Void
  ) async throws {
    try await FeatureFlags.$isEnabled.withValue(isEnabled) {
      try await function()
    }
  }
}

extension Trait where Self == _IsEnabledTrait {
  static func isEnabled(_ isEnabled: Bool) -> Self {
    Self(isEnabled: isEnabled)
  }
}
```

Once that is done you get to bind the task local in a test like so:

```swift
@Test(.isEnabled(true)) 
func basics() {
  // Feature flag is enabled in here
  #expect(FeatureFlags.isEnabled)
}
```

This boilerplate must be written for _every_ task local in your library or app that you want to be
bindable in tests.

Well, if our proposal is accepted, the custom conformance and static helper can be deleted, and
a `.taskLocal` trait will always be available: 

```swift
@Test(.taskLocal(FeatureFlags.$isEnabled, true))
func basics() {
  // Assert feature logic with flag enabled
}
```

It's a small convenience, but does save everyone from defining custom traits for each task local
they define, and can save you from needing to define a dedicated "test support" library for your
package since test traits cannot be defined alongside app code.

If you have any questions or comments, please be sure to participate in the 
[pitch][evolution pitch]!

[ConcurrencyExtras]: https://github.com/pointfreeco/swift-concurrency-extras
[task-local-post]: /blog/posts/209-tasklocal-test-traits
[task-local-proposal]: https://github.com/swiftlang/swift-evolution/pull/3329
[test-scoping-post]: /blog/posts/169-new-in-swift-6-1-test-scoping-traits
[evolution pitch]: https://forums.swift.org/t/pitch-add-a-tasklocal-trait-to-swift-testing/87603
