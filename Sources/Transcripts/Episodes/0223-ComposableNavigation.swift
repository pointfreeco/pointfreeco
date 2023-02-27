import Foundation

extension Episode {
  public static let ep223_composableNavigation = Episode(
    blurb: """
      Let's dip our toes into the new composable navigation tools by improving how alerts and
      confirmation dialogs can used in the library. We will create a new reducer operator that more
      correctly handles the logic and hides unnecessary details.
      """,
    codeSampleDirectory: "0223-composable-navigation-pt2",
    exercises: _exercises,
    id: 223,
    length: .init(.timestamp(hours: 1, minutes: 2, seconds: 8)),
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-20")!,
    references: [
      Episode.Reference(
        author: "Brandon Williams & Stephen Celis",
        blurb: """
          Learn about “single entry point” systems, and why they are best suited for our
          [dependencies library](http://github.com/pointfreeco/swift-dependencies), although it is
          possible to use the library with non-single entry point systems.
          """,
        link:
          "https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/singleentrypointsystems",
        title: "Single entry point systems"
      ),
      .composableNavigationBetaDiscussion,
    ],
    sequence: 223,
    subtitle: "Alerts & Dialogs",
    title: "Composable Navigation",
    trailerVideo: .init(
      bytesLength: 90_600_000,
      downloadUrls: .s3(
        hd1080: "0223-trailer-1080p-7164ba22b9a34e56999420bda8e94e41",
        hd720: "0223-trailer-720p-386321530f5d4c55bcf5a2727ba41497",
        sd540: "0223-trailer-540p-772dd301a804428789094562001838e1"
      ),
      vimeoId: 797_895_435
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
