extension Episode.Collection {
  static let wwdc = Self(
    blurb: """
      Each year Apple holds their Worldwide Developer Conference (WWDC) where the next version of iOS, macOS and watchOS are announced as well as hundreds of new APIs. It can be daunting to follow everything, especially when documentation is sparse, so we like to highlight a few particularly interesting topics and dive deep into their details.
      """,
    sections: [
      .init(
        blurb: """
          This year's WWDC 26 brought some much needed updates to SwiftUI and SwiftData, and we'd \
          like to dive deep into a few of these changes, especially as it pertains to some of the
          tools in the greater Point-Free ecosystem. In particular:
          
          * AppleOS 27 brings a new alert API to SwiftUI that improves domain modeling. This is \
          great, but also we have provided this kind of API in our [SwiftNavigation] for the past \
          5 years, and it even comes with additional binding transformation tools.
          * SwiftData has new features for handling `Codable` fields, sections, and tools for \
          observing queries outside of SwiftUI views. We'd like to compare these tools with our \
          SwiftData alternative, [SQLiteData].
          * And finally, `@State` was changed from a property wrapper to a macro, fixing a \
          long-standing quirk in the tool. We will discuss the change, and show how it can be \
          pushed even further to provide what we consider to be a crucial feature of the tool.
          
          [SwiftNavigation]: https://github.com/pointfreeco/swift-navigation
          [SQLiteData]: https://github.com/pointfreeco/sqlite-data
          """,
        coreLessons: [
          .init(episode: .ep370_wwdc26),
          .init(episode: .ep371_wwdc26),
          .init(episode: .ep372_wwdc26),
        ],
        isFinished: false,
        related: [],
        title: "WWDC: 2026",
        whereToGoFromHere: nil
      ),
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
      ),
    ],
    title: "WWDC"
  )
}
