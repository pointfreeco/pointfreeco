import Foundation

extension Episode {
  static let ep73_modularStateManagement_viewState = Episode(
    blurb: """
      While we've seen that each reducer we've written is super modular, and we were easily able to extract each one into a separate framework, our views are still far from modular. This week we address this by considering: what does it mean to transform the state a view has access to?
      """,
    codeSampleDirectory: "0073-modular-state-management-view-state",
    exercises: _exercises,
    id: 73,
    image: "https://i.vimeocdn.com/video/816196940.jpg",
    length: 28 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_569_218_400),
    references: [
      .manyFacesOfMap,
      .positiveNegativePosition,
      .whyFunctionalProgrammingMatters,
      .accessControl,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 73,
    subtitle: "View State",
    title: "Modular State Management",
    trailerVideo: .init(
      bytesLength: 22_600_192,
      downloadUrl:
        "https://player.vimeo.com/external/361282678.hd.mp4?s=d8e331e9071cb35f62c1da2c8b32f952c4393498&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/361282678"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Another way to isolate code is to move it to its own file and mark part of it `private` or `fileprivate`. How does this kind of modularization differ from using an actual Swift module?
      """),
  Episode.Exercise(
    problem: """
      In this episode we discussed how it was not appropriate to give the name `map` to the transformation we defined on `Store` due to the trickiness of reference types. Let's explore defining `map` on another type with reference semantics.

      Previously on Point-Free, we defined a `Lazy` type as a struct around a function that returns a value:

      ```swift
      struct Lazy<A> {
        let run: () -> A
      }
      ```

      Upgrade this struct to a class so that we can introduce memoization. A call to `run` should perform the given closure and cache the return value so that any repeat calls to `run` can immediately return this cached value. It should behave as follows:

      ``` swift
      import Foundation

      let slow = Lazy<Int> {
        sleep(1)
        return 1
      }
      slow.run() // Returns `1` after a second
      slow.run() // Returns `1` immediately
      ```

      From here, define `map` on `Lazy`:

      ```swift
      extension Lazy {
        func map<B>(_ f: @escaping (A) -> B) -> Lazy<B> {
          fatalError("Unimplemented")
        }
      }
      ```

      Given our discussion around `map` on the `Store` type, is it appropriate to call this function `map`?
      """),
  Episode.Exercise(
    problem: """
      Sometimes it can be useful to `view` into a store so that it removes all access to the underlying state of the store. For example, a "debug" screen for your app could have a UI for listing out every single action in your application as buttons, and tapping the button will send the action to the store. Such a screen doesn't need any access to the app state.

      Try building such a screen, and provide it `view` of the store that removes all access to the underlying app state.
      """),
  Episode.Exercise(
    problem: """
      Write a function that transforms a `Store<GlobalValue, GlobalAction>` into a `Store<GlobalValue, LocalAction>`. That is, a function of the following signature:

      ```swift
      extension Store {
        func view<LocalAction>(
          /* what arguments are needed? */
          ) -> Store<Value, LocalAction> {

          fatalError("Unimplemented")
        }
      }
      ```

      What kind of data does the function need to be supplied with in addition to a store? Is this kind of transformation familiar? Does it have a name we've used before on Point-Free?
      """),
]
