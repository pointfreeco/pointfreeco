import Foundation

extension Episode {
  public static let ep213_navStacks = Episode(
    blurb: """
      When all-new SwiftUI navigation tools were announced at WWDC, the one that got the most attention by far was `NavigationStack`, which powers navigation with an array. It is extremely powerful, but comes with trade-offs and new complexities.
      """,
    codeSampleDirectory: "0213-navigation-stacks-pt3",
    exercises: _exercises,
    id: 213,
    length: 61 * 60 + 52,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_669_010_400),
    references: [
      .swiftUINav
    ],
    sequence: 213,
    subtitle: "Stacks",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 60_800_800,
      downloadUrls: .s3(
        hd1080: "0213-trailer-1080p-848d2cc0d543435d83250af50dd161ef",
        hd720: "0213-trailer-720p-89bd5e75065d40168971dd07c7409ae2",
        sd540: "0213-trailer-540p-644a884e53bf436d87a48ad965298804"
      ),
      vimeoId: 772_210_599
    )
  )
}

private let _exercises: [Episode.Exercise] = []
