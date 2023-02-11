import CustomDump
import Parsing
import XCTest

@testable import Models

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

      [01:30:34] **Stephen:** And so that's why we have our own like, kind of thinking about it from the bottom up. And we'll be revisiting a lot of the topics from the vanilla episodes, but it's gonna be dedicated to just the Composable Architecture.

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
          And so that's why we have our own like, kind of thinking about it from the bottom up. And we'll be revisiting a lot of the topics from the vanilla episodes, but it's gonna be dedicated to just the Composable Architecture.

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
      try paragraphs.parse(input),
      output
    )

    XCTAssertEqual(
      try String(Substring(paragraphs.print(output))),
      input
    )
  }
}
