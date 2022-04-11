import Foundation

extension Episode {
  public static let ep185_tourOfParserPrinters = Episode(
    blurb: """
Today we celebrate a huge release of swift-parsing, which includes the ability to build invertible parser-printers with ease. We'll demonstrate by using the library to build three different parser-printers, starting with a fun exercise from Advent of Code
""",
    codeSampleDirectory: "0185-parser-printers-tour-pt1",
    exercises: _exercises,
    id: 185,
    length: 40*60 + 37,
    permission: .free,
    publishedAt:  Date(timeIntervalSince1970: 1649653200),
    references: [
      .invertibleSyntaxDescriptions,
      .unifiedParsingAndPrintingWithPrisms,
    ],
    sequence: 185,
    subtitle: "Introduction",
    title: "Tour of Parser-Printers",
    trailerVideo: .init(
      bytesLength: 84_200_000,
      downloadUrls: .s3(
        hd1080: "0185-trailer-1080p-a0d9fff168e545e8898748be60318d78",
        hd720: "0185-trailer-720p-6c3566baed8b446f85050d476b92e589",
        sd540: "0185-trailer-540p-fcb1777aa23446f99b65b75021979bef"
      ),
      vimeoId: 697129966
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
