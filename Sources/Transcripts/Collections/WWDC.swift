extension Episode.Collection {
  static let wwdc = Self(
    blurb: """
      Each year Apple holds their Worldwide Developer Conference (WWDC) where the next version of iOS, macOS and watchOS are announced as well as hundreds of new APIs. It can be daunting to follow everything, especially when documentation is sparse, so we like to highlight a few particularly interesting topics and dive deep into their details.
      """,
    sections: [
      .init(
        blurb: """
          This year Apple released a brand new concurrency model for Swift, which radically changes how one writes asynchronous code in Swift. We explore this topic in the context of SwiftUI's new `.refreshable` API, and we take a look at how to integrate `@FocusState` into the Composable Architecture, as well as the new `.searchable` API.
          """,
        coreLessons: [
          .init(episode: .ep153_asyncRefreshableSwiftUI),
          .init(episode: .ep154_asyncRefreshableTCA),
          .init(episode: .ep155_focusState),
          .init(episode: .ep156_searchable),
          .init(episode: .ep157_searchable),
        ],
        related: [],
        title: "WWDC: 2021",
        whereToGoFromHere: nil
      )
    ],
    title: "WWDC"
  )
}
