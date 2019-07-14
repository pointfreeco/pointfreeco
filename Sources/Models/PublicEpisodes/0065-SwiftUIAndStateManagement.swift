import Foundation

public let ep65 = Episode(
  blurb: """
Let's begin exploring application architecture by understanding what are the common problems we encounter when trying to build large, complex applications. We will build an app in SwiftUI to see how Apple's new framework approaches solving these problems.
""",
  codeSampleDirectory: "0065-swiftui-and-state-management-pt1", // TODO
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 935_800_000,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/full/0065-swiftui-and-state-management-pt1-c3a3fb39-full.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/full/0065-swiftui-and-state-management-pt1.m3u8"
  ),
  id: 65,
  // todo: cloudfront
  image: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/itunes-poster.jpg",
  length: 26 * 60 + 45,
  permission: .free,
  previousEpisodeInCollection: nil,
  publishedAt: .init(timeIntervalSince1970: 1563170400),
  references: [
    .swiftUiTutorials,
    .insideSwiftUIAboutState
  ],
  sequence: 65,
  title: "SwiftUI and State Management: Part 1",
  trailerVideo: .init(
    bytesLength: 81_600_000,
    downloadUrl: "https://pointfreeco-episodes-processed.s3.amazonaws.com/0065-swiftui-and-state-management-pt1/trailer/0065-trailer-trailer.mp4",
    streamingSource: "https://pointfreeco-episodes-processed.s3.amazonaws.com/0065-swiftui-and-state-management-pt1/trailer/0065-trailer.m3u8"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(problem: """
Let's make the state even _more_ persistent by saving the state whenever a change is made and loading the state when the app launches. This can be done in a few steps:

* Make `AppState` conform to `Codable`. This unfortunately requires implement manual encoding and decoding due to the `PassthroughSubject`.
* Tap into each `didSet` on the model and save the JSON representation of the state to `UserDefaults`.
* When the root `ContentView` is created for the playground live view load the `AppState` from `UserDefaults`.

Once you have accomplished this your data will persist across multiple runs of the playground! However, there are quite a few problems with it. Implementing `Codable` is annoying due to the `PassthroughSubject`, we are saving the state to `UserDefaults` on every state change which is probably too inefficient, and we have to repeat that work for each `didSet` entry point. We will explore better ways of dealing with this soon 😄.
"""),
  .init(problem: """
Search for an algorithm online that checks if an integer is prime, and port it to Swift.
"""),
  .init(problem: """
Make the counter `Text` view green when the current count value is prime, and red otherwise.
"""),
  .init(problem: """
To present modals in SwiftUI one uses the `presentation` method on views that takes a single argument of an optional `Modal` value. If this value is present then the modal will be presented, and if it's `nil` the modal will be dismissed (or if no modal is showing, nothing will happen).

Add an additional `@State` value to our `CounterView` and use it to show and hide the modal when the "Is this prime?" button is tapped.
"""),
  .init(problem: """
Add a `var favoritePrimes: [Int]` field to our `AppState`, and make sure to ping `didChange` when this value is mutated.

Use this new `favoritePrimes` state to render a "Add to favorite primes" / "Remove from favorite primes" button in the modal. Also hook up the action on this button to remove or add the current counter value to the list of favorite primes.
"""),
  .init(problem: """
Right now it's cumbersome to add new state to our `AppState` class. We have to always remember to ping `didChange` whenever any of our fields is mutated and even more work is needed if we wanted to bundle up a bunch of fields into its own state class.

These problems can be fixed by creating a generic class `Store<A>` that wraps access to a single value type `A`. Implement this class and replace all instances of `AppState` in our application with `Store<AppState>`.
""")
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  // todo
]
