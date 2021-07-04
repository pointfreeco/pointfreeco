import Foundation

extension Episode {
  public static let ep152_casePathPerformance = Episode(
    blurb: """
This week we improve the performance of another part of the Composable Architecture ecosystem: case paths! We will benchmark the reflection mechanism that powers case paths and speed things up with the help of a Swift runtime function.
""",
    codeSampleDirectory: "0152-case-path-performance",
    exercises: _exercises,
    id: 152,
    image: "TODO",
    length: 31*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1625461200),
    references: [
      reference(
        forSection: .casePaths,
        additionalBlurb: #"""
The series of episodes in which Case Paths were first theorized and introduced.
"""#",
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
    subtitle: "Case Path Reflection",
    title: "Composable Architecture Performance",
    trailerVideo: .init(
      bytesLength: 0, // TODO
      vimeoId: 0, // TODO
      vimeoSecret: "" // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
