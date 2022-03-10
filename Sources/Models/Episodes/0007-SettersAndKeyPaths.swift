import Foundation

extension Episode {
  static let ep7_settersAndKeyPaths = Episode(
    blurb: """
This week we explore how functional setters can be used with the types we build and use everyday. It turns out that Swift generates a whole set of functional setters for you to use, but it can be hard to see just how powerful they are without a little help.
""",
    codeSampleDirectory: "0007-setters-and-key-paths",
    exercises: _exercises,
    id: 7,
    length: 1872,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_520_848_623),
    references: [.composableSetters, .semanticEditorCombinators],
    sequence: 7,
    title: "Setters and Key Paths",
    trailerVideo: .init(
      bytesLength: 35648849,
      downloadUrls: .s3(
        hd1080: "0007-trailer-1080p-a408453170df4d7e9a1961c53c6654bc",
        hd720: "0007-trailer-720p-c80af4f620d646398b8abae3eae8354a",
        sd540: "0007-trailer-540p-41f9fea5494941aba6bd8cad01f13e40"
      ),
      vimeoId: 354214982
    )
  )
}

private let _exercises: [Episode.Exercise] = [
    Episode.Exercise(
        problem: """
In this episode we used `Dictionary`'s subscript key path without explaining it much. For a `key: Key`,
one can construct a key path `\\.[key]` for setting a value associated with `key`. What is the
signature of the setter `prop(\\.[key])`? Explain the difference between this setter and the setter
`prop(\\.[key]) <<< map`, where `map` is the optional map.
""",
        solution: """
The signature of the setter `prop(\\.[key])` is `((Value?) -> Value?) -> [Key: Value] -> [Key: Value]`,
whereas the signature for the mapped version is `((Value) -> Value) -> [Key: Value] -> [Key: Value]`.
The `prop(\\.[key])` version allows you to both set values for nonexistant keys as well as nil out existing keys.
"""
    ),

    Episode.Exercise(
        problem: """
The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values.
However, that shouldn't stop us from defining a functional setter! Define a function `elem` with
signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one
to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the
input determines if the value is already in the set and the output determines if the value should be
included.
""",
        solution: """
```
func elem<A>(_ e: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
  return { shouldInclude in
    return { set in
      if shouldInclude(set.contains(e)) {
        return set.union(Set([e]))
      } else {
        return set.subtracting(Set([e]))
      }
    }
  }
}

let xs: Set<String> = [1, 2, 3, 4]
xs
  |> elem(1) { _ in false }
  |> elem(2) { !$0 }
  |> elem(10) { _ in true }
```
"""
    ),

    Episode.Exercise(
        problem: """
Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler
generated key path. Use array's subscript key path to uppercase the first favorite food for a user.
What happens if the user's favorite food array is empty?
""",
        solution: """
```(prop(\\User.favoriteFoods[0].name)) { $0.uppercased() }```
If the user's favorite food array is empty, an out of bounds error will be thrown.
"""
    ),

    Episode.Exercise(
        problem: """
Recall from a [previous episode](/episodes/ep5-higher-order-functions) that the free `filter` function
on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the
composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
""",
        solution: """
`prop(\\User.favoriteFoods) <<< filter` allows you to filter a users favorite foods in-place. For example,
the following code, updates a user to keep only fruits that start with 'o'.
```
user
  |> (prop(\\User.favoriteFoods) <<< filter) { $0.name.starts(with: 'o') }
```
"""
    ),

    Episode.Exercise(
        problem: """
Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing
into those cases.
""",
        solution: """
```

func value<A, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case .success(let v):
      return .success(f(v))
    case .failure(let e):
      return .failure(e)
    }
  }
}

func error<A, E>(_ f: @escaping (E) -> F) -> (Result<A, E>) -> Result<A, F> {
  return { result in
    switch result {
    case .success(let v):
      return .success(v)
    case .failure(let e):
      return .failure(f(e))
    }
  }
}
```
"""
    ),

  Episode.Exercise(
    problem: """
Is it possible to make key path setters work with `enum`s?
""",
    solution: """
Unfortunately no :( Swift only gives us access to key paths for structs, and provides nothing for enums. Maybe that will change some day!
"""),

  Episode.Exercise(
    problem: """
Redefine some of our setters in terms of `inout`. How does the type signature and composition change?
""",
    solution: """
```
func inoutProp<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (inout Value) -> Void)
  -> (inout Root) -> Void {

    return { update in
      { root in
        update(&root[keyPath: kp])
      }
    }
}
```
"""),
]
