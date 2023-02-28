import Foundation

extension Episode {
  static let ep10_aTaleOfTwoFlatMaps = Episode(
    blurb: """
      Swift 4.1 deprecated and renamed a particular overload of `flatMap`. What made this `flatMap` different from \
      the others? We'll explore this and how understanding that difference helps us explore generalizations of the \
      operation to other structures and derive new, useful code!
      """,
    codeSampleDirectory: "0010-a-tale-of-two-flat-maps",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 164_582_242,
      downloadUrls: .s3(
        hd1080: "0010-1080p-084db37c0b2342368f493b1c7d427c47",
        hd720: "0010-720p-e9a302614ab44c4ba7199874d0865d18",
        sd540: "0010-540p-90e398348bc442bb84d64cee7a4c1b4b"
      ),
      vimeoId: 354_238_926
    ),
    id: 10,
    length: 25 * 60 + 4,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_522_144_623),
    references: [.introduceSequenceCompactMap],
    sequence: 10,
    title: "A Tale of Two Flat‑Maps",
    trailerVideo: .init(
      bytesLength: 25_231_039,
      downloadUrls: .s3(
        hd1080: "0010-trailer-1080p-0f172d293f844d02a5faae0b934cdf04",
        hd720: "0010-trailer-720p-289dc308319540d78ebdc739a3085984",
        sd540: "0010-trailer-540p-4c1d7713c53e4ed7b2ca03c9e79d7527"
      ),
      vimeoId: 354_214_922
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 10)
  )
}
