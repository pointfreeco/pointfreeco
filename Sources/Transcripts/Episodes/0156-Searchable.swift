import Foundation

extension Episode {
  public static let ep156_searchable = Episode(
    blurb: """
      Let's develop a new application from scratch to explore SwiftUI's new `.searchable` API. We'll use MapKit to search for points of interest, and we will control this complex dependency so that our application can be fully testable.
      """,
    codeSampleDirectory: "0156-searchable-pt1",
    exercises: _exercises,
    id: 156,
    length: 41 * 60 + 11,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_628_485_200),
    references: [
      Episode.Reference(
        author: "Harry Lane",
        blurb: #"""
          A WWDC session exploring the `.searchable` view modifier.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10176/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-06-09"),
        title: "Craft search experiences in SwiftUI"
      ),
      .init(
        author: "Sarun Wongpatcharapakorn",
        blurb: """
          A comprehensive article explaining the full `.searchable` API, including some things we did not cover in this episode, such as the `.dismissSearch` environment value and search completions.

          > SwiftUI finally got native search support in iOS 15. We can add search functionality to any navigation view with the new searchable modifier. Let's explore its capability and limitation.
          """,
        link: "https://sarunw.com/posts/searchable-in-swiftui/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-07-07"),
        title: "Searchable modifier in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for the `.searchable` view modifier.
          """#,
        link:
          "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`searchable(_:text:placement:suggestions:)`"
      ),
    ],
    sequence: 156,
    subtitle: "Part 1",
    title: "Searchable SwiftUI",
    trailerVideo: .init(
      bytesLength: 31_309_457,
      downloadUrls: .s3(
        hd1080: "0156-trailer-1080p-836a72236461459ebf40f5b17bb3fef5",
        hd720: "0156-trailer-720p-373e109ac9324227b64e362d6c1a8159",
        sd540: "0156-trailer-540p-c8a285e9b8ab4c1f80ae2209074dfa21"
      ),
      vimeoId: 582_736_899
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 156)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

extension Episode.Video {
  public static let ep156_searchable = Self(
    bytesLength: 335_953_333,
    downloadUrls: .s3(
      hd1080: "0156-1080p-1c2b6ae09e1447d6afc08e5e37e4d66b",
      hd720: "0156-720p-64a722c881eb4630b347e1d92a5559ad",
      sd540: "0156-540p-4fa66c888ec64c41aca8d47657d7f0f2"
    ),
    vimeoId: 582_736_915
  )
}
