import Foundation

extension Episode {
  static let ep90_composingArchitectureWithCasePaths = Episode(
    blurb: #"""
Let's explore a real world application of "case paths," which provide key path-like functionality to enum cases. We'll upgrade our composable architecture to use them and see why they're a better fit than our existing approach.
"""#,
    codeSampleDirectory: "0090-composing-architecture-with-case-paths",
    exercises: _exercises,
    id: 90,
    length: 22*60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1581314400),
    references: [
      .swiftCasePaths,
      .structs🤝Enums,
      .makeYourOwnCodeFormatterInSwift,
      .introductionToOpticsLensesAndPrisms,
      .opticsByExample,
    ],
    sequence: 90,
    title: "Composing Architecture with Case Paths",
    trailerVideo: .init(
      bytesLength: 58829798,
      downloadUrls: .s3(
        hd1080: "0090-trailer-1080p-78892b775f3b43e7b68f5e1cc8139884",
        hd720: "0090-trailer-720p-6ae06243040f4ca19f55dde6e3ed57fa",
        sd540: "0090-trailer-540p-6c01c5b32e8d4aa9b61ff4ecc2d4dcd1"
      ),
      vimeoId: 389513997
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
In this week's episode let's explore more real world applications of case paths.

SwiftUI introduces a [Binding](https://developer.apple.com/documentation/swiftui/binding) type, which is a getter-setter pair that isn't so different from a writable key path, and in fact has an [operation](https://developer.apple.com/documentation/swiftui/binding/3264175-subscript) that takes a key path from the binding's root to a value that returns a new binding for the value.

Is it possible to define this operation for case paths?

```swift
extension Binding {
  subscript<Subject>(
    casePath: CasePath<Value, Subject>
  ) -> Binding<Subject> {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
Any implementation of this function will be unsafe: case path extraction results in an optionally failable operation, which means the `get` function of the binding would need to force unwrap the value,
"""#
  ),
  .init(
    problem: #"""
Implement the following function, which is similar to the previous exercise, but optionalizes the returned binding.

```swift
extension Binding {
  subscript<Subject>(
    casePath: CasePath<Value, Subject>
  ) -> Binding<Subject>? {
    fatalError("unimplemented")
  }
}
```
"""#,
    solution: #"""
```swift
extension Binding {
  subscript<Subject>(
    casePath: CasePath<Value, Subject>
  ) -> Binding<Subject>? {
    casePath.extract(from: self.wrappedValue).map { subject in
      Binding<Subject>(
        get: { subject },
        set: { self.wrappedValue = casePath.embed($0) }
      )
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
While we typically model application state using structs, it is totally valid to model application state using enums. For example, your root state may be an enumeration of logged-in and logged-out states:

```swift
enum AppState {
  case loggedIn(LoggedInState)
  case loggedOut(LoggedOutState)
}
```

Use the case path helper from the previous exercise and define a root `AppView` that works with `AppState` and renders a `LoggedInView` or `LoggedOutView` with a `Binding` for their state.
"""#,
    solution: #"""
```swift
struct LoggedInView: View {
  @Binding var state: LoggedInState

  var body: some View {
    EmptyView()
  }
}

struct LoggedOutView: View {
  @Binding var state: LoggedOutState

  var body: some View {
    EmptyView()
  }
}

struct AppView: View {
  @Binding var state: AppState

  var body: some View {
    if let loggedInBinding = self.$state[/AppState.loggedIn] {
      return AnyView(LoggedInView(state: loggedInBinding))
    } else if let loggedOutBinding = self.$state[/AppState.loggedOut] {
      return AnyView(LoggedOutView(state: loggedOutBinding))
    } else {
      return AnyView(EmptyView())
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
The previous exercises introduce a case path helper analog to a key path helper that uses dynamic member lookup. Theorize how a first-class case path dynamic member lookup API would look like in Swift.
"""#,
    solution: nil
  ),
  .init(
    problem: #"""
Combine defines a key path API for [reactive bindings](https://developer.apple.com/documentation/combine/receiving_and_handling_events_with_combine):

```swift
extension Publisher where Failure == Never {
  func assign<Root>(
    to keyPath: ReferenceWritableKeyPath<Root, Output>,
    on object: Root
  ) -> AnyCancellable
}
```

What would it take to define an equivalent API that takes case paths?
"""#,
    solution: #"""
This API depends on a "reference-writable" key path in order to capture the reference to an object to be mutated later. Case paths, however, typically describe enums, which are value types, which cannot be mutated in the same way. For a function to mutate a value, the value must be annotated with `inout` and this mutable value cannot be captured for mutation later.
"""#
  ),
  .init(
    problem: #"""
Swift defines a key path API for [key-value observing](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift):

```swift
extension NSObject {
  func observe<Value>(
    keyPath: KeyPath<Self, Value>,
    options: NSKeyValueObservingOptions,
    changeHandler: @escaping (Self, NSKeyValueObservedChange<Value>) -> Void
  )
}
```

What would it take to define an equivalent API that takes case paths?
"""#,
    solution: #"""
Swift's key-value observing APIs depends on the Objective-C runtime, and the method that takes key paths is based on a more primitive method that uses the property's name to observe changes to the property. Swift enums are not portable to Objective-C, so no such API can exist today.
"""#
  ),
  .init(
    problem: #"""
Take additional, existing APIs that take key paths and explore their case path equivalents! And [share them with us](mailto:support@pointfree.co)!
"""#,
    solution: nil
  ),
]
