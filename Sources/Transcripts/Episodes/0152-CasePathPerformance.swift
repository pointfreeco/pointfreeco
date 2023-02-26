import Foundation

extension Episode {
  public static let ep152_casePathPerformance = Episode(
    blurb: """
      This week we improve the performance of another part of the Composable Architecture ecosystem: case paths! We will benchmark the reflection mechanism that powers case paths and speed things up with the help of a Swift runtime function.
      """,
    codeSampleDirectory: "0152-case-path-performance",
    exercises: _exercises,
    id: 152,
    length: 31 * 60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_625_461_200),
    references: [
      reference(
        forSection: .casePaths,
        additionalBlurb: #"""
          The series of episodes in which Case Paths were first theorized and introduced.
          """#,
        sectionUrl: "https://www.pointfree.co/collections/enums-and-structs/case-paths"
      ),
      .init(
        author: "Mike Ash",
        blurb: #"""
          A post on the official Swift Blog explaining how Swift's reflection APIs work, including calls to functions that live on the runtime metadata, like the enum tag code we use in this week's episode.
          """#,
        link: "https://swift.org/blog/how-mirror-works/",
        publishedAt: yearMonthDayFormatter.date(from: "2018-09-26"),
        title: "How Mirror Works"
      ),
      .init(
        author: "Jordan Rose",
        blurb: #"""
          A series of posts on the Swift runtime.
          """#,
        link: "https://belkadan.com/blog/tags/swift-runtime/",
        publishedAt: yearMonthDayFormatter.date(from: "2020-08-31"),
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
      downloadUrls: .s3(
        hd1080: "0152-trailer-1080p-9e275b75116749159bbbd9b881d5673d",
        hd720: "0152-trailer-720p-7fabf95afbe4452e8adcc3771eacc391",
        sd540: "0152-trailer-540p-88d07ebad06d423f902d3ba3355d80a3"
      ),
      vimeoId: 571_082_849
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
