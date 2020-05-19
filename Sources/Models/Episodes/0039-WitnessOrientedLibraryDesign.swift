import Foundation

extension Episode {
  static let ep39_witnessOrientedLibraryDesign = Episode(
    blurb: """
We previously refactored a library using protocols to make it more flexible and extensible but found that it wasn't quite as flexible or extensible as we wanted it to be. This week we re-refactor our protocols away to concrete datatypes using our learnings from earlier in the series.
""",
    codeSampleDirectory: "0039-witness-oriented-library-design",
    exercises: _exercises,
    id: 39,
    image: "https://i.vimeocdn.com/video/801301315.jpg",
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
      downloadUrl: "https://player.vimeo.com/external/349952469.hd.mp4?s=9886af414316acc1f0b3fc67cfaf26f6e7b6a4af&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349952469"
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
