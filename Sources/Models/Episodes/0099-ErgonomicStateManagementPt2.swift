import Foundation

extension Episode {
  public static let ep99_ergonomicStateManagement_pt2 = Episode(
    blurb: """
We've made creating and enhancing reducers more ergonomic, but we still haven't given much attention to the ergonomics of the view layer of the Composable Architecture. This week we'll make the Store much nicer to use by taking advantage of a new Swift feature and by enhancing it with a SwiftUI helper.
""",
    codeSampleDirectory: "0099-ergonomic-state-management-pt2",
    exercises: _exercises,
    fullVideo: nil,
    id: 99,
    image: "https://i.vimeocdn.com/video/880871976.jpg",
    length: 24*60 + 3,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1587358800),
    references: [
      // TODO
    ],
    sequence: 99,
    subtitle: nil,
    title: "Ergonomic State Management: Part 2",
    trailerVideo: .init(
      bytesLength: 20290250,
      downloadUrl: "https://player.vimeo.com/external/409489458.hd.mp4?s=e02b22edc5afb66e2beb1187d0224fbb8ec07ccb&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/409489458"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Let's add a little more polish to the Composable Architecture. Right now there is no easy way of working with optional state. In particular, it is not possible to write a reducer on non-optional state and use `pullback` to transform it to a reducer that works on optional state.

Define a custom property on `Reducer` that transforms reducers on non-optional state to reducers on optional state.
"""#,
    solution: #"""
```swift
extension Reducer {
  public var optional: Reducer<Value?, Action, Environment> {
    .init { value, action, environment in
      guard value != nil else { return [] }
      return self(&value!, action, environment)
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
There is also no easy way of working with collections in state. In particular, it is not possible to write a reducer on an element of state and use `pullback` to transform it to a reducer that works on a collection of state.

Define an `indexed` method on `Reducer` that handles this kind of transformation such that the state's key path is of the form `WritableKeyPath<GlobalValue, [Value]>`. In order to send an action to a particular element of the array, it must identify the element in some way. Take inspiration from the method's name. 😁
"""#,
    solution: #"""
Given some global app state:

```swift
struct AppState {
  var list: [RowState]
}
```

In order to send actions to individual elements, you can identify them by index.

```swift
enum AppAction {
  case list(index: Int, action: RowAction)
}
```

Which means that `indexed` would take a case path from `AppAction` to `(Int, Action)`.

From this we can deduce the signature and define the following method:

```swift
extension Reducer {
  func indexed<GlobalValue, GlobalAction, GlobalEnvironment>(
    value: WritableKeyPath<GlobalValue, [Value]>,
    action: CasePath<GlobalAction, (Int, Action)>,
    environment: @escaping (GlobalEnvironment) -> Environment
  ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    .init { globalValue, globalAction, globalEnvironment in
      guard
        let (index, localAction) = action.extract(from: globalAction)
        else { return [] }
      return self(
        &globalValue[keyPath: value][index],
        localAction,
        environment(globalEnvironment)
      )
      .map { effect in
        effect
          .map { action.embed((index, $0)) }
          .eraseToEffect()
      }
    }
  }
}
```
"""#
  ),
]
