import Foundation

extension Episode {
  public static let ep152_casePathPerformance = Episode(
    blurb: """
This week we improve the performance of another part of the Composable Architecture ecosystem: case paths! We will benchmark the reflection mechanism that powers case paths and speed things up with the help of a Swift runtime function.
""",
    codeSampleDirectory: "0152-case-path-performance",
    exercises: _exercises,
    id: 152,
    image: "https://i.vimeocdn.com/video/1181160605",
    length: 31*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1625461200),
    references: [
      reference(
        forSection: .casePaths,
        additionalBlurb: #"""
The series of episodes in which Case Paths were first theorized and introduced.
"""#,
        sectionUrl: "https://www.pointfree.co/collections/enums-and-structs/case-paths"
      ),
      .init(
        author: "Jordan Rose",
        blurb: #"""
A series of posts on the Swift runtime.
"""#,
        link: "https://belkadan.com/blog/tags/swift-runtime/",
        publishedAt: referenceDateFormatter.date(from: "2020-08-31"),
        title: "The Swift Runtime"
      ),
      .init(
        author: "Alejandro Alonso",
        blurb: #"""
A complete reflection library for Swift.
"""#,
        link: "https://github.com/Azoy/Echo",
        publishedAt: nil,
        title: "Echo"
      ),
    ],
    sequence: 152,
    subtitle: "Case Paths",
    title: "Composable Architecture Performance",
    trailerVideo: .init(
      bytesLength: 39_003_300,
      vimeoId: 571082849,
      vimeoSecret: "82d10ada78766823ba7db0df44545d68e8cd1151"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
