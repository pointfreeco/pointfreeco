import Foundation

extension Episode {
  static let ep75_modularStateManagement_thePoint = Episode(
    blurb: """
We’ve now fully modularized our app by extracting its reducers and views into their own modules. Each screen of our app can be run as a little app on its own so that we can test its functionality, all without needing to know how it's plugged into the app as a whole. And _this_ is the point of modular state management!
""",
    codeSampleDirectory: "0075-modular-state-management-wtp",
    exercises: _exercises,
    id: 75,
    image: "https://i.vimeocdn.com/video/820093778.jpg",
    length: 19*60 + 59,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 74,
    publishedAt: .init(timeIntervalSince1970: 1570428000),
    references: [
      reference(
        forEpisode: .ep21_playgroundDrivenDevelopment,
        additionalBlurb: """
This week's episode took "playground-driven development" to the next level by showing that a fully modularized app allows each of its screens to be run in isolation like a mini-app on its own. Previously we talked about playground-driven development for quickly iterating on screen designs, and showed what is necessary to embrace this style of development.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep21-playground-driven-development"
      ),
      .playgroundDrivenDevelopmentFrenchKit,
      .playgroundDrivenDevelopmentAtKickstarter,
      .whyFunctionalProgrammingMatters,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 75,
    title: "Modular State Management: The Point",
    trailerVideo: .init(
      bytesLength: 54413353,
      downloadUrl: "https://player.vimeo.com/external/363166208.hd.mp4?s=47bf7363dd306a34c18c77b02a25cca90de6b02c&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/363166208"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: #"""
So far it has been very easy to tap into SwiftUI's button actions in order to send those actions to the store. However, not all SwiftUI actions are that easy. For instance, `TextField`s do not expose closures for us to implement that will be notified when text is changed in the field. Instead, they use `Binding<String>` values, which are 2-way bindings that allow you to simulataneously change the text field's value and observe text field changes.

This model unfortauntely does not fit our architecture since we prefer _all_ mutations of state go through our store and reducer. However, it's easy to fix! Implement the following function on `Store`, which allows you to construct a `Binding` by providing a way to construct an `Action` from the binding value and a way to extract a binding value from our store's value:

```swift
extension Store {
  public func send<LocalValue>(
    _ event: @escaping (LocalValue) -> Action,
    binding keyPath: KeyPath<Value, LocalValue>
  ) -> Binding<LocalValue> {
    fatalError("Unimplemented")
  }
}
```

We have decided to call this method `send` so that it mimics the standard `send` method on `Store`. This means that you can simply search for `store.send` in your application to find all places where user actions feed into the architecture.
"""#),
  Episode.Exercise(problem: #"""
Using the `send` implementation from the previous exercise, change the `Text` view that holds the counter into a `TextField`, which would allow the user to enter any number they want. To accomplish this you will need to introduce a new counter action `counterTextFieldChanged(String)` in order to be notified when the user types into the field.
"""#),
]
