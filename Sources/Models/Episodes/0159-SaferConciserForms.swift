import Foundation

extension Episode {
  public static let ep159_saferConciserForms = Episode(
    blurb: #"""
We just made the Composable Architecture's concise binding helpers safer, but can we make them even more concise? We'll start with a suggestion that came from the community and employ even more Swift tricks, like dynamic member lookup, to get things even conciser than vanilla SwiftUI.
"""#,
    codeSampleDirectory: "0159-safer-conciser-forms-pt2",
    exercises: _exercises,
    id: 159,
    image: "https://i.vimeocdn.com/video/1228086486",
    length: 28*60 + 1,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1630904400),
    references: [
      Episode.Reference(
        author: "June Bash",
        blurb: #"""
June Bash first suggested using a protocol like `BindableAction` in this GitHub discussion.
"""#,
        link: "https://github.com/pointfreeco/swift-composable-architecture/discussions/370",
        publishedAt: referenceDateFormatter.date(from: "2021-02-01"),
        title: "Further reducing boilerplate with... a protocol...?"
      ),
      Episode.Reference(
        author: "Suyash Drijan",
        blurb: #"""
The Swift Evolution proposal that made it possible for enums to conform to protocols via their case initializers.
"""#,
        link: "https://github.com/apple/swift-evolution/blob/main/proposals/0280-enum-cases-as-protocol-witnesses.md",
        publishedAt: referenceDateFormatter.date(from: "2020-01-18"),
        title: "Enum cases as protocol witnesses"
      ),
    ],
    sequence: 159,
    subtitle: "Part 2",
    title: "Safer, Conciser Forms",
    trailerVideo: .init(
      bytesLength: 39848626,
      vimeoId: 592111084,
      vimeoSecret: "3ab0c5de7401c965db37eb5039e8e094f26f4a7b"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
