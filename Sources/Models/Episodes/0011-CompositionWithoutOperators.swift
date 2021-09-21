import Foundation

extension Episode {
  static let ep11_compositionWithoutOperators = Episode(
    blurb: """
While we unabashedly promote custom operators in this series, we understand that not every codebase can \
adopt them. Composition is too important to miss out on due to operators, so we want to explore some \
alternatives to unlock these benefits.
""",
    codeSampleDirectory: "0011-composition-without-operators",
    exercises: _exercises,
    id: 11,
    image: "https://i.vimeocdn.com/video/807678863.jpg",
    length: 21*60 + 5,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_523_267_823),
    references: [.swiftOverture],
    sequence: 11,
    title: "Composition without Operators",
    trailerVideo: .init(
      bytesLength: 21548139,
      vimeoId: 354214923,
      vimeoSecret: "a56ebb0868f225c916e4559b06bbaa7af2aca20f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
Write `concat` for functions `(inout A) -> Void`.
""",
    solution: """
```
func concat<A>(
  _ f: @escaping (inout A) -> Void,
  _ g: @escaping (inout A) -> Void,
  _ fs: ((inout A) -> Void)...
  ) -> (inout A) -> Void {

  return { a in
    f(&a)
    g(&a)
    fs.forEach { $0(&a) }
  }
}
```
"""
  ),
  .init(
    problem: """
Write `concat` for functions `(A) -> A`.
""",
    solution: """
```
func concat<A>(
  _ f: @escaping (A) -> A,
  _ g: @escaping (A) -> A,
  _ fs: ((A) -> A)...)
  -> (A) -> A {

    return { a in
      ([f, g] + fs).reduce(a, { $1($0) })
    }
}
```
"""
  ),
  .init(
    problem: """
 Write a function called `compose` for backward composition. Recreate some of the examples from our functional setters
episodes ([part 1](/episodes/ep6-functional-setters) and [part 2](/episodes/ep7-setters-and-key-paths)) using
`compose` and `pipe`.
""",
    solution: """
```
func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
  return { f(g($0)) }
}

with(
  ((1, true), "Swift"),
  pipe(
    backPipe(first, first)(incr),
    backPipe(first, second)(!),
    second { $0 + "!" }
  )
)

with(
  (42, ["Swift", "Objective-C"]),
  pipe(
    first(incr),
    backPipe(second, map)({ $0.uppercased() })
  )
)
```
"""),
]
