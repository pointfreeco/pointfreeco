A little over two weeks ago, [we announced][macro-testing-announcement] a new open source library,
[MacroTesting][gh-macro-testing], which is a simple to use and powerful tool for asserting on every
aspect of your Swift macros, including expanded source, diagnostics, fix-its, and more.

This week we are releasing a [version 0.2.0][gh-macro-testing-020] of the library, which makes it
even easier to assert on your macros in a holistic fashion.

Join us for a quick update on the library, or watch our
[free collection of episodes][macros-collection] for an introduction of what the library has to
offer and how it greatly improves upon the tools Apple provides.

[macros-collection]: /collections/macros
[macro-testing-announcement]: /blog/posts/114-a-new-tool-for-testing-macros-in-swift
[gh-macro-testing]: https://github.com/pointfreeco/swift-macro-testing
[gh-macro-testing-020]: https://github.com/pointfreeco/swift-macro-testing/releases/0.2.0

## Diagnostics, fix-its, expansions, oh my!

MacroTesting provides a single function for making assertions against macros, `assertMacro`, which
is given some source code to assert against.

For example, we could test an `@AddCompletionHandler` macro that automatically defines a completion
handler function for a given async function with the following invocation:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
}
```

That's all you need to write. The library will write the rest of this assertion for you,
automatically, the first time it runs, by inlining the result directly into your test file.

In the library's initial release, it would decide what to assert against depending on whether or not
the macro emitted any diagnostics or fix-its. In the above case, in which the macro was applied to a
non-`async` function, that meant inserting the diagnostic and fix-it in an easy-to-read fashion:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
} matches: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
  ┬───
  ╰─ 🛑 can only add a completion-handler variant to an 'async' function
     ✏️ add 'async'
    return b
  }
  """
}
```

To test how the fix-it applies to the original source, you would need to write the assertion all
over again, but with the `applyFixIts` argument set to `true`:

```swift
assertMacro(applyFixIts: true) {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
} matches: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) async -> String {
    return b
  }
  """
}
```

And finally, if you wanted to test the expansion of the fixed source, you would need to write one
final assertion:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) async -> String {
    return b
  }
  """
} matches: {
  """
  func f(a: Int, for b: String) async -> String {
    return b
  }

  func f(a: Int, for b: String, completionHandler: @escaping (String) -> Void) {
    Task {
      completionHandler(await f(a: a, for: b, value))
    }
  }
  """
}
```

While the library does a lot of the work for you, this is still a lot of manual work you need to do
in order to test every aspect of your macro.

## A even better `assertMacro`

MacroTesting 0.2.0 takes care of these details for you, automatically, all at once. If we re-run the
original assertion:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
}
```

The library will now automatically insert diagnostics, applied fix-its, and the final expansion into
separate trailing closures:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
} diagnostics: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
  ┬───
  ╰─ 🛑 can only add a completion-handler variant to an 'async' function
     ✏️ add 'async'
    return b
  }
  """
} fixes: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) async -> String {
    return b
  }
  """
} expansion: {
  """
  func f(a: Int, for b: String) async -> String {
    return b
  }

  func f(a: Int, for b: String, completionHandler: @escaping (String) -> Void) {
    Task {
      completionHandler(await f(a: a, for: b, value))
    }
  }
  """
}
```

This makes it even easier to test every aspect of your macros thoroughly, with very little work.

## Migrating from 0.1.0

MacroTesting provides tools that make it very easy to upgrade an existing test suite. If you use the
`withMacroTesting` helper in a base test case, you can flip `isRecording: true` to automatically
re-record your entire suite's assertions in the new format:

```swift
import MacroTesting
import XCTest

class MyTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(isRecording: true) {
      super.invokeTest()
    }
  }
}
```

And because the library writes the assertions for you, it is always as simple as deleting the
existing `matches` closure and re-running the test to get an existing assertion up-to-date.

## Upgrade or try MacroTesting today

If you've been interested in trying out Swift 5.9's new macro feature, now's a great time to see
what [MacroTesting][gh-macro-testing] has to offer. Consider giving it a shot today!

[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing
