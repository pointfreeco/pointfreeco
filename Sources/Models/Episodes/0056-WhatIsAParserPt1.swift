import Foundation

extension Episode {
  static let ep56_whatIsAParser_pt1 = Episode(
    blurb: """
Parsing is a difficult, but surprisingly ubiquitous programming problem, and functional programming has a lot to say about it. Let's take a moment to understand the problem space of parsing, and see what tools Swift and Apple gives us to parse complex text formats.
""",
    codeSampleDirectory: "0056-what-is-a-parser-pt1",
    id: 56,
    length: 16*60 + 44,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1557122400),
    references: [
      .scannerAppleDocs,
      .nsscannerNsHipster,
      .ledgeMacAppParsingTechniques,
      .parseDontValidate
    ],
    sequence: 56,
    title: "What Is a Parser?: Part 1",
    trailerVideo: .init(
      bytesLength: 58500760,
      vimeoId: 348473323,
      vimeoSecret: "7272e46eac1e8dc3f15bf4206c10cd5b589c09d3"
    )
  )
}
