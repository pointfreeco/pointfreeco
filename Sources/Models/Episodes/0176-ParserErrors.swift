import Foundation

extension Episode {
  public static let ep176_parserErrors = Episode(
    blurb: """
Let's explore the topic of error handling. We will scrutinize how we model errors in our parsing library and the problems that have come out of it, and we will address these problems by changing the fundamental shape of the parser type.
""",
    codeSampleDirectory: "0176-parser-errors-pt1",
    exercises: _exercises,
    id: 176,
    length: 32*60 + 53,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1643608800),
    references: [
      .init(
        author: "Federico Zanetello",
        blurb: "A journey into Swift overloading thanks to this private attribute.",
        link: "https://www.fivestars.blog/articles/disfavoredOverload/",
        publishedAt: referenceDateFormatter.date(from: "2020-11-10"),
        title: "What is @_disfavoredOverload in Swift?"
      )
    ],
    sequence: 176,
    subtitle: "from Nil to Throws",
    title: "Parser Errors",
    trailerVideo: .init(
      bytesLength: 15127018,
      vimeoId: 671265224,
      vimeoStyle: .new(
        filename: "0176-trailer.m4v",
        signature720: "96485a0352a0ef3e723d1fa4dd7e9524e108296f1af18df804be1472cee1a15a",
        signature540: "aef43ea41ee59017a26ac8e4b7c66c26370a1face43a17bec4618fb6ee9a821d"
      )
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
