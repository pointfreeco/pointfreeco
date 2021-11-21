import Foundation

extension Episode {
  public static let ep162_navigationSheets = Episode(
    blurb: """
It's time to look at a more advanced kind of navigation: modals. We will implement a new feature that will be driven by a sheet and can be deep-linked into. Along the way we'll introduce a helper to solve a domain modeling problem involving enum state.
""",
    codeSampleDirectory: "0162-navigation-pt3",
    exercises: _exercises,
    id: 162,
    length: 43*60 + 32,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1633323600),
    references: [
      .swiftUINav,
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
      .demystifyingSwiftUI,
      .stateObjectAndObservableObjectInSwiftUI,
    ],
    sequence: 162,
    subtitle: "Sheets & Popovers, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 52804666,
      vimeoId: 617405822,
      vimeoSecret: "c7053b4d4f6232ff3d302928a1f6e4310259e0af"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
