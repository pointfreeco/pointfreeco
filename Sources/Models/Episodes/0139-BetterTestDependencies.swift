import Foundation

extension Episode {
  public static let ep139_betterTestDependencies = Episode(
    blurb: """
Exhaustively describing dependencies in your tests makes them stronger _and_ easier to understand, but a failed expectation shouldn't bring down your whole test suite. Let's improve how we assert against exhaustivity by better leveraging XCTest.
""",
    codeSampleDirectory: "0139-better-test-dependencies-pt2",
    exercises: _exercises,
    id: 139,
    image: "https://i.vimeocdn.com/video/TODO.jpg",
    length: 36*60 + 22,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1616389200),
    references: [
      // TODO
      .designingDependencies,
      .tourOfTCA,
      .composableArchitectureDependencyManagement,
      .theComposableArchitecture,
    ],
    sequence: 139,
    subtitle: "Failability",
    title: "Better Test Dependencies",
    trailerVideo: .init(
      bytesLength: 0, // TODO
      vimeoId: 0, // TODO
      vimeoSecret: "TODO"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Define failing schedulers for `OperationQueue` and `RunLoop`.
"""#,
    solution: #"""
Both operation queues and run loops have time types that wrap `Date`:

```swift
extension Scheduler
where
  SchedulerTimeType == OperationQueue.SchedulerTimeType,
  SchedulerOptions == OperationQueue.SchedulerOptions
{
  public static var failing: AnySchedulerOf<Self> {
    .failing(
      now: .init(Date())
    )
  }
}

extension Scheduler
where
  SchedulerTimeType == RunLoop.SchedulerTimeType,
  SchedulerOptions == RunLoop.SchedulerOptions
{
  public static var failing: AnySchedulerOf<Self> {
    .failing(
      now: .init(Date())
    )
  }
}
```
"""#
  ),
]
