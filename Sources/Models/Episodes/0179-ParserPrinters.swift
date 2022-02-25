import Foundation

extension Episode {
  public static let ep179_parserPrinters = Episode(
    blurb: """
Now that we've framed the problem of printing, let's begin to tackle it. We will introduce a `Printer` protocol by "reverse-engineering" the `Parser` protocol, and we will conform more and more parsers to the printer protocol.
""",
    codeSampleDirectory: "0179-parser-printers-pt2",
    exercises: _exercises,
    id: 179,
    length: 38*60 + 21,
    permission: .subscriberOnly,
    publishedAt:  Date(timeIntervalSince1970: 1646028000),
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
    sequence: 179,
    subtitle: "The Solution, Part 1",
    title: "Invertible Parsing",
    trailerVideo: .init(
      bytesLength: 15029946,
      vimeoId: 680666420,
      vimeoStyle: .new(
        filename: "0179-trailer.m4v",
        signature720: "284e47394d6484184954cee3f56b3635d3760245633d4bd28a30635d0458b5b9",
        signature540: "47c5682fa82bcbcca2b38c792632004979101b9364f188f7566db1c194d05c28"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
