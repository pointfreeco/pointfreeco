import Foundation

extension Episode {
  public static let ep136_animations = Episode(
    alternateSlug: "swiftui-animation-the-basics",
    blurb: """
The Composable Architecture mostly "just works" with SwiftUI animations out of the box, except for one key situation: animations driven by asynchronous effects. To fix this we are led to a really surprising transformation of Combine schedulers.
""",
    codeSampleDirectory: "0136-swiftui-animation-pt2",
    exercises: _exercises,
    id: 136,
    image: "https://i.vimeocdn.com/video/1066642776-12f5cfb8abdbc0166d6da1caac420759b86100721a57d0a540955440683286e6-d?mw=2200&mh=1238&q=70",
    length: 44*60 + 38,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1613973600),
    references: [
      .isowords,
      .combineSchedulersSection,
      .combineSchedulers,
    ],
    sequence: 136,
    subtitle: "Composable Architecture",
    title: "SwiftUI Animation",
    trailerVideo: .init(
      bytesLength: 60558782,
      vimeoId: 514083267,
      vimeoSecret: "6e374c14961b4c8308d0219a18868e79d9302a8c"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
    If you tap "cycle colors" and then immediately tap "reset" any in-flight effects will still animate the circle's color. Add effect cancellation logic to the reducer so that the "reset" button cancels such in-flight effects.
    """#,
    solution: nil
  ),
  .init(
    problem: #"""
    Our application is simple in that most of the actions fed to the reducer mutate state simply. Reduce the number of explicitly-defined actions in `AppAction` to use the `BindingAction` form helper instead.
    """#,
    solution: nil
  ),
]
