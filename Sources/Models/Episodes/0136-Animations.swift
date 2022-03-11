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
      downloadUrls: .s3(
        hd1080: "0136-trailer-1080p-9b71c8199d974c509b93cf7bdf032e79",
        hd720: "0136-trailer-720p-8cc7ffba53bb4e20a5b6e19de0ce09af",
        sd540: "0136-trailer-540p-d1028f8fc2ab4ab1a1fc8187f5f2cbcf"
      ),
      vimeoId: 514083267
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
