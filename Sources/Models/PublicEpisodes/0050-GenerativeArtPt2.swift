
import Foundation

public let ep50 = Episode(
  blurb: """
TODO
""",
  codeSampleDirectory: "0050-generative-art-pt2", // TODO
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 0, // todo
  downloadUrl: "todo",
    streamingSource: "todo"
  ),
  id: 50,
  image: "https://s3.amazonaws.com/pointfreeco-episodes-processed/0050-generative-art-pt2/poster.jpg",
  itunesImage: "https://s3.amazonaws.com/pointfreeco-episodes-processed/0050-generative-art-pt2/itunes-poster.jpg",
  length: 27*60 + 22,
  permission: .free,
  publishedAt: .init(timeIntervalSince1970: 1552287600),
  references: [
    .randomUnification,
    Episode.Reference(
      author: "Wikipedia contributors",
      blurb: """
The artwork used as inspiration in this episode comes from the album cover from the band Joy Division.
""",
      link: "https://en.wikipedia.org/wiki/Unknown_Pleasures#Artwork_and_packaging",
      publishedAt: referenceDateFormatter.date(from: "2019-01-02"),
      title: "Unknown Pleasures – Artwork and packaging"
    ),
    Episode.Reference(
      author: "Wikipedia contributors",
      blurb: """
We used "bump functions" in this episode to construct functions that are zero everywhere except in a small region where they smoothly climb to 1 and then plateau. They are useful in mathematics for taking lots of local descriptions of a function and patching them together into a global function.
""",
      link: "https://en.wikipedia.org/wiki/Bump_function",
      publishedAt: referenceDateFormatter.date(from: "2018-04-06"),
      title: "Bump Function"
    )
    // todo: reference other episodes?
    ],
  sequence: 50,
  title: "Generative Art: Part 2",
  trailerVideo: .init(
    bytesLength: 0, // todo
    downloadUrl: "todo",
    streamingSource: "todo"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  //todo
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  // todo
]
