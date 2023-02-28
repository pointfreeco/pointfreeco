import Transcripts
import CustomDump
import XCTest

final class TranscriptsTests: XCTestCase {
  func testBasics() throws {
    Episode.bootstrapPrivateEpisodes()
    for episode in Episode.all where episode.permission == .free {
      print("Episode #", episode.sequence)

      let text = String(Substring(try blocksParser.print(Array(episode.transcriptBlocks))))
      //dump(text)

      try! Data(text.utf8).write(
        to: URL(fileURLWithPath: #filePath)
          .deletingLastPathComponent()
          .deletingLastPathComponent()
          .deletingLastPathComponent()
          .appendingPathComponent("Sources")
          .appendingPathComponent("Transcripts")
          .appendingPathComponent("Resources")
          .appendingPathComponent(String(format: "%04d", episode.sequence.rawValue))
          .appendingPathExtension("md")
      )
    }
  }
}
