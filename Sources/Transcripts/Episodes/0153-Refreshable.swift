import Foundation

extension Episode {
  public static let ep153_asyncRefreshableSwiftUI = Episode(
    blurb: """
      Let's take a look at the new refreshable API in SwiftUI. We will explore how to add it to a feature, how it depends on Swift's new async/await tools, and how to introduce cancellation.
      """,
    codeSampleDirectory: "0153-refreshable-pt1",
    exercises: _exercises,
    id: 153,
    length: 33 * 60 + 10,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_626_670_800),
    references: [
      Episode.Reference(
        author: "Matt Ricketson and Taylor Kelly",
        blurb: #"""
          A WWDC session covering what's new in SwiftUI this year, including the `refreshable` API.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10018/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-06-08"),
        title: "What's new in SwiftUI"
      ),

      .pullToRefreshInSwiftUIWithRefreshable,

      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for `refreshable`.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/view/refreshable(action:)/",
        publishedAt: nil,
        title: "`refreshable(action:)`"
      ),
    ],
    sequence: 153,
    subtitle: "SwiftUI",
    title: "Async Refreshable",
    trailerVideo: .init(
      bytesLength: 65_947_881,
      downloadUrls: .s3(
        hd1080: "0153-trailer-1080p-394711ada66c4a85a70ea163df006daf",
        hd720: "0153-trailer-720p-98ced3efd3264897a471df054325908b",
        sd540: "0153-trailer-540p-947266c77d554d5f803d5b60c2f89e87"
      ),
      vimeoId: 575_950_723
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 153)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep153_asyncRefreshableSwiftUI = Self(
    bytesLength: 315_386_887,
    downloadUrls: .s3(
      hd1080: "0153-1080p-613f15e46b3646faa41f998990646e3b",
      hd720: "0153-720p-46fc507c0b8e40749d67c8f7dd238d9f",
      sd540: "0153-540p-49657509798e49c6b9f9084351ac9a5c"
    ),
    vimeoId: 575_950_740
  )
}
