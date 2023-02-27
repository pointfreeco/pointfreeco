import CustomDump
import Models
import Parsing
import XCTest

@testable import TranscriptParser

class TranscriptParserTests: XCTestCase {
  func testPrefixUpTo() throws {
    var input = "Hello, world!"[...]

    let comma = Parse { "," }

    let output = try _PrefixUpTo { comma }.parse(&input)
    XCTAssertEqual(output, "Hello")
    XCTAssertEqual(input, ", world!")
  }

  func testParser() {
    let input = """
      [01:30:34] # Introduction

      [01:30:34] **Stephen:** And so that's why we have our own like, kind of thinking about it \
      from the bottom up. And we'll be revisiting a lot of the topics from the vanilla episodes, \
      but it's gonna be dedicated to just the Composable Architecture.

      ```swift
      let x = 42

      [1, 2, 3]
      ```

      [01:30:47] **Brandon:** Yep.
      """

    let output = [
      Episode.TranscriptBlock(
        content: "Introduction",
        speaker: nil,
        timestamp: .timestamp(hours: 1, minutes: 30, seconds: 34),
        type: .title
      ),
      Episode.TranscriptBlock(
        content: """
          And so that's why we have our own like, kind of thinking about it from the bottom up. \
          And we'll be revisiting a lot of the topics from the vanilla episodes, but it's gonna be \
          dedicated to just the Composable Architecture.

          ```swift
          let x = 42

          [1, 2, 3]
          ```
          """,
        speaker: "Stephen",
        timestamp: 5434,
        type: .paragraph
      ),
      Episode.TranscriptBlock(
        content: "Yep.",
        speaker: "Brandon",
        timestamp: 5447,
        type: .paragraph
      ),
    ]

    XCTAssertNoDifference(
      try blocksParser.parse(input),
      output
    )

    XCTAssertEqual(
      try String(Substring(blocksParser.print(output))),
      input
    )
  }

  func testBlocks() throws {
    let transcriptFragment = """
      [00:00:00] # Title

      [00:00:01] **Stephen:** Paragraph.
      With new lines.

      And double new lines.

      !> [correction]: This is a
      > special announcement!

      More paragraph.

      # Title without timestamp
      """
    let blocks: [Episode.TranscriptBlock] = [
      .init(content: "Title", timestamp: 0, type: .title),
      .init(
        content: "Paragraph.\nWith new lines.\n\nAnd double new lines.", speaker: "Stephen",
        timestamp: 1, type: .paragraph),
      .init(content: "This is a\nspecial announcement!", type: .box(.correction)),
      .init(content: "More paragraph.\n\n# Title without timestamp", type: .paragraph),
    ]
    XCTAssertNoDifference(
      try blocksParser.parse(transcriptFragment),
      blocks
    )
    XCTAssertNoDifference(
      String(Substring(try blocksParser.print(blocks))),
      transcriptFragment
    )
  }

  func testLegacy_Code() throws {
    let blocks: [Episode.TranscriptBlock] = [
      .init(
        content: "let x = 1",
        type: .code(lang: .swift)
      )
    ]

    XCTAssertNoDifference(
      String(Substring(try blocksParser.print(blocks))),
      """
      ```swift
      let x = 1
      ```
      """
    )
  }
}
