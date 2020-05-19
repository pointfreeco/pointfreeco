import Foundation

extension Episode {
  static let ep40_asyncFunctionalRefactoring = Episode(
    blurb: """
The snapshot testing library we have been designing over the past few weeks has a serious problem: it can't snapshot asynchronous values, like web views and anything that uses delegates or callbacks. Today we embark on a no-regret refactor to fix this problem with the help of a well-studied and well-understood functional type that we have discussed numerous times before.
""",
    codeSampleDirectory: "0040-async-functional-refactoring",
    exercises: _exercises,
    id: 40,
    image: "https://i.vimeocdn.com/video/801301102.jpg",
    length: 34 * 60 + 8,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1545030000),
    references: [
      .protocolOrientedProgrammingWwdc,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost
    ],
    sequence: 40,
    title: "Async Functional Refactoring",
    trailerVideo: .init(
      bytesLength: 71878337,
      downloadUrl: "https://player.vimeo.com/external/348583967.hd.mp4?s=f1547174ac322cf2b1ecd0480dd1d17b38656e54&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348583967"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Redefine `pullback` on `Snapshotting` in terms of `asyncPullback`.
"""),
  .init(problem: """
While we were introduced to `pullback` by doing a deep dive on contravariance, `asyncPullback` seems to have a different shape.

Extract the `snapshot` logic of `asyncPullback` to a more general function on `Parallel`. What is the shape of this function? Is it familiar? What other types from past episodes have a similar operation?
""")
]
