import Foundation

extension Episode {
  public static let ep103_ATourOfTheComposableArchitecture_pt4 = Episode(
    blurb: """
      We conclude our tour of the Composable Architecture by demonstrating how to test a complex effect. This gives us a chance to show off how the library can control time-based effects by using Combine schedulers.
      """,
    codeSampleDirectory: "0103-swift-composable-architecture-tour-pt4",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 337_105_933,
      downloadUrls: .s3(
        hd1080: "0103-1080p-372129e4183c48caa23ce58ba8901d29",
        hd720: "0103-720p-da7ae39f6c274874b828c90f83fada69",
        sd540: "0103-540p-b21b45e7bab34824bae03ede202bdb86"
      ),
      vimeoId: 416_347_703
    ),
    id: 103,
    length: 32 * 60 + 39,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_590_382_800),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 103,
    subtitle: "Part 4",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 21_727_020,
      downloadUrls: .s3(
        hd1080: "0103-trailer-1080p-24f063a7fc7e4f45a8b013b07465445f",
        hd720: "0103-trailer-720p-c658c583e0ee430a81b3a926ac37156f",
        sd540: "0103-trailer-540p-c350d81dbba947cc89a3471332ec2b1d"
      ),
      vimeoId: 416_533_236
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 103)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
