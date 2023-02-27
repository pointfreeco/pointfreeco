import Foundation

extension Episode {
  public static let ep165_navigationLinks = Episode(
    blurb: """
      It's time to explore the most complex form of navigation in SwiftUI: links! We'll start with some simpler flavors of `NavigationLink` to see how they work, how they compare with other navigation APIs, and how they interact with the tools we've built in this series.
      """,
    codeSampleDirectory: "0165-navigation-pt6",
    exercises: _exercises,
    id: 165,
    length: 39 * 60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_635_138_000),
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
    sequence: 165,
    subtitle: "Links, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 83_182_826,
      downloadUrls: .s3(
        hd1080: "0165-trailer-1080p-e566441380244c78bf5d5afa4322e558",
        hd720: "0165-trailer-720p-a4911c0e2a034d95bcf2e4166d676e49",
        sd540: "0165-trailer-540p-6429d160562c4e71972426b7f56df0be"
      ),
      vimeoId: 638_459_060
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
