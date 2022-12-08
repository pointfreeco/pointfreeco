import Foundation

extension Episode {
  public static let ep215_modernSwiftUI = Episode(
    blurb: """
      We begin to layer on behavior in our rewrite of Apple's "Scrumdinger" demo application, starting with navigation. We will do some upfront work to model it in our application state, as concisely as possible, to avoid a whole class of bugs, unlock deep linking, and enable testability.
      """,
    codeSampleDirectory: "0215-modern-swiftui-pt2",
    exercises: _exercises,
    id: 215,
    length: 34 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_670_220_000),
    references: [
      .scrumdinger,
      .swiftUINavigation,
      .swiftNonEmpty,
      .pointfreecoPackageCollection,
    ],
    sequence: 215,
    subtitle: "Navigation, Part 1",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 26_200_000,
      downloadUrls: .s3(
        hd1080: "0215-trailer-1080p-2c3fb0e7adc74c758817cd04867db4d0",
        hd720: "0215-trailer-720p-c11e68082fb74f03907832f025a33182",
        sd540: "0215-trailer-540p-06dd739cc055418793549368ddbae03f"
      ),
      vimeoId: 775_910_687
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Refactor `Standup.attendees` to be a `NonEmpty` collection using the [NonEmpty](https://github.com/pointfreeco/swift-nonempty) package.
      """#
  )
]
