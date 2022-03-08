import Foundation

extension Episode {
  public static let ep178_parserPrinters = Episode(
    blurb: """
We've spent many episodes discussing parsing, which turns nebulous blobs of data into well-structured data, but sometimes we need the "inverse" process to turn well-structured data back into nebulous data. This is called "printing" and can be useful for serialization, URL routing and more. This week we begin a journey to build a unified, composable framework for parsers and printers.
""",
    codeSampleDirectory: "0178-parser-printers-pt1",
    exercises: _exercises,
    id: 178,
    length: 30*60 + 13,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1645423200),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 178,
    subtitle: "The Problem",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 58943224,
      vimeoId: 677916872,
      vimeoStyle: .vimeo(
        filename: "0178-trailer.m4v",
        signature720: "52adbe64746e7a619e4b9640fc1b2b23087073e6077fb0f7a515ba8a34bf8398",
        signature540: "46dc2b711348754c2f3f632c4a08e7be81b69afb0b7b4e5e3cc5c5adbf2fff8b"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
