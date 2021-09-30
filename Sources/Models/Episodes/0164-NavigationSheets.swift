import Foundation

extension Episode {
  public static let ep164_navigationSheets = Episode(
    blurb: """
Now that we've built up the tools needed to bind application state to navigation, let's exercise them. We'll quickly add one more feature to our application, and we'll even write unit tests that assert against navigation and deep-linking.
""",
    codeSampleDirectory: "0164-navigation-pt5",
    exercises: _exercises,
    id: 164,
    length: 40*60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1634533200),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 164,
    subtitle: "Sheets and Popovers, Part 3",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 40885266,
      vimeoId: 617406005,
      vimeoSecret: "c817837a9cf5b41512131c550c0add0e3ca41c16"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
