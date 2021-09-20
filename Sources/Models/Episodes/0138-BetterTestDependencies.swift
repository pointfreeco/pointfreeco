import Foundation

extension Episode {
  public static let ep138_betterTestDependencies = Episode(
    blurb: """
We talk about dependencies a lot on Point-Free, but we've never done a deep dive on how to tune them for testing. It's time to do just that, by first showing how a test can exhaustively describe its dependencies, which comes with some incredible benefits.
""",
    codeSampleDirectory: "0138-better-test-dependencies-pt1",
    exercises: _exercises,
    id: 138,
    image: "https://i.vimeocdn.com/video/1084484166-b5067bd87562055eef4260459b184665e86f38e9496d7a57d2560d303e6cc919-d?mw=2200&mh=1238&q=70",
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
      vimeoId: 522615995,
      vimeoSecret: "f43ad7f9f64d05fe526aa17e0846222d4f5fb136"
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
