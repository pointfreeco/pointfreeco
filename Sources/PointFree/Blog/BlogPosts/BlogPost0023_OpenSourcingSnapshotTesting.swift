import Foundation

let post0023_openSourcingSnapshotTesting = BlogPost(
  author: .brandon,
  blurb: """
Today we are open sourcing SnapshotTesting 1.0: a modern, composable snapshot testing library built entirely
in Swift!
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0023-announcing-snapshot-testing/cover-1.jpg")
    ),

    .init(
      content: """
---

> Today we are open sourcing [SnapshotTesting 1.0](https://github.com/pointfreeco/swift-snapshot-testing):
a modern, composable snapshot testing library built entirely in Swift!

---

The iOS community has been a large proponent of snapshot testing, mostly thanks to the wonderful
[iOSSnapshotTestCase](https://github.com/uber/ios-snapshot-test-case) library
(formerly known as [FBSnapshotTestCase](https://github.com/facebookarchive/ios-snapshot-test-case)). It
introduced a new kind of test coverage for iOS applications by allowing us to assert against an image
screenshot of a UI component. This is a whole new level of testing that can catch regressions in the pixel
data of our UI so that you can make sure that future changes and refactors do not introduce visual
regressions into your views.

However, iOSSnapshotTestCase has not evolved much over the years, and its still largely written in
Objective-C, which means the API isn't as generic and composable as it could be in Swift. Also, it only
allows snapshotting `CALayer`s and `UIView`s into a PNG format, but there are many more types we might want
to snapshot and many more formats we want to snapshot _into_.

That's why today we are excited to officially announce
[SnapshotTesting 1.0](https://github.com/pointfreeco/swift-snapshot-testing): a modern, composable snapshot
testing library built entirely in Swift!

## Witness-Oriented Library Design

One of the most important decisions we made in designing this library is to eschew the liberal use of
protocols, as is encouraged in "protocol-oriented programming", and instead use plain concrete datatypes.
In the former style we would create a system of protocols that users of our library conform to in order to
unlock functionality, whereas in the latter style we provide a system of concrete generic types that the user
will create for their types in order to unlock functionality. It's a seemingly small distinction, but it
unlocks worlds of new possibilities.

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
to change the superclass of your test cases:
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

## Intermediate Usage

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
      type: .code(lang: .plainText)
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
      type: .code(lang: .diff)
    ),

    .init(
      content: """
It's worth comparing this to the more traditional way of unit testing using `XCTAssert`. You would have to
create an entire `URLRequest` from scratch and assert against it. And then if it failed you wouldn't have any
specific information of what went wrong. With snapshot testing we are getting very broad coverage on the full
request, including URL, method, headers and body, with very little work. And when the snapshot fails we get a
nice, human-readable failure with a diff.

## Advanced Usage

### Transforming snapshot strategies

Not only are snapshot strategies extensible in the sense that you can create them for snapshotting a wide
variety of types into a wide variety of formats, but they are also transformable. In particular, if
you have a function `f: (A) -> B`, then you can transform a snapshot strategy `Snapshotting<B, Format>`
to a snapshot strategy `Snapshotting<A, Format>`. Notice that the `A` and `B` flipped positions, and this is
due to [contravariance](/episodes/ep14-contravariance).

We call this operation [`pullback`](/blog/posts/22-some-news-about-contramap), and it makes it easy to create
all new snapshot strategies out of existing ones. For example, the library comes with a
`Snapshotting<UIImage, UIImage>.image` value for snapshotting images into the image format. We can _pull_
that back to work on layers by using the function `(CALayer) -> UIImage` that renders a layer into an image:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Snapshotting where Value == CALayer, Format == UIImage {
  static let image = Snapshotting<UIImage, UIImage>.image.pullback { layer in
    return UIGraphicsImageRenderer(size: layer.bounds.size)
      .image { ctx in layer.render(in: ctx.cgContext) }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We can then _pull_ that back to work on views by using the function `(UIView) -> CALayer` that plucks out
a view's layer:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Snapshotting where Value == UIView, Format == UIImage {
  static let image: Snapshotting =
    Snapshotting<CALayer, UIImage>.image.pullback { $0.layer }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And finally _pull_ that back to work on view controllers by using the function `(UIViewController) -> UIView`
that plucks out a view controller's view:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Snapshotting where Value == UIViewController, Format == UIImage {
  static let image: Snapshotting =
    Snapshotting<UIView, UIImage>.image.pullback { $0.view }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And with just a few lines of code we created 3 all new snapshot strategies from a single base one. This
is the essence of composability that we should strive for in library design.

### Async snapshots

Some values need to perform a lot of work before they are ready to be snapshot, and many times that work
happens with the use of async callbacks or delegates. A common example is `WKWebView` for snapshotting
web content. This is why we also support async snapshots. When creating a `Snapshotting<Value, Format>`
value you can provide a function `(Value) -> Async<Format>`, which allows you to asynchronously turn
your value into the diffable format.

We can use this to snapshot `WKWebView` by creating a private navigation delegate class, and using it inside
the async function:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
class NavigationDelegate: NSObject, WKNavigationDelegate {
  var callback: (() -> Void)?

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.callback?()
  }
}

extension Snapshotting where Value == WKWebView, Format == UIImage {
  static let image = Snapshotting(
    diffing: .image,
    pathExtension: "png",
    snapshot: { webView in
      Async<UIImage> { callback in
        let delegate = NavigationDelegate()
        delegate.callback = {
          webView.takeSnapshot(with: nil) { image, error in
            callback(image!)
            _ = delegate
          }
        }
        webView.navigationDelegate = delegate
      }
  })
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
It took a little bit of extra work, but now we can deterministically snapshot web views without worrying
about its contents not loading in time.

## Feature-packed

Not only is the API of SnapshotTesting a pleasure to use, but we've also packed a whole bunch of features
not found in any other snapshot library:

  - [**Dozens of snapshot strategies**](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.0.0/Documentation/Available-Snapshot-Strategies.md). Snapshot testing isn't just for `UIView`s and `CALayer`s. Write snapshots against _any_ value, including…
  - [**Write your own snapshot strategies**](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.0.0/Documentation/Defining-Custom-Snapshot-Strategies.md). If you can convert it to an image, string, data, or your own diffable format, you can snapshot test it! Build your own snapshot strategies from scratch or transform existing ones.
  - **No configuration required.** Don't fuss with scheme settings and environment variables. Snapshots are automatically saved alongside your tests.
  - **More hands-off.** New snapshots are recorded whether `record` mode is `true` or not.
  - **Subclass-free.** Assert from any XCTest case or Quick spec.
  - **Device-agnostic snapshots.** Render views and view controllers for specific devices and trait collections from a single simulator.
  - **First-class Xcode support.** Image differences are captured as XCTest attachments. Text differences are rendered inline in error messages.
  - **Supports any platform that supports Swift.** Write snapshot tests for iOS, Linux, macOS, and tvOS.
  - **SceneKit, SpriteKit, and WebKit support.** Most snapshot testing libraries don't support these view subclasses.
  - **`Codable` support**. Snapshot encodable data structures into their [JSON](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.0.0/Documentation/Available-Snapshot-Strategies.md#json) and [property list](https://github.com/pointfreeco/swift-snapshot-testing/blob/1.0.0/Documentation/Available-Snapshot-Strategies.md#plist) representations.
  - **Custom diff tool integration.**

And believe it or not, there's even more.

## Give it a spin today!

If you currently use a form of snapshot testing in your Swift applications, then you may be interested
in giving this library a spin. Not only does it improve upon the classic snapshot tests of UI as images,
but will also encourage you to begin snapshotting your data structures as strings to gain even more
test coverage. [Check it out today!](https://github.com/pointfreeco/swift-snapshot-testing)

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
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0023-announcing-snapshot-testing/cover-1.jpg",
  id: 23,
  publishedAt: .init(timeIntervalSince1970: 1543827600),
  title: "SnapshotTesting 1.0: Delightful Swift snapshot testing"
)
