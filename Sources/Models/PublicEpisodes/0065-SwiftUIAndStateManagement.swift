import Foundation

public let ep65 = Episode(
  // TODO: workshop
  blurb: """
Let's begin exploring application architecture by understanding what are the common problems we encounter when trying to build large, complex applications. We will build an app in SwiftUI to see how Apple's new framework approaches solving these problems.
""",
  codeSampleDirectory: "0065-swiftui-and-state-management-pt1", // TODO
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 0, // todo
    downloadUrl: "todo",
    streamingSource: "todo"
  ),
  id: 65,
  // todo: cloudfront
  image: "https://s3.amazonaws.com/pointfreeco-episodes-processed/0065-swiftui-and-state-management-pt1/poster.jpg",
  itunesImage: "https://s3.amazonaws.com/pointfreeco-episodes-processed/0065-swiftui-and-state-management-pt1/itunes-poster.jpg",
  length: 26 * 60 + 45,
  permission: .free,
  previousEpisodeInCollection: nil,
  publishedAt: .init(timeIntervalSince1970: 1563170400),
  references: [
    .swiftUiTutorials
    // todo
  ],
  sequence: 65,
  title: "SwiftUI and State Management: Part 1",
  trailerVideo: .init(
    bytesLength: 0, // todo
    downloadUrl: "todo",
    streamingSource: "todo"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(problem: """
Search for an algorithm online that checks if an integer is prime, and port it to Swift.
"""),
  .init(problem: """
To present modals in SwiftUI one uses the `presentation` method on views that takes a single argument of an optional `Modal` value. If this value is present then the modal will be presented, and if it's `nil` the modal will be dismissed (or if no modal is showing, nothing will happen).

Add an additional `@State` value to our `CounterView` and use it to show and hide the modal when the "Is this prime?" button is tapped.
"""),
  .init(problem: """
Add a `var favoritePrimes: [Int]` field to our `AppState`, and make sure to ping `didChange` when this value is mutated.

Use this new `favoritePrimes` state to render a "Add to favorite primes" / "Remove from favorite primes" button in the modal. Also hook up the action on this button to remove or add the current counter value to the list of favorite primes.
""")
  // todo
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  // todo
]
