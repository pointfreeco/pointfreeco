import Foundation

extension Episode {
  public static let ep368_isolation = Episode(
    blurb: """
      The `sending` keyword has special behavior when applied to closure arguments, as well as \
      `inout` arguments. We will employ our knowledge of "disconnected" and "task-isolated" \
      regions to get an understanding for how they work, why nested closures are problematic, and \
      how a throwback from our second episode can help us grapple with `inout sending`.
      """,
    codeSampleDirectory: "0368-beyond-basics-isolation-pt14",
    exercises: _exercises,
    id: 368,
    length: 22 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-01")!,
    references: [
      .se0430_sending,
    ],
    sequence: 368,
    socialImage: nil,
    subtitle: "Sending Closures",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 32_100_000,
      downloadUrls: .s3(
        hd1080: "0368-trailer-1080p-678ad02338974e20aaaf72a02d806906",
        hd720: "0368-trailer-1080p-678ad02338974e20aaaf72a02d806906",
        sd540: "0368-trailer-1080p-678ad02338974e20aaaf72a02d806906"
      ),
      id: "f7cfc64b394c8a3344e8fd37fec800a4"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
