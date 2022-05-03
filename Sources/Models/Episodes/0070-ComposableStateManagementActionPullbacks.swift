import Foundation

extension Episode {
  static let ep70_composableStateManagement_actionPullbacks = Episode(
    blurb: """
      Turns out, reducers that work on local actions can be _pulled back_ to work on global actions. However, due to an imbalance in how Swift treats enums versus structs it takes a little work to implement. But never fear, a little help from our old friends "enum properties" will carry us a long way.
      """,
    codeSampleDirectory: "0070-composable-state-management-action-pullbacks",
    exercises: _exercises,
    id: 70,
    length: 28 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_566_194_400),
    references: [
      .pointFreePullbackAndContravariance,
      .categoryTheory,
      .composableReducers,
      reference(
        forEpisode: .ep51_structs🤝Enums,
        additionalBlurb: """
          To understand why it is so important for Swift to treat structs and enums fairly, look no further than our episode on the topic. In this episode we demonstrate how many features of one manifest themselves in the other naturally, yet there are still some ways in which Swift favors structs over enums.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep51-structs-enums"
      ),
      reference(
        forEpisode: .ep52_enumProperties,
        additionalBlurb: """
          The concept of "enum properties" were essential for our implementation of the "action pullback" operation on reducers. We first explored this concept in [episode #52](/episodes/ep52-enum-properties) and showed how this small amount of boilerplate can improve the ergonomics of data access in enums.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep52-enum-properties"
      ),
      reference(
        forEpisode: .ep55_swiftSyntaxCommandLineTool,
        additionalBlurb: """
          Although "enum properties" are powerful, it is a fair amount of boilerplate to maintain if you have lots of enums. Luckily we also were able to create a CLI tool that can automate the process! We use Apple's SwiftSyntax library to edit source code files directly to fill in these important properties.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep55-swift-syntax-command-line-tool"
      ),
      .pointfreecoEnumProperties,
      .elmHomepage,
      .reduxHomepage,
      .pullbackWikipedia,
      .someNewsAboutContramap,
    ],
    sequence: 70,
    subtitle: "Action Pullbacks",
    title: "Composable State Management",
    trailerVideo: .init(
      bytesLength: 33_400_000,
      downloadUrls: .s3(
        hd1080: "0070-trailer-1080p-a46f158c59c64b6b819479b685a3982d",
        hd720: "0070-trailer-720p-934214411ef246709cfa1d54f5c45887",
        sd540: "0070-trailer-540p-6c7f4be9e0994df9a687ca6d5b402391"
      ),
      vimeoId: 354_416_530
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      We've seen that it is possible to pullback reducers along action key paths, but could we have also gone the other direction? That is, can we define a `map` with key paths too? If this were possible, then we could implement the following signature:

      ```
      func map<Value, Action, OtherAction>(
        _ reducer: @escaping (inout Value, Action) -> Void,
        value: WritableKeyPath<Action, OtherAction>
      ) -> (inout Value, OtherAction) -> Void {
        fatalError("Unimplemented")
      }
      ```

      Can this function be implemented? If not, what goes wrong?
      """#,
    solution: #"""
      This function cannot be implemented. As we saw last time with value key paths, if we try to implement this function we quickly hit a roadblock:

      ```
      func map<Value, Action, OtherAction>(
        _ reducer: @escaping (inout Value, Action) -> Void,
        value: WritableKeyPath<Action, OtherAction>
      ) -> (inout Value, OtherAction) -> Void {
        return { value, otherAction in

        }
      }
      ```

      We have a local `OtherAction` that we can pluck out of a global `Action`, but the `reducer` we have requires a global `Action`, which we have no access to.
      """#),
  Episode.Exercise(
    problem: #"""
      Right now we have activity feed logic scattered throughout a few reducers, such as our `primeModalReducer` and `favoritePrimesReducer`. The mutations we perform for the activity feed are independent of the other logic going on in those reducers, which means it's ripe for extracting in some way.

      Explore how one can extract all of the activity feed logic out of our reducers by transforming our `appReducer` into a whole new reducer, and inside that transformation one would perform all of the activity feed logic. Such a transformation would have the following signature:

      ```
      func activityFeed(
        _ reducer: @escaping (inout AppState, AppAction) -> Void
      ) -> (inout AppState, AppAction) -> Void {
        fatalError("Unimplemented activity feed logic")
      }
      ```

      You would apply this function to the `appReducer` to obtain a whole new reducer that has the activity feed logic baked in, without needing to add anything to the reducers that make up `appReducer`.
      """#,
    solution: #"""
      ```
      func activityFeed(
        _ reducer: @escaping (inout AppState, AppAction) -> Void
      ) -> (inout AppState, AppAction) -> Void {

        return { state, action in
          switch action {
          case .counter:
            break

          case .primeModal(.removeFavoritePrimeTapped):
            value.activityFeed.append(
              .init(timestamp: Date(), type: .removedFavoritePrime(value.count))
            )

          case .primeModal(.addFavoritePrime):
            value.activityFeed.append(
              .init(timestamp: Date(), type: .saveFavoritePrimeTapped(value.count))
            )

          case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
              value.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(value.favoritePrimes[index]))
              )
            }
          }

          reducer(&state, action)
        }
      }

      activityFeed(appReducer)
      ```
      """#),
  Episode.Exercise(
    problem: #"""
      Explore ways of adding logging to our application. Perhaps the easiest is to add `print` statements to the `send` action of our `Store`. That would allow you to get logging for every single action sent to the store, and you can log the state that resulted from that mutation.

      However, there is a nicer way of adding logging to our application. Instead of putting it in the `Store`, where not _all_ users of the `Store` class may want logging, try implementing a transformation of reducer functions that automatically adds logging to any reducer.

      Such a function would have the following signature:

      ```
      func logging<Value, Action>(
        _ reducer: @escaping (inout Value, Action) -> Void
      ) -> (inout Value, Action) -> Void
      ```

      You would apply this function to the `appReducer` to obtain a whole new reducer that logs whenever an action is processed by the reducer.

      Are there any similarities to this transformation and the transformation from the previous exercise?
      """#,
    solution: #"""
      ```
      func logging(
        _ reducer: @escaping (inout AppState, AppAction) -> Void
      ) -> (inout AppState, AppAction) -> Void {
        return { value, action in
          reducer(&value, action)
          print("Action: \(action)")
          print("State:")
          dump(value)
          print("---")
        }
      }
      ```
      """#),
]
