One of the more exciting announcements from this year's WWDC was the introduction of a native
Swift testing framework. It is built entirely in Swift, will be able to integrate into a 
variety of IDEs, not just Xcode, and comes with a suite of powerful testing tools.

We are excited to announce that our popular [SnapshotTesting][snapshot-gh] library has been updated
([version 1.17.0][snapshot-1.17]) to support the new Swift Testing framework, as well as our 
[MacroTesting][macro-testing-gh] library, and we've even introduced a few new features along the 
way.

## Beta preview for Swift Testing support

> Note: Currently our support of the Swift Testing framework is considered "beta" 
> because the new testing framework has not even officially been released yet. Once it is officially 
> released, probably sometime in September, we will have an official release with support.

To use the new Swift Testing tools in SnapshotTesting you just need to upgrade to 
[version 1.17.0][snapshot-1.17] of the library. Once that is done the `assertSnapshot` function
can be used in both `XCTestCase` subclasses as well as inside new-style `@Test`s and `@Suite`s:

```swift
@Suite
struct FeatureTests {
  @Test func snapshot() {
    assertSnapshot(FeatureView(), as: .image)
  }
}
```

It may not seem like much, but this actually pretty great. The new Swift Testing framework is not
compatible with the older XCTest framework. Invoking `XCTAssert` inside a new-style test cannot 
register test failures, and similarly using the new `#expect` macro from within an `XCTestCase` 
subclass also does not work.

To make this work, the `assertSnapshot` function dynamically detects which testing environment
it is in so that it knows to either invoke `XCTFail` or the new `Issue.record` under the hood.
For the most part it just works seamlessly without you having to worry about it.

However, there is one major difference. Swift Testing does not (yet) have a substitute for 
`invokeTest`, which can be used to configuration snapshots for every test in a suite, such as the
record mode or diff tool used in failure messages.

There is an experimental version of this tool in Swift Testing, called 
[`CustomExecutionTrait`][custom-execution-trait-gh], and this library provides such a trait called 
`.snapshots(record:diffTool:)`. It allows you to customize snapshots for a `@Test` or `@Suite`, but 
to get access to it you must perform an `@_spi(Experimental)` import of snapshot testing:

```swift
@_spi(Experimental) import SnapshotTesting

@Suite(.snapshots(record: .all, diffTool: .ksdiff))
struct FeatureTests {
  …
}
```

That will override the `diffTool` and `record` options for the entire `FeatureTests` suite.

> Important: As evident by the usage of `@_spi(Experimental)` this API is subject to change. As
> soon as the Swift Testing library finalizes its API for `CustomExecutionTrait` we will update
> the library accordingly and remove the `@_spi` annotation.

## New features in SnapshotTesting

Alongside support for Swift Testing we have also introduced a few new features.  Currently there 
are two global variables in the library for customizing snapshot testing:

  * ``isRecording`` determines whether new snapshots are generated and saved to disk when the test
    runs.

  * ``diffTool`` determines the command line tool that is used to inspect the diff of two files on
    disk.

These customization options have a few downsides currently. 

  * First, because they are globals they can easily bleed over from test to test in unexpected ways.
    And further, Swift's new testing library runs parallel tests in the same process, which is in
    stark contrast to XCTest, which runs parallel tests in separate processes. This means there are
    even more chances for these globals to bleed from one test to another.

  * And second, these options aren't as granular as some of our users wanted. When ``isRecording``
    is true snapshots are generated and written to disk, and when it is false snapshots are not 
    generated, _unless_ a file is not present on disk. The a snapshot _is_ generated. Some of our
    users wanted an option between these two extremes, where snapshots would not be generated if the
    file does not exist on disk.

    And the ``diffTool`` variable allows one to specify a command line tool to use for visualizing
    diffs of files, but only works when the command line tool accepts a very narrow set of 
    arguments,  _e.g.:

    ```sh
    ksdiff /path/to/file1.png /path/to/file2.png
    ```

