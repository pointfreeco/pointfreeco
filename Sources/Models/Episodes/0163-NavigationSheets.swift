import Foundation

extension Episode {
  public static let ep163_navigationSheets = Episode(
    blurb: """
SwiftUI comes with a lot of great tools for working with struct-based state, but sadly lacks a lot of tools for working with optionals and enums, which are perfect for modeling navigation. We will bridge the gap by defining helpers that allow us to effortlessly add deep-linking to our applications.
""",
    codeSampleDirectory: "0163-navigation-pt4",
    exercises: _exercises,
    id: 163,
    length: 31*60 + 51,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1633928400),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 163,
    subtitle: "Sheets & Popovers, Part 2",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 36419368,
      vimeoId: 617405838,
      vimeoSecret: "96aec1fadf7db5b90549bf8ea73f5a24d7f2b4b3"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
