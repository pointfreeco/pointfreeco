import Foundation

extension Episode {
  static let ep38_protocolOrientedLibraryDesign_pt2 = Episode(
    blurb: """
With our library fully generalized using protocols, we show off the flexibility of our abstraction by adding new conformances and functionality. In fleshing out our library we find out why protocols may not be the right tool for the job.
""",
    codeSampleDirectory: "0038-protocol-oriented-library-design-pt2",
    exercises: _exercises,
    id: 38,
    image: "https://i.vimeocdn.com/video/803400334.jpg",
    length: 22*60+22,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1542607200),
    references: [
      .protocolOrientedProgrammingWwdc,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 38,
    title: "Protocol-Oriented Library Design: Part 2",
    trailerVideo: .init(
      bytesLength: 109172787,
      vimeoId: 348604549,
      vimeoSecret: "a4d331c15bd2ae3186d31b246e566a21c2fbd296"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Using our series on protocol witnesses ([part 1](/episodes/ep33-protocol-witnesses-part-1), [part 2](/episodes/ep34-protocol-witnesses-part-2), [part 3](/episodes/ep35-advanced-protocol-witnesses-part-1), [part 4](/episodes/ep36-advanced-protocol-witnesses-part-2)) as a guide, translate the `Diffable` protocol into a `Diffing` struct.
"""),
  .init(problem: """
Translate the `Snapshottable` protocol into a `Snapshotting` struct. How do you capture the associated type constraint?
"""),
  .init(problem: """
Translate each conformance of `Diffable` into a witness value on `Diffing`.

- `String`
- `UIImage`
"""),
  .init(problem: """
Translate the `Snapshottable` protocol into a `Snapshotting` struct. How do you capture the associated type constraint?
"""),
  .init(problem: """
Translate each conformance of `Snapshottable` into a witness value on `Snapshotting`.

- `String`
- `UIImage`
- `CALayer`
- `UIView`
- `UIViewController`
"""),
  .init(problem: """
Translate the `assertSnapshot` generic algorithm to take an explicit `Snapshotting` witness.
"""),
]
