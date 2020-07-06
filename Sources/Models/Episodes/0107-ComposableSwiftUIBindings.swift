import Foundation

extension Episode {
  public static let ep107_composableSwiftUIBindings_pt1 = Episode(
    blurb: """
Bindings are one of the core units of SwiftUI data flow and allow disparate parts of an application communicate with each other, but are built in such a way that strongly favors structs over enums. We will show that this prevents us from properly modeling our domains and causes unnecessary complexity in the process.
""",
    codeSampleDirectory: "0107-composable-bindings-pt1",
    exercises: _exercises,
    id: 107,
    image: "https://i.vimeocdn.com/video/917725581.jpg",
    length: 31*60 + 57,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1594011600),
    references: [
      // TODO
    ],
    sequence: 107,
    subtitle: "The Problem",
    title: "Composable SwiftUI Bindings",
    trailerVideo: .init(
      bytesLength: 57765707,
      vimeoId: 434545566,
      vimeoSecret: "173b142f45b0038c8984961c38d46911e8b30b31"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
