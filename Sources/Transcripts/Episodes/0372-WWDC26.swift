import Foundation

extension Episode {
  public static let ep372_wwdc26 = Episode(
    blurb: """
      We examine what's new in SwiftData through Apple's Trips sample code: this includes \
      sectioning, added `Codable` support, observing changes outside the view, and we also explore \
      a new feature from last year: inheritance. We dive deep into each topic to figure out what \
      exactly _is_ new, what are the gotchas, and prepare for another lesson on concisely modeled \
      domains.
      """,
    codeSampleDirectory: "0372-wwdc26-pt3",
    exercises: _exercises,
    id: 372,
    length: 54 * 60 + 23,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-13")!,
    references: [
      Episode.Reference(
        author: "Thomas Bartelmess",
        blurb: """
          > Discover the latest enhancements to SwiftData. We’ll show you how to persist custom and third-party types using `Codable`, and group fetched data into sections in your SwiftUI app. We’ll also explore how to observe data store changes anywhere else using `ResultsObserver` and `HistoryObserver`, giving you the flexibility to drive powerful state objects and react precisely to model updates.
          """,
        link: "https://developer.apple.com/videos/play/wwdc2026/278/",
        publishedAt: yearMonthDayFormatter.date(from: "2026-06-09")!,
        title: "WWDC26: What's new in SwiftData"
      )
    ],
    sequence: 372,
    socialImage: nil,
    subtitle: "SwiftData",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 49_900_000,
      downloadUrls: .s3(
        hd1080: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6",
        hd720: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6",
        sd540: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6"
      ),
      id: "d2618d2b8f8757101304bb2ea021d2fc"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
