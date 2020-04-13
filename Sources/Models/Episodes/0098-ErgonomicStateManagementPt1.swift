import Foundation

extension Episode {
  public static let ep98_ergonomicStateManagement_pt1 = Episode(
    blurb: """
The Composable Architecture is robust and solves all of the problems we set out to solve (and more), but we haven't given enough attention to ergonomics. We will enhance one of its core units to be a little friendlier to use and extend, which will bring us one step closing to being ready for production.
""",
    codeSampleDirectory: "ergonomic-state-management-pt1",
    exercises: _exercises,
    fullVideo: nil,
    id: 98,
    image: "https://i.vimeocdn.com/video/877567536.jpg",
    length: 27*60 + 45,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 97,
    publishedAt: Date(timeIntervalSince1970: 1586754000),
    references: [
      // TODO
    ],
    sequence: 98,
    subtitle: nil,
    title: "Ergonomic State Management: Part 1",
    trailerVideo: .init(
      bytesLength: 43_493_260, 
      downloadUrl: "https://player.vimeo.com/external/407009519.hd.mp4?s=e40eed7d59217cb481988ec844c810b10c24db24&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/407009519"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Now that the `Reducer` type is a proper struct we can provide specialized initializes for common use cases. For example, it often happens that a reducer doesn't need to do any side effects, and therefore it doesn't need to return anything and its environment could be `Void`. Create an initializer on `Reducer` for when `Environment == Void` that allows us to create a reducer without having to worry about side effects.
"""#,
    solution: #"""
```swift
extension Reducer where Environment == Void {
  init(_ reducer: (inout State, Action) -> Void) {
    self.reducer = {state, action, _ in
      reducer(&state, action)
      return []
    }
  }
}
```
"""#),

  .init(
    problem: #"""
Continuing the previous exercise, there is another form of reducer that some may like more than our current shape. Right now we have immediate access to the environment in the reducer, which means we _technically_ could invoke the effects right there in the reducer. We should never do that, but it's technically possible.

There is a slight alteration we can make to the reducer so that it is not handed an environment, but instead it will return a function that takes an environment and then returns effects. Create a static function on `Reducer` called `strict` that allows one to create reducers from that shape.
"""#,
    solution: #"""
```swift
extension Reducer {
  init(_ reducer: (inout State, Action) -> (Environment) -> Effect<Action>) {
    self.reducer = {state, action, enviroment in
      reducer(&state, action)(enviroment)
    }
  }
}
```
"""#)
]
