import Foundation

extension Episode {
  public static let ep163_navigationSheets = Episode(
    blurb: """
      This week we’ll explore how to drive a sheet with optional state and how to facilitate communication between the sheet and the view presenting it. In the process we will discover a wonderful binding transformation for working with optionals.
      """,
    codeSampleDirectory: "0163-navigation-pt4",
    exercises: _exercises,
    id: 163,
    length: 31 * 60 + 51,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_633_928_400),
    references: [
      .swiftUINav,
      .init(
        author: "Brandon Williams and Stephen Celis",
        blurb: """
          We uncovered a crash in SwiftUI's Binding initializer that can fail, and filed a feedback
          with Apple. We suggest other duplicate our feedback so that this bug is fixed as soon
          as possible.
          """,
        link: "https://gist.github.com/stephencelis/3a232a1b718bab0ae1127ebd5fcf6f97",
        title: "Crash in Binding's failable initializer"
      ),
      .demystifyingSwiftUI,
      .se_0293,
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
      bytesLength: 36_419_368,
      downloadUrls: .s3(
        hd1080: "0163-trailer-1080p-c2a27c13d52544ddbd813ee1c5709320",
        hd720: "0163-trailer-720p-f0150f11844f43a8900d40ff37f1efbb",
        sd540: "0163-trailer-540p-d82fc125744f40b2af99bbae5619eb72"
      ),
      vimeoId: 617_405_838
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
