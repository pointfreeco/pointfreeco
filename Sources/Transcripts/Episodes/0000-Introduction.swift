import Foundation

extension Episode {
  public static let ep0_introduction = Episode(
    blurb: """
      Point-Free is here, bringing you videos covering functional programming concepts using the Swift language. \
      Take a moment to hear from the hosts about what to expect from this new series.
      """,
    exercises: [],
    fullVideo: .init(
      bytesLength: 90_533_615,
      downloadUrls: .s3(
        hd1080: "0000-1080p-cccfbb7934ff42a8964d0e0393b72cf1",
        hd720: "0000-720p-0b46e32932784805a1b6b699413fe281",
        sd540: "0000-540p-c542d5fad5164174aeb83a97555d50ea"
      ),
      vimeoId: 354_215_017
    ),
    id: 0,
    length: 179,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_517_206_269),
    sequence: 0,
    title: "We launched!",
    // NB: Same as full video
    trailerVideo: .init(
      bytesLength: 90_533_615,
      downloadUrls: .s3(
        hd1080: "0000-1080p-cccfbb7934ff42a8964d0e0393b72cf1",
        hd720: "0000-720p-0b46e32932784805a1b6b699413fe281",
        sd540: "0000-540p-c542d5fad5164174aeb83a97555d50ea"
      ),
      vimeoId: 354_215_017
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 0)
  )
}
