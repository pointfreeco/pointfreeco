import Foundation

extension Episode {
  static let ep72_modularStateManagement_reducers = Episode(
    blurb: """
In exploring four forms of composition on reducer functions, we made the claim that it gave us the power to fully isolate app logic, making it simpler and easier to understand. This week we put our money where our mouth is and show just how modular these reducers are!
""",
    codeSampleDirectory: "0072-modular-state-management-reducers",
    exercises: _exercises,
    id: 72,
    length: 26*60 + 24,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1568008800),
    references: [
      .whyFunctionalProgrammingMatters,
      Episode.Reference(
        author: "Anders Bertelrud",
        blurb: "A Swift Evolution proposal for the Swift Package Manager to support resources.",
        link: "https://github.com/abertelrud/swift-evolution/blob/package-manager-resources/proposals/NNNN-package-manager-resources.md",
        publishedAt: Date(timeIntervalSince1970: 1544158800),
        title: "Package Resources"
      ),
      .accessControl,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 72,
    subtitle: "Reducers",
    title: "Modular State Management",
    trailerVideo: .init(
      bytesLength: 64250490,
      vimeoId: 358487507,
      vimeoSecret: "1e3cf7aeaf03e5ca9672c14845186412d3ff7ca2"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Explore the possibilities of transforming a store that works on global values to one that works with local values. That is, a function with the following shape of signature:

```swift
extension Store {
  func view<LocalValue>(
    /* what arguments are needed? */
  ) -> Store<LocalValue, Action> {

    fatalError("Unimplemented")
  }
}
```

Such a transformation would allow you to pass along more localized stores to views rather than forcing all views to work with the global store that holds all application state and actions.
"""#,
    solution: #"""
```swift
extension Store {
  func view<LocalValue>(
    _ f: @escaping (Value) -> LocalValue
  ) -> Store<LocalValue, Action> {

    return Store<LocalValue, Action>(
      initialValue: f(self.value),
      reducer: { localValue, action in
        self.reducer(&self.value, action)
        localValue = f(self.value)
    }
    )
  }
}
```
"""#),
  Episode.Exercise(
    problem: #"""
Update the `FavoritePrimes` view to work with a `Store` that concentrates entirely on the state it cares about and nothing more.
"""#,
    solution: nil
  ),
  Episode.Exercise(
    problem: #"""
When instantiating this updated `FavoritePrimes` view, use the `view` method on `Store` to focus in on this concentrated state.
"""#,
    solution: nil
  ),
  Episode.Exercise(
    problem: #"""
Modularity (via Swift modules) is just one flavor of code isolation. Another common means of isolating code in Swift is via various levels of [access control](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html). How do `internal`, `private`, and `fileprivate` access control isolate code? What are the benefits of each scope? How does this isolation differ from module boundaries?
"""#,
    solution: nil
  ),
  .init(
    problem: #"""
In this episode we created a `PrimeModalState` struct to model the local state that the prime modal needed in its module, and then later refactored that into a tuple to reduce a little bit of boilerplate. There is another common way to pass around subsets of data in Swift: protocols! Try converting `PrimeModalState` to a protocol that exposes only the fields of `AppState` that it cares about, and fix all of the compiler errors until it works. What things unexpectedly break? Does it reduce boilerplate more than the struct or tuple approach?
"""#,
    solution: nil
  )
]
