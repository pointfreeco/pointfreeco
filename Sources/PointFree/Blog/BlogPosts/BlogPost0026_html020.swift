import Foundation

let post0026_html020 = BlogPost(
  author: .pointfree,
  blurb: """
Announcing swift-html 0.2.0: support for CocoaPods, Carthage, SnapshotTesting, and more!
""",
  contentBlocks: [
    .init(
      content: """
Today we're releasing our [first minor update](https://github.com/pointfreeco/swift-html/releases/tag/0.2.0) to [swift-html](\(gitHubUrl(to: .repo(.html)))).

It contain a number of new features and fixes, including patches from the community!

## What's new?

### iOS Support

While we imagined swift-html to be most useful on the server, [a pull request](https://github.com/pointfreeco/swift-html/pull/27) let us know that there was interest in using our library on iOS, as well! With the help of the community we now  support being embedded in iOS, tvOS, and watchOS.

### Carthage and CocoaPods Support

After adding support for iOS we figured it'd be best to add support for its popular dependency management tools!

### `debugRender`

We've added a new `debugRender` function that will render HTML nodes in a more human-readable format by indenting each node.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
let doc = html([
  body([
    h1(["Welcome!"]),
    p(["You’ve found our site!"])
    ])
  ])

render(doc)
// <html><body><h1>Welcome!</h1><p>You’ve found our site!</p></body></html>

debugRender(doc)
// <html>
//   <body>
//     <h1>
//       Welcome!
//     </h1>
//     <p>
//       You’ve found our site!
//     </p>
//   </body>
// </html>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
While this rendering format is not suitable for rendering in a browser (it introduces additional whitespace), it's perfect for reading and snapshot testing.

### `HtmlSnapshotTesting`

Speaking of snapshot testing, swift-html now comes with a helper module, `HtmlSnapshotTesting`!

A couple months ago we had [our first official release](\(path(to: .blog(.show(post0023_openSourcingSnapshotTesting))))) of [SnapshotTesting](\(gitHubUrl(to: .repo(.html)))), a library that lets you snapshot test not only `UIView`s to images, but _any_ value to _any_ format. We've been snapshot testing the HTML of the Point-Free web site since day one, so we're excited to make this kind of testing easier for everyone.

You can snapshot test swift-html's `Node` type using the `html` strategy.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
assertSnapshot(matching: doc, as: .html)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
### Bug fixes and performance improvements

This release also contains a few bug fixes from the community, and rendering performance improvements thanks to a heavy dose of `inout`.

---

To give swift-html a try today, check out [its GitHub page](\(gitHubUrl(to: .repo(.html)))).
""",
      timestamp: nil,
      type: .paragraph
    )
    ],
  coverImage: Current.assets.emailHeaderImgSrc,
  id: 26,
  publishedAt: .init(timeIntervalSince1970: 1546938000),
  title: "swift-html 0.2.0"
)
