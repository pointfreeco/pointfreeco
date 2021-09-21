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
    image: "https://i.vimeocdn.com/video/952246161-0dfe953ea075aa8d3fc3b86ef9c1c6d7bcdd92f6e2425cd41ea0bc71676ac541-d",
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
      vimeoId: 454928021,
      vimeoSecret: "6265936d587d05bcad3bbb5838ddf148a4a0fa06"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

