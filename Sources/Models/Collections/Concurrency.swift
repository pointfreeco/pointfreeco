extension Episode.Collection {
  public static let concurrency = Self(
    blurb: """
      Swift has many tools for concurrency, including threads, operation queues, dispatch queues, Combine and now first class tools built directly into the language. We start from the beginning to understand what the past tools excelled at and where they faultered in order to see why the new tools are so incredible.
      """,
    sections: [
      .init(
        blurb: """
          Swift has many tools for concurrency, including threads, operation queues, dispatch queues, Combine and now first class tools built directly into the language. We start from the beginning to understand what the past tools excelled at and where they faultered in order to see why the new tools are so incredible.
          """,
        coreLessons: [
          .init(episode: .ep190_concurrency),
          .init(episode: .ep191_concurrency),
        ],
        isFinished: false,
        related: [
          .init(
            blurb: """
              We briefly discussed Swift's new concurrency tools in a previous episode where we looked at how to use SwiftUI's `refreshable` API in a Composable Architecture application.
              """,
            content: .section(.wwdc, index: 0)
          )
        ],
        title: "Concurrency",
        whereToGoFromHere: nil
      )
    ],
    title: "Concurrency"
  )
}
