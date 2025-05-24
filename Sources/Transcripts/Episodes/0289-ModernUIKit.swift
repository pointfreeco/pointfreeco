import Foundation

extension Episode {
  public static let ep289_modernUIKit = Episode(
    blurb: """
      While we rebuilt SwiftUI bindings in UIKit to power state-driven navigation, that's not all \
      SwiftUI uses them for! Let's see what it takes to power `UIControl`s from model bindings. \
      And finally, let's ask "what’s the point?” by comparing the tools we’ve built over many \
      episodes with the alternative.
      """,
    codeSampleDirectory: "0289-modern-uikit-pt9",
    exercises: _exercises,
    id: 289,
    length: 55 * 60 + 9,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-29")!,
    references: [
      Episode.Reference(
        author: "Chris Eidhof",
        blurb: """
          While SwiftUI provides a `Binding(get:set:)` initializer, there is a better way to \
          transform bindings, and that is with dynamic member lookup.
          """,
        link: "https://chris.eidhof.nl/post/swiftui-binding-tricks/",
        publishedAt: yearMonthDayFormatter.date(from: "2024-01-07"),
        title: "SwiftUI Binding Tips"
      ),
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 289,
    subtitle: "UIControl Bindings",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 65_600_000,
      downloadUrls: .s3(
        hd1080: "0289-trailer-1080p-b767aabcfc784119b5651c78c9681ff8",
        hd720: "0289-trailer-720p-3ad43e846a6741dab60e68df94dda29e",
        sd540: "0289-trailer-540p-6461e759cdcc46ffbe3b4554f45bccf4"
      ),
      id: "81271ac55660ce7705446ddbff49651f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
