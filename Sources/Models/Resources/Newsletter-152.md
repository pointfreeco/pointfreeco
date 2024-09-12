We maintain many [open-source projects](http://github.com/pointfreeco) that thousands of developers and companies clone over a million times on a bi-weekly basis. It is important for us to keep each one updated with the newest advancements in the Swift language, Apple’s platforms (iOS, macOS, visionOS, etc.), as well as Apple’s development environment (Xcode).

And so to celebrate the official release of Xcode 16 and Swift 6.0, we are happy to announce that every single one of our libraries is ready for the future, and we didn’t drop support for any older Swift versions or Apple platforms!

# Swift 6 language mode

The new concurrency checking tools of Swift 6 is a major milestone for the language. It will take a lot of work for everyone to update their code bases to play nicely with the tools, but luckily Swift comes with “language modes” that try to make easing into the process possible. For example, it is possible to develop an app with the Swift 6 *compiler* running in the Swift 5 *language mode* so that you do not need to be 100% concurrency correct right this moment while still getting access to Swift 6’s new features.

We are happy to announce that all of our libraries have not only been updated to work with the Swift 6 *compiler*, but also the Swift 6 *language mode*. This means the compiler now has our back every step of the way as we add new features and fix bugs. This has already been incredibly helpful for us to understand when newly added logic is not concurrency safe and needs to be rethought.

This has been most important in specifically two of our libraries:

- [**Dependencies**](http://github.com/pointfreeco/swift-dependencies): Our powerful dependency management library builds fully in Swift 6 mode with no errors or warnings. And further, we have zero usages of `nonisolated(unsafe)` and only one single usage of `@unchecked Sendable` where a manual lock was required, and this is thanks to our usage of `TaskLocal` for modeling dependencies, which is concurrency-safe out of the box. This means we are never working outside the purview of the compiler when it comes to concurrency checking, and we can largely feel confident in our handling of concurrent situations.
- [**The Composable Architecture**](http://github.com/pointfreeco/swift-composable-architecture): As of version 1.14, the `Store`, `TestStore` and various view helpers are all now `@MainActor`, and this was accomplished in a 100% backwards compatible manner. This now enforces a requirement that was previously checked at runtime and flagged with warnings. In the future it will be possible to restrict the `Store` type to *any* actor, not just the main actor.

And we want to stress again that all of this was accomplished in a 100% backwards compatible manner. We did not need to drop the supported Swift version, or the supported Swift platforms, and everything fit into minor version releases (we did not need to release a single major version of any library!).

# Swift Testing

The other big thing Xcode 16 brings to the Swift community is the new, native Swift [Testing framework](https://developer.apple.com/documentation/testing/). This is the successor to Xcode’s XCTest framework that brings many new features and ergonomic improvements.

And we are happy to announce that our libraries now fully support Swift’s Testing framework while still maintaining backwards compatibility with XCTest. This was most important in 3 of our libraries:

## Dependencies

One of the most powerful features of our Dependencies library is that it forces you to override your dependencies in tests. If you execute a code path during tests that causes an un-overridden dependency to be accessed:

```swift
func testSignUp() {
  …
  // Implementation of this method uses an APIClient
  model.signUpButtonTapped()
  …
}
```

…then a test failure will be triggered:

> Failed: APIClient has no test implementation, but was accessed from a test context: …

This helps make sure you never access a live dependency in tests, *and* forces you to prove that you know exactly which dependencies are being used in a particular execution flow. This makes your tests stronger and acts as documentation for what is involved to run your feature.

This has always worked with XCTest, but it will now behave the same in a `@Test` case too.

Further, one can also leverage an experimental Swift Testing [trait](https://developer.apple.com/documentation/testing/traits) to override dependencies at a high level:

```swift
import DependenciesTestSupport

@Suite(
  .dependency(\.apiClient, .failsOnSignUp),
  .dependency(\.date.now, Date(timeIntervalSince1970: 1234567890)),
  .dependency(\.continuousClock, .immediate)
)
struct FeatureTests {
  // The 'apiClient', 'date' and 'continuousClock' dependencies
  // are all overridden in this scope.
}
```

> Note: Due to a [Swift bug](https://github.com/swiftlang/swift/issues/76409), traits will not compile inline if they contain closures:
>
> ```swift:2:fail
> @Suite(
>   .dependency(\.apiClient.fetchUser, { .mock })
> )
> struct FeatureTests { … }
> ```
>
> You can work around this bug by defining the closure _outside_ of the `@Test` or `@Suite` macro:
>
> ```swift:3:pass
> private let fetchMockUser: @Sendable (Int) async throws -> User = { .mock }
> @Suite(
>   .dependency(\.apiClient.fetchUser, fetchMockUser)
> )
> struct FeatureTests { … }
> ```

By using the `.dependency` test trait we can guarantee that dependencies will be overridden for the entire duration of a test or suite. This makes it very easy to upfront declare your dependencies for your tests, and then the body of your test function can focus just on the testing logic. And even better: all of this is compatible with Swift Testing’s “parallel by default” test runner! Multiple tests can run in parallel and use our dependencies library without worry of dependencies bleeding over from test to test.

We have even brought this functionality to SwiftUI previews! Using [preview traits](https://developer.apple.com/documentation/swiftui/preview(_:traits:_:body:)) one can do the following to override dependencies for a preview:

```swift
#Preview(
  .dependencies {
    $0.apiClient = .failsOnSignUp
    $0.date.now = Date(timeIntervalSince1970: 1234567890)
    $0.continuousClock = .immediate
  }
) {
  // The 'apiClient', 'date' and 'continuousClock' dependencies
  // are all overridden in this preview.
  SignUpView(
    model: SignUpModel()
  )
}
```

These dependencies will remain overridden for the entire duration of the preview.

## The Composable Architecture

One of the biggest selling points of the Composable Architecture is its [broad testing capabilities](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing). You can test how every little piece of state changes in your feature, as well as how every effect executes and feeds data back into the system. When there is a mismatch between the expected and actual state of your feature a beautifully formatted failure message is presented in Xcode.

And now this works when writing tests in Swift’s Testing framework while still keeping compatibility with Xcode’s XCTest framework. This means you can immediately start writing tests with Swift’s shiny, new testing framework for your Composable Architecture features and everything will work just as you expect.

## Issue Reporting

And last, but not least, our [Issue Reporting](http://github.com/pointfreeco/swift-issue-reporting) library has also been updated for Swift’s native Testing framework. Previously, when reporting an issue from your app code while in a testing context a test failure would be raised. This makes it possible for you to write tests that prove no issues are reported, or you can test that an issue *is* reported.

This now works when writing tests in Swift’s Testing framework too. Any issue reported in your feature code will be recorded as a test issue causing a test failure. Further, you can use `withKnownIssue` to assert that you expect the issue to be reported in order to get test coverage on that behavior.

# Update your libraries today!

Be sure to update all of your dependencies today! And as we mentioned a few times in this blog post, these updates are 100% backwards compatible with the previous version of our libraries. You can take advantage of these features right away and should not have any breaking changes in your app.

Enjoy!
