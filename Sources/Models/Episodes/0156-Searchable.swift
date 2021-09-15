import Foundation

extension Episode {
  public static let ep156_searchable = Episode(
    blurb: """
Let's develop a new application from scratch to explore SwiftUI's new `.searchable` API. We'll use MapKit to search for points of interest, and we will control this complex dependency so that our application can be fully testable.
""",
    codeSampleDirectory: "0156-searchable-pt1",
    exercises: _exercises,
    id: 156,
    image: "https://i.vimeocdn.com/video/1209772277",
    length: 41*60 + 11,
    permission: .free,
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
      .init(
        author: "Sarun Wongpatcharapakorn",
        blurb: """
          A comprehensive article explaining the full `.searchable` API, including some things we did not cover in this episode, such as the `.dismissSearch` environment value and search completions.

          > SwiftUI finally got native search support in iOS 15. We can add search functionality to any navigation view with the new searchable modifier. Let's explore its capability and limitation.
          """,
        link: "https://sarunw.com/posts/searchable-in-swiftui/",
        publishedAt: referenceDateFormatter.date(from: "2021-07-07"),
        title: "Searchable modifier in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
Documentation for the `.searchable` view modifier.
"""#,
        link: "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`searchable(_:text:placement:suggestions:)`"
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
