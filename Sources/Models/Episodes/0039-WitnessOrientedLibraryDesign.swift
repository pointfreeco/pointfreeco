import Foundation

extension Episode {
  static let ep39_witnessOrientedLibraryDesign = Episode(
    blurb: """
We previously refactored a library using protocols to make it more flexible and extensible but found that it wasn't quite as flexible or extensible as we wanted it to be. This week we re-refactor our protocols away to concrete datatypes using our learnings from earlier in the series.
""",
    codeSampleDirectory: "0039-witness-oriented-library-design",
    exercises: _exercises,
    id: 39,
    length: 39 * 60 + 1,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1543208400),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .gallagherProtocolsWithAssociatedTypes,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost,
      .scrapYourTypeClasses,
      .haskellAntipatternExistentialTypeclass,
      .protocolWitnessesAppBuilders2019,
      .pullbackWikipedia,
      .someNewsAboutContramap,
    ],
    sequence: 39,
    title: "Witness-Oriented Library Design",
    trailerVideo: .init(
      bytesLength: 102105644,
      downloadUrls: .s3(
        hd1080: "0039-trailer-1080p-a66b3e9d6799454da97211f4438a3426",
        hd720: "0039-trailer-720p-b45a682ab4194bedb848f137460b6d24",
        sd540: "0039-trailer-540p-fcffd964d26f49c7bb1048e62b5f4e9a"
      ),
      vimeoId: 349952469
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Take our witness-oriented library and define some interesting strategies! Think about your own code base and specialized `Snapshotting` (and `Diffing`) instances you can define. Here are some suggestions to get you started!

- Define a `dump` strategy on `Snapshotting<Any, String>` that uses the output of Swift's `dump` function. You can reuse logic from the `recursiveDescription` strategy to remove occurrences of memory addresses.

- Define a `Snapshotting<URLRequest, String>` strategy that snapshots a raw HTTP request, pretty-printing the method, headers, and body of the request.

- Define a `Snapshotting<NSAttributedString, UIImage>` strategy that snapshots images of attributed strings.

- Define a `Snapshotting<NSAttributedString, String>` strategy that snapshots HTML representations of attributed strings.
"""),
]
