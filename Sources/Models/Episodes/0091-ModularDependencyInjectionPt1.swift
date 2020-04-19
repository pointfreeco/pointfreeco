import Foundation

extension Episode {
  static let ep91_modularDependencyInjection_pt1 = Episode(
    blurb: """
While we love the "environment" approach to dependency injection, which we introduced many episodes ago, it doesn't feel quite right in the Composable Architecture and introduces a few problems in how we manage dependencies. Today we'll make a small tweak to the architecture in order to solve them!
""",
    codeSampleDirectory: "0091-modular-dependency-injection-pt1",
    exercises: _exercises,
    id: 91,
    image: "https://i.vimeocdn.com/video/856735090.jpg",
    length: 32*60 + 48,
    permission: .subscriberOnly,
    previousEpisodeInCollection: nil,
    publishedAt: Date(timeIntervalSince1970: 1581919200),
    references: [
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: #"This is the episode that first introduced our `Current` environment approach to dependency injection."#,
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      reference(
        forEpisode: .ep18_dependencyInjectionMadeComfortable,
        additionalBlurb: #""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep18-dependency-injection-made-comfortable"
      ),
      .howToControlTheWorld,
      reference(
        forEpisode: .ep76_effectfulStateManagement_synchronousEffects,
        additionalBlurb: #"This is the start of our series of episodes on "effectful" state management, in which we explore how to capture the idea of side effects directly in our composable architecture."#,
        episodeUrl: "https://www.pointfree.co/episodes/ep76-effectful-state-management-synchronous-effects"
      ),
      reference(
        forEpisode: .ep82_testableStateManagement_reducers,
        additionalBlurb: #"This is the start of our series of episodes on "testable" state management, in which we explore just how testable the Composable Architecture is, effects and all!"#,
        episodeUrl: "https://www.pointfree.co/episodes/ep82-testable-state-management-reducers"
      ),
      // todo: more?
    ],
    sequence: 91,
    title: "Dependency Injection Made Composable",
    trailerVideo: .init(
      bytesLength: 57_635_470,
      downloadUrl: "https://player.vimeo.com/external/391879146.hd.mp4?s=684f56c2b7031948253f28f3f85cbd3ea597dc7d&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/391879146"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Fix the PrimeTime application so that it works with the new reducer signature we developed in this episode.
"""#),
  
  Episode.Exercise(
    problem: #"""
What are the differences between the reducer we defined in the episode:

```swift
(inout Value, Action, Environment) -> [Effect<Action>]
```

And this alternative formulation, where `Environment` has been curried to _after_ `Value` and `Action`?

```swift
(inout Value, Action) -> (Environment) -> [Effect<Action>]
```

Update the `ComposableArchitecture` module to use this form of `Reducer`. What impact does it have on behavior and ergonomics?
"""#,
    solution: #"""
The architecture now looks like this:

```swift
public typealias Reducer<Value, Action, Environment> = (inout Value, Action) -> (Environment) -> [Effect<Action>]

public func combine<Value, Action, Environment>(
  _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
  return { value, action in
    let effects = reducers.map { $0(&value, action) }
    return { environment in effects.flatMap { $0(environment) } }
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>,
  environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
  return { globalValue, globalAction in
    guard let localAction = action.extract(from: globalAction) else { return { _ in [] } }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return { globalEnvironment in
      localEffects(environment(globalEnvironment)).map { localEffect in
        localEffect.map(action.embed)
          .eraseToEffect()
      }
    }
  }
}

public func logging<Value, Action, Environment>(
  _ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return { environment in
      [.fireAndForget {
        print("Action: \(action)")
        print("Value:")
        dump(newValue)
        print("---")
        }] + effects(environment)
    }
  }
}

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action, Any>
  private let environment: Any
  @Published public private(set) var value: Value
  private var viewCancellable: Cancellable?
  private var effectCancellables: Set<AnyCancellable> = []

  public init<Environment>(
    initialValue: Value,
    reducer: @escaping Reducer<Value, Action, Environment>,
    environment: Environment
  ) {
    self.reducer = { value, action in
      let effects = reducer(&value, action)
      return { environment in effects(environment as! Environment) }
    }
    self.value = initialValue
    self.environment = environment
  }

  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)(self.environment)
    effects.forEach { effect in
      var effectCancellable: AnyCancellable?
      var didComplete = false
      effectCancellable = effect.sink(
        receiveCompletion: { [weak self] _ in
          didComplete = true
          guard let effectCancellable = effectCancellable else { return }
          self?.effectCancellables.remove(effectCancellable)
      },
        receiveValue: self.send
      )
      if !didComplete, let effectCancellable = effectCancellable {
        self.effectCancellables.insert(effectCancellable)
      }
    }
  }

  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return { _ in [] }
    },
      environment: self.environment
    )
    localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}
```

By delaying the application of an environment to a reducer, we are given stricter guarantees that it can never be used to execute arbitrary side effects that mutate the reducer's value. And this is because `value` has in-out semantics, and a reducer _must_ mutate this `value` _before_ opening the trailing function that has an environment in scope. Overall this formulation of a reducer is a little stricter, but also a little less ergonomic, due to the increased nesting involved.
"""#
  ),

  Episode.Exercise(
    problem: #"""
Revert any work left over from the previous exercise.

Update the `logging` higher-order reducer to make the caller provide their own printing function instead of using `print` directly in the implementation. The API for this can allow the caller to get access to the printing function by plucking it out of the environment:

```swift
public func logging<Value, Action, Environment>(
  _ reducer: @escaping Reducer<Value, Action, Environment>,
  logger: @escaping (Environment) -> (String) -> Void
) -> Reducer<Value, Action, Environment>
```

Note that the Swift standard library has a second [`dump`](https://developer.apple.com/documentation/swift/1641218-dump) function that prints into a given stream/string rather than the console.
"""#,
    solution: #"""
```swift
public func logging<Value, Action, Environment>(
  _ reducer: @escaping Reducer<Value, Action, Environment>,
  logger: @escaping (Environment) -> (String) -> Void
) -> Reducer<Value, Action, Environment> {
  return { value, action, environment in
    let effects = reducer(&value, action, environment)
    let newValue = value
    return [.fireAndForget {
      let print = logger(environment)
      print("Action: \(action)")
      print("Value:")
      var dumpedValue = ""
      dump(newValue, to: &dumpedValue)
      print(dumpedValue)
      print("---")
      }] + effects
  }
}
```
"""#
  ),

  Episode.Exercise(
    problem: #"""
Erase the environment from the store _without_ resorting to a force cast. The simplest way to achieve this is to remove the `Any`s:

- Remove the `environment` property from the store so that it's not even possible to force cast it.
- Replace the `reducer` property with a `Reducer<Value, Action, Void>`
- Update the initializer, `send`, and `view` methods accordingly.
"""#,
    solution: #"""
The initializer has an `environment` at the ready, so all we need to do is capture it and pass it along while ignoring the environment inside.

```swift
public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action, Void>
  @Published public private(set) var value: Value
  private var viewCancellable: Cancellable?
  private var effectCancellables: Set<AnyCancellable> = []

  public init<Environment>(
    initialValue: Value,
    reducer: @escaping Reducer<Value, Action, Environment>,
    environment: Environment
  ) {
    self.reducer = { value, action, _ in
      reducer(&value, action, environment)
    }
    self.value = initialValue
  }

  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action, ())
    effects.forEach { effect in
      var effectCancellable: AnyCancellable?
      var didComplete = false
      effectCancellable = effect.sink(
        receiveCompletion: { [weak self] _ in
          didComplete = true
          guard let effectCancellable = effectCancellable else { return }
          self?.effectCancellables.remove(effectCancellable)
      },
        receiveValue: self.send
      )
      if !didComplete, let effectCancellable = effectCancellable {
        self.effectCancellables.insert(effectCancellable)
      }
    }
  }

  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction, _ in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
    },
      environment: ()
    )
    localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}
```
"""#
  ),

  Episode.Exercise(
    problem: #"""
We've seen that a reducer with a `Void` environment is equivalent to a reducer that takes no environment at all. Use this knowledge to further simplify the store by holding onto a function that looks like a reducer, but just doesn't have the 3rd enviroment argument.
"""#,
    solution: #"""
Instead of holding onto a `Reducer`, we can hold onto a simpler function signature:

```swift
public final class Store<Value, Action>: ObservableObject {
  private let reducer: (inout Value, Action) -> [Effect<Action>]
```

This simplifies the initializer where the private field is assigned:

```swift
self.reducer = { value, action in
  reducer(&value, action, environment)
}
```

And the `send` method, where this field is invoked:

```swift
let effects = self.reducer(&self.value, action)
```

The `view` method can still take a void environment.
"""#
  ),
  // todo: more?

]