Because of these reasons, the globals ``isRecording`` and ``diffTool`` are now deprecated, and we
have introduced a new tool that greatly improves upon all of these problems. There is now a function
called `withSnapshotTesting` for customizing snapshots. It allows you to customize how 
the `assertSnapshot` tool behaves for a well-defined scope.

Rather than overriding `isRecording` or `diffTool` directly in your tests, you can wrap your test in
`withSnapshotTesting`:

```swift
// Before
func testFeature() {
  isRecording = true 
  diffTool = "ksdiff"
  assertSnapshot(…)
}

// After
func testFeature() {
  withSnapshotTesting(record: .all, diffTool: .ksdiff) {
    assertSnapshot(…)
  }
}
```

If you want to override the options for an entire test class, you can override the `invokeTest`
method of `XCTestCase`:

```swift
// Before
class FeatureTests: XCTestCase {
  override func invokeTest() {
    isRecording = true 
    diffTool = "ksdiff"
    defer { 
      isRecording = false
      diffTool = nil
    }
    super.invokeTest()
  }
}

// After
class FeatureTests: XCTestCase {
  override func invokeTest() {
    withSnapshotTesting(record: .all, diffTool: .ksdiff) {
      super.invokeTest()
    }
  }
}
```

And if you want to override these settings for _all_ tests, then you can implement a base
`XCTestCase` subclass and have your tests inherit from it.

Further, the `diffTool` and `record` arguments have extra customization capabilities:

  * `diffTool` is now a function 
    `(String, String) -> String` that is handed the current snapshot file and the failed snapshot
    file. It can return the command that one can run to display a diff. For example, to use
    ImageMagick's `compare` command and open the result in Preview.app:

    ```swift
    extension SnapshotTestingConfiguration.DiffTool {
      static let compare = Self { 
        "compare \"\($0)\" \"\($1)\" png: | open -f -a Preview.app" 
      }
    }
    ```

  * `record` is now a type with 4
    choices: `all`, `missing`, `never`, `failed`:
    * `all`: All snapshots will be generated and saved to disk. 
    * `missing`: only the snapshots that are missing from the disk will be generated
    and saved. 
    * `never`: No snapshots will be generated, even if they are missing. This option is appropriate
    when running tests on CI so that re-tries of tests do not surprisingly pass after snapshots are
    unexpectedly generated.
    * `failed`: Snapshots only for failing tests will be generated. This can be useful for tests
    that use precision thresholds so that passing tests do not re-record snapshots that are 
    subtly different but still within the threshold.

## MacroTesting updates

And SnapshotTesting is not the only library getting updates for Swift Testing. Our macro testing
library, aptly named [MacroTesting][macro-testing-gh], has also been updated to support the new
testing framework. You can now use the `assertMacro` helper in both XCTest and Swift Testing
contexts in order to assert how your macros expand and emit diagnostics: 

```swift
@Test
func expansionWithMalformedURLEmitsError() {
  assertMacro {
    """
    let invalid = #URL("https://not a url.com")
    """
  } diagnostics: {
    """
    let invalid = #URL("https://not a url.com")
                  ┬────────────────────────────
                  ╰─ 🛑 malformed url: "https://not a url.com"
    """
  }
}
```

## Get started today

Upgrade to [version 1.17.0][snapshot-1.17] of SnapshotTesting and [version 0.5.0][macro-testing-0.5]
of MacroTesting today to start writing your tests in the brand new, shiny Swift Testing framework.
And if you encounter any issues please open a discussion on one of the GitHub repos.

[macro-testing-0.5]: https://github.com/pointfreeco/swift-macro-testing/releases/tag/0.5.0
[snapshot-1.17]: https://github.com/pointfreeco/swift-snapshot-testing/releases/tag/1.17.0
[macro-testing-gh]: http://github.com/pointfreeco/swift-macro-testing 
[snapshot-gh]: http://github.com/pointfreeco/swift-snapshot-testing
[custom-execution-trait-gh]: https://github.com/apple/swift-testing/blob/3c93f6f9fc3fcdfedcdd3f543553023492533012/Sources/Testing/Traits/Trait.swift#L81-L86
