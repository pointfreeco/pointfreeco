We have added a small but useful new tool to [Concurrency Extras]: a Swift Testing trait that
overrides any task local value for the duration of a test or suite. It not only reduces boilerplate
for overriding task locals in tests, but it also works around a thorny build system bug in Xcode.

[Concurrency Extras]: https://github.com/pointfreeco/swift-concurrency-extras

## The problem

Task locals are a great tool for modeling global configuration in a concurrency-safe way. They 
are globally accessible, but they can only be changed for a well-defined, lexical scope:

```swift
enum FeatureFlags {
  @TaskLocal static var isEnabled = false
}

FeatureFlags.isEnabled  // false
FeatureFlags.$isEnabled.withValue(true) {
  FeatureFlags.isEnabled  // true
}
FeatureFlags.isEnabled  // false
```

This makes test locals safe to use in parallel tests that run in-process, such as in Swift Testing,
but it can create quite a bit of boilerplate to override a task local for a test case. You have
to wrap your entire test function in `$local.withValue`:

```swift
@Test func basics() async throws {
  try await FeatureFlags.$isEnabled.withValue(true) {
    // Assert feature logic with flag enabled
  }
}
```

And it gets worse if you need to override multiple task locals:

```swift
@Test func basics() async throws {
  try await FeatureFlags.$isEnabled.withValue(true) {
    try await User.$current.withValue(User(name: "Blob")) {
      // Assert feature logic with flag enabled and current user
    }
  }
}
```

And if every test in a suite needs the same override you have to literally repeat this code for each
test function. Or, you can define a whole new scoping `SuiteTrait` that allows you to override the
task local for each test in the suite:

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

With that bit of boilerplate out of the way you now get to override the feature flag for an entire
suite:

```swift
@Suite(.isEnabled(true)) 
struct MySuite {
  // All tests run in here will have feature flag enabled
}
```

It gets the job done, but it's also 20 lines of boilerplate that is going to be a pain to maintain,
especially if you have many task locals that you want to be able to control in tests.

## The new trait

Concurrency Extras now ships a `ConcurrencyExtrasTestSupport` product with a generic `.taskLocal`
trait:

```swift
import ConcurrencyExtrasTestSupport
import Testing

@Test(.taskLocal(FeatureFlags.$isEnabled, true))
func basics() {
  #expect(FeatureFlags.isEnabled)
}
```

The same trait can be applied to an entire suite:

```swift
import ConcurrencyExtrasTestSupport

@Suite(.taskLocal(FeatureFlags.$isEnabled, true))
struct FeatureTests {
  @Test func basics() {
    #expect(FeatureFlags.isEnabled)
  }
}
```

The trait is recursive, so applying it to a suite scopes the value to all of the suite's tests and
nested suites. It also flattens the nesting when you need to override multiple task locals:

```swift
import ConcurrencyExtrasTestSupport

@Suite(
  .taskLocal(FeatureFlags.$isEnabled, true),
  .taskLocal(User.$current, .mock)
)
struct FeatureTests {
  ...
}
```

That is all it takes. No need to recreate 20 lines of boilerplate for each individual task local,
and no need to indent your test code inside `withValue` for each task local you override.

## A better test-support story

While reducing boilerplate is great, it's not actually the reason we added this feature. The real
reason is that it is not currently possible to ship test support libraries in a way that plays 
nicely with Xcode's build system.

Suppose you have a library, Widget, which contains a task local `$style` that alters the behavior
of the library. You want users of the library to be able to write tests with this `$style` 
task local overriden to any value, and so you would like to provide a `.style(…)` test trait
so that they can easily override it on `@Test` and `@Suite`.

The question is: where should this trait be defined? It cannot be defined in the Widget library
because you cannot import Testing into non-testing targets. So, instead you create a 
WidgetTestSupport library that depends on Widget and defines the trait. This library is only meant
to be linked to test targets, and so it is fine to import the Testing framework.

Unfortunately, such a WidgetTestSupport library is not actually usable in Xcode, generally speaking.
If Widget depends on some other library, say [Swift Collections], and if the target you are testing
also depends on Swift Collections, then Xcode cannot build the test target. It's not clear what the
root issue is, or whether Apple considers it a bug, but it's the reality. It's worth noting that 
this issue is _not_ present in Swift Package Manager.  

[Swift Collections]: https://github.com/apple/swift-collections

This problem is fixed using our newly released tool. There is no need for you to create a 
WidgetTestSupport just to provide a way to override a task local. Instead, your users can depend
only on ConcurrencyExtrasTestSupport to get a general purpose tool for overriding any task local:

```swift
import ConcurrencyExtrasTestSupport
import Testing 

@Suite(.taskLocal(Widget.$style, .dark))
struct MySuite {
 …
}
```

## Get started

Add the `ConcurrencyExtrasTestSupport` product to your test target:

```swift
.testTarget(
  name: "FeatureTests",
  dependencies: [
    "Feature",
    .product(
      name: "ConcurrencyExtrasTestSupport",
      package: "swift-concurrency-extras"
    ),
  ]
)
```

Then import `ConcurrencyExtrasTestSupport` from any test file that wants to scope a task local with
Swift Testing:

```swift
import ConcurrencyExtrasTestSupport
import Testing

@Test(.taskLocal(FeatureFlags.$isEnabled, true))
func basics() {
  …
}
```

It is a tiny API, but it removes a surprising amount of ceremony from tests that use task locals,
and it gives library authors a simple way to support Swift Testing without fighting Xcode's current
build system limitations.
