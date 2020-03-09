import Foundation

extension Episode {
  static let ep68_composableStateManagement_reducers = Episode(
    blurb: """
Now that we understand some of the fundamental problems that we will encounter when building a complex application, let's start solving some of them! We will begin by demonstrating a technique for describing the state and actions in your application, as well as a consistent way to apply mutations to your application's state.
""",
    codeSampleDirectory: "0068-composable-state-management-reducers",
    exercises: _exercises,
    id: 68,
    image: "https://i.vimeocdn.com/video/803546602.jpg",
    length: 41*60 + 42,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 67,
    publishedAt: .init(timeIntervalSince1970: 1564984800),
    references: [
      .reduceWithInout,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
      reference(
        forEpisode: .ep2_sideEffects,
        additionalBlurb: """
We first discussed the idea of equivalence between functions of the form `(A) -> A` and functions `(inout A) -> Void` in our episode on side effects. Since then we have used this equivalence many times in order to transform our code into an equivalent form while improving its performance.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep2-side-effects"
      )
    ],
    sequence: 68,
    subtitle: "Reducers",
    title: "Composable State Management",
    trailerVideo: .init(
      bytesLength: 59339942,
      downloadUrl: "https://player.vimeo.com/external/351832614.hd.mp4?s=58db5a30394acaedeba4843d76dca1d211fe7040&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/351832614"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
In this episode we remarked that there is an equivalence between functions of the form `(A) -> A` and functions `(inout A) -> Void`, which is something we covered in our episode on [side effects](/episodes/ep2-side-effects). Prove this to yourself by implementing the following two functions which demonstrate how to transform from one type of function to the other:

```
func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
  fatalError("Unimplemented")
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
  fatalError("Unimplemented")
}
```
""",
    solution: """
```
func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
  return { inoutA in
    let updatedA = f(inoutA)
    inoutA = updatedA
  }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
  return { a in
    var mutableA = a
    f(&mutableA)
    return mutableA
  }
}
```
"""
),
  .init(
    problem: """
Our `appReducer` is starting to get pretty big. Right now we are switching over an enum that has 5 cases, but for a much larger application you may have dozen or even hundreds of cases to consider. This clearly is not going to scale well.

It's possible to break up a reducer into smaller reducers by implementing the following function:

```
func combine<Value, Action>(
  _ first: @escaping (inout Value, Action) -> Void,
  _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
  fatalError("Unimplemented")
}
```

Implement this function.
""",
    solution: """
```
func combine<Value, Action>(
  _ first: @escaping (inout Value, Action) -> Void,
  _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
  return { value, action in
    first(&value, action)
    second(&value, action)
  }
}
```
"""),
  .init(
    problem: """
Generalize the function in the previous exercise by implementing the following variadic version:

```
func combine<Value, Action>(
  _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
  fatalError("Unimplemented")
}
```
""",
    solution: """
```
func combine<Value, Action>(
  _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
  return { value, action in
    reducers.forEach { reducer in
      reducer(&value, action)
    }
  }
}
```
"""),
  .init(
    problem: """
Break up the `appReducer` into 3 reducers: one for the counter view, one for the prime modal, and one for the favorites prime view. Reconstitute the `appReducer` by using the `combine` function on each of the 3 reducers you create.

What do you lose in breaking the reducer up?
""",
    solution: """
You can break `appReducer` down into the following more domain-specific reducers:

```
func counterReducer(value: inout AppState, action: AppAction) -> Void {
  switch action {
  case .counter(.decrTapped):
    state.count -= 1

  case .counter(.incrTapped):
    state.count += 1

  default:
    break
  }
}

func primeModalReducer(state: inout AppState, action: AppAction) -> Void {
  switch action {
  case .primeModal(.addFavoritePrime):
    state.favoritePrimes.append(state.count)
    state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

  case .primeModal(.removeFavoritePrime):
    state.favoritePrimes.removeAll(where: { $0 == state.count })
    state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

  default:
    break
  }
}

func favoritePrimesReducer(state: inout AppState, action: AppAction) -> Void {
  switch action {
  case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
    for index in indexSet {
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
      state.favoritePrimes.remove(at: index)
    }

  default:
    break
  }
}
```

Unfortunately, we needed to add `default` cases to each switch statement.
"""),
  .init(
    problem: """
Although it is nice that the previous exercise allowed us to break up the `appReducer` into 3 smaller ones, each of those smaller reducers still operate on the entirety of `AppState`, even if they only want a small piece of sub-state.

Explore ways in which we can transform reducers that work on sub-state into reducers that work on global `AppState`. To get your feet wet, start by trying to implement the following function to lift a reducer on just the `count` field up to global state:

```
func transform(
  _ localReducer: @escaping (inout Int, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
  fatalError("Unimplemented")
}
```
""",
    solution: """
```
func transform(
  _ localReducer: @escaping (inout Int, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
  return { appState, appAction in
    localReducer(&appState.count, appAction)
  }
}
```
"""),
  .init(
    problem: """
Can you generalize the solution to the previous exercise to work for any generic `LocalValue` and `GlobalValue` instead of being specific to `Int` and `AppState`? And can you generalize the action to a single shared `Action` among global and local state?

Hint: this solution requires you to both extract a local value from a global one to send it through the reducer, and take the updated local value and set it on the global one. Swift provides an excellent way of handling this: writable key paths!
""",
    solution: """
```
func transform<GlobalValue, LocalValue, Action>(
  _ localReducer: @escaping (inout LocalValue, Action) -> Void,
  localValueKeyPath: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
  return { globalValue, action in
    localReducer(&globalValue[keyPath: localValueKeyPath], action)
  }
}
```
""")
]
