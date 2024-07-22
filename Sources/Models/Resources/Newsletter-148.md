We are excited to announce that we now have beta support for Swift's new native Testing framework
in all of [Point-Free's](/) libraries. This includes the [Composable Architecture][tca-gh],
[SnapshotTesting][snapshot-testing-gh], [Dependencies][deps-gh], and a lot more! 

> Note: Currently our support of the Swift Testing framework is considered "beta" because Swift's
> own testing framework has not even officially been released yet. Once it is officially released,
> probably sometime in September, we will have an official release of our libraries with support.

## Swift Testing

Swift 6 and Xcode 16 have introduced a brand new testing framework that is native to the Swift
language. It is powerful and robust, and will eventually be able to run on all platforms, not just
Apple's platforms.

We currently maintain many libraries that provide test helpers, but currently those helpers work
only for the XCTest framework. If you try to write a test with the new Testing framework, and use
one of our helpers, any failure triggered by the failure will not actually fail the test suite.

So, we have updated every one of our libraries so that they can be seamlessly used in Swift Testing
_and_ XCTest.

### Composable Architecture

Our popular [Composable Architecture][tca-gh] library comes with a tool, called `TestStore`, that
allows one to fully test features built with the library. You can now write these tests in a 
modern `@Test` function and it will all just work:

```swift
@MainActor
@Test
func basics() async {
  let store = TestStore(initialState: Feature.State()) {
    Feature()
  } withDependencies: {
    $0.factClient = .mock
  }
  
  await store.send(.factButtonTapped) {
    $0.isLoading = true
  }
  await store.receive(\.response.success) {
    $0.fact = "0 is a good number"
  }
}
```

Running this test will fail because we forgot to assert that `isLoading` goes back to `false` after
receiving a response:

> Failed: A state change does not match expectation: …
>
> ```
>   Feature.State(
>     count: 0,
>     fact: "0 is a good number",
> −   isLoading: true,
> +   isLoading: false,
>   )
> ```
>
> (Expected: −, Actual: +)

### Dependencies

Our [dependency management library][deps-gh] provides a special feature to make sure that you do
not accidentally access live dependencies in a test. It does so by triggering a test failure if
you access a dependency that has not been explicitly overridden. This is great for making sure
that you do not accidentally execute network requests or track analytics in tests.

And now this feature works perfectly in the modern Testing framework too. For example, in the
example above, if we had forgotten to override the `factClient` dependency:

```diff
 let store = TestStore(initialState: Feature.State()) {
   Feature()
-} withDependencies: {
-  $0.factClient = .mock
 }
```

…then running the test produces a test failure letting you know you are accessing a live dependency
from a test context:

> Failed: `@Dependency(\.factClient)` has no test implementation, but was accessed from a test 
> context:
>
> ```
> Location:
>   MyApp/Feature.swift:26
> Dependency:
>   FactClient
> ```
> 
> Dependencies registered with the library are not allowed to use their default, live 
> implementations when run from tests.
>
> To fix, override 'factClient' with a test value. 

### Custom Dump

Our [Custom Dump][custom-dump-gh] library comes with a few tools for printing out large data 
structures into a nicely formatted string. The string can be used to provide helpful debugging tools 
to apps and libraries, but can also be used to power a test assertion tools that helps visualize the 
exact difference between two values.

For example, if you have two user values that have only a small difference:

```swift
var other = user
other.name += "!"
XCTAssertEqual(user, other)
```

…then the test failure is not very helpful:

> Failed: XCTAssertEqual failed: ("`User(favoriteNumbers: [42, 1729], id: 2, name: "Blob")`") is not equal to ("`User(favoriteNumbers: [42, 1729], id: 2, name: "Blob!")`")

And so CustomDump provides a tool that makes this failure message much easier to read, and it's
called `XCTAssertNoDifference`:

```swift
var other = user
other.name += "!"
XCTAssertNoDifference(user, other)
```

Now the failure wil look like this:

> Failed: XCTAssertNoDifference failed: …
> 
>     User(
>       favoriteNumbers: […],
>       id: 2,
>   −   name: "Blob"
>   +   name: "Blob!"
>     )
> 
> (First: −, Second: +)

However, as is clear from the name, `XCTAssertNoDifference` was built to work with the XCTest
testing framework. We now provide a new tool, simply called `expectNoDifference`, that works in
both XCTest and Swift's new native Testing framework:

```swift
@Test func user() {
  let user = User(…)
  var other = user
  other.name += "!"
  expectNoDifference(user, other)
}
```

Anytime the test failure messages of `#expect` are difficult for you to parse you may consider
using our library to produce better failure messages.

[custom-dump-gh]: https://github.com/pointfreeco/swift-custom-dump

### Snapshot Testing

Our popular [SnapshotTesting][snapshot-testing-gh] library provides powerful tools for testing
large, complex data structures by snapshotting them into a serializable format, and saving them
to disk. This allows you to easily test views, controllers, server responses, and a lot more.

And the library has now been updated to support both XCTest and the new Testing framework, and
it's completely seamless. Simply use the `assertSnapshot` tool just as you would normally,
and it will just work regardless if you are in an `XCTestCase` subclass or `@Test` function.

For more details, see [this dedicated blog post](/blog/posts/146-swift-testing-support-for-snapshottesting).

### …and more!

The above represents some of the biggest libraries that provide test helpers, but there are even
more and they have all been updated!

## Get started today

Be sure to update all our libraries to their newest version, and start writing tests with Swift's
native Testing framework today!

[clocks-gh]: https://github.com/pointfreeco/swift-clocks
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[deps-gh]: http://github.com/pointfreeco/swift-dependencies
[swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[case-paths-gh]: https://github.com/pointfreeco/swift-case-paths
[snapshot-testing-gh]: https://github.com/pointfreeco/swift-snapshot-testing
