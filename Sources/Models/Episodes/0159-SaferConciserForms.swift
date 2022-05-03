import Foundation

extension Episode {
  public static let ep159_saferConciserForms = Episode(
    blurb: #"""
      We just made the Composable Architecture's concise binding helpers safer, but can we make them even more concise? We'll start with a suggestion that came from the community and employ even more Swift tricks, like dynamic member lookup, to get things even conciser than vanilla SwiftUI.
      """#,
    codeSampleDirectory: "0159-safer-conciser-forms-pt2",
    exercises: _exercises,
    id: 159,
    length: 28 * 60 + 1,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_630_904_400),
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
        link:
          "https://github.com/apple/swift-evolution/blob/main/proposals/0280-enum-cases-as-protocol-witnesses.md",
        publishedAt: referenceDateFormatter.date(from: "2020-01-18"),
        title: "Enum cases as protocol witnesses"
      ),
    ],
    sequence: 159,
    subtitle: "Part 2",
    title: "Safer, Conciser Forms",
    trailerVideo: .init(
      bytesLength: 39_848_626,
      downloadUrls: .s3(
        hd1080: "0159-trailer-1080p-4d561c106c484a83ad3ef1ceb2c38c4d",
        hd720: "0159-trailer-720p-83eae9cfe4cf4c899385b27899376f2a",
        sd540: "0159-trailer-540p-f0d99961e9324c079df532023f1ab345"
      ),
      vimeoId: 592_111_084
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
