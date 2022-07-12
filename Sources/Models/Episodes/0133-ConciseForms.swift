import Foundation

extension Episode {
  public static let ep133_conciseForms = Episode(
    blurb: """
      The Composable Architecture makes it easy to layer complexity onto a form, but it just can't match the brevity of vanilla SwiftUI…or can it!? We will overcome a Swift language limitation using key paths and type erasure to finally say "bye!" to boilerplate.
      """,
    codeSampleDirectory: "0133-concise-forms-pt3",
    exercises: _exercises,
    id: 133,
    length: 58 * 60 + 55,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_612_159_200),
    references: [
      reference(
        forEpisode: .ep106_combineSchedulers_erasingTime,
        additionalBlurb: """
          We took a deep dive into type erasers when we explored Combine's `Scheduler` protocol, and showed that type erasure prevented generics from infecting every little type in our code.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep106-combine-schedulers-erasing-time"
      ),
      .isowords,
      // TODO: Type erasure?
      // TODO: Existential types?
    ],
    sequence: 133,
    subtitle: "Bye Bye Boilerplate",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 73_474_769,
      downloadUrls: .s3(
        hd1080: "0133-trailer-1080p-87bb96830f4d4bb4977d04ca124c4a27",
        hd720: "0133-trailer-720p-6f99b9fa40434002b2ac2062751997ce",
        sd540: "0133-trailer-540p-7ff55c711fcd4b078a52e7d6cd96eb8d"
      ),
      vimeoId: 505_234_170
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
        …
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
  )
]
