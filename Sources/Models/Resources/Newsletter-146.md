One of the more exciting announcements from this year's WWDC was the introduction of a native
Swift testing framework. It is built entirely in Swift, will be able to integrate into a 
variety of IDEs, not just Xcode, and comes with a suite of powerful testing tools.

We are excited to announce that our popular [SnapshotTesting][snapshot-gh] library has been updated
to support the new Swift Testing framework, as well as our [MacroTesting][macro-testing-gh] library,
and we've even introduced a few new features along the way.

## Beta preview

However, this new system and the existing proprietary one, XCTest, are unfortunately not 
compatible with each other. Invoking `XCTAssert` inside a new-style test cannot register test
failures, and similarly using the new `#expect` macro from within an `XCTestCase` subclass also
does not work.

  

However, this does leave test support libraries, like our popular [SnapshotTesting][snapshot-gh]
library, in a bit of an awkward spot.



[macro-testing-gh]: http://github.com/pointfreeco/swift-macro-testing 
[snapshot-gh]: http://github.com/pointfreeco/swift-snapshot-testing



---


This release of the library provides beta support for Swift's native Testing library. Prior to this
release, using `assertSnapshot` in a `@Test` would result in a passing test no matter what. That is
because under the hood `assertSnapshot` uses `XCTFail` to trigger test failures, but that does not
cause test failures when using Swift Testing.

In version 1.17 the `assertSnapshot` helper will now intelligently figure out if tests are running
in an XCTest context or a Swift Testing context, and will determine if it should invoke `XCTFail` or
`Issue.record` to trigger a test failure.

For the most part you can write tests for Swift Testing exactly as you would for XCTest. However,
there is one major difference. Swift Testing does not (yet) have a substitute for `invokeTest`,
which we used alongside `withSnapshotTesting` to customize snapshotting for a full test class.

There is an experimental version of this tool in Swift Testing, called `CustomExecutionTrait`, and
this library provides such a trait called ``Testing/Trait/snapshots(diffTool:record:)``. It allows 
you to customize snapshots for a `@Test` or `@Suite`, but to get access to it you must perform an
`@_spi(Experimental)` import of snapshot testing:

```swift
@_spi(Experimental) import SnapshotTesting

@Suite(.snapshots(diffTool: .ksdiff, record: .all))
struct FeatureTests {
  …
}
```

That will override the `diffTool` and `record` options for the entire `FeatureTests` suite.

> Important: As evident by the usage of `@_spi(Experimental)` this API is subject to change. As
soon as the Swift Testing library finalizes its API for `CustomExecutionTrait` we will update
the library accordingly and remove the `@_spi` annotation.
