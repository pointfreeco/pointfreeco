import Foundation

extension Episode {
  public static let ep140_betterTestDependencies = Episode(
    blurb: """
A major source of complexity in our applications is asynchrony. It is a side effect that is easy to overlook and can make testing more difficult and less reliable. We will explore the problem and come to a solution using Combine schedulers.
""",
    codeSampleDirectory: "0140-better-test-dependencies-pt3",
    exercises: _exercises,
    id: 140,
    length: 40*60 + 40,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1616994000),
    references: [
      reference(
        forSection: .combineSchedulers,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/combine/schedulers"
      ),
      .designingDependencies,
      .composableArchitectureDependencyManagement,
      .theComposableArchitecture,
    ],
    sequence: 140,
    subtitle: "Immediacy",
    title: "Better Test Dependencies",
    trailerVideo: .init(
      bytesLength: 71564364,
      downloadUrls: .s3(
        hd1080: "0140-trailer-1080p-387d03e98430428e8c7e7a2512eef54f",
        hd720: "0140-trailer-720p-10213452d34c45b88624772adc2b8784",
        sd540: "0140-trailer-540p-53b422f5f3a84ac9b85d6745f1378d76"
      ),
      vimeoId: 529130454
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Define immediate schedulers for `OperationQueue` and `RunLoop`.
"""#,
    solution: #"""
This can be done exactly the same as we did for `failing` schedulers last week!

```swift
extension Scheduler
where
  SchedulerTimeType == OperationQueue.SchedulerTimeType,
  SchedulerOptions == OperationQueue.SchedulerOptions
{
  public static var immediate: AnySchedulerOf<Self> {
    .immediate(now: .init(Date()))
  }
}

extension Scheduler
where
  SchedulerTimeType == RunLoop.SchedulerTimeType,
  SchedulerOptions == RunLoop.SchedulerOptions
{
  public static var immediate: AnySchedulerOf<Self> {
    .immediate(now: .init(Date()))
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Implement cancellation in the designing dependencies application. This could be as simple as adding a button to the view. Feel free to get creative!
"""#
  ),
  .init(
    problem: #"""
With cancellation implemented in the UI, it'd be nice to be able to see it working in the preview. To do so, introduce a `badWifi` weather client, which slows each of its endpoints down by several seconds.
"""#
  ),
  .init(
    problem: #"""
What happens to the UI if we cancel things before the first API request to fetch locations succeeds? What happens to the UI if we cancel things _after_ it succeeds? How might we improve the user experience?
"""#
  ),
]
