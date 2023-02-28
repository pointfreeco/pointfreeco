import Foundation

extension Episode {
  static let ep2_sideEffects = Episode(
    blurb: """
      Side effects: can’t live with ’em; can’t write a program without ’em. Let’s explore a few kinds of side effects we encounter every day, why they make code difficult to reason about and test, and how we can control them without losing composition.
      """,
    codeSampleDirectory: "0002-side-effects",
    exercises: [],
    fullVideo: .init(
      bytesLength: 238_376_744,
      downloadUrls: .s3(
        hd1080: "0002-1080p-84525c69046640e7949c920fc41b91a3",
        hd720: "0002-720p-161f2904f8a24b33b21695df3555cfae",
        sd540: "0002-540p-22d75cd83c6d4aa58f80f50838800e1c"
      ),
      vimeoId: 355_115_445
    ),
    id: 2,
    length: 2676,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_517_811_069),
    sequence: 2,
    title: "Side Effects",
    trailerVideo: .init(
      bytesLength: 24_127_308,
      downloadUrls: .s3(
        hd1080: "0002-trailer-1080p-d9c32948496f4295b1f247a55cea3800",
        hd720: "0002-trailer-720p-4b6b318e6a45436b8f48548a14158111",
        sd540: "0002-trailer-540p-f26a263c7f454438a9561f864580318b"
      ),
      vimeoId: 354_214_906
    ),
    transcriptBlocks: []//loadTranscriptBlocks(forSequence: 2)
  )
}
