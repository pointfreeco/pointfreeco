import Foundation

extension Episode {
  public static let ep162_navigationSheets = Episode(
    blurb: """
      It's time to look at a more advanced kind of navigation: modals. We will implement a new feature that will be driven by a sheet and can be deep-linked into. Along the way we'll introduce a helper to solve a domain modeling problem involving enum state.
      """,
    codeSampleDirectory: "0162-navigation-pt3",
    exercises: _exercises,
    id: 162,
    length: 43 * 60 + 32,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_633_323_600),
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
      bytesLength: 52_804_666,
      downloadUrls: .s3(
        hd1080: "0162-trailer-1080p-6a6fc223dc5b4362a28c9cb48c9805ee",
        hd720: "0162-trailer-720p-4b7f08f098404c83a4ceb33d26546887",
        sd540: "0162-trailer-540p-611e8147471f4857ae8388a997a5ccf0"
      ),
      vimeoId: 617_405_822
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
