import Foundation

extension Episode {
  public static let ep107_composableSwiftUIBindings_pt1 = Episode(
    blurb: """
Bindings are one of the core units of SwiftUI data flow and allow disparate parts of an application to communicate with one another, but they are built in such a way that strongly favors structs over enums. We will show that this prevents us from properly modeling our domains and causes unnecessary complexity in the process.
""",
    codeSampleDirectory: "0107-composable-bindings-pt1",
    exercises: _exercises,
    id: 107,
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
      downloadUrls: .s3(
        hd1080: "0107-trailer-1080p-8fa8f7d90445445f90179e117a0742f6",
        hd720: "0107-trailer-720p-ae99132b77fd433fa40d937ebf5f2f20",
        sd540: "0107-trailer-540p-3bd7111798374a3fa27da20afe5adccf"
      ),
      vimeoId: 434545566
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
