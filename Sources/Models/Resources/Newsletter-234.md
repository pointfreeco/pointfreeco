We are excited to announce **CompilationTesting**, the newest addition to our
[Beta Previews](/beta-previews). It lets you write unit tests for Swift code that should
_not_ compile, and snapshot the compiler's errors, warnings, notes, and fix-its directly
in your test file.

Some of the most important guarantees a library makes are enforced by the compiler.
An unavailable overload can steer someone toward the correct API. An isolation annotation
can prevent unsafe access to shared state. A macro can generate code whose correctness
depends on the compiler's type checker.

But how do you test these guarantees? If you put an invalid use of your library in a test,
the test target itself won't compile. And if in the future one of your guarantees accidentally
regresses, you won't have any way of knowning until someone reports an issue. 

CompilationTesting allows you to unit test things kinds of things by compiling the Swift snippets
directly in your test suite, and performing an inline snapshot of any diagnostics. This technique
uses our powerful [InlineSnapshotTesting] library, which also powers our [MacroTesting] library.

[InlineSnapshotTesting]: https://github.com/pointfreeco/swift-snapshot-testing
[MacroTesting]: https://github.com/pointfreeco/swift-macro-testing

## Testing code that doesn't compile

Start by importing CompilationTesting and passing a string of Swift source to
`assertCompilation`:

```swift
import CompilationTesting
import Testing

@Test func compilationError() async {
  await assertCompilation {
    """
    #error("This is a compilation error")
    """
  }
}
```

The library invokes the Swift compiler on the snippet and records its diagnostics as an
inline snapshot. On the first run, it inserts a `diagnostics` closure into your test:

```swift
@Test func compilationError() async {
  await assertCompilation {
    """
    #error("This is a compilation error")
    """
  } diagnostics: {
    """
    #error("This is a compilation error")
           ˄
           ╰─ error: This is a compilation error
    """
  }
}
```

Review the recorded output and run the test again to verify it. From then on, a change to
the diagnostics fails the test with a diff. If the code unexpectedly starts compiling,
the test fails too.

And when you want to prove that a snippet compiles cleanly, leave off the `diagnostics`
closure:

```swift
@Test func validCode() async {
  await assertCompilation {
    "let count: Int = 42"
  }
}
```

If this test passes then it means the Swift snippet compiles with no diagnostics emitted.

## Testing your library

The real power comes from testing your own APIs. Modules built as dependencies of your
test target are automatically discoverable by CompilationTesting, so you can import them
inside a snippet:

```swift
@Test func deprecatedAPI() async {
  await assertCompilation {
    """
    import MyLibrary
    useDeprecatedSymbol()
    """
  }
}
```

Here, `MyLibrary` and `useDeprecatedSymbol` stand in for a module and API from your own
package. Run the test to record the warning you expect callers to see. You can then catch
changes to that warning, including accidentally removing the deprecation entirely.

The library also automatically loads macro plugins built by your package. This lets you
test aspects of macros that [MacroTesting] alone cannot, such as how the type checker interacts
with macros: 

```swift
@Test func `diagnost non-Equatable fields`() async {
  await assertCompilation {
    """
    import Equatable
    struct Avatar {}
    @DeriveEquatable struct User {
      var avatar: Avatar
    }
    """
  } diagnostics: {
    """
    import Equatable
    struct Avatar {}
    @DeriveEquatable struct User {
      var avatar: Avatar
      ˄
      ╰─ error: 'Avatar' does not conform to 'Equatable' (from macro 'EquatableCheck')
    }
    """
  }
}
```

## Controlling the compiler

You can customize compilation with flags, including the Swift language mode, default
actor isolation, and upcoming or experimental features. For example, this snippet compiles only
because it is compiled in Swift 5 language mode:

```swift
@Test func `default main actor isolation`() async {
  await assertCompilation(flags: [.languageMode(.v5)]) {
    """
    class Model {
      var count = 0
      static let shared = Model()
    }
    """
  }
}
```

In Swift 6 model, globals must be `Sendable`, which `Model` is not, and so the only reason this
can compile is specifically because we are compiling in Swift 5 mode. 

You can also apply configuration to an entire suite with the `.compilation` trait:

```swift
@Suite(.compilation(flags: [.languageMode(.v6)]))
struct Swift6Tests {
  …
}
```

If you want to take a little trip down memory lane, you can even write tests on how your code
compiles in Swift 4 language mode, and in that mode `try?` on a throwing function that returns an
optional does not squash the double optionality:

```swift
@Test func `swift 4 language mode`() async {
  await assertCompilation(flags: [.languageMode(.v4)]) {
    """
    func get() throws -> Int? { return 42 }
    let value: Int? = try? get()
    """
  } diagnostics: {
    """
    func get() throws -> Int? { return 42 }
    let value: Int? = try? get()
                      ˄
                      ╰─ error: value of optional type 'Int??' not unwrapped; did you mean to use 'try!' or chain with '?'?
                      ╰─ fix-it: try!
    """
  }
}
```

## Join the beta

CompilationTesting is available today as a [Beta Preview](/beta-previews), exclusively for
[Point-Free Max](/pricing) members. Join from the beta previews page to receive a GitHub
invitation to the repository, where you can try the library, report issues, and help shape
its API before public release.

We would love to see the compiler guarantees you want to protect in your own libraries:
unavailable overloads, concurrency restrictions, value lifetime restrictions, macro-generated code,
and more. 
