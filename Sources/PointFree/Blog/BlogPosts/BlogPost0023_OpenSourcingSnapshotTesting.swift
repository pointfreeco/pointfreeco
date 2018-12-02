import Foundation

let post0023_openSourcingSnapshotTesting = BlogPost(
  author: .brandon,
  blurb: """
TODO
""",
  contentBlocks: [

    .init(
      content: """
---

> TODO

---

The Swift community has been a large proponent of snapshot testing, mostly thanks to the wonderful
[iOSSnapshotTestCase](https://github.com/uber/ios-snapshot-test-case) library
(formerly known as [FBSnapshotTestCase](https://github.com/facebookarchive/ios-snapshot-test-case)). It
introduced a new kind
of test coverage for iOS applications by allowing us to assert against an image screenshot of a UI component.
This is a whole new level of testing that can catch regressions in the pixel data of our UI so that you can
make sure that future changes and refactors do not introduce visual regressions into your views.

However, iOSSnapshotTestCase has not evolved much over the years, and its still largely written in
Objective-C, which means the API isn't as generic and composable as it could be in Swift. Also, it only
allows snapshotting `CALayer`s and `UIView`s into a PNG format, but there are many more types we might want to snapshot and
many more formats we want to snapshot _into_.

That's why today we are excited to officially announce
[SnapshotTesting 1.0](https://github.com/pointfreeco/swift-snapshot-testing): a modern, composable snapshot
testing library built entirely in Swift!

## Witness-Oriented Library Design

One of the most important decisions we made in designing this library is to eschew the liberal use of
protocols, as is encouraged in "protocol-oriented programming", and instead use plain concrete datatypes.
In the former style we would create a system of protocols that users of our library conform to in order to
unlock functionality. In the latter style we provide a system of concrete generic types that the user will
create for their types in order to unlock functionality. It's a seemingly small distinction, but it unlocks
worlds of new possibilities.

Most importantly, it allows us to create multiple snapshot strategies for a single type, whereas types can
conform to a protocol only a single time. This means we can have a image strategy for snapshotting
`UIView`s, but also a text snapshot strategy that prints out the view's hierarchy with all of its children
and their properties.

We can also create strategies for types that cannot conform to protocols, like tuples, functions and `Any`.
The last one is particularly powerful because it means we can create a snapshot strategy for _any_ type by
using Swift's `dump` function, which is just not possible with protocols.

## Basic Usage

SnapshotTesting supports CocoaPods, Carthage and the Swift Package Manager, so bringing it into your project
should be a cinch. Once integrated, you can immediately start snapshotting your views. You don't even need
to change the superclass of your test cases!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import SnapshotTesting
import XCTest

class MyViewControllerTests: XCTestCase {
  func testView() {
    let vc = MyViewController()

    assertSnapshot(matching: vc, as: .image)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Upon first run of this test a screenshot will be generated and saved to disk. Subsequent runs will generate
new screenshots and compare them against what is on disk, and if a single pixel is off the test will fail.
If the changes in the screenshot are intentional and you want to record a new screenshot to disk, then you
can put the test into record mode:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
  func testView() {
    record = true

    let vc = MyViewController()

    assertSnapshot(matching: vc, as: .image)
  }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now when running this test a new screenshot will be generated and written to disk, and when you are happy
with the new image you can remove the `record = true` flag.

## Advanced Usage

SnapshotTesting goes well beyond just snapshotting views as PNG images. We can snapshot _any_ type into
_any_ diffable format. For example, you may have an `ApiService` that is responsible for preparing requests
to your web API by attaching authorization and some custom headers. You can write a textual snapshot test
for that logic:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import SnapshotTesting
import XCTest

class ApiServiceTests: XCTestCase {
  func testUrlRequestPreparation() {
    let service = ApiService()
    let request = service.prepare(endpoint: .createArticle("Hello, world!"))

    assertSnapshot(matching: request, as: .raw)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This will record the following data to disk:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
POST https://api.site.com/articles?oauth_token=deadbeef
User-Agent: iOS/BlobApp 1.0
X-App-Version: 42

title=Hello%20World
""",
      timestamp: nil,
      type: .code(lang: .other("txt"))
    ),

    .init(
      content: """
Then, later if we performed a refactoring of this code, and accidentally messed up the logic that sets
the HTTP method, we would get a test failure with a nicely formatted failure message:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
-POST https://api.site.com/articles?oauth_token=deadbeef
+GET https://api.site.com/articles?oauth_token=deadbeef
 User-Agent: iOS/BlobApp 1.0
 X-App-Version: 42

 title=Hello%20World
""",
      timestamp: nil,
      type: .code(lang: .other("diff"))
    ),

    .init(
      content: """
It's worth comparing this to the more traditional way of unit testing using `XCTAssert`. You would have to
create an entire `URLRequest` from scratch and assert against it. And then if it failed you wouldn't have any
specific information of what went wrong. With snapshot testing we are getting very broad coverage on the full
request, including URL, method, headers and body, with very little work. And when the snapshot fails we get a
nice, human-readable failure with a diff.

## Give it a spin today!

---

> The design of this library has been extensively covered in a series of episodes on Point-Free. We first
discussed the idea of protocol witnesses and how to translate protocols into concrete types in a two-part
miniseries ([part 1](/episodes/ep33-protocol-witnesses-part-1)),
[part 2](/episodes/ep34-protocol-witnesses-part-2). We then expanded on those ideas to show how to convert
some of the more advanced concepts of Swift protocols into concrete types in another two-part miniseries
([part 1](/episodes/ep35-advanced-protocol-witnesses-part-1),
[part 2](/episodes/ep36-advanced-protocol-witnesses-part-2)). And finally, we applied all of those ideas to
designing this very library, first in the protocol-oriented style
([part 1](/episodes/ep37-protocol-oriented-library-design-part-1),
[part 2](/episodes/ep38-protocol-oriented-library-design-part-2)), and then refactored into the
[witness-oriented style](/episodes/ep39-witness-oriented-library-design).
""",
      timestamp: nil,
      type: .paragraph
    )

    ],
  coverImage: "TODO",
  id: 23,
  publishedAt: .init(timeIntervalSince1970: 1543827600),
  title: "Open Sourcing SnapshotTesting" // todo
)
