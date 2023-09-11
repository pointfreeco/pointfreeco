We are excited to announce a major update to our popular [SnapshotTesting][gh-snapshot-testing]
library: [_inline_ snapshot testing][gh-inline-snapshot-testing]!

This allows your text-based snapshots to live right in the test source code, rather than in an
external file. This makes it simpler to verify your snapshots are correct, and even allows you to
build your own testing tools on top of our tools. For example, our recently released
[MacroTesting][gh-macro-testing] library uses inline snapshotting under the hood, but as a user of
the library you would never know!

Join us for a quick overview of snapshot testing, and a preview of what inline snapshotting brings 
to the table.

[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing
[gh-inline-snapshot-testing]: http://github.com/pointfreeco/swift-inline-snapshot-testing
[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing

* [Snapshot testing](#Snapshot-testing)
* [_Inline_ snapshot testing](#Inline-snapshot-testing)
  <!--* [Why a separate package?](#Why-a-separate-package)-->
* [Get started today](#Get-started-today)

<div id="Snapshot-testing"></div>

## Snapshot testing

Snapshot testing is a style of testing where you don't explicitly provide both values you are 
asserting against, but rather you provide a single value that can be snapshot into some serializable 
format. When you run the test the first time, a snapshot is recorded to disk, and future runs of 
the test will take a new snapshot of the value and compare it against what is on disk. If those 
snapshots differ, then the test will fail.

The most canonical example of this is snapshot views into images. This is because 
testing views can be quite difficult in general. You can sometimes perform hacks to actually assert 
on what kinds of view components are on the screen and what data they hold, but this often feels 
like testing an implementation detail. And it’s also possible to perform UI tests, but those are 
very slow, can be flakey, and test a wide range of behavior that you may not really care about.

Our [snapshot testing library][gh-snapshot-testing] allows you to test just the very basics of what 
a view looks like. For example, we could test a very small, simple SwiftUI view by asserting its 
snapshot as an image like this:

[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing

```swift
import SnapshotTesting
import SwiftUI

class Test: XCTestCase {
  func testView() {
    assertSnapshot(
      of: ZStack {
        Rectangle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [.white, .black]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
        Text("Point-Free").bold()
      }
      .frame(width: 200, height: 200),
      as: .image
    )
  }
}
```

The first time we run this the test fails because there is no snapshot of this view already on 
disk:

> ❌ testView(): failed - No reference was found on disk. Automatically recorded snapshot: …
> 
> open "…/ExperimentationTests/\_\_Snapshots\_\_/ExperimentationTests/testView.1.png"
> 
> Re-run "testView" to test against the newly-recorded snapshot.

And it even helpfully let’s us know where the new snapshot was recorded so that we can easily 
preview it:

![inset](https://pointfreeco-blog.s3.amazonaws.com/posts/0114-inline-snapshot-testing/recorded.png)

The next time we run this test it passes because it made a new snapshot of the image and compared 
it to the previously recorded snapshot. Since nothing changed in the view, the test passes.

But, if we change something in the view, say like swapping the order of the gradient:

```diff
-gradient: Gradient(colors: [.white, .black]),
+gradient: Gradient(colors: [.black, .white]),
```

…then the test fails:

> ❌ testView(): failed - Snapshot does not match reference.
> 
> @−
> "file:///…/ExperimentationTests/\_\_Snapshots\_\_/ExperimentationTests/testView.1.png"
>
> @+
> "file:///…/tmp/ExperimentationTests/testView.1.png"
> 
> To configure output for a custom diff tool, like Kaleidoscope:
> 
>     SnapshotTesting.diffTool = "ksdiff"
> 
> Newly-taken snapshot does not match reference.

And we helpfully get easy links to the expected and actual images so that we can see the difference. 
Or, if we have an application on our computers that can do image diffing, such as 
[Kaleidoscope][kaleidoscope], then we can use it:

```swift
diffTool = "ksdiff"
```

Now the test fails with a command that we can copy-and-paste into terminal to open Kaleidoscope and 
show us a very nice diff of the images:

> 🛑 testView(): failed - Snapshot does not match reference.
> 
>     ksdiff \
>       "…/ExperimentationTests/\_\_Snapshots\_\_/ExperimentationTests/testView.1.png"
>       "…/tmp/ExperimentationTests/testView.1.png"
> 
> Newly-taken snapshot does not match reference.

Pasting this command into Terminal opens up Kaleidoscope with both the expected and actual images
presented to make it easy to see what changed:

[kaleidoscope]: http://kaleidoscope.app

![inset](https://pointfreeco-blog.s3.amazonaws.com/posts/0114-inline-snapshot-testing/diff.png)

So, this is pretty great, but snapshot testing goes well beyond just snapshotting views into images. 
You can snapshot any Swift data type into any kind of format you want.

For example, if you have very custom JSON encoding and decoding logic in one of your models (see, 
for example, [this][game-context-codable] complex `Codable` conformance in our 
[isowords][isowords-gh] codebase), then you probably want to write a test to make sure you are 
getting everything right. But doing so can be quite onerous. You have to assert against a big, 
hardcoded JSON string, and you can easily get a test failure if your formatting is slightly wrong.

[isowords-gh]: https://github.com/pointfreeco/isowords
[game-context-codable]: https://github.com/pointfreeco/isowords/blob/4628db568226de01a69d7c9954d807aa372165f0/Sources/ClientModels/GameContext.swift#L22-L73

Well, snapshot testing makes this incredibly easy. You can instantly test any data type that is 
`Codable` by turning it into a JSON file:

```swift
struct User: Codable {
  let id: Int
  var name: String
}
assertSnapshot(of: User(id: 42, name: "Blob"), as: .json)
```

Running this fails letting us know that a new file was saved to disk:

> ❌ testView(): failed - No reference was found on disk. Automatically recorded snapshot: …
> 
>     open "…/ExperimentationTests/\_\_Snapshots\_\_/ExperimentationTests/testView.1.json"
> 
> Re-run "testView" to test against the newly-recorded snapshot.

And that file contains the JSON representation of the data type:

```json
{
  "id" : 42,
  "name" : "Blob"
}
```

And of course if this data type was a lot more complicated we would have a lot more JSON here.

<div id="Inline-snapshot-testing"></div>

## _Inline_ snapshot testing

So this is great, but also sometimes it can be a bit of a pain to have the snapshot stored in an 
external file, especially for text-based snapshot formats.

Well, our library has another snapshotting tool that makes this a lot nicer, and it is called 
“inline” snapshots. This was actually a tool [first contributed][inline-snapshot-pr] to the library 
by a Point-Free viewer, [Rob Chatfield][rob-chatfield-twitter], over 4 years ago, and we have 
finally put the final touches on it to make it ready for prime time.

[inline-snapshot-pr]: https://github.com/pointfreeco/swift-snapshot-testing/pull/199
[rob-chatfield-twitter]: https://twitter.com/rjchatfield

You can assert an inline snapshot by first importing `InlineSnapshotTesting` instead of 
`SnapshotTesting`:

```diff
-import SnapshotTesting
+import InlineSnapshotTesting
```

And then change `assertSnapshot` to `assertInlineSnapshot`:

```diff
-assertSnapshot(of: User(id: 42, name: "Blob"), as: .json)
+assertInlineSnapshot(of: User(id: 42, name: "Blob"), as: .json)
```

Running this test causes the library to see that you are not currently asserting against a 
particular snapshot, and so generates a fresh one and inserts it directly _into_ your test source
code as a trailing closure:

```swift
assertInlineSnapshot(of: User(id: 42, name: "Blob"), as: .json)  {
  """
  {
    "id" : 42,
    "name" : "Blob"
  }
  """
}
```

And you can run this over and over and it will pass, but now the snapshot lives right alongside the 
value you are snapshotting.

Even better, the `assertInlineSnapshot` testing tool is fully customizable so that you can build
your own testing helpers on top of it without your users even knowing they are using snapshot
testing. Our recently released [MacroTesting][macro-testing-blog] library does just that. Users
of our library can test their macros by simply invoking `assertMacro` with a fragment of Swift
source code using the macro:

```swift
func testStringify() {
  assertMacro {
    """
    let (result, code) = #stringify(a + b)
    """ 
  }
}
```

And upon first run of the test it will automatically generate and insert the expanded macro Swift
code directly into the test file: 

```swift
func testStringify() {
  assertMacro {
    """
    let (result, code) = #stringify(a + b)
    """ 
  } matches: { 
    """
    let (result, code) = (a + b, "a + b")
    """
  }
}
```

This allows one to easily test their macros and see when their expanded macro code changes, and
they never even have to know that under the hood our snapshot testing library is powering it.

[macro-testing-gh]: http://github.com/pointfreeco/swift-macro-testing
[macro-testing-blog]: /blog/posts/113-a-new-tool-for-testing-macros-in-swift

<!--<div id="Why-a-separate-package"></div>-->
<!---->
<!--## Why a separate package?-->
<!---->
<!--In order to make inline snapshotting as versatile and resilient as possible, we turned to Apple's-->
<!--[SwiftSyntax][gh-swift-syntax] for modifying the source of the test file to insert the snapshot-->
<!--string. SwiftSyntax is incredibly powerful, and it makes it possible to for us to create this tool-->
<!--without much work. However, it's not without its downsides.-->
<!---->
<!--The SwiftSyntax project is quite heavy weight. It takes nearly 30 seconds to compile in DEBUG mode-->
<!--on an M1 Macbook Pro, and over 4 minutes (!) to compile in RELEASE mode. Currently, SnapshotTesting-->
<!--takes less than 2 seconds to compile, and so increasing the build times by that much for a -->
<!--completely optional tool was out of the question. So, no matter what we needed InlineSnapshotTesting-->
<!--to at least be its own library.-->
<!---->
<!--But why did we further put it in its own _package_ in a completely separate _repository_?-->
<!---->
<!--Well, another downside to SwiftSyntax is its strange versioning style. If you look at the project's-->
<!--[released tags][swift-syntax-tags] on GitHub, you will see some really strange ones:-->
<!---->
<!--* 509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-09-05-a-->
<!--* 509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-08-28-a-->
<!--* …-->
<!---->
<!--The naming convention is roughly:-->
<!---->
<!--1. The version of Swift supported by SwiftSyntax with the period removed and optionally padded-->
<!--with 0's (e.g. 5.9 → 509, 5.10 → 510).-->
<!--1. The minor version of the library.-->
<!--1. The patch version of the library.-->
<!--1. The string "-swift-DEVELOPMENT-SNAPSHOT-"-->
<!--1. The date the library was released-->
<!--1. A trailing "-a" string that we are not sure what it represents.-->
<!---->
<!--It's a bit strange, but that allows the version of Swift to act as a major version of SwiftSyntax, -->
<!--and the date it was released acts as a patch version. -->
<!---->


<div id="Get-started-today"></div>

## Get started today

Add our new [InlineSnapshotTesting][gh-inline-snapshot-testing] to your project today to start
writing powerful tests in just a few lines of code. And if you are writing macros, be sure to 
check out our [MacroTesting][gh-macro-testing] library too, which allows you to easy test the
expansion of your macros, as well as their diagnostics and fix-its. 

[macro-versioning]: https://github.com/apple/swift-syntax/blob/56b057ba77c3417f2873906d22a7caf5540c6a78/Sources/SwiftSyntax/Documentation.docc/Macro%20Versioning.md
[swift-syntax-tags]: https://github.com/apple/swift-syntax/tags
[swift-syntax-concerns]: https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588
[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing
[gh-inline-snapshot-testing]: http://github.com/pointfreeco/swift-inline-snapshot-testing
[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing
[gh-swift-syntax]: http://github.com/apple/swift-syntax
