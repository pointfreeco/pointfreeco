import Transcripts
import CustomDump
import XCTest

final class TranscriptsTests: XCTestCase {
  func testBasics() throws {
    XCTAssertEqual(
      blocksParser.print(Episode.00),
      <#T##expression2: Equatable##Equatable#>
    )
  }
}
