import Foundation

extension Episode {
  public static let ep137_animations = Episode(
    blurb: """
Combine schedulers give us a natural way of animating the result of asynchronous effects in the Composable Architecture, but that doesn't mean we can't go deeper. We will use animated schedulers in a vanilla SwiftUI app to see what problems they solve.
""",
    codeSampleDirectory: "0137-swiftui-animation-pt3",
    exercises: _exercises,
    id: 137,
    image: "https://i.vimeocdn.com/video/TODO.jpg",
    length: 44*60 + 10,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1614578400),
    references: [
      .init(
        author: "Point-Free",
        blurb: "A word game by us, written in the Composable Architecture.",
        link: "https://www.isowords.xyz",
        publishedAt: nil,
        title: "isowords"
      ),
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
