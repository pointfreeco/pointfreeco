import Foundation

extension Episode {
  public static let ep164_navigationSheets = Episode(
    blurb: """
Now that we've built up the tools needed to bind application state to navigation, let's exercise them. We'll quickly add *two* more features to our application, beef up our navigation tools, and even write unit tests that assert against navigation and deep-linking.
""",
    codeSampleDirectory: "0164-navigation-pt5",
    exercises: _exercises,
    id: 164,
    length: 40*60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1634533200),
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
    sequence: 164,
    subtitle: "Sheets & Popovers, Part 3",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 40885266,
      downloadUrls: .s3(
        hd1080: "0164-trailer-1080p-7e8eaa9ad7e545439930a95e0d0c453b",
        hd720: "0164-trailer-720p-1048eee2f8854b6d9502ed52c681c1e7",
        sd540: "0164-trailer-540p-0f63b3b309e4457388d210e6f95d9c19"
      ),
      vimeoId: 617406005
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
