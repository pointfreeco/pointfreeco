import Foundation

extension Episode {
  public static let ep135_animations = Episode(
    blurb: """
One of the most impressive features of SwiftUI is its animation system. Let's explore the various flavors of animation, such as implicit versus explicit and synchronous versus asynchronous, to help prepare us for how animation works with the Composable Architecture.
""",
    codeSampleDirectory: "0135-swiftui-animation-pt1",
    exercises: _exercises,
    id: 135,
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
      downloadUrls: .s3(
        hd1080: "0135-trailer-1080p-281b73b60a7543e98c9deb69f6a99a2a",
        hd720: "0135-trailer-720p-8c83ca52487147e2a3e70f2b87a097cd",
        sd540: "0135-trailer-540p-b5f0d0e03aff438abb0a0a1ec9e16482"
      ),
      vimeoId: 511011576
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
