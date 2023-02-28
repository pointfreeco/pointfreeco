import Foundation

extension Episode {
  static let ep50_generativeArt_pt2 = Episode(
    blurb: """
      Let's put some finishing touches to our random artwork generator, incorporate it into an app, and write some snapshot tests to help support us in adding a fun easter egg.
      """,
    codeSampleDirectory: "0050-generative-art-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 290_467_801,
      downloadUrls: .s3(
        hd1080: "0050-1080p-d5623b3b27474bf585ae44c347867146",
        hd720: "0050-720p-2328e10634a54c238367f0f8cef4448d",
        sd540: "0050-540p-ed835b5a5d2e44a695dede209a51720a"
      ),
      vimeoId: 348_480_337
    ),
    id: 50,
    length: 27 * 60 + 22,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_552_284_000),
    references: [
      .randomUnification,
      Episode.Reference(
        author: "Wikipedia contributors",
        blurb: """
          The artwork used as inspiration in this episode comes from the album cover from the band Joy Division.
          """,
        link: "https://en.wikipedia.org/wiki/Unknown_Pleasures#Artwork_and_packaging",
        publishedAt: yearMonthDayFormatter.date(from: "2019-01-02"),
        title: "Unknown Pleasures – Artwork and packaging"
      ),
    ],
    sequence: 50,
    title: "Generative Art: Part 2",
    trailerVideo: .init(
      bytesLength: 29_107_528,
      downloadUrls: .s3(
        hd1080: "0050-trailer-1080p-3d532435892e45649f5797b59b4d604e",
        hd720: "0050-trailer-720p-00d0cdcbf91c456b9fce2bd919851385",
        sd540: "0050-trailer-540p-ada6a16b2e2f4841800c1ea509f37c0d"
      ),
      vimeoId: 348_480_265
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 50)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
