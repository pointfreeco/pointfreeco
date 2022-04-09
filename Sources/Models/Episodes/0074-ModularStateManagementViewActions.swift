import Foundation

extension Episode {
  static let ep74_modularStateManagement_viewActions = Episode(
    blurb: """
It's time to fully modularize our app! Our views can still send any app action, so let's explore transforming stores to focus in on just the local actions a view cares about.
""",
    codeSampleDirectory: "0074-modular-state-management-view-actions",
    exercises: _exercises,
    id: 74,
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
      downloadUrls: .s3(
        hd1080: "0074-trailer-1080p-b6e3d99525074d81bfda4c6312a3d29d",
        hd720: "0074-trailer-720p-7e954f48b9b948b0a4351d9c1661a470",
        sd540: "0074-trailer-540p-ef9f5c31be324b32a2882d84b246da59"
      ),
      vimeoId: 363166004
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
