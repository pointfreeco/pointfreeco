import Foundation

extension Episode {
  static let ep56_whatIsAParser_pt1 = Episode(
    blurb: """
      Parsing is a difficult, but surprisingly ubiquitous programming problem, and functional programming has a lot to say about it. Let's take a moment to understand the problem space of parsing, and see what tools Swift and Apple gives us to parse complex text formats.
      """,
    codeSampleDirectory: "0056-what-is-a-parser-pt1",
    id: 56,
    length: 16 * 60 + 44,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_557_122_400),
    references: [
      .scannerAppleDocs,
      .nsscannerNsHipster,
      .ledgeMacAppParsingTechniques,
      .parseDontValidate,
    ],
    sequence: 56,
    title: "What Is a Parser?: Part 1",
    trailerVideo: .init(
      bytesLength: 58_500_760,
      downloadUrls: .s3(
        hd1080: "0056-trailer-1080p-38aeb24dca8c4e748282b3b7f0adc333",
        hd720: "0056-trailer-720p-aabe104d673148378749e1af3b5bf0b0",
        sd540: "0056-trailer-540p-e9b28a24e5114f17b991a5ca77d6b81f"
      ),
      vimeoId: 348_473_323
    )
  )
}
