import Foundation

extension Episode {
  public static let ep370_wwdc26 = Episode(
    blurb: """
      Point-Free does WWDC26! We take a look at some of the new features of the AppleOS 27 family of
      releases and how they relate to topics we cover on Point-Free, starting with a new alert API.
      This will give us a chance to talk about concisely modeled domains, and how we can take things
      even further with a little help from our SwiftNavigation package.
      """,
    codeSampleDirectory: "0370-wwdc26-pt1",
    exercises: _exercises,
    id: 370,
    length: 53 * 60 + 32,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-29")!,
    references: [
      Episode.Reference(
        author: "Julia Vashchenko & Steven Peterson",
        blurb: """
          > Explore the latest additions to SwiftUI and discover how they can improve your apps. 
          """,
        link: "https://developer.apple.com/videos/play/wwdc2026/269/",
        publishedAt: yearMonthDayFormatter.date(from: "2026-06-09")!,
        title: "WWDC26: What's new in SwiftUI"
      ),
      .swiftNavigation,
      .swiftCasePaths,
    ],
    sequence: 370,
    socialImage: nil,
    subtitle: "Alerts",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 65_000_000,
      downloadUrls: .s3(
        hd1080: "0370-trailer-1080p-8d7887e9eb25429abf660814a6597122",
        hd720: "0370-trailer-1080p-8d7887e9eb25429abf660814a6597122",
        sd540: "0370-trailer-1080p-8d7887e9eb25429abf660814a6597122"
      ),
      id: "8f9984f1c99edc9e05bc590633569e5a"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
