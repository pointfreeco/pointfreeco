import Foundation

extension Episode {
  static let ep12_tagged = Episode(
    blurb: """
We typically model our data with very general types, like strings and ints, but the values themselves are often far more specific, like emails and ids. We'll explore how this can lead to subtle runtime bugs and how we can strengthen these types in an ergonomic way using several features new to Swift 4.1.
""",
    codeSampleDirectory: "0012-tagged",
    exercises: _exercises,
    id: 12,
    length: 26*60 + 49,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_523_872_623),
    references: [.swiftTagged, .taggedSecondsAndMilliseconds, .typeSafeFilePathsWithPhantomTypes],
    sequence: 12,
    title: "Tagged",
    trailerVideo: .init(
      bytesLength: 33936050,
      vimeoId: 354214920,
      vimeoSecret: "4b448ee6516faaf254a070f8116f7dc54a7096db"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Conditionally conform `Tagged` to `ExpressibleByStringLiteral` in order to restore the ergonomics of initializing our `User`'s `email` property. Note that `ExpressibleByStringLiteral` requires a couple other prerequisite conformances.
"""),
  Episode.Exercise(problem: """
Conditionally conform `Tagged` to `Comparable` and sort users by their `id` in descending order.
"""),
  Episode.Exercise(problem: """
Let's explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an `age` property to `User` that is tagged to wrap an `Int` value. Ensure that it doesn't collide with `User.Id`. (Consider how we tagged `Email`.)
"""),
  Episode.Exercise(problem: """
Conditionally conform `Tagged` to `Numeric` and alias a tagged type to `Int` representing `Cents`. Explore the ergonomics of using mathematical operators and literals to manipulate these values.
"""),
  Episode.Exercise(problem: """
Create a tagged type, `Light<A> = Tagged<A, Color>`, where `A` can represent whether the light is on or off. Write `turnOn` and `turnOff` functions to toggle this state.
"""),
  Episode.Exercise(problem: """
Write a function, `changeColor`, that changes a `Light`'s color when the light is on. This function should produce a compiler error when passed a `Light` that is off.
"""),
  Episode.Exercise(problem: """
Create two tagged types with `Double` raw values to represent `Celsius` and `Fahrenheit` temperatures. Write functions `celsiusToFahrenheit` and `fahrenheitToCelsius` that convert between these units.
"""),
  Episode.Exercise(problem: """
Create `Unvalidated` and `Validated` tagged types so that you can create a function that takes an `Unvalidated<User>` and returns an `Optional<Validated<User>>` given a valid user. A valid user may be one with a non-empty `name` and an `email` that contains an `@`.
"""),
]
