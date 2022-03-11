import Foundation

extension Episode {
  public static let ep116_redactions_pt2 = Episode(
    alternateSlug: "redacted-swiftui-the-composable-architecture",
    blurb: """
We've seen how cool redacted SwiftUI views are, but we've also seen some of their pitfalls: while it's easy to redact UI, it's not so easy to redact logic, that is unless you're using the Composable Architecture!
""",
    codeSampleDirectory: "0116-redacted-swiftui-pt2",
    exercises: _exercises,
    id: 116,
    length: 20*60 + 32,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1599454800),
    references: [
      .init(
        author: nil,
        blurb: #"""
          Apple's new API for redacting content in SwiftUI.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
        publishedAt: nil,
        title: "redacted(reason:)"
      ),
      .init(
        author: nil,
        blurb: #"""
          "Separation of Concerns" is a design pattern that is expressed often but is a very broad guideline, and not something that can be rigorously applied.
          """#,
        link: "https://en.wikipedia.org/wiki/Separation_of_concerns",
        publishedAt: nil,
        title: "Separation of Concerns"
      ),
    ],
    sequence: 116,
    subtitle: "The Composable Architecture",
    title: "Redacted SwiftUI",
    trailerVideo: .init(
      bytesLength: 52_765_930,
      downloadUrls: .s3(
        hd1080: "0116-trailer-1080p-e63e379df6e342048ad43bd49cbb72e6",
        hd720: "0116-trailer-720p-184d42fa3fe74d15aab6d4356e2028d8",
        sd540: "0116-trailer-540p-ea3ca3af36e644a6b9f91ff182969d9c"
      ),
      vimeoId: 454928021
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

