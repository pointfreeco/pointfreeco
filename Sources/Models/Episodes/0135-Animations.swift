import Foundation

extension Episode {
  public static let ep135_animations = Episode(
    blurb: """
One of the most impressive features of SwiftUI is its animation system. Let's explore the various flavors of animation, such as implicit versus explicit and synchronous versus asynchronous, to help prepare us for how animation works with the Composable Architecture.
""",
    codeSampleDirectory: "0135-swiftui-animation-pt1",
    exercises: _exercises,
    id: 135,
    image: "https://i.vimeocdn.com/video/1060835876.jpg",
    length: 39*60 + 13,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1613368800),
    references: [
      // TODO
    ],
    sequence: 135,
    subtitle: "The Basics",
    title: "SwiftUI Animation",
    trailerVideo: .init(
      bytesLength: 41008156,
      vimeoId: 511011576,
      vimeoSecret: "30b11860020f5fd9689f65af618220236b802772"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
    Our little app currently has some funny functionality: if we tap "cycle colors" and then tap "reset" before the color cycling is complete, any remaining colors will still animate. Let's fix this by upgrading the "reset" button logic to cancel any upcoming color cycle animations.
    """#,
    solution: nil
  ),
  .init(
    problem: #"""
    Rather than rely on `@State`, refactor our animation view to use a view model that conforms to `ObservableObject`.
    """#,
    solution: nil
  ),
]
