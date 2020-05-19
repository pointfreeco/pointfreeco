import Foundation

extension Episode {
  public static let ep95_adaptiveStateManagement_pt2 = Episode(
    blurb: """
There's a potential performance problem lurking in the Composable Architecture, and it's time to finally solve it. But, in doing so, we will stumble upon a wonderful way to make the architecture adaptive to many more situations.
""",
    codeSampleDirectory: "0095-adaptive-state-management-pt2",
    exercises: _exercises,
    id: 95,
    image: "https://i.vimeocdn.com/video/867881736.jpg",
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
      downloadUrl: "https://player.vimeo.com/external/399723100.hd.mp4?s=e4fe717ad3522f4cd45899582c69bc98dac29670&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/399723100"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
  // TODO: Exercise for computed property state
]
