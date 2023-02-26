import Foundation
import Overture

extension Episode {
  public static let ep146_derivedBehavior = Episode(
    blurb: """
      The ability to break down applications into small domains that are understandable in isolation is a universal problem, and yet there is no default story for doing so in SwiftUI. We explore the problem space and a possible solution in vanilla SwiftUI before turning our attention to the Composable Architecture.
      """,
    codeSampleDirectory: "0146-derived-behavior-pt1",
    exercises: _exercises,
    fullVideo: nil,
    id: 146,
    length: 42 * 60 + 8,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_621_227_600),
    references: [
      update(.stateObjectAndObservableObjectInSwiftUI) {
        $0.blurb = """
          In this episode we only considered `@ObservedObject`, but there's also something called `@StateObject` that can be handy for giving some behavior responsibilities to a child domain. This article describes in detail how each of the objects work under the hood and when it's appropriate to use each one.
          """
      },
      .dataEssentialsInSwiftUI,
      .nestedObservableObjectsInSwiftUI,
      update(.childStores) {
        $0.blurb = """
          In the absence of Apple providing source code for the demo application used in [Data Essentials](https://developer.apple.com/videos/play/wwdc2020/10040/) many have wondered what Apple had in mind for the solution. This Twitter thread details some people's conjectures, including [Daniel Peter's](https://twitter.com/Oh_Its_Daniel) conjecture which is almost exactly the solution we came up with in this episode.
          """
      },
    ],
    sequence: 146,
    subtitle: "The Problem",
    title: "Derived Behavior",
    trailerVideo: .init(
      bytesLength: 72_969_840,
      downloadUrls: .s3(
        hd1080: "0146-trailer-1080p-b9ab3990934d4c39965d2a2e36b67343",
        hd720: "0146-trailer-720p-a469cfa620c04678b9231d5ebec78779",
        sd540: "0146-trailer-540p-5d258308ac7d47c1b79435a0bdc107c0"
      ),
      vimeoId: 549_279_750
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
