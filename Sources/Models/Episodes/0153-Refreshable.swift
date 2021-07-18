import Foundation

extension Episode {
  public static let ep153_asyncRefreshableSwiftUI = Episode(
    blurb: """
Let's take a look at the new refreshable API in SwiftUI. We will explore how to add it to a feature, how it depends on Swift's new async/await tools, and how to introduce cancellation.
""",
    codeSampleDirectory: "0153-refreshable-pt1",
    exercises: _exercises,
    id: 153,
    image: "TODO",
    length: 33*60 + 10,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1626670800),
    references: [
      Episode.Reference(
        author: "Matt Ricketson and Taylor Kelly",
        blurb: #"""
A WWDC session covering what's new in SwiftUI this year, including the `refreshable` API.
"""#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10018/",
        publishedAt: referenceDateFormatter.date(from: "2021-06-08"),
        title: "What's new in SwiftUI"
      ),
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
      bytesLength: 65947881,
      vimeoId: 575950723,
      vimeoSecret: "77d04b5f177876cc363905294b8cdc26a4f9fb1d"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
