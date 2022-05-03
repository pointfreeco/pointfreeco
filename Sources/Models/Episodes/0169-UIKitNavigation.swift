import Foundation

extension Episode {
  public static let ep169_uikitNavigation = Episode(
    blurb: """
      What does all the work we've done with navigation in SwiftUI have to say about UIKit? Turns out a lot! Without making a single change to the view models we can rewrite the entire view layer in UIKit, and the application will work exactly as it did before, deep-linking and all!
      """,
    codeSampleDirectory: "0169-uikit-navigation-pt1",
    exercises: _exercises,
    id: 169,
    length: 45 * 60 + 46,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_638_165_600),
    references: [
      reference(
        forSection: .navigation,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/swiftui/navigation"
      )
    ],
    sequence: 169,
    subtitle: "Part 1",
    title: "UIKit Navigation",
    trailerVideo: .init(
      bytesLength: 62_879_609,
      downloadUrls: .s3(
        hd1080: "0169-trailer-1080p-6b5cd5d7617f45f98e00c9f17d22d5e1",
        hd720: "0169-trailer-720p-14f4e6f94e5f4b6a8a5a8f3b5895420e",
        sd540: "0169-trailer-540p-77d9d84718f94550a918a866b09c9f69"
      ),
      vimeoId: 650_444_458
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
