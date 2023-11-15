import Foundation

extension Episode {
  public static let ep258_macroCasePaths = Episode(
    blurb: """
      We have now totally reimagined the design of our case paths library to create actual key paths
      for enum cases, but there is some boilerplate involved. Let’s create a macro that eliminates
      all of it and explore a few of the possibilities it unlocks.
      """,
    codeSampleDirectory: "0258-macro-case-paths-pt2",
    exercises: _exercises,
    id: 258,
    length: 55 * 60 + 17,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-20")!,
    references: [
      // TODO
    ],
    sequence: 258,
    subtitle: "Part 2",
    title: "Macro Case Paths",
    trailerVideo: .init(
      bytesLength: 50_500_000,
      downloadUrls: .s3(
        hd1080: "0258-trailer-1080p-f44f825f34bc4fdb8f4f5328b41fd5b1",
        hd720: "0258-trailer-720p-7e37bd0771bb4b3d91cefe506d101656",
        sd540: "0258-trailer-540p-b121ecb9778e4f2db0ecdd389ee1ebee"
      ),
      vimeoId: 877_840_640
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
