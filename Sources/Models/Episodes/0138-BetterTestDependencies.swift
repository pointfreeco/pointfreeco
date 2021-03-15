import Foundation

extension Episode {
  public static let ep138_betterTestDependencies = Episode(
    blurb: """
TODO
""",
    codeSampleDirectory: "0138-better-test-dependencies-pt1",
    exercises: _exercises,
    id: 138,
    image: "TODO",
    length: 41*60 + 55,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1615784400),
    references: [
      // TODO: dependencies
    ],
    sequence: 138,
    subtitle: "Better Test Dependencies",
    title: "Exhaustivity",
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
