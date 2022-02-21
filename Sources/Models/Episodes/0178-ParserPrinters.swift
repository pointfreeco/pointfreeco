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
      .init(
        author: "Tillmann Rendel and Klaus Ostermann",
        blurb: """
> Parsers and pretty-printers for a language are often quite similar, yet both are typically implemented separately, leading to redundancy and potential inconsistency. We propose a new interface of syntactic descriptions, with which both parser and pretty-printer can be described as a single program using this interface. Whether a _syntactic description_ is used as a parser or as a pretty-printer is determined by the implementation of the interface. Syntactic descriptions enable programmers to describe the connection between concrete and abstract syntax once and for all, and use these descriptions for parsing or pretty-printing as needed. We also discuss the generalization of our programming technique towards an algebra of partial isomorphisms.

This publication (from 2010!) was the initial inspiration for our parser-printer explorations, and a much less polished version of the code was employed on the Point-Free web site on day one of our launch!
""",
        link: "https://www.informatik.uni-marburg.de/~rendel/unparse/",
        publishedAt: referenceDateFormatter.date(from: "2010-09-30"),
        title: "Invertible syntax descriptions: Unifying parsing and pretty printing"
      ),
      .init(
        author: "Fraser Tweedale",
        blurb: """
> Parsers and pretty printers are commonly defined as separate values, however, the same essential information about how the structured data is represented in a stream must exist in both values. This is therefore a violation of the DRY principle – usually quite an obvious one (a cursory glance at any corresponding `FromJSON` and `ToJSON` instances suffices to support this fact). Various methods of unifying parsers and printers have been proposed, most notably _Invertible Syntax Descriptions_ due to Rendel and Ostermann (several Haskell implementations of this approach exist).

Another approach to the parsing-printing problem using a construct known as a "prism" (a construct Point-Free viewers and library users may better know as a "case path").
""",
        link: "https://yowconference.com/talks/fraser-tweedale/yow-lambda-jam-2016/unified-parsing-and-printing-with-prisms-12532/",
        publishedAt: referenceDateFormatter.date(from: "2016-04-29"),
        title: "Unified Parsing and Printing with Prisms"
      ),

    ],
    sequence: 178,
    subtitle: "The Problem",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 58943224,
      vimeoId: 677916872,
      vimeoStyle: .new(
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
