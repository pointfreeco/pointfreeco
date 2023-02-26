import Foundation

extension Episode {
  public static let ep166_navigationLinks = Episode(
    blurb: """
      Let's explore "tag" and "selection"-based navigation links in SwiftUI. What are they for and how do they compare with the link and link helpers we've used so far? We will then take a step back to compare links with all of the other forms of navigation out there and propose a "Grand Unified Theory of Navigation."
      """,
    codeSampleDirectory: "0166-navigation-pt7",
    exercises: _exercises,
    id: 166,
    length: 37 * 60 + 56,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_635_742_800),
    references: [
      .swiftUINav,
      .demystifyingSwiftUI,
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
          """#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 166,
    subtitle: "Links, Part 2",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 27_828_052,
      downloadUrls: .s3(
        hd1080: "0166-trailer-1080p-1885ec6298794c61b13aaa5a651303b9",
        hd720: "0166-trailer-720p-6bb5b8842c9e4a3a9f6a3efe47055d51",
        sd540: "0166-trailer-540p-6bb5488328cd4b7bb339bc300be4de62"
      ),
      vimeoId: 640_691_264
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
