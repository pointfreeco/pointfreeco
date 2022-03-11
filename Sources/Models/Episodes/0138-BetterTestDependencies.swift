import Foundation

extension Episode {
  public static let ep138_betterTestDependencies = Episode(
    blurb: """
We talk about dependencies a lot on Point-Free, but we've never done a deep dive on how to tune them for testing. It's time to do just that, by first showing how a test can exhaustively describe its dependencies, which comes with some incredible benefits.
""",
    codeSampleDirectory: "0138-better-test-dependencies-pt1",
    exercises: _exercises,
    id: 138,
    length: 41*60 + 55,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1615784400),
    references: [
      .designingDependencies,
      .tourOfTCA,
      .composableArchitectureDependencyManagement,
      .theComposableArchitecture,      
    ],
    sequence: 138,
    subtitle: "Exhaustivity",
    title: "Better Test Dependencies",
    trailerVideo: .init(
      bytesLength: 43986963,
      downloadUrls: .s3(
        hd1080: "0138-trailer-1080p-19d6b791347148bd8fee9ef00f9575e2",
        hd720: "0138-trailer-720p-523c2782198f4ecb9c3d47751fe8d978",
        sd540: "0138-trailer-540p-eea62628359f4384b78a17e4b7292a8e"
      ),
      vimeoId: 522615995
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Define an assertion helper that asserts against the events that buffer into the `events` array _and_ clear them out to prepare for the next assertion.

Bonus points if you make it generic over any collection of equatable elements so that it can be extracted into a reusable library!
"""#,
    solution: #"""
Because `events` has been extracted to a test case property, the simplest solution can be defined as a helper method:

```swift
class TodosTests: XCTestCase {
  ...

  func assertTracked(events: [AnalyticsClient.Event]) {
    XCTAssertEqual(events, self.events)
    self.events.removeAll()
  }
}
```
"""#
  ),
]
