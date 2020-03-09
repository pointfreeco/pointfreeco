import Foundation

extension Episode {
  static let ep88_theCaseForCasePaths_pt2 = Episode(
    blurb: """
We've now seen that it's possible to define "case paths": the enum equivalent of key paths. So what are their features? Let's explore a few properties of key paths to see if there are corresponding concepts on case paths.
""",
    codeSampleDirectory: "0088-the-case-for-case-paths-pt2",
    exercises: _exercises,
    id: 88,
    image: "https://i.vimeocdn.com/video/850265068.jpg",
    length: 24*60 + 55,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 87,
    publishedAt: Date(timeIntervalSince1970: 1580104800),
    references: [
      .structs🤝Enums,
      reference(
        forEpisode: .ep8_gettersAndKeyPaths,
        additionalBlurb: #"""
In this episode we first define the `^` operator to lift key paths to getter functions.
"""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep8-getters-and-key-paths"
      ),
      .se0249KeyPathExpressionsAsFunctions,
      .makeYourOwnCodeFormatterInSwift,
      .goshDarnIfCaseLetSyntax,
      .introductionToOpticsLensesAndPrisms,
      .opticsByExample,
    ],
    sequence: 88,
    subtitle: "Properties",
    title: "The Case for Case Paths",
    trailerVideo: .init(
      bytesLength: 18382159,
      downloadUrl: "https://player.vimeo.com/external/386554253.hd.mp4?s=1cc1944394c785d14a4c8e974a3ee7e90cfdcbee&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/386554253"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Case paths don't only need to focus on a single case of an enum. They can also focus on multiple cases of an enum, we just have to do a little bit of manual work first.

Consider the following enum:

```swift
enum AppAction {
  case activity(ActivityAction)
  case dashboard(DashboardAction)
  case profile(ProfileAction)
}

enum ActivityAction {}
enum DashboardAction {}
enum ProfileAction {}
```

Write a case path that can extract an `activity` or `profile` action from an app action, but not a `dashboard` action. Compare this to how one would write a computed property that focuses on two struct fields at the same time.
"""#,
    solution: #"""
To define a case path that can select several cases out of an enum, we need a type that can describe those cases. We can define it manually:

```swift
enum ActivityOrProfileAction {
  case activity(ActivityAction)
  case profile(ProfileAction
}
```

And then we can create a case path from `AppAction` to this new container.

```swift
extension CasePath
  where Root == AppAction,
  Value == ActivityOrProfile {

  static let activityOrProfile = CasePath(
    embed: {
      switch $0 {
      case let .activity(action): return .activity(action)
      case let .profile(action): return .profile(action)
      }
  },
    extract: {
      switch $0 {
      case let .activity(action): return .activity(action)
      case let .profile(action): return .profile(action)
      default: return nil
      }
  })
}
```

You could even use the `Either` type for this kind of thing!

``` swift
CasePath<AppAction, Either<ActivityAction, ProfileAction>>
```
"""#),
  .init(
    problem: #"""
Every computed property on a type (structs, enums and classes) is given a key path for free by the Swift compiler. For example:

```swift
struct State {
  var count: Int
  var favorites: [Int]

  var isFavorite: Bool {
    get { self.favorites.contains(self.count) }
    set {
      newValue
        ? self.favorites.removeAll(where: { $0 == self.count })
        : self.favorites.append(self.count)
    }
  }
}

\State.isFavorite // WritableKeyPath<State, Bool>
```

The `isFavorite` computed property is given a `WritableKeyPath`, even though it is not a stored field on the struct.

What is the equivalent concept for case paths? Theorize what a "computed case" syntax could look like in Swift.
"""#
  ),
  .init(
    problem: #"""
Although enums are a great source for case paths, it is not the only situation in which case paths can occur. At its core, case paths only express the idea of being able to try to extract some data from a value, and the ability to construct a value from that data.

Implement the following case paths. A natural place to hold these case paths is as static variables on `CasePath` with `Root` and `Value` suitably constrained.

  * `int: CasePath<String, Int>`
  * `uuid: CasePath<String, UUID>`
  * `literal: (String) -> CasePath<String, String>`:
    ```swift
    let blobCasePath = CasePath.literal("Blob")
    blob.extract("Blob")     // "Blob"
    blob.extract("Blob Jr.") // nil
    blob.embed("Blob Sr.")   // "Blob"
    ```
  * `first: CasePath<[A], A>`
  * `first: (where: (A) -> Bool) -> CasePath<[A], A>`
  * `key: (K) -> CasePath<[K: V], V>`
  * `rawValue: CasePath<R.RawValue, R> where R: RawRepresentable`
"""#,
    solution: #"""
```swift
extension CasePath where Root == String, Value == Int {
  static let int = CasePath(
    embed: String.init,
    extract: Int.init
  )
}

import Foundation
extension CasePath where Root == String, Value == UUID {
  static let uuid = CasePath(
    embed: { $0.uuidString },
    extract: UUID.init(uuidString:)
  )
}

extension CasePath where Root == String, Value == String {
  static func literal(_ string: String) -> CasePath {
    CasePath(
      embed: { _ in string },
      extract: { $0 == string ? string : nil }
    )
  }
}

extension CasePath
  where Root: RangeReplaceableCollection,
  Value == Root.Element {

  static var first: CasePath {
    CasePath(
      embed: { Root([$0]) },
      extract: { $0.first }
    )
  }

  static func first(
    where p: @escaping (Value) -> Bool
  ) -> CasePath {
    CasePath(
      embed: { Root([$0]) },
      extract: { $0.first(where: p) }
    )
  }
}

extension CasePath {
  static func key<Key>(
    _ key: Key
  ) -> CasePath where Root == [Key: Value] {
    CasePath(
      embed: { [key: $0] },
      extract: { $0[key] }
    )
  }
}

extension CasePath
  where Value: RawRepresentable,
  Root == Value.RawValue {

  static var rawRepresentable: CasePath {
    CasePath(
      embed: { $0.rawValue },
      extract: Value.init(rawValue:)
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
As we've seen, both key paths and case paths are composable: they both support an `appending(path:)` operation for combining key paths with key paths or case paths with case paths. The next few exercises will explore if it is possible to combine key paths with case paths in various ways.

First: is it possible to implement a function that appends a key path with a case path to return a new case path?

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> CasePath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```

Or a function that appends a case path with a key path to return a new case path?

```swift
extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> CasePath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
It is not possible to implement these functions. While it is possible to define the `extract` functions, it is impossible to define the `embed` functions because the key path's root is never available.

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> CasePath<Root, AppendedValue> {
    return CasePath<Root, AppendedValue>(
      extract: { root in path.extract(self.get(root)) },
      embed: { appendedValue in fatalError() }
    )
  }
}

extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> CasePath<Root, AppendedValue> {
    CasePath<Root, AppendedValue>(
      extract: { root in
        guard let value = self.extract(root) else { return nil }
        return path.get(value)
    },
      embed: { appendedValue in fatalError() })
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Is it possible to write a function that appends a key path with a case path to return a new key path?

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```

How about a function that appends a case path with a key path to return a new key path?

```swift
extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
It is not possible to implement these functions, either, because it is not possible to implement the returned key path's getter. Each `get` function must return a non-optional `AppendedValue`, but case path extraction requires this value to be optional.

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(path: CasePath<Value, AppendedValue>) -> _WritableKeyPath<Root, AppendedValue> {
    return _WritableKeyPath<Root, AppendedValue>(
      get: { root in
        let value = self.get(root)
        let appendedValue = path.extract(value)
        return appendedValue // 🛑
    },
      set: { root, appendedValue in
        self.set(&root, path.embed(appendedValue))
    }
    )
  }
}

extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue> {
    _WritableKeyPath<Root, AppendedValue>(
      get: { root in
        guard let value = self.extract(root) else {
          return nil // 🛑
        }
        let appendedValue = path.get(value)
        return appendedValue
    },
      set: { root, appendedValue in
        guard var value = self.extract(root) else { return }
        path.set(&value, appendedValue)
        root = self.embed(value)
    }
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Implement a function that appends a key path with a case path and returns a new key path with an optional value.

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue?> {
    fatalError("unimplemented")
  }
}
```

Also implement a function that appends a case path with a key path and returns a new key path with an optional appended value.

```swift
extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue?> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue?> {
    _WritableKeyPath<Root, AppendedValue?>(
      get: { root in path.extract(self.get(root)) },
      set: { root, appendedValue in
        guard let appendedValue = appendedValue else { return }
        self.set(&root, path.embed(appendedValue))
    }
    )
  }
}

extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> _WritableKeyPath<Root, AppendedValue?> {
    _WritableKeyPath<Root, AppendedValue?>(
      get: { root in
        guard let value = self.extract(root) else { return nil }
        return path.get(value)
    },
      set: { root, appendedValue in
        guard var value = self.extract(root) else { return }
        guard let appendedValue = appendedValue else { return }
        path.set(&value, appendedValue)
        root = self.embed(value)
    }
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Given the previous exercise's operations that append key paths with case paths and case paths with key paths, what happens when you try to compose the following?

```swift
// KP = _WritableKeyPath
// CP = CasePath

KP<A, B> + CP<B, C> + KP<C, D>
```

Can key paths and case paths compose more than one time?
"""#,
    solution: #"""
Because this form of composition makes the appended `Value` parameter optional, it is impossible to further append paths without introducing new operations that flatten this optional.
"""#
  ),
  .init(
    problem: #"""
There exists another path type that avoids the issue raised in the previous exercise. It captures the Swift semantic of optional chaining, where the getter is optional:

```swift
user?.location.city // Optional("Brooklyn")
```

And the setter is non-optional:

```swift
user?.location.city = "Los Angeles"
// ✅

user?.location.city = nil
// 🛑 error: 'nil' cannot be assigned to type 'String'
```

Express these requirements in a new `OptionalPath<Root, Value>` type.
"""#,
    solution: #"""
```swift
struct OptionalPath<Root, Value> {
  let extract: (Root) -> Value?
  let set: (inout Root, Value) -> Void
}
```
"""#
  ),
  .init(
    problem: #"""
Define `appending(path:)` on `OptionalPath`:

```swift
extension OptionalPath {
  func appending<AppendedValue>(
    path: OptionalPath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension OptionalPath {
  func appending<AppendedValue>(
    path: OptionalPath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    OptionalPath<Root, AppendedValue>(
      extract: { root in
        self.extract(root).flatMap(path.extract)
    },
      set: { root, appendedValue in
        guard var value = self.extract(root) else { return }
        path.set(&value, appendedValue)
        self.set(&root, value)
    }
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
We have seen in previous episodes and exercises that key paths and case paths have an "identity" path. Define the identity optional path:

```swift
extension OptionalPath where Root == Value {
  static var `self`: OptionalPath {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension OptionalPath where Root == Value {
  static var `self`: OptionalPath {
    OptionalPath {
      extract: { .some($0) },
      set { $0 = $1 }
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Implement a function that appends a key path with a case path and returns an optional path.

```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```

Also implement a function that appends a case path with a key path and returns a new optional path.

```swift
extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension _WritableKeyPath {
  func appending<AppendedValue>(
    path: CasePath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    OptionalPath<Root, AppendedValue>(
      extract: { root in path.extract(self.get(root)) },
      set: { root, appendedValue in
        self.set(&root, path.embed(appendedValue))
    }
    )
  }
}

extension CasePath {
  func appending<AppendedValue>(
    path: _WritableKeyPath<Value, AppendedValue>
  ) -> OptionalPath<Root, AppendedValue> {
    OptionalPath<Root, AppendedValue>(
      extract: { root in
        self.extract(root).map(path.get)
    },
      set: { root, appendedValue in
        guard var value = self.extract(root) else { return }
        path.set(&value, appendedValue)
        root = self.embed(value)
    }
    )
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Describe the hierarchy of path composition between:

```
KP = (Writable) Key Paths
CP = Case Paths
OP = Optional Paths

KP + KP = ?
CP + CP = ?
OP + OP = ?

KP + CP = ?
CP + KP = ?

KP + OP = ?
OP + CP = ?

CP + OP = ?
OP + CP = ?
"""#,
    solution: #"""
```
KP + KP = KP
CP + CP = CP
OP + OP = OP

KP + CP = OP
CP + KP = OP

KP + OP = OP
OP + CP = OP

CP + OP = OP
OP + CP = OP
```
"""#
  ),
  .init(
    problem: #"""
With the solution to the previous exercise in hand, is it possible to reduce the number of `append` overloads you need to define between `_WritableKeyPath`, `CasePath`, and `OptionalPath`?
"""#,
    solution: #"""
All compositions, whenever two paths differ, lead to `OptionalPath`. This means that `_WritableKeyPath` and `CasePath` are both convertible to `OptionalPath`. We can employ a `Path` protocol to describe this ability.

```swift
protocol Path {
  associatedtype Root
  associatedtype Value

  var asOptionalPath: OptionalPath<Root, Value> { get }
}
```

And all three paths can conform:

```swift
struct _WritableKeyPath: Path {
  var asOptionalPath: OptionalPath<Root, Value> {
    OptionalPath<Root, Value>(
      extract: { .some(self.get($0)) },
      set: self.set
    )
  }
}

struct CasePath: Path {
  var asOptionalPath: OptionalPath<Root, Value> {
    OptionalPath<Root, Value>(
      extract: self.extract,
      set: { $0 = self.embed($1) }
    )
  }
}

struct OptionalPath: Path {
  var asOptionalPath: OptionalPath<Root, Value> { self }
}
```

With these in hand, one can extend `Path` with an `appending(path:)` operation:

```swift
extension Path {
  func appending<AppendedPath: Path>(
    path: AppendedPath
  ) -> OptionalPath<Root, AppendedValue> where AppendedPath.Root == Value {
    self.asOptionalPath.appending(path: path.asOptionalPath)
  }
}
```
"""#
  ),
]
