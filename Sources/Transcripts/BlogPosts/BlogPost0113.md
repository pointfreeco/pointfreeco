We are excited to announce the biggest update to our popular [SnapshotTesting][gh-snapshot-testing]
library since 1.0: _inline_ snapshot testing. This allows your text-based snapshots to live right 
in the test source code, rather than in an external file:

[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing

![fullWidth](https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/inline-snapshot.gif)

This makes it simpler to verify your snapshots are correct, and even allows you to build your own
inline testing tools on top of it.

<!--For example, our recently released-->
<!--[MacroTesting][gh-macro-testing] library uses inline snapshotting under the hood, but as a user of-->
<!--the library you would never know!-->

Join us for a quick overview of snapshot testing, and a preview of what inline snapshotting brings 
to the table.

* [Snapshot testing](#Snapshot-testing)
* [_Inline_ snapshot testing](#Inline-snapshot-testing)
* [Get started today](#Get-started-today)

<div id="Snapshot-testing"></div>

## Snapshot testing

Snapshot testing is a style of testing where you don't explicitly provide both values you are 
asserting against, but rather you provide a single value that can be snapshot into some serializable 
format. When you run the test the first time, a snapshot is recorded to disk, and future runs of the
test will take a new snapshot of the value and compare it against what is on disk. If those
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
    let view = ZStack {
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
    .frame(width: 200, height: 200)
    
    assertSnapshot(of: view, as: .image)
  }
}
```

The first time we run this the test fails because there is no snapshot of this view already on 
disk:

> ❌ testView(): failed - No reference was found on disk. Automatically recorded snapshot: …
> 
> ```sh
> open "file:///…/__Snapshots__/ExperimentationTests/testView.1.png"
> ```
> 
> Re-run "testView" to test against the newly-recorded snapshot.

And it even helpfully let’s us know where the new snapshot was recorded so that we can easily 
preview it:

![inset](https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/recorded.png)

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
> "file:///…/\_\_Snapshots\_\_/ExperimentationTests/testView.1.png"
>
> @+
> "file:///…/tmp/ExperimentationTests/testView.1.png"
>
> To configure output for a custom diff tool, like Kaleidoscope:
>
> ```swift
> SnapshotTesting.diffTool = "ksdiff"
> ```

And we helpfully get easy links to the expected and actual images so that we can see the difference. 
Or, if we have an application on our computers that can do image diffing, such as 
[Kaleidoscope][kaleidoscope], then we can use it:

```swift
SnapshotTesting.diffTool = "ksdiff"
```

Now the test fails with a command that we can copy-and-paste into terminal to open Kaleidoscope and 
show us a very nice diff of the images:

> ❌ testView(): failed - Snapshot does not match reference.
> 
> ```sh
> ksdiff \
>   "…/__Snapshots__/ExperimentationTests/testView.1.png"
>   "…/tmp/ExperimentationTests/testView.1.png"
> ```
>
> Newly-taken snapshot does not match reference.

Pasting this command into Terminal opens up Kaleidoscope with both the expected and actual images
presented to make it easy to see what changed:

[kaleidoscope]: http://kaleidoscope.app

![inset](https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/diff.png)

So, this is pretty great, but snapshot testing goes well beyond just snapshotting views into images. 
You can snapshot _any_ Swift data type into _any_ kind of format you want.

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
  var isAdmin: Bool
  var name: String
}
let user = User(id: 42, isAdmin: true, name: "Blob")
assertSnapshot(of: user, as: .json)
```

Running this fails letting us know that a new file was saved to disk:

> ❌ testView(): failed - No reference was found on disk. Automatically recorded snapshot: …
> 
> ```sh
> open "file:///…/__Snapshots__/ExperimentationTests/testView.1.json"
> ```
>
> Re-run "testView" to test against the newly-recorded snapshot.

And that file contains the JSON representation of the data type:

```json
{
  "id" : 42,
  "isAdmin": true,
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
finally put the finishing touches to it to make it ready for prime time.

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
-assertSnapshot(of: user, as: .json)
+assertInlineSnapshot(of: user, as: .json)
```

Running this test causes the library to see that you are not currently asserting against a 
particular snapshot, and so generates a fresh one and inserts it directly _into_ your test source
code as a trailing closure:

```swift
assertInlineSnapshot(of: user, as: .json)  {
  """
  {
    "id" : 42,
    "isAdmin": true,
    "name" : "Blob"
  }
  """
}
```

It feels almost magical, but unfortunately static text in a blog post does not do it justice. This
is what it looks like when you run the test in Xcode:

![fullWidth](https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/inline-snapshot.gif)

And you can run this over and over and it will pass, but now the snapshot lives right alongside the 
value you are snapshotting.

Even better, the `assertInlineSnapshot` testing tool is fully customizable so that you can build
your own testing helpers on top of it without your users even knowing they are using snapshot
testing. In fact, we do this to create a testing tool that helps us test the Swift code that powers
this very site. It's called [`assertRequest`][assert-request-gh], and it allows you to 
simultaneously assert the request being made to the server (including URL, query parameters, 
headers, POST body) as well as the response from the server (including status code and headers).

For example, to test that when a request is made for a user to join a team subscription, we can
[write the following][assert-request-example]:

```swift
await assertRequest(
  connection(
    from: request(
      to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: nil)),
      session: .loggedIn(as: currentUser)
    )
  )
) {
  """
  POST http://localhost:8080/join/subscriptions-team_invite_code3
  Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}
  """
} response: {
  """
  302 Found
  Location: /account
  Referrer-Policy: strict-origin-when-cross-origin
  Set-Cookie: pf_session={"flash":{"message":"You now have access to Point-Free!","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
  X-Content-Type-Options: nosniff
  X-Download-Options: noopen
  X-Frame-Options: SAMEORIGIN
  X-Permitted-Cross-Domain-Policies: none
  X-XSS-Protection: 1; mode=block
  """
}
```

This shows that the response redirects the use back to their account page and shows them the flash
message that they now have full access to Point-Free. This makes writing complex and nuanced tests
incredibly easy, and so there is no reason to not right lots of tests for all the subtle edge cases
of your application's logic.

[assert-request-gh]: https://github.com/pointfreeco/pointfreeco/blob/5b5cd26d8240bd0e1afb77b7ef342458592c7366/Sources/PointFreeTestSupport/PointFreeTestSupport.swift#L42-L87
[assert-request-example]: https://github.com/pointfreeco/pointfreeco/blob/a237ce693258b363ebfb4bdffe6025cc28ac891f/Tests/PointFreeTests/JoinMiddlewareTests.swift#L285-L309


<!--Our recently released [MacroTesting][macro-testing-blog] library does just that. Users-->
<!--of our library can test their macros by simply invoking `assertMacro` with a fragment of Swift-->
<!--source code using the macro:-->
<!---->
<!--```swift-->
<!--func testStringify() {-->
<!--  assertMacro {-->
<!--    """-->
<!--    let (result, code) = #stringify(a + b)-->
<!--    """ -->
<!--  }-->
<!--}-->
<!--```-->
<!---->
<!--And upon first run of the test it will automatically generate and insert the expanded macro Swift-->
<!--code directly into the test file: -->
<!---->
<!--```swift-->
<!--func testStringify() {-->
<!--  assertMacro {-->
<!--    """-->
<!--    let (result, code) = #stringify(a + b)-->
<!--    """ -->
<!--  } matches: { -->
<!--    """-->
<!--    let (result, code) = (a + b, "a + b")-->
<!--    """-->
<!--  }-->
<!--}-->
<!--```-->
<!---->
<!--This allows one to easily test their macros and see when their expanded macro code changes, and-->
<!--they never even have to know that under the hood our snapshot testing library is powering it.-->

[macro-testing-gh]: http://github.com/pointfreeco/swift-macro-testing
[macro-testing-blog]: /blog/posts/113-a-new-tool-for-testing-macros-in-swift

<div id="Get-started-today"></div>

## Get started today

Bring [SnapshotTesting 1.13][gh-snapshot-testing-release]'s new `InlineSnapshotTesting` module into
your project today to start writing powerful tests in just a few lines of code.

<!--And if you are writing macros, be sure to -->
<!--check out our [MacroTesting][gh-macro-testing] library too, which allows you to easy test the-->
<!--expansion of your macros, as well as their diagnostics and fix-its. -->

[macro-versioning]: https://github.com/apple/swift-syntax/blob/56b057ba77c3417f2873906d22a7caf5540c6a78/Sources/SwiftSyntax/Documentation.docc/Macro%20Versioning.md
[swift-syntax-tags]: https://github.com/apple/swift-syntax/tags
[swift-syntax-concerns]: https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588
[gh-snapshot-testing]: http://github.com/pointfreeco/swift-snapshot-testing
[gh-snapshot-testing-release]: http://github.com/pointfreeco/swift-snapshot-testing/releases/1.13.0
[gh-macro-testing]: http://github.com/pointfreeco/swift-macro-testing
[gh-swift-syntax]: http://github.com/apple/swift-syntax
