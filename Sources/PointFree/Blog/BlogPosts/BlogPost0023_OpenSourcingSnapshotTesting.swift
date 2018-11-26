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
[iOSSnapshotTestCase](todo) library (formerly known as [FBSnapshotTestCase](todo). It introduced a new kind
of test coverage for iOS applications by allowing us to assert against an image screenshot of a UI component.
This is a whole new level of testing that can catch regressions in the pixel data of our UI so that you can
make sure that future changes and refactors do not introduce visual regressions into your views.

However, iOSSnapshotTestCase has not evolved much over the years, and its still largely written in
Objective-C, which means the API isn't as generic and composable as it could be in Swift. Also, it only
allows snapshotting `UIView`s into a PNG format, but there are many more types we might want to snapshot and
many more formats we want to snapshot _into_.

That's why today we are excited to officially announce SnapshotTesting 1.0, a modern, composable snapshot
testing library built in Swift!

## Usage

## Witness-Oriented Library Design

One of the most important decisions we made in designing this library is to eschew the liberal use of
protocols, as is encouraged in "protocol-oriented programming", and instead use plain concrete datatypes.
In the former style we would create a system of protocols that users of our library conform to in order to
unlock functionality. In the latter style we provide a system of concrete generic types that the user will
create for their types in order to unlock functionality. It's a seemingly small distinction, but it unlocks
new possibilities.

Most importantly, it allows us to create multiple snapshot strategies for a single type, whereas types can
conform to a protocol only a single time. This means we can have a image strategy for snapshotting
`UIView`'s, but also a text snapshot strategy that prints out the view's hierarchy with all of its children
and their properties.

We can also create strategies for types that cannot conform to protocols, like tuples, functions and `Any`.
The last one is particularly powerful because it means we can create a snapshot strategy for _any_ type by
using Swift `dump` function, which is just not possible with protocols.

## Give it a spin today!
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
