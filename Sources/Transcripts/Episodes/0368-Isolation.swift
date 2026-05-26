import Foundation

extension Episode {
  public static let ep368_isolation = Episode(
    blurb: """
      TODO
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
      id: "bd3ef5f0a12ca7f1a9c336ce6265b00b"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
