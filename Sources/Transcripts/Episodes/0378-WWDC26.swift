import Foundation

extension Episode {
  public static let ep378_wwdc26 = Episode(
    blurb: """
      WWDC26 brought us the brand new `@State` macro to succeed the property wrapper, which has \
      been in SwiftUI since day one, in a completely backwards compatible way, which is some feat! \
      But what's different about the macro, and how does it work? We'll pick apart the cryptic \
      macro expansions to see something quite simple at the core.
      """,
    codeSampleDirectory: "0378-wwdc26-pt9",
    exercises: _exercises,
    id: 378,
    length: 18 * 60 + 29,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-24")!,
    references: [
      Episode.Reference(
        blurb: """
          A technote that covers SwiftUI's backwards compatible migration from `@State` property \
          wrapper to macro.
          """,
        link: "https://developer.apple.com/documentation/technotes/tn3211-resolving-swiftui-source-incompatibilities-for-state-and-contentbuilder",
        publishedAt: yearMonthDayFormatter.date(from: "2026-06-08"),
        title: "TN3211: Resolving SwiftUI source incompatibilities for State and ContentBuilder"
      )
    ],
    sequence: 378,
    socialImage: nil,
    subtitle: "The @State Macro",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 55_800_000,
      downloadUrls: .s3(
        hd1080: "0378-trailer-1080p-ec7fe124df584259bfd97414b559604d",
        hd720: "0378-trailer-1080p-ec7fe124df584259bfd97414b559604d",
        sd540: "0378-trailer-1080p-ec7fe124df584259bfd97414b559604d"
      ),
      id: "68481eabdacc47225ffe03ee4d8f1dfa"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
