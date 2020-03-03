import Foundation

extension Episode {
  static let ep37_protocolOrientedLibraryDesign_pt1 = Episode(
    blurb: """
Perhaps the most popular approach to code reuse and extensibility in Swift is to liberally adopt protocol-oriented programming, and many Swift libraries are designed with protocol-heavy APIs. In today's episode we refactor a sample library to use protocols and examine the pros and cons of this approach.
""",
    codeSampleDirectory: "0037-protocol-oriented-library-design-pt1",
    exercises: _exercises,
    id: 37,
    image: "https://i.vimeocdn.com/video/801301580.jpg",
    length: 22*60 + 59,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 36,
    publishedAt: .init(timeIntervalSince1970: 1542013200),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 37,
    title: "Protocol-Oriented Library Design: Part 1",
    trailerVideo: .init(
      bytesLength: 135099501,
      downloadUrl: "https://player.vimeo.com/external/349952467.hd.mp4?s=4a98d131f07dff93440785c32b0a63bd89ff60ec&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349952467"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
There's one protocol requirement we missed: the fact that we hard-code the path extension of the snapshot reference to "png". Move this requirement into our protocols. Which protocol does it belong to?
"""),
  .init(problem: """
Add a default implementation of path extension so that those conforming their own types to be `Snapshottable` do not need to declare `"png"` every time.
"""),
  .init(problem: """
Showing the difference between two images is a matter of using a [Core Image difference filter](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIDifferenceBlendMode). Unfortunately, Apple provides no such API to show the difference between two strings. Implement a line diff algorithm to describe the difference between two strings in Swift.

A popular, human-readable algorithm is called the "patience diff". Here are some resources:

- [Patience Diff, a brief summary](https://alfedenzo.livejournal.com/170301.html), [Patience Diff Advantages](https://bramcohen.livejournal.com/73318.html): a brief introduction and description of advantages by the author.

- [diff.py](https://github.com/SamB/debian-codeville/blob/master/Codeville/diff.py), [lcsmatch.py](https://github.com/SamB/debian-codeville/blob/master/Codeville/lcsmatch.py): one of the original implementations, in Python.

- [Enumerating longest increasing subsequences and patience sorting](http://en.wikipedia.org/wiki/Patience_sorting#Algorithm_for_finding_a_longest_increasing_subsequence): a paper that describes the algorithm.
"""),
]
