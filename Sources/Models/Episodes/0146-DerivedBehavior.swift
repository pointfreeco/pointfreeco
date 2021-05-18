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
    image: "https://i.vimeocdn.com/video/1139060977.jpg",
    length: 42*60 + 8,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1621227600),
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
      bytesLength: 72969840,
      vimeoId: 549279750,
      vimeoSecret: "e8793d4ed437a6335b2cf1b0f0df605b0e57792d"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
