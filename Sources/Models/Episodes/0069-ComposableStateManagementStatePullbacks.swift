import Foundation

extension Episode {
  static let ep69_composableStateManagement_statePullbacks = Episode(
    blurb: """
So far we have pulled a lot of our application's logic into a reducer, but that reducer is starting to get big. Turns out that reducers emit many types of powerful compositions, and this week we explore two of them: combines and pullbacks.
""",
    codeSampleDirectory: "0069-composable-state-management-state-pullbacks",
    exercises: _exercises,
    id: 69,
    image: "https://i.vimeocdn.com/video/805102611.jpg",
    length: 25*60 + 42,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1565589600),
    references: [
      .pointFreePullbackAndContravariance,
      .pullbackWikipedia,
      .someNewsAboutContramap,
      .categoryTheory,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 69,
    subtitle: "State Pullbacks",
    title: "Composable State Management",
    trailerVideo: .init(
      bytesLength: 25_380_000,
      downloadUrl: "https://player.vimeo.com/external/353049110.hd.mp4?s=01f74c914424d5005780a54fb755092be8473a89&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/353049110"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: #"""
In this episode we mentioned that pullbacks along key paths satisfy a simple property: if you pull back along the identity key path you do not change the reducer, i.e. `reducer.pullback(\.self) == reducer`.

Pullbacks also satisfy a property with respect to composition, which is very similar to that of map: `map(f >>> g) == map(f) >>> map(g)`. Formulate what this property would be for pullbacks and key paths.
"""#),
  .init(problem: #"""
We had to create a struct, `FavoritePrimeState`, to hold just the data that the favorite primes screen needed, which was the activity feed and the array of favorite primes. Is it possible to instead use a typelias of a tuple with named fields instead of the struct? Does anything need to change to get the application compiling again? Do you like this approach over the struct?
"""#),
  .init(problem: #"""
By the end of this episode we showed how to make reducers work on local state by using the pullback operation. However, the reducers still operate on the full `AppAction` enum, even if it doesn't care about all of the cases in that enum. Try to repeat what we did in this episode for action enums, i.e. define a `pullback` operation that is capable of transforming reducers that work with local actions to ones that work on global actions.

For the state pullback we needed a key path to implement this function. What kind of information do you need to implement the action pullback?
"""#),
  .init(problem: #"""
By the end of this episode we showed how to make reducers work on local state by using the pullback operation. However, all of the views still take the full global store, `Store<AppState, AppAction>`, even if they only need a small part of the state. Explore how one might transform a `Store<GlobalValue, Action>` into a `Store<LocalValue, Action>`. Such an operation would help simplify views by allowing them to focus on only the data they care about.
"""#),
  .init(
    problem: #"""
We've seen that it is possible to pullback reducers along state key paths, but could we have also gone the other direction? That is, can we define a `map` with key paths too? If this were possible, then we could implement the following signature:

```
func map<Value, OtherValue, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void,
  value: WritableKeyPath<Value, OtherValue>
) -> (inout OtherValue, Action) -> Void {
  fatalError("Unimplemented")
}
```

Can this function be implemented? If not, what goes wrong?
"""#,
    solution: #"""
This function cannot be implemented. When we try to return a new reducer that works on `OtherValue` we hit a roadblock quickly:

```
func map<Value, OtherValue, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void,
  value: WritableKeyPath<Value, OtherValue>
) -> (inout OtherValue, Action) -> Void {
  return { otherValue, action in

  }
}
```

`OtherValue` is a local something that we can pluck out of more global `Value`, but we cannot create a more global `Value` from the local `OtherValue` we have access to, so we can never call the `reducer` that requires this global `Value`.
"""#),
  .init(
    problem: #"""
The previous exercise leads us to realize that there is something specific happening between the interplay of key paths and pullbacks when it comes to reducers. What do you think the underlying reason is that we can pullback reducers with key paths but we cannot map reducers with key paths?
"""#,
    solution: nil)
]
