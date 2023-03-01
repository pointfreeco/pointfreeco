import Foundation

extension Episode {
  public static let ep185_tourOfParserPrinters = Episode(
    blurb: """
      Today we celebrate a huge release of [swift-parsing](https://github.com/pointfreeco/swift-parsing), which includes the ability to build invertible parser-printers with ease. We'll demonstrate by using the library to build three different parser-printers, starting with a fun exercise from Advent of Code
      """,
    codeSampleDirectory: "0185-parser-printers-tour-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 345_900_000,
      downloadUrls: .s3(
        hd1080: "0185-1080p-849e5dbf04de463ba37cf2e858cdc3a8",
        hd720: "0185-720p-5eaee19b6f0a4d62a6cc554831ec2272",
        sd540: "0185-540p-8ac8e74324ec494ca496c1bb412cea78"
      ),
      vimeoId: 697_130_371
    ),
    id: 185,
    length: 40 * 60 + 37,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_649_653_200),
    references: [
      .swiftParsing,
      .invertibleSyntaxDescriptions,
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
      vimeoId: 697_129_966
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 185)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
