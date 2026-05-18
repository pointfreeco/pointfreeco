import Foundation

extension Episode {
  public static let ep366_isolation = Episode(
    blurb: """
      "Region-based isolation" expanded the definition of isolation beyond actors to something called "regions." Learn what a region is, how they work, and how they loosened the overly strict sendability rules of Swift 5.
      """,
    codeSampleDirectory: "0366-beyond-basics-isolation-pt12",
    exercises: _exercises,
    id: 366,
    length: 36 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-05-18")!,
    references: [
      .se0414_regionBasedIsolation,
    ],
    sequence: 366,
    socialImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/cd54a69d-355f-4427-7a72-dfdf282b7100/public",
    subtitle: "Regions",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 66_800_000,
      downloadUrls: .s3(
        hd1080: "0366-trailer-1080p-2e4bc6b250144c44af45db832152b3ae",
        hd720: "0366-trailer-1080p-2e4bc6b250144c44af45db832152b3ae",
        sd540: "0366-trailer-1080p-2e4bc6b250144c44af45db832152b3ae"
      ),
      id: "05ac299b0aa20de0a0ff0b6a37a7e6aa"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
