import Foundation

extension Episode {
  public static let ep137_animations = Episode(
    blurb: """
Animating asynchronous effects with Combine schedulers is not only important for the Composable Architecture. It can be incredibly useful for any SwiftUI application. We will explore this with a fresh SwiftUI project to see what problems they solve and how they can allow us to better embrace SwiftUI's APIs.
""",
    codeSampleDirectory: "0137-swiftui-animation-pt3",
    exercises: _exercises,
    id: 137,
    image: "https://i.vimeocdn.com/video/1072702783.jpg",
    length: 44*60 + 10,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1614578400),
    references: [
      .isowords,
      .combineSchedulersSection,
      .combineSchedulers,
    ],
    sequence: 137,
    subtitle: "The Point",
    title: "SwiftUI Animation",
    trailerVideo: .init(
      bytesLength: 59535206,
      vimeoId: 516537386,
      vimeoSecret: "3bbebea3b8d772d3a4a78f62c13762a41de2d129"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
