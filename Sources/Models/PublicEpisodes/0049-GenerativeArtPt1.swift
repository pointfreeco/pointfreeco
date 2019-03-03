
import Foundation

let ep49 = Episode(
  blurb: """
Now that we have made randomness both composable _and_ testable, let's have a little fun with it! We are going to explore making some complex generative art that is built from simple, composable units.
""",
  codeSampleDirectory: "0049-generative-art-pt1", // TODO
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 1_000_000_000,
  downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/full/0049-generative-art-pt1-d6ad970a-full.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/full/0049-generative-art-pt1.m3u8"
  ),
  id: 49,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/itunes-poster.jpg",
  length: 32*60 + 06,
  permission: .free,
  publishedAt: .init(timeIntervalSince1970: 1551682800),
  references: [
    .randomUnification,
    .unknownPleasures
    ],
  sequence: 49,
  title: "Generative Art: Part 1",
  trailerVideo: .init(
    bytesLength: 67_900_000,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/trailer/0048-trailer-trailer.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0049-generative-art-pt1/trailer/0048-trailer.m3u8"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(problem: """
Create a generator `Gen<UIColor>` of colors. Can this be expressed in terms of multiple `Gen<CGFloat>` generators?
"""),
  .init(problem: """
Create a generator `Gen<CGPath>` of random lines on a canvas. Can this be expressed in terms of multiple `Gen<CGPoint>` generators?
"""),
  .init(problem: """
Create a generator `Gen<UIImage>` that draws a random number of randomly positioned straight lines on a canvas with random colors. Try to compose this generator out of lots of smaller generators.
"""),
  .init(problem: """
Change the `bump` function we created in this episode so that it adds a bit of random noise to the curve. To do this you will want to change the signature so that it returns a function `(CGFloat) -> Gen<CGFloat>` instead of just a simple function `(CGFloat) -> CGFloat`. This will allow you to introduce random perturbations into the y-coordinate of the graph.
""")
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
]
