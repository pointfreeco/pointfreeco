import Foundation

extension Episode {
  public static let ep216_modernSwiftUI = Episode(
    blurb: """
      We add more screens and more navigation to our rewrite of Apple's Scrumdinger, including the standup detail view, a delete confirmation alert, and we set up parent-child communication between features.
      """,
    codeSampleDirectory: "0216-modern-swiftui-pt3",
    exercises: _exercises,
    id: 216,
    length: 42 * 60 + 33,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1670824800),
    references: [
      .scrumdinger,
      .swiftUINavigation,
      .xctestDynamicOverlay,
      .pointfreecoPackageCollection,
    ],
    sequence: 216,
    subtitle: "Navigation, Part 2",
    title: "Modern SwiftUI",
    trailerVideo: .init(
      bytesLength: 37_600_000,
      downloadUrls: .s3(
        hd1080: "0216-trailer-1080p-81a1ddea6f0d4d538f0a1a5c7a6a17c4",
        hd720: "0216-trailer-720p-82f813c87d1149caa7995e1b5af6243e",
        sd540: "0216-trailer-540p-d9b20c33dd8044febfdc85c334505166"
      ),
      vimeoId: 775910723
    )
  )
}

private let _exercises: [Episode.Exercise] = []
