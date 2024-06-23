import Foundation

extension Episode {
  public static let ep284_modernUIKit = Episode(
    blurb: """
      Now that we have a tool that brings the power of the Observation framework to UIKit, let's \
      put it through the paces. We will use it to build state-driven navigation tools that can \
      drive alerts, sheets, popovers, drill-downs, and more, and they will look a lot like \
      SwiftUI's navigation tools.
      """,
    codeSampleDirectory: "0284-modern-uikit-pt4",
    exercises: _exercises,
    id: 284,
    length: 37 * 60 + 50,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-06-24")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 284,
    subtitle: "Basics of Navigation",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 46_900_000,
      downloadUrls: .s3(
        hd1080: "0284-trailer-1080p-40b87705f43641b690ce269a9f0bd7c5",
        hd720: "0284-trailer-720p-0ad2dc3f8c4b4aa1b41b3854fabe8274",
        sd540: "0284-trailer-540p-9e9ac8b4e40641ef9deb87e8a5304c1a"
      ),
      vimeoId: 956_800_583
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
