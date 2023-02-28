import Foundation

extension Episode {
  static let ep49_generativeArt_pt1 = Episode(
    blurb: """
      Now that we have made randomness both composable _and_ testable, let's have a little fun with it! We are going to explore making some complex generative art that is built from simple, composable units.
      """,
    codeSampleDirectory: "0049-generative-art-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 334_663_601,
      downloadUrls: .s3(
        hd1080: "0049-1080p-1d0a8d7ab8ce48238f9f4b58eb63a6e2",
        hd720: "0049-720p-7dbc53f2d4064ed98142c40f19e168d9",
        sd540: "0049-540p-39aa3c39c4a148d9918591e53304061d"
      ),
      vimeoId: 349_952_492
    ),
    id: 49,
    length: 32 * 60 + 06,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_551_682_800),
    references: [
      .randomUnification,
      Episode.Reference(
        author: "Wikipedia contributors",
        blurb: """
          The artwork used as inspiration in this episode comes from the album cover from the band Joy Division.
          """,
        link: "https://en.wikipedia.org/wiki/Unknown_Pleasures#Artwork_and_packaging",
        publishedAt: yearMonthDayFormatter.date(from: "2019-01-02"),
        title: "Unknown Pleasures – Artwork and packaging"
      ),
      Episode.Reference(
        author: "Wikipedia contributors",
        blurb: """
          We used "bump functions" in this episode to construct functions that are zero everywhere except in a small region where they smoothly climb to 1 and then plateau. They are useful in mathematics for taking lots of local descriptions of a function and patching them together into a global function.
          """,
        link: "https://en.wikipedia.org/wiki/Bump_function",
        publishedAt: yearMonthDayFormatter.date(from: "2018-04-06"),
        title: "Bump Function"
      ),
    ],
    sequence: 49,
    title: "Generative Art: Part 1",
    trailerVideo: .init(
      bytesLength: 56_799_598,
      downloadUrls: .s3(
        hd1080: "0049-trailer-1080p-3754999c0ecd4420a08320b06acb7cd6",
        hd720: "0049-trailer-720p-8ace77d3650140cd815947ec16f4bc99",
        sd540: "0049-trailer-540p-87f5b564f8474d69968579a08a69131f"
      ),
      vimeoId: 349_952_489
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 49)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Create a generator `Gen<UIColor>` of colors. Can this be expressed in terms of multiple `Gen<CGFloat>` generators?
      """),
  .init(
    problem: """
      Create a generator `Gen<CGPath>` of random lines on a canvas. Can this be expressed in terms of multiple `Gen<CGPoint>` generators?
      """),
  .init(
    problem: """
      Create a generator `Gen<UIImage>` that draws a random number of randomly positioned straight lines on a canvas with random colors. Try to compose this generator out of lots of smaller generators.
      """),
  .init(
    problem: """
      Change the `bump` function we created in this episode so that it adds a bit of random noise to the curve. To do this you will want to change the signature so that it returns a function `(CGFloat) -> Gen<CGFloat>` instead of just a simple function `(CGFloat) -> CGFloat`. This will allow you to introduce random perturbations into the y-coordinate of the graph.
      """),
]
