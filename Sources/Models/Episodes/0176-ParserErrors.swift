import Foundation

extension Episode {
  public static let ep176_parserErrors = Episode(
    blurb: """
      Let's explore the topic of error handling. We will scrutinize how we model errors in our parsing library and the problems that have come out of it, and we will address these problems by changing the fundamental shape of the parser type.
      """,
    codeSampleDirectory: "0176-parser-errors-pt1",
    exercises: _exercises,
    id: 176,
    length: 32 * 60 + 53,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_643_608_800),
    references: [
      .init(
        author: "Federico Zanetello",
        blurb: "A journey into Swift overloading thanks to this private attribute.",
        link: "https://www.fivestars.blog/articles/disfavoredOverload/",
        publishedAt: yearMonthDayFormatter.date(from: "2020-11-10"),
        title: "What is @_disfavoredOverload in Swift?"
      )
    ],
    sequence: 176,
    subtitle: "from Nil to Throws",
    title: "Parser Errors",
    trailerVideo: .init(
      bytesLength: 15_127_018,
      downloadUrls: .s3(
        hd1080: "0176-trailer-1080p-144a74d7361f422686c2dbff573c64b1",
        hd720: "0176-trailer-720p-868372f15b3f40718a6d77cd61d59942",
        sd540: "0176-trailer-540p-acdff51973e844518b59ec9c1ac54b17"
      ),
      vimeoId: 671_265_224
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
