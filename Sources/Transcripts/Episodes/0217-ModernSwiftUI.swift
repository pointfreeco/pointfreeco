import Foundation

extension Episode {
  public static let ep217_modernSwiftUI = Episode(
    blurb: """
      After a brief digression to explore the performance and ergonomics of identified collections, we dive into the messy world of side effects by implementing the "record meeting" screen. We'll start with the timer, which has surprisingly nuanced logic.
      """,
    codeSampleDirectory: "0217-modern-swiftui-pt4",
    exercises: _exercises,
    id: 217,
    length: 37 * 60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_671_429_600),
    references: [
      .scrumdinger,
      .syncUpsApp,
      .swiftIdentifiedCollections,
      .swiftUINavigation,
      .pointfreecoPackageCollection,
    ],
    sequence: 217,
    subtitle: "Effects, Part 1",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 69_800_000,
      downloadUrls: .s3(
        hd1080: "0217-trailer-1080p-59d22c28379d456594e9fd2342b2698e",
        hd720: "0217-trailer-720p-282697e380fa4c12a624588d3cdcb966",
        sd540: "0217-trailer-540p-17469f2273804927a58d9a9aca1b28f7"
      ),
      vimeoId: 776_647_235
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Refactor `RecordMeetingModel.speakerIndex` to be derived from `elapsedSeconds`, instead.
      """#
  ),
  .init(
    problem: #"""
      The original Scrumdinger application plays a sound when it advances to the next speaker, bring
      this sound into Standups and insert this logic into the record meeting view.
      """#
  ),
]
