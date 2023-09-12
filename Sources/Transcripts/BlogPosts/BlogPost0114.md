Today we are excited to announce [MacroTesting][gh-macro-testing], a brand new tool for testing
macros in Swift that is simple to use and powerful. It allows you to assert on every aspect of
your macros, incuding expanded source, diagnostics, fix-its, and more.

[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing

Join us for a quick overview of the library, or watch [this week's _free_ episode][macro-testing-ep]
to see what our library has to offer and how it greatly improves upon the tools Apple provides.

[macro-testing-ep]: todo

## Using MacroTesting

After adding MacroTesting to your project and importing it into your test file, there is one
primary tool for testing: [`assertMacro`][assert-macro-docs]. This function is similar to the 
[`assertMacroExpansion`][assert-macro-expansion-source] function that comes with 
[SwiftSyntax][swift-syntax-gh], but our function does not require you to specify the source string
that the macro expands to.

[assert-macro-docs]: todo
[assert-macro-expansion-source]: https://github.com/apple/swift-syntax/blob/13f113e8a180d4cf1b4460d7e3db697cdf3a3fa8/Sources/SwiftSyntaxMacrosTestSupport/Assertions.swift#L245-L259
[swift-syntax-gh]: https://github.com/apple/swift-syntax 

For example, suppose you had an [`@AddCompletionHandler`][add-completion-handler-source] macro that
can be applied to any `async` method in order to generate an equivalent callback-based method. To 
test this we merely have to specify the input source string that we want to expand:

<!-- todo: update link -->
[add-completion-handler-source]: https://github.com/pointfreeco/swift-macro-testing/blob/bd81bb61318cab572210943e43d7188415e20bdb/Tests/MacroTestingTests/MacroExamples/AddCompletionHandlerMacro.swift

```swift
func testAddAsyncCompletionHandler() {
  assertMacro(["AddCompletionHandler": AddCompletionHandlerMacro.self]) {
    """
    struct MyStruct {
    @AddCompletionHandler
    func f(a: Int) async -> String {
      return b
    }
  }
}
```

Just that little bit of code is already compiling with our library. But, the first time you run
this test, the macro will be automatically expanded and inserted into the test for you:

```swift
func testAddAsyncCompletionHandler() {
  assertMacro {
    """
    struct MyStruct {
      @AddCompletionHandler
      func f(a: Int) async -> String {
        return b
      }
    }
    """
  } matches: {
    """
    struct MyStruct {
      func f(a: Int) async -> String {
        return b
      }

      func f(a: Int, completionHandler: @escaping (String) -> Void) {
        Task {
          completionHandler(await f(a: a))
        }
      }
    }
    """
  }
}
```

You can then visually inspect the expanded source string in order to make sure it is correct.

This is pretty amazing, but static code snippets do not do it justice. Here is a GIF of what this 
looks like when you run the test in Xcode:

![inset](https://pointfreeco-blog.s3.amazonaws.com/posts/0114-macro-testing/macro-testing.gif)

This is a remarkable improvement over the `assertMacroExpansion` tool that SwiftSyntax gives us
by default, which essentially requires us to run the test, get a test failure to see what the
expanded source is, and then copy-and-paste that string back into our test file. That can be
laborious and error prone.

## Testing diagnostics

But our [`assertMacro`][assert-macro-docs] goes even further for testing macros. It also renders
diagnostics the macro emits directly into the source string so that it is crystal clear what line,
column and even highlight range an error or warning is pointing to.

For example, the `@AddCompletionHandler` macro can only be applied to functions. So, if we wanted
to write a test to see what happens when it is erroneously applied to something else, say a struct,
we can simply do the following:

```swift
func testNonFunctionDiagnostic() {
  assertMacro {
    """
    @AddCompletionHandler
    struct Foo {}
    """
  } matches: {
    """
    @AddCompletionHandler
    ┬────────────────────
    ╰─ 🛑 @addCompletionHandler only works on functions
    struct Foo {}
    """
  }
}
```

This helpfully shows that the macro will emit a diagnostic, in particular an error, and it will show
the exact line, column and highlight range the error took place.

This is in stark contrast with Apple's `assertMacroExpansion` method, which only allows asserting
against diagnostics by describing the [numeric line and column number][diagnostic-spec-line-column],
which can be quite difficult to visualize exactly where the diagnostic points to in the source
string. 

[diagnostic-spec-line-column]: https://github.com/apple/swift-syntax/blob/13f113e8a180d4cf1b4460d7e3db697cdf3a3fa8/Tests/SwiftSyntaxMacroExpansionTest/DeclarationMacroTests.swift#L96

## Testing fix-its

But our [`assertMacro`][assert-macro-docs] goes _even_ further for testing macros. Not only can
macros emit diagnostics when being processed, but they can also emit "fix-its", which allow you to
provide quick actions to the user of your macro to fix the problem in their code.

For example, the `@AddCompletionHandler` macro can only be added to functions that are marked as
`async`, and using it on a non-`async` function is an error:

```swift
@AddCompletionHandler
func f(a: Int) -> String {  // 🛑 can only add a completion-handler variant to an 'async' function
  return b
}
```

But the macro helpfully provides a "fix-it" that allows the user to automatically add `async` to 
their function with a single click in Xcode. Our `assertMacro` helper allows us to test fix-its
by expanding their definition directly inline where they can be applied:

```swift
assertMacro { 
  """
  @AddCompletionHandler
  func f(a: Int) -> String {
    return b
  }
  """
} matches: {
  """
  @AddCompletionHandler
  func f(a: Int) -> String {
  ╰─ 🛑 can only add a completion-handler variant to an 'async' function
     ✏️ add 'async'
    return b
  }
  """
}
```

This very clearly shows that when the non-`async` diagnostic is emitted it will come with an 
"add 'async'" diagnostic.

But we can also test how the fix-it is applied. Simply pass `applyFixIts: true` to the `assertMacro`
function and all fix-its will be automatically applied in the expanded source:

```swift
assertMacro(applyFixIts: true) { 
  """
  @AddCompletionHandler
  func f(a: Int) -> String {
    return b
  }
  """
} matches: {
  """
  @AddCompletionHandler
  func f(a: Int) async -> String {
    return b
  }
  """
}
```

This clearly shows that when the "add 'async'" fix-it is applied it inserts the `async` keyword
after the arguments of the function. This is absolutely amazing. This makes it possible for you
to really see what the final, expanded source code looks like so that you can be sure you are 
generating valid code for your users.

## Get started today

This is only scratching the surface of what our [MacroTesting][gh-macro-testing] is capable of.
It is an essential tool for testing your macros and making sure you are providing the best 
experience to your users. Consider adding it to your project today!

[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing
[assert-macro-docs]: todo
[assert-macro-expansion-source]: https://github.com/apple/swift-syntax/blob/13f113e8a180d4cf1b4460d7e3db697cdf3a3fa8/Sources/SwiftSyntaxMacrosTestSupport/Assertions.swift#L245-L259
[swift-syntax-gh]: https://github.com/apple/swift-syntax 
[macro-testing-ep]: todo
