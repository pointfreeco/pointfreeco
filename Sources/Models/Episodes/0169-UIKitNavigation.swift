import Foundation

extension Episode {
  public static let ep169_uikitNavigation = Episode(
    blurb: """
What does all the work we've done with navigation in SwiftUI have to say about UIKit? Turns out a lot! Without making a single change to the view models we can rewrite the entire view layer in UIKit, and the application will work exactly as it did before, deep-linking and all!
""",
    codeSampleDirectory: "0169-uikit-navigation-pt1",
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
    title: "UIKit Navigation",
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
