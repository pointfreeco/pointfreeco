import Foundation

extension Episode {
  static let ep38_protocolOrientedLibraryDesign_pt2 = Episode(
    blurb: """
      With our library fully generalized using protocols, we show off the flexibility of our abstraction by adding new conformances and functionality. In fleshing out our library we find out why protocols may not be the right tool for the job.
      """,
    codeSampleDirectory: "0038-protocol-oriented-library-design-pt2",
    exercises: _exercises,
    id: 38,
    length: 22 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_542_607_200),
    references: [
      .protocolOrientedProgrammingWwdc,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 38,
    title: "Protocol-Oriented Library Design: Part 2",
    trailerVideo: .init(
      bytesLength: 109_172_787,
      downloadUrls: .s3(
        hd1080: "0038-trailer-1080p-457cde979c214735ba8bf20d8f42dccf",
        hd720: "0038-trailer-720p-2ee2e83cd6664e6e99a5793c520c7c7c",
        sd540: "0038-trailer-540p-fa2eb4b58f83456e8788bcdfa069da0e"
      ),
      vimeoId: 348_604_549
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Using our series on protocol witnesses ([part 1](/episodes/ep33-protocol-witnesses-part-1), [part 2](/episodes/ep34-protocol-witnesses-part-2), [part 3](/episodes/ep35-advanced-protocol-witnesses-part-1), [part 4](/episodes/ep36-advanced-protocol-witnesses-part-2)) as a guide, translate the `Diffable` protocol into a `Diffing` struct.
      """),
  .init(
    problem: """
      Translate the `Snapshottable` protocol into a `Snapshotting` struct. How do you capture the associated type constraint?
      """),
  .init(
    problem: """
      Translate each conformance of `Diffable` into a witness value on `Diffing`.

      - `String`
      - `UIImage`
      """),
  .init(
    problem: """
      Translate the `Snapshottable` protocol into a `Snapshotting` struct. How do you capture the associated type constraint?
      """),
  .init(
    problem: """
      Translate each conformance of `Snapshottable` into a witness value on `Snapshotting`.

      - `String`
      - `UIImage`
      - `CALayer`
      - `UIView`
      - `UIViewController`
      """),
  .init(
    problem: """
      Translate the `assertSnapshot` generic algorithm to take an explicit `Snapshotting` witness.
      """),
]
