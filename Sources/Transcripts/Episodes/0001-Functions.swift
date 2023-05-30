import Foundation
import Models

extension Episode {
  static let ep1_functions = Episode(
    blurb: """
      Our first episode is all about functions! We talk a bit about what makes functions special, contrasting them with the way we usually write code, and have some exploratory discussions about operators and composition.
      """,
    codeSampleDirectory: "0001-functions",
    exercises: [],
    fullVideo: .init(
      bytesLength: 197_667_168,
      downloadUrls: .s3(
        hd1080: "0001-1080p-2b31da6a785b4cbaa816e18a8cd23aa3",
        hd720: "0001-720p-b4472975549c4a0b9a3e0d1eba144ec5",
        sd540: "0001-540p-7632868f031e41d885b7aaad3eb8e92d"
      ),
      vimeoId: 348_650_932
    ),
    id: 1,
    length: 1219,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_517_206_269),
    sequence: 1,
    title: "Functions",
    // NB: Same as full video
    trailerVideo: .init(
      bytesLength: 197_667_168,
      downloadUrls: .s3(
        hd1080: "0001-1080p-2b31da6a785b4cbaa816e18a8cd23aa3",
        hd720: "0001-720p-b4472975549c4a0b9a3e0d1eba144ec5",
        sd540: "0001-540p-7632868f031e41d885b7aaad3eb8e92d"
      ),
      vimeoId: 348_650_932
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 1)
  )
}
