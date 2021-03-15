import Foundation

extension Episode {
  public static let ep138_betterTestDependencies = Episode(
    blurb: """
It is possible to write tests in such a way that they precisely describe which dependencies they use and which are not necessary. We explore this by strengthening an existing test suite to be more exhaustive in which dependencies are provided, and show some incredible benefits when doing this.
""",
    codeSampleDirectory: "0138-better-test-dependencies-pt1",
    exercises: _exercises,
    id: 138,
    image: "https://i.vimeocdn.com/video/1084484166.jpg",
    length: 41*60 + 55,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1615784400),
    references: [
      // TODO: dependencies
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
