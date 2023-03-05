import Foundation

extension Episode {
  static let ep66_swiftuiAndStateManagement_pt2 = Episode(
    blurb: """
      This week we finish up our moderately complex SwiftUI application by adding more screens, more state, and even sprinkle in a side effect so that we can finally ask: "what's the point!?"
      """,
    codeSampleDirectory: "0066-swiftui-and-state-management-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 199_193_552,
      downloadUrls: .s3(
        hd1080: "0066-1080p-4f54a06c01524cda80c75986d0ecb3d4",
        hd720: "0066-720p-513e7d37e7464d3d9c9ac20e2bee2198",
        sd540: "0066-540p-bfff070d308a44098fc4cffd1f31b600"
      ),
      vimeoId: 348_431_195
    ),
    id: 66,
    length: 24 * 60 + 26,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_563_775_200),
    references: [
      .swiftUiTutorials,
      .insideSwiftUIAboutState,
    ],
    sequence: 66,
    title: "SwiftUI and State Management: Part 2",
    trailerVideo: .init(
      bytesLength: 19_831_912,
      downloadUrls: .s3(
        hd1080: "0066-trailer-1080p-cbaae9ea43c84564bd161aa47d82984f",
        hd720: "0066-trailer-720p-99ae3677268f4b668afa5d73bed7ee7b",
        sd540: "0066-trailer-540p-446056df738747c7a808582554f85af9"
      ),
      vimeoId: 348_469_619
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 66)
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      SwiftUI provides another state management solution in the form of an [`@EnvironmentObject`](https://developer.apple.com/documentation/swiftui/environmentobject) property wrapper that, like `@ObjectBinding`, wraps a `BindableObject`, but rather than having to pass state via the view's initializer, you must instead inject the object using the `environmentObject` method on the root view (and on views that are presented modally or via presentation).

      Update the playground to use `@EnvironmentObject` instead of `@ObjectBinding`. What are some of the trade-offs between each strategy?
      """
  )
]
