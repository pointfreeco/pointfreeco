import Foundation

extension Episode {
  public static let ep139_betterTestDependencies = Episode(
    blurb: """
      Exhaustively describing dependencies in your tests makes them stronger _and_ easier to understand. We improve the ergonomics of this technique by ditching the `fatalError` in unimplemented dependencies, using `XCTFail`, and we open source a library along the way.
      """,
    codeSampleDirectory: "0139-better-test-dependencies-pt2",
    exercises: _exercises,
    id: 139,
    length: 36 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_616_389_200),
    references: [
      .init(
        author: "Brandon Williams & Stephen Celis",
        blurb: """
          We open sourced a [library](https://github.com/pointfreeco/xctest-dynamic-overlay) for dynamically loading `XCTFail` so that you can ship test support code right along side production code. We also released new versions of [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) that take advantage of the dynamic `XCTFail` to ship failing effects and schedulers so that you can make your tests more exhaustive. Check out the details in this blog post.
          """,
        link: "https://www.pointfree.co/blog/posts/56-better-testing-bonanza",
        publishedAt: .init(timeIntervalSince1970: 1_616_389_200),
        title: "Better Testing Bonanza"
      ),

      .designingDependencies,
      .tourOfTCA,
      .composableArchitectureDependencyManagement,
      .theComposableArchitecture,
    ],
    sequence: 139,
    subtitle: "Failability",
    title: "Better Test Dependencies",
    trailerVideo: .init(
      bytesLength: 44_982_339,
      downloadUrls: .s3(
        hd1080: "0139-trailer-1080p-d869ec8a01094b229d5e82292f91a681",
        hd720: "0139-trailer-720p-cb65378a262f42a997251614bfc06250",
        sd540: "0139-trailer-540p-dff40530ee45462aa99c1ba44cb1a524"
      ),
      vimeoId: 526_410_765
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
  )
]
