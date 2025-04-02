Swift 6.1 and Xcode 16.3 are officially here, and with them come a few new features improving type inference and concurrency tools. However, there is one change that hasn’t gotten too much attention, and to us it’s one of the most important ones: [test scoping traits](https://github.com/swiftlang/swift-evolution/blob/main/proposals/testing/0007-test-scoping-traits.md)!

This feature has allowed us to vastly improve three of our libraries, [Dependencies](http://github.com/pointfreeco/swift-dependencies), [SnapshotTesting](http://github.com/pointfreeco/swift-snapshot-testing), and [MacroTesting](http://github.com/pointfreeco/swift-macro-testing), all of which provide powerful testing tools. Join us for a quick overview of this new tool in Swift 6.1, as well as an explanation of why it has been so helpful for our libraries.

# What are scoping traits?

When writing tests one often needs to perform a little bit of work before and after the test runs. In XCTest, the proprietary predecessor to Swift Testing, one can do this in the `setUp` and `tearDown` methods on `XCTestCase`:

```swift
import XCTest

class FeatureTests: XCTestCase {
  override func setUp() {
    super.setUp()
    print("Before test is run...")
  }
  override func tearDown() {
    super.tearDown()
    print("After test is run...")
  }
  …
}
```

This allows you to set up resources for your tests, such as create and migrate an in-memory SQLite database, a single time rather than for each test.

Swift’s new Testing framework supports this too, and has from the beginning. Set-up can be done in the `init` of your suite, and tear-down can be performed in the `deinit` suite, as long as you are using a `~Copyable` type or class:

```swift
import Testing

@Suite struct FeatureTests: ~Copyable {
  init() {
    print("After test is run...")
  }
  deinit {
    print("After test is run...")
  }
  …
}
```

However, these kinds of set-ups and tear-downs have limitations. They are what you might call “unstructured” testing tools in that they do not play nicely with the structured programming paradigm that we all known and love.

For example, Swift provides a tool that allows us to model global state in a concurrency safe *and* structured programming safe manner, called [task locals](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0311-task-locals.md). Such a value can be declared like so:

```swift
@TaskLocal var count = 0
```

This is a globally accessible value, but it is read-only, despite the `var` designation. The only way to change the value of a task local is using the `withValue` method, which allows you to change the value for only the duration of a single lexical scope:

```swift
print(count)  // 0
$count.withValue(42) {
  print(count)  // 42
}
print(count)  // 0
```

This may seem restrictive, but it is what makes this global value concurrency safe, and what makes it behave as we would expect with respect to structured programming.

However, if we want to override such globals for every test in a suite, we cannot do so with in `setUp`:

```swift
override func setUp() {
  super.setUp()
  $count.withValue(42) {
    // Value overridden only inside here, not the 
    // rest of the test
  }
}
```

Luckily XCTest does provide a tool that places nicely with structured programming, and it is called `invokeTest`. Overriding `invokeTest`:

```swift
import XCTest

class FeatureTests: XCTestCase {
  override func invokeTest() {
  }
}
```

…gives you a handle on the underlying test that is currently being run, which is `super.invokeTest()`. This allows you to perform work before and after the test is run, as well as surround the invocation of the test in a unit of work, such as a task local’s `withValue`:

```swift
override func invokeTest() {
  print("Before test is run...")
  $count.withValue(42) {
    // Test is run in a context where 'count' is 42
    super.invokeTest()
  }
  print("After test is run...")
}
```

Unfortunately, Swift’s new, native testing framework did not come with such a tool. At least, not until Swift 6.1.

It is now possible to create a test trait that allows you to override the `count` task local for one specific test like so:

```swift
@Test(.count(42))
func basics() {
  // 'count' is 42 in here
}
```

Or for an entire test suite like so:

```swift
@Suite(.count(42))
struct FeatureTests {
  // Every test will have 'count' equal to 42
}
```

To unlock this syntax we can conform to the `TestTrait`, `SuiteTrait` and new `TestScoping` protocols:

```swift
struct CountTrait: TestTrait, SuiteTrait, TestScoping {
  let value: Int
  func provideScope(
    for test: Test, 
    testCase: Test.Case?, 
    performing function: @Sendable () async throws -> Void
  ) async throws {
    try await $count.withValue(value) {
      try await function()
    }
  }
}

extension Trait where Self == CountTrait {
  static func count(_ value: Int) -> Self {
    Self(value: value)
  }
}
```

That is all it takes.

Not only does this unlock a short syntax for safely overriding global variables for tests, but it also plays nicely with parallel testing. The new Swift Testing framework has taken the strong stance of running tests in parallel by default, *and* running all tests in a single process. This means that more than ever tests are not isolated and that the responsibility is on us to make sure that our app code and test code is built in a way that isolates access to shared, mutable state. Task locals are one of the most important tools we have towards this end, and so it is now great to see it is possible to write tests for code written in the proper manner.

# Improving our libraries with scoping traits

We have three main libraries that will benefit from the new `TestScoping` tool in Swift Testing: [Dependencies](http://github.com/pointfreeco/swift-dependencies), [SnapshotTesting](http://github.com/pointfreeco/swift-snapshot-testing) and [MacroTesting](http://github.com/pointfreeco/swift-macro-testing). All 3 libraries heavily use task locals, and so up until Swift 6.1 it has been difficult to support Swift Testing. We have had hacks in place for the past year to *mostly* support the new testing framework, but it did not work in all situations (in particular, parameterized tests and repeatedly run tests).

Here is how one can now use test scoping in order to write tests with each of our libraries:

### Dependencies

Our Dependencies library provides the tools for providing a global set of dependencies to your entire application in a concurrency safe manner. All dependencies are held inside a `@TaskLocal`, which immediately makes them safe to access from any thread, *and* makes them immediately possible to test in a concurrent environment.

Overriding dependencies on a per-test basis was one of the [motivating examples](https://github.com/swiftlang/swift-evolution/blob/main/proposals/testing/0007-test-scoping-traits.md#supporting-scoped-access) for test scoping, and it works great with our Dependencies library. In order to provide an isolated set of dependencies to every test in a suite, simply apply the `.dependencies` trait:

```swift
@Suite(.dependencies)
struct FeatureTests {
  ¬
}
```

That will guarantee that each test gets an isolated set of dependencies, even when tests are run in parallel.

If you further want to override a dependency for a particular test or suite, you can open up a trailing closure on the trait and mutate the argument to provide your dependencies:

```swift
@Suite(.dependencies {
  $0.date.now = Date(timeIntervalSinceNow: 1234567890)
  $0.uuid = .incrementing
})
struct FeatureTests {
  …
}
```

To our knowledge, [Dependencies](https://github.com/pointfreeco/swift-dependencies) is the only Swift dependencies library built on top of task locals, and hence the only library that is fully compatible with Swift Testing. When using all other libraries, one’s tests must either be serialized if using Swift Testing, or you must use XCTest in order to benefit from parallel testing since each test runs in its own process.

### SnapshotTesting

Next, our [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library benefits from these new tools because it stores configuration in a `@TaskLocal`, such as the record mode of tests, as well as which diffing tool to use for test failures.

Previously one would be forced to wrap each test in `withSnapshotTesting` in order to change these values since they were stored in a task local:

```swift
@Test func basics() {
  withSnapshotTesting(record: .failed, diffTool: .ksdiff) {
    …
  }
}
```

But now, with `TestScoping`, we can override these settings for every test in an entire suite:

```swift
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct FeatureTests {
  …
}
```

### MacroTesting

And finally, our [MacroTesting](https://github.com/pointfreeco/swift-macro-testing) library also benefits from the new `TestScoping` tools in Swift 6.1. This library makes it easy to test your macros by expanding the source code of a macro and snapshotting the result directly inline to your test:

```swift
@Test func stringify() {
  withMacroTesting([StringifyMacro.self], record: failed) {
    assertMacro {
      """
      #stringify(a + b)
      """
    } expansion: {
      """
      (a + b, "a + b")
      """
    }
  }
}
```

Prior to Swift 6.1 it was required to wrap each test in `withMacroTesting` because certain configuration values were stored in a `@TaskLocal`. But now it is possible to specify this information a single test for an entire suite of tests:

```swift
@Suite(.macros([StringifyMacro.self], record: .failed))
struct MacroTests {
  …
}
```

# Get started today

We have officially released new versions of all 3 libraries so that you can take advantage of these tools today: [Dependencies 1.9.0](https://github.com/pointfreeco/swift-dependencies/releases/tag/1.9.0), [SnapshotTesting 1.18.3](https://github.com/pointfreeco/swift-snapshot-testing/releases/tag/1.18.3), and [MacroTesting 0.6.1](https://github.com/pointfreeco/swift-macro-testing/releases/tag/0.6.1). Let us know what you think!
