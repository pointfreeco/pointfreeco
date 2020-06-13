import Foundation

extension Episode {
  static let ep87_theCaseForCasePaths_pt1 = Episode(
    blurb: """
      You've heard of key paths, but…case paths!? Today we introduce the concept of "case paths," a tool that helps you generically pick apart an enum just like key paths allow you to do for structs. It's the tool you never knew you needed.
      """,
    codeSampleDirectory: "0087-the-case-for-case-paths-pt1",
    exercises: _exercises,
    id: 87,
    image: "https://i.vimeocdn.com/video/848203050.jpg",
    length: 28 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_579_500_000),
    references: [
      .structs🤝Enums,
      .makeYourOwnCodeFormatterInSwift,
      .swiftTipBindingsWithKvoAndKeyPaths,
      .introductionToOpticsLensesAndPrisms,
      .opticsByExample,
    ],
    sequence: 87,
    subtitle: "Introduction",
    title: "The Case for Case Paths",
    trailerVideo: .init(
      bytesLength: 48_631_704,
      downloadUrl:
        "https://player.vimeo.com/external/385885943.hd.mp4?s=420b92a57d842c272f3f3bce38621a58b66b11c7&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/385885943"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Define the "never" case path: for any type `A` there exists a unique case path `CasePath<A, Never>`.

      This operation is useful for when you don't want to focus on any part of the type.
      """#,
    solution: #"""
      This solution depends on the `absurd` function, which we explored way back in one of our episodes on [algebraic data types](https://www.pointfree.co/episodes/ep9-algebraic-data-types-exponents). It can be defined as the following:

      ```swift
      func absurd<A>(_ never: Never) -> A {}
      ```

      With it in hand, we can pass it to the `embed` part of the case path, whereas `extract` expects us to return an optional `Never`. Values of `Never` are impossible to construct, so we're left with no other choice but to return `nil`.

      ```swift
      extension CasePath where Value == Never {
        static var never: CasePath {
          CasePath(
            extract: { _ in nil },
            embed: absurd
          )
        }
      }
      ```
      """#
  ),
  .init(
    problem: #"""
      Define the "void" key path: for any type `A` there is a unique key path `_WritableKeyPath<A, Void>`.

      This operation is useful for when you do not want to focus on any part of the type.

      Define this operation from scratch on the `_WritableKeyPath` type:

      ```swift
      struct _WritableKeyPath<Root, Value> {
        let get: (Root) -> Value
        let set: (inout Root, Value) -> Void
      }
      ```

      Is it possible to define this key path on Swift's `WritableKeyPath`?
      """#,
    solution: #"""
      ```swift
      extension _WritableKeyPath where Value == Void {
        static var void: _WritableKeyPath {
          _WritableKeyPath(
            get: { _ in () },
            set: { _, _ in }
          )
        }
      }
      ```

      It is possible to define a "void" key path on a specific type or protocol by defining a "void" property:

      ```swift
      protocol Voidable {}

      extension Voidable {
        var void: Void {
          get { () }
          set {}
        }
      }

      struct Foo: Voidable {}

      \Foo.void // WritableKeyPath<Foo, Void>
      ```

      But it is not currently possible to define a general void key path because key paths are not transformable, and `Any` is not extensible.
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Key paths are equipped with an operation that allows you to append them. For example:

      ```swift
      struct Location {
        var name: String
      }
      struct User {
        var location: Location
      }

      (\User.location).appending(path: \Location.name)
      // WritableKeyPath<User, String>
      ```

      Define `appending(path:)` from scratch on `_WritableKeyPath`.
      """#,
    solution: #"""
      ```swift
      extension _WritableKeyPath {
        func appending<AppendedValue>(path: _WritableKeyPath<Value, AppendedValue>) -> _WritableKeyPath<Root, AppendedValue> {
          return _WritableKeyPath<Root, AppendedValue>(
            get: { root in path.get(self.get(root)) },
            set: { root, appendedValue in
              var value = self.get(root)
              path.set(&value, appendedValue)
              self.set(&root, value)
          })
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Define an `appending(path:)` method on `CasePath`, which allows you to combine a `CasePath<A, B>` and a `CasePath<B, C>`, into a `CasePath<A, C>`.
      """#,
    solution: #"""
      ```swift
      extension CasePath {
        func appending<AppendedValue>(
          path: CasePath<Value, AppendedValue>
        ) -> CasePath<Root, AppendedValue> {
          CasePath<Root, AppendedValue>(
            extract: { root in
              self.extract(root).flatMap(path.extract)
          },
            embed: { appendedValue in
              self.embed(path.embed(appendedValue))
          })
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Every type in Swift automatically comes with a special key path known as the "identity" key path. One gets access to it with the following syntax:

      ```swift
      \User.self
      \Int.self
      \String.self
      ```

      Define this operation for `_WritableKeyPath`.
      """#,
    solution: #"""
      ```swift
      extension _WritableKeyPath where Root == Value {
        static var `self`: _WritableKeyPath {
          _WritableKeyPath(
            get: { $0 },
            set: { root, value in root = value }
          )
        }
      }
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      Define the "self" case path: for any type `A` there is a case path `CasePath<A, A>`.

      This case path is useful for when you want to focus on the whole type.
      """#,
    solution: #"""
      ```swift
      extension CasePath where Root == Value {
        static var `self`: CasePath {
          CasePath(
            extract: { .some($0) },
            embed: { $0 }
          )
        }
      }
      ```
      """#
  ),
  .init(
    problem: #"""
      Implement the "pair" key path: for any types `A`, `B`, and `C` one can combine two key paths `_WritableKeyPath<A, B>` and `_WritableKeyPath<A, C>` into a third key path `_WritableKeyPath<A, (B, C)>`.

      This operation allows you to easily focus on two properties of a struct at once.

      Note that this is not possible to do with Swift's `WritableKeyPath` because they are not directly constructible by us, only by the compiler.
      """#,
    solution: #"""
      ```swift
      func pair<A, B, C>(
        _ lhs: _WritableKeyPath<A, B>,
        _ rhs: _WritableKeyPath<A, C>
      ) -> _WritableKeyPath<A, (B, C)> {
        _WritableKeyPath(
          get: { a in (lhs.get(a), rhs.get(a)) },
          set: { a, bc in
            lhs.set(a, bc.0)
            rhs.set(a, bc.1)
        })
      }
      ```
      """#
  ),
  .init(
    problem: #"""
      Implement the "either" case path: for any types `A`, `B` and `C` one can combine two case paths `CasePath<A, B>`, `CasePath<A, C>` into a third case path `CasePath<A, Either<B, C>>`, where:

      ```swift
      enum Either<A, B> {
        case left(A)
        case right(B)
      }
      ```

      This operation allows you to easily focus on two cases of an enum at once.
      """#,
    solution: #"""
      ```swift
      func either<A, B, C>(
        _ lhs: CasePath<A, B>,
        _ rhs: CasePath<A, C>
      ) -> CasePath<A, (B, C)> {
        CasePath<A, Either<B, C>>(
          extract: { a in
            lhs.extract(a).map(Either.left)
              ?? rhs.extract(a).map(Either.right)
          },
          embed: { bOrC in
            switch bOrC {
            case let .left(b):  lhs.embed(b)
            case let .right(c): rhs.embed(c)
            }
          })
      }
      ```
      """#
  ),
]
