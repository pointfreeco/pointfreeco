import Transcripts
import CustomDump
import XCTest

final class TranscriptsTests: XCTestCase {
  func testBasics() throws {
    Episode.bootstrapPrivateEpisodes()
    for episode in [Episode.all[1]] {
      print("Episode #", episode.sequence)

      let text = String(Substring(try blocksParser.print(episode.transcriptBlocks)))
      dump(text)
      print("!!!")

      for block in episode.transcriptBlocks {
        print(block)
        let text = try blocksParser.print([block])
        let blocks = try blocksParser.parse(text)
        XCTAssertNoDifference([block], blocks)
        print("✅")
      }
    }
  }
}
