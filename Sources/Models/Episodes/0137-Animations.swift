import Foundation

extension Episode {
  public static let ep137_animations = Episode(
    blurb: """
Animating asynchronous effects with Combine schedulers is not only important for the Composable Architecture. It can be incredibly useful for any SwiftUI application. We will explore this with a fresh SwiftUI project to see what problems they solve and how they can allow us to better embrace SwiftUI's APIs.
""",
    codeSampleDirectory: "0137-swiftui-animation-pt3",
    exercises: _exercises,
    id: 137,
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
      downloadUrls: .s3(
        hd1080: "0137-trailer-1080p-ee65691987974cd888657c084b1cca8b",
        hd720: "0137-trailer-720p-5ba396c1f5104ae7bb603c8f8ee274f7",
        sd540: "0137-trailer-540p-c9521c077ef1457d9976f9c2cf27f084"
      ),
      vimeoId: 516537386
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
