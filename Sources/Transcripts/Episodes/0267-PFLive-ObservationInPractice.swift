import Foundation

extension Episode {
  public static let ep267_pfLive_observationInPractice = Episode(
    blurb: """
      To celebrate our 6th anniversary we had another livestream! We updated an app from the most
      recent Composable Architecture tour to the latest observation tools, showed how these tools
      can improve UIKit-based apps, showed off some recent enhancements to the `@Reducer` macro,
      gave a sneak peek of a _highly anticipated topic_, and answered your questions along the way.
      """,
    codeSampleDirectory: "0267-pflive-observation-in-practice",
    exercises: _exercises,
    format: .livestream,
    fullVideo: .init(
      bytesLength: 1_380_000_000,
      downloadUrls: .s3(
        hd1080: "0267-1080p-37fde85b3ad34d7f8fe688795f28a4d9",
        hd720: "0267-720p-3a57abad7e0342c19b94f2b525a200ea",
        sd540: "0267-540p-648b6325eaa14bbba1ed7b95a1a83fec"
      ),
      vimeoId: 912_461_576
    ),
    id: 267,
    length: 114 * 60 + 34,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-02-19")!,
    questions: [],
    references: [],
    sequence: 267,
    subtitle: "Observation in Practice",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 68_637_004,
      downloadUrls: .s3(
        hd1080: "0267-trailer-1080p-37fde85b3ad34d7f8fe688795f28a4d9",
        hd720: "0267-trailer-720p-3a57abad7e0342c19b94f2b525a200ea",
        sd540: "0267-trailer-540p-648b6325eaa14bbba1ed7b95a1a83fec"
      ),
      vimeoId: 914084508
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 267)
  )
}

private let _exercises: [Episode.Exercise] = []
