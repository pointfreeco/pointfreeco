import Foundation

extension Episode {
  public static let ep220_modernSwiftUI = Episode(
    blurb: """
      We conclude the series by taking control of the last two dependencies: persistence and \
      speech recognition. We'll make use of even more features of our new Dependencies library \
      and we'll write tests for our features that would have been impossible before.
      """,
    codeSampleDirectory: "0220-modern-swiftui-pt7",
    exercises: _exercises,
    id: 220,
    length: 40 * 60 + 36,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_673_848_800),
    references: [
      .scrumdinger,
      .swiftCustomDump,
      .swiftUINavigation,
      .combineSchedulers,
      .swiftCasePaths,
      .swiftClocks,
      .swiftDependencies,
      .swiftIdentifiedCollections,
      .swiftTagged,
      .xctestDynamicOverlay,
      .pointfreecoPackageCollection,
    ],
    sequence: 220,
    subtitle: "Dependencies & Testing, Part 2",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 18_500_000,
      downloadUrls: .s3(
        hd1080: "0220-trailer-1080p-794e656b021144838963318b5a4a3005",
        hd720: "0220-trailer-720p-49b80e52b228496a8c62e501f4da80f0",
        sd540: "0220-trailer-540p-1919a6e7e9a0424b94af60f6f00d4d09"
      ),
      vimeoId: 777_191_092
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Use `@Dependency(\.speechClient.authorizationStatus)` in the standup detail view to show \
      alert when authorization has been denied.

      Further, add an alert button action that uses `@Dependency(\.openURL)` to go to the \
      application notification settings.
      """#
  ),
  .init(
    problem: #"""
      Use `@Dependency(\.date)` and `@Dependency(\.uuid)` to take control of all instances of \
      `Date()` and `UUID()` in the application.
      """#
  ),
  .init(
    problem: #"""
      Write a test for the record screen that confirms that the timer pauses when the end meeting \
      alert is presented. Use a test clock to show that when the alert is up, the `elapsedSeconds` \
      state does not change when the clock is advanced. Dismiss the alert, advance the clock, and \
      assert that the timer continues.
      """#
  ),
  .init(
    problem: #"""
      Write a test for the deletion flow of a standup. Start the test off in a state with at least \
      one standup, and simulate drilling down to the detail, tapping the delete button, assert \
      that an alert was shown, simulate tapping the confirm deletion button, and then assert that \
      the screen popped back to the root and the standup was removed from the collection.
      """#
  ),
  .init(
    problem: #"""
      Let's beef up the static `DataManager.mock` method to support accessing data from more than \
      one URL in a test. Instead of wrapping a mutable blob of `Data`, wrap a `[URL: Data]` \
      dictionary instead.
      """#
  ),
  .init(
    problem: #"""
      Let's further beef up the `DataManager` dependency. Define a static `testValue` that calls \
      `XCTFail` by default. Then, define `override` methods that bypasses failure on a per-URL \
      basis.
      """#
  ),
]
