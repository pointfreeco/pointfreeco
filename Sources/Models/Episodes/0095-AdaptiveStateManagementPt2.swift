import Foundation

extension Episode {
  public static let ep95_adaptiveStateManagement_pt2 = Episode(
    blurb: """
There's a potential performance problem lurking in the Composable Architecture, and it's time to finally solve it. But, in doing so, we will stumble upon a wonderful way to make the architecture adaptive to many more situations.
""",
    codeSampleDirectory: "0095-adaptive-state-management-pt2",
    exercises: _exercises,
    id: 95,
    length: 40*60 + 25,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1584939600),
    references: [
      // TODO
    ],
    sequence: 95,
    subtitle: nil,
    title: "Adaptive State Management: State",
    trailerVideo: .init(
      bytesLength: 42191494,
      vimeoId: 399723100,
      vimeoSecret: "e4fe717ad3522f4cd45899582c69bc98dac29670"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
  // TODO: Exercise for computed property state
]
