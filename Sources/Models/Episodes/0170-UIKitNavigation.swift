import Foundation

extension Episode {
  public static let ep170_uikitNavigation = Episode(
    blurb: """
We finish porting our SwiftUI application to UIKit by introducing a collection view. Along the way we will demonstrate how deep-linking works exactly as it did in SwiftUI, and we show the power of state driven navigation by seamlessly switching between the two view paradigms.
""",
    codeSampleDirectory: "0170-uikit-navigation-pt2",
    exercises: _exercises,
    id: 170,
    length: 49*60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1638770400),
    references: [
      reference(
        forSection: .navigation,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/swiftui/navigation"
      ),
    ],
    sequence: 170,
    subtitle: "Part 2",
    title: "UIKit Navigation",
    trailerVideo: .init(
      bytesLength: 19176941,
      downloadUrls: .s3(
        hd1080: "0170-trailer-1080p-84419b4f612a4efd80d36496da031130",
        hd720: "0170-trailer-720p-1c958842a31a46e493ec154ba258bd19",
        sd540: "0170-trailer-540p-cdaf709b1aeb4b99bb55f8b524cbd482"
      ),
      vimeoId: 651611406
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
