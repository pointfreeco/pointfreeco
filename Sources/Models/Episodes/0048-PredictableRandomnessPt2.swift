
import Foundation

extension Episode {
  static let ep48_predictableRandomness_pt2 = Episode(
    blurb: """
This week we finally make our untestable Gen type testable. We'll compare several different ways of controlling Gen, consider how they affect Gen's API, and find ourselves face-to-face with yet another `flatMap`.
""",
    codeSampleDirectory: "0048-predictable-randomness-pt2",
    exercises: _exercises,
    id: 48,
    image: "https://i.vimeocdn.com/video/801299668-49a55f0c29a974b51af66724b95145b08575b111a890e29c8a3fa5903998247d-d",
    length: 37*60 + 02,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1551078000),
    references: [
      .randomUnification,
      .stateMonadTutorialForTheConfused,
      .haskellUnderstandingMonadsState
    ],
    sequence: 48,
    title: "Predictable Randomness: Part 2",
    trailerVideo: .init(
      bytesLength: 43611137,
      vimeoId: 348484907,
      vimeoSecret: "f3bd0056d3cbb264d365523fb4f0621455445b57"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
We've all but completely recovered the ergonomics of `Gen` from before we controlled it, but our public `run` function requires an explicit `RandomNumberGenerator` is passed in as a dependency. Add an overload to recover the ergonomics of calling `gen.run()` without a `RandomNumberGenerator`.
""",
    solution: """
The problem here is a bare `run` function collides with the `run` property. This isn't a big blocker, though, because the property is a private concern. We can rename it to anything, like `_run` or `gen` and recover a really nice public interface.

```
struct Gen<A> {
  let gen: (inout AnyRandomNumberGenerator) -> A

  func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> A {
    var arng = AnyRandomNumberGenerator(rng: rng)
    let result = self.run(&rng)
    rng = arng.rng as! RNG
    return result
  }

  func run() -> A {
    var srng = SystemRandomNumberGenerator()
    return self.run(using: &srng)
  }
}
```
"""),
  Episode.Exercise(
    problem: """
The `Gen` type perfectly encapsulates producing a random value from a given mutable random number generator. Generalize `Gen` to a type `State` that produces values from a given mutable parameter.
""",
    solution: """
Generalizing `Gen` to `State` requires us to introduce another generic to take the place of `AnyRandomNumberGenerator`.

```
struct State<S, A> {
  let run: (inout S) -> A
}
```
"""
  ),
  Episode.Exercise(
    problem: """
Recover `Gen` as a specification of `State` using a type alias.
""",
    solution: """
Generic type aliases allow us to fix any generic, so we can set `S` to `AnyRandomNumberGenerator`.

```
typealias Gen<A> = State<AnyRandomNumberGenerator, A>
```
"""
  ),
  Episode.Exercise(
    problem: """
Deriving `Gen` as a type alias of `State` breaks a bunch of implementations, including:

- `map`
- `flatMap`
- `int(in:)`
- `float(in:)`
- `bool`

Update each implementation for `State`.
""",
    solution: """
We're currently defining `map` by extending `Gen` and working with the `Gen` type internally, which fixes the `S` parameter of `State` to `AnyRandomNumberGenerator`. Let's redefine things without any mention of `Gen`.

```
extension State {
  func map<B>(_ f: @escaping (A) -> B) -> State<S, B> {
    return State<S, B> { s in f(self.run(&s)) }
  }
}
```

And `flatMap` can be updated similarly.

```
extension State {
  func flatMap<B>(_ f: @escaping (A) -> State<S, B>) -> State<S, B> {
    return State<S, B> { s in
      f(self.run(&s)).run(&s)
    }
  }
}
```

Our static helpers on `Gen` need to give the type system a bit more information to behave. Unfortunately `extension Gen` is not the same as `extension State where S == AnyRandomNumberGenerator`, so we need to manually constrain things to have things behave nicely. It helps to define these extensions without mentioning `Gen`.

```
extension State where S == AnyRandomNumberGenerator, A: FixedWidthInteger {
  static func int(in range: ClosedRange<A>) -> State {
    return State { rng in .random(in: range, using: &rng) }
  }
}

extension State where S == AnyRandomNumberGenerator, A: BinaryFloatingPoint, A.RawSignificand: FixedWidthInteger {
  static func int(in range: ClosedRange<A>) -> State {
    return State { rng in .random(in: range, using: &rng) }
  }
}

extension State where S == AnyRandomNumberGenerator, A == Bool {
  static let bool = State { rng in .random(using: &rng) }
  }
}
```
"""
  ),
]
