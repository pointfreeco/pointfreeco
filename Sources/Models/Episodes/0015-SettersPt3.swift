import Foundation

extension Episode {
  static let ep15_settersErgonomicsAndPerformance = Episode(
    blurb: """
Functional setters can be very powerful, but the way we have defined them so far is not super ergonomic \
or performant. We will provide a friendlier API to use setters and take advantage of Swift's value mutation \
semantics to make setters a viable tool to bring into your code base _today_.
""",
    codeSampleDirectory: "0015-setters-pt-3",
    exercises: _exercises,
    id: 15,
    image: "https://i.vimeocdn.com/video/804927717.jpg",
    length: 34*60 + 19,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_525_082_223 + 604_800*2),
    references: [
      .swiftOverture,
      .composableSetters,
      .semanticEditorCombinators
    ],
    sequence: 15,
    title: "Setters: Ergonomics & Performance",
    trailerVideo: .init(
      bytesLength: 26952059,
      downloadUrl: "https://player.vimeo.com/external/352798200.hd.mp4?s=ab557585434b2c4f38960aaac70d50d8b0cb1ee5&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/352798200"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
We previously saw that functions `(inout A) -> Void` and functions `(A) -> Void where A: AnyObject` can be composed the same way. Write `mver`, `mut`, and `^` in terms of `AnyObject`. Note that there is a specific subclass of `WritableKeyPath` for reference semantics.
"""),
  Episode.Exercise(problem: """
Our [episode on UIKit styling](/episodes/ep3-uikit-styling-with-functions) was nothing more than setters in disguise! Explore building some of the styling functions we covered using both immutable and mutable setters, specifically how setters compose over sub-typing in Swift, and how setters compose between roots that are reference types, and values that are value types.
"""),
  Episode.Exercise(problem: """
We've explored `<>`/`concat` as single-type composition, but this doesn't mean we're limited to a single generic parameter! Write a version of `<>`/`concat` that allows for composition of value transformations of the same input and output type. This should allow for `prop(\\UIEdgeInsets.top) <> prop(\\.bottom)` as a way of assigning both `top` and `bottom` the same value at once.
"""),
  Episode.Exercise(problem: """
Define an operator-free version of setters using `with` and `concat` from our episode on [composition without operators](/episodes/ep11-composition-without-operators). Define an `update` function that combines the semantics of `with` and the variadic convenience of `concat` for ergonomics.
"""),
  Episode.Exercise(problem: """
In the Haskell Lens library, `over` and `set` are defined as infix operators `%~` and `.~`. Define these operators and explore what their precedence should be, updating some of our examples to use them. Do these operators tick the boxes?
"""),
]
