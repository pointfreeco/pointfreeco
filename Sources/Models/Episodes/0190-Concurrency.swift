import Foundation

extension Episode {
  public static let ep190_concurrency = Episode(
    blurb: """
      To better understand Swift's concurrency tools, let's first look to the past, starting with threads. Threads are a tool most developers don't reach for these days, but are important to understand, and the way they solve problems reverberate even in today's tools.
      """,
    codeSampleDirectory: "0190-concurrency-pt1",
    exercises: _exercises,
    id: 190,
    length: 52 * 60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_653_282_000),
    references: [],
    sequence: 190,
    subtitle: "Threads",
    title: "Concurrency's Past",
    trailerVideo: .init(
      bytesLength: 131_000_000,
      downloadUrls: .s3(
        hd1080: "0190-trailer-1080p-f6766c38e52843ca9278b46279f6e1bc",
        hd720: "0190-trailer-720p-e1ad0d2b15214882bd1b591183c6f42f",
        sd540: "0190-trailer-540p-83d1c5e8743e47ceae1fbcf5bffbbea6"
      ),
      vimeoId: 712_223_584
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
