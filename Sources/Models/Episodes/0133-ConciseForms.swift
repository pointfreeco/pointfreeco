import Foundation

extension Episode {
  public static let ep133_conciseForms = Episode(
    blurb: """
The Composable Architecture makes it easy to layer complexity onto a form, but it just can't match the brevity of vanilla SwiftUI…or can it!? We will overcome a Swift language limitation using key paths and type erasure to finally say "bye!" to boilerplate.
""",
    codeSampleDirectory: "0133-concise-forms-pt3",
    exercises: _exercises,
    id: 133,
    image: "https://i.vimeocdn.com/video/1049138364.jpg",
    length: 58*60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1612159200),
    references: [
      reference(
        forEpisode: .ep106_combineSchedulers_erasingTime,
        additionalBlurb: """
We took a deep dive into type erasers when we explored Combine's `Scheduler` protocol, and showed that type erasure prevented generics from infecting every little type in our code.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep106-combine-schedulers-erasing-time"
      ),
      .init(
        author: "Point-Free",
        blurb: "A word game by us, written in the Composable Architecture.",
        link: "https://www.isowords.xyz",
        publishedAt: nil,
        title: "isowords"
      ),
      // TODO: Type erasure?
      // TODO: Existential types?
    ],
    sequence: 133,
    subtitle: "Bye Bye Boilerplate",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 73474769,
      vimeoId: 505234170,
      vimeoSecret: "f2e622af6d91593ef960ab1801c54d4cf35e12cf"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Loosen the `Hashable` constraint on `FormAction`'s erased `Value` generic to `Equatable` by implementing an `AnyEquatable` type eraser, such that `AnyEquatable(myEquatableValue)` should compile.
"""#,
    solution: #"""
We can implement `AnyEquatable` using erasure in a similar way to how we did with `FormAction`: by erasing the given value _and_ holding onto a function that captures the equatable conformance. Then, we can introduce a generic initializer that enforces things safely.

```swift
struct AnyEquatable: Equatable {
  let value: Any
  let valueIsEqualTo: (Any) -> Bool

  init<Value>(_ value: Value) where Value: Equatable {
    self.value = value
    self.valueIsEqualTo = { $0 as? Value == value }
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.valueIsEqualTo(rhs.value)
  }
}
```

Now we can update `FormAction` to be initialized with an `Equatable` constraint instead of a `Hashable` constraint by holding the value in an `AnyEquatable` instead of `AnyHashable`:

```swift
struct FormAction<Root>: Equatable {
  let keyPath: PartialKeyPath<Root>
  let value: AnyEquatable
  let setter: (inout Root) -> Void

  init<Value>(
    _ keyPath: WritableKeyPath<Root, Value>,
    _ value: Value
  ) where Value: Equatable {
    self.keyPath = keyPath
    self.value = AnyEquatable(value)
    self.setter = { $0[keyPath: keyPath] = value }
  }

  static func set<Value>(
    _ keyPath: WritableKeyPath<Root, Value>,
    _ value: Value
  ) -> Self where Value: Equatable {
    self.init(keyPath, value)
  }
  ...
}
```

This lets us update the view store binding helper, as well:

```swift
extension ViewStore {
  func binding<Value>(
    keyPath: WritableKeyPath<State, Value>,
    send action: @escaping (FormAction<State>) -> Action
  ) -> Binding<Value> where Value: Equatable {
    self.binding(
      get: { $0[keyPath: keyPath] },
      send: { action(.init(keyPath, $0)) }
    )
  }
}
```

Now we can even drop the `Hashable` constraing on `AlertState` and everything still compiles!
"""#
  ),
]
