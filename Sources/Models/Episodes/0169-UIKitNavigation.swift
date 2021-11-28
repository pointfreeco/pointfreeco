import Foundation

extension Episode {
  public static let ep169_uikitNavigation = Episode(
    blurb: """
What does all the work we've done with navigation in SwiftUI have to say about UIKit? Turns out a lot! Let's take the application we built over many episodes and rewrite the view layer from scratch in UIKit.
""",
    codeSampleDirectory: "0169-uikit-navigation",
    exercises: _exercises,
    id: 169,
    length: 45*60 + 46,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1638165600),
    references: [
      reference(
        forSection: .navigation,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/swiftui/navigation"
      ),
    ],
    sequence: 169,
    subtitle: "Part 1",
    title: "Navigation in UIKit",
    trailerVideo: .init(
      bytesLength: 62879609,
      vimeoId: 650444458,
      vimeoSecret: "edb900f80899019b59b49f046bcd66a3a8dd48bd"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
