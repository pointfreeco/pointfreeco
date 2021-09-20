import Foundation

extension Episode {
  static let ep74_modularStateManagement_viewActions = Episode(
    blurb: """
It's time to fully modularize our app! Our views can still send any app action, so let's explore transforming stores to focus in on just the local actions a view cares about.
""",
    codeSampleDirectory: "0074-modular-state-management-view-actions",
    exercises: _exercises,
    id: 74,
    image: "https://i.vimeocdn.com/video/818256265.jpg",
    length: 25*60 + 54,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1569823200),
    references: [
      .pointFreePullbackAndContravariance,
      .whyFunctionalProgrammingMatters,
      .accessControl,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 74,
    subtitle: "View Actions",
    title: "Modular State Management",
    trailerVideo: .init(
      bytesLength: 42018767,
      vimeoId: 363166004,
      vimeoSecret: "894c29594098d752879eb133df1d965fbad399f7"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
It can be useful to produce "read-only" stores that cannot send any actions. Write a `view` that transforms a store that can perform actions into a store that cannot perform actions. What is the appropriate data type to describe the `Action` of such a store?

In our second episode on [algebraic data types](/episodes/ep9-algebraic-data-types-exponents), we explored such a transformation.
"""),
  Episode.Exercise(problem: """
In our first episode on [algebraic data types](/episodes/ep4-algebraic-data-types), we introduced the `Either` type, which is the most generic, non-trivial enum one could make:

```swift
enum Either<A, B> {
  case left(A)
  case right(B)
}
```

In this episode we create a wrapper enum called `CounterViewAction` to limit the counter view's ability to send any app action. Instead of introducing an ad hoc enum, refactor things to utilize the `Either` type.

How does this compare to utilizing structs and tuples for intermediate state?
"""),
]
