import Foundation

extension Episode {
  public static let ep156_searchable = Episode(
    blurb: """
Let's develop a new application from scratch to explore SwiftUI's new `.searchable` API. We'll use MapKit to search for points of interest, and we will control this complex dependency so that our application can be fully testable.
""",
    codeSampleDirectory: "0156-searchable-pt1",
    exercises: _exercises,
    id: 156,
    image: "TODO",
    length: 41*60 + 11,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1628485200),
    references: [
      Episode.Reference(
        author: "Harry Lane",
        blurb: #"""
A WWDC session exploring the `.searchable` view modifier.
"""#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10176/",
        publishedAt: referenceDateFormatter.date(from: "2021-06-09"),
        title: "Craft search experiences in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
Documentation for the `.searchable` view modifier.
"""#,
        link: "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`FocusState`"
      ),
    ],
    sequence: 156,
    subtitle: "Part 1",
    title: "Searchable SwiftUI",
    trailerVideo: .init(
      bytesLength: 31309457,
      vimeoId: 582736899,
      vimeoSecret: "01acec942ad2b2e4287a6dff558b694bd1138588"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
