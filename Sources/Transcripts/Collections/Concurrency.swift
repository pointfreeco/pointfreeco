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
          .init(episode: .ep192_concurrency),
          .init(episode: .ep193_concurrency),
          .init(episode: .ep194_concurrency),
        ],
        related: [
          .init(
            blurb: """
              We briefly discussed Swift's new concurrency tools in a previous episode where we looked at how to use SwiftUI's `refreshable` API in a Composable Architecture application.
              """,
            content: .section(.wwdc, index: 0)
          )
        ],
        title: "Threads, queues and tasks",
        whereToGoFromHere: """
          Now that we understand the basics of Swift's native concurrency tools, let's dive into
          a more advanced topic: time-based asynchrony.
          """
      ),
      .init(
        blurb: """
          The `Clock` protocol is the fundamental unit for expressing time-based asynchrony in
          Swift. It serves a similar purpose to Combine's `Scheduler` protocol, but is simpler
          and more powerful. Understanding this protocol and creating your own conformances can
          allow you to take control over time in your applications, rather than letting it control
          you.
          """,
        coreLessons: [
          .init(episode: .ep209_clocks),
          .init(episode: .ep210_clocks),
        ],
        related: [
          .init(
            blurb: """
              We previously covered Combine schedulers in depth, including how to erase their
              types for tests and how to build clocks that allow us to control how time flows
              through our features' code.
              """,
            content: .section(.combine, index: 1)
          )
        ],
        title: "Clocks",
        whereToGoFromHere: """
          We now know a lot about concurrency and time-based asynchrony in Swift, but what does
          it takes to test any of the code we written? Well, sadly it's a lot harder than we
          think it should be.
          """
      ),
      .init(
        blurb: """
          Tests are an important tool to exercise the various subtleties and edge cases of your
          code, and doubly so for async code which tends to have a lot more complexity. Swift
          provides some basic tools for testing async code, but unfortunately they fall short for
          more real world code, and so it is on us to create all new tools.
          """,
        coreLessons: [
          .init(episode: .ep238_reliablyTestingAsync),
          .init(episode: .ep239_reliablyTestingAsync),
          .init(episode: .ep240_reliablyTestingAsync),
          .init(episode: .ep241_reliablyTestingAsync),
        ],
        isFinished: false,
        related: [],
        title: "Testing async code",
        whereToGoFromHere: nil
      ),
    ],
    title: "Concurrency"
  )
}
