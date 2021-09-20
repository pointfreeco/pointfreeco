import Foundation

extension Episode {
  static let ep89_theCaseForCasePaths_pt3 = Episode(
    blurb: """
Although case paths are powerful and a natural extension of key paths, they are difficult to work with right now. They require either hand-written boilerplate, or code generation. However, there's another way to generate case paths for free, and it will make them just as ergonomic to use as key paths.
""",
    codeSampleDirectory: "0089-the-case-for-case-paths-pt3",
    exercises: _exercises,
    id: 89,
    image: "https://i.vimeocdn.com/video/850265054.jpg",
    length: 35*60 + 7,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1580709600),
    references: [
      .init(
        author: "Giuseppe Lanza",
        blurb: #"""
This Swift forum post offers a reflection-based solution for extracting an enum's associated value and inspired our solution for deriving case paths from enum case embed functions.
"""#,
        link: "https://forums.swift.org/t/extract-payload-for-enum-cases-having-associated-value/27606",
        publishedAt: Date(timeIntervalSince1970: 1564935360),
        title: "Extract Payload for enum cases having associated value"
      ),
      .init(
        author: "Giuseppe Lanza",
        blurb: #"""
A protocol-oriented library for extracting an enum's associated value.
"""#,
        link: "https://github.com/gringoireDM/EnumKit",
        publishedAt: nil,
        title: "EnumKit"
      ),
      .init(
        author: "Josh Smith",
        blurb: #"""
An early exploration of how an enum's associated values can be extracted using reflection and the case name.
"""#,
        link: "https://ijoshsmith.com/2017/04/08/reflectable-enums-in-swift-3/",
        publishedAt: Date(timeIntervalSince1970: 1491667200),
        title: "Reflectable enums in Swift 3"
      ),
      .structs🤝Enums,
      .makeYourOwnCodeFormatterInSwift,
      .introductionToOpticsLensesAndPrisms,
      .opticsByExample,
    ],
    sequence: 89,
    title: "Case Paths for Free",
    trailerVideo: .init(
      bytesLength: 46590660,
      vimeoId: 387150414,
      vimeoSecret: "74737075ffad18263e23694682be5d6ac894ba25"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
In the Composable Architecture we have been building, the [`pullback`](https://github.com/pointfreeco/episode-code-samples/blob/main/0084-testable-state-management-ergonomics/PrimeTime/ComposableArchitecture/ComposableArchitecture.swift#L97-L115) operation on reducers took two transformations: a writable key path for state and a writable key path for actions. Replace the key path on actions with a case path, and update the project to use this new API.
"""#,
    solution: #"""
```swift
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
    guard let localAction = action.extract(globalAction) else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return localEffects.map { localEffect in
      localEffect.map(action.embed).eraseToEffect()
    }
  }
}
```
"""#
  ),
  .init(
    problem: #"""
Our reflection-based case path initializer is relatively simple, but it's also relatively brittle: there are several edge cases that it will fail to work with. The next few exercises will explore finding solutions to these edge cases.

For one, given the following enum with a labeled case.

```swift
enum EnumWithLabeledCase {
  case labeled(label: Int)
}
```

Extraction fails:

```swift
extractHelp(
  case: EnumWithLabeledCase.labeled,
  from: EnumWithLabeledCase.labeled(label: 1)
)
// nil
```

Study the mirror of `EnumWithLabeledCase.labeled(label: 1)` and update `extractHelp` with the capability of extracting this value.

Note that it is perfectly valid Swift to add a second case to this enum with the same name but a different label:

```swift
enum EnumWithLabeledCase {
  case labeled(label: Int)
  case labeled(anotherLabel: Int)
}
```

Ensure that `extractHelp` fails to extract this mismatch:
"""#,
    solution: #"""
`EnumWithLabeledCase.labeled(label: 1)` has a single child with an unusual value:

```swift
let labeled = EnumWithLabeledCase.labeled(label: 1)
let children = Mirror(reflecting: labeled).children
children.count  // 1
children.first! // (label: "labeled", value: (label: 1))
```

Strange! The `Mirror.Child` has a label matching the case name, but its value appears to be a tuple of one labeled element, something that's typically forbidden in Swift. It's important to note that the tuple label matches the associated value's label.

In order to interact with this structure, we must again reflect.

```swift
let newChildren = Mirror(reflecting: children.first!.value)
newChildren.count  // 1
newChildren.first! // (label: "label", value: 1)
```

Alright, this should be enough for us to update `extractHelp` to do just a little more work. We want to dive one step further into the structure, so let's extract that work into a helper function in order to perform it twice.

```swift
func extractHelp<Root, Value>(
  case: @escaping (Value) -> Root,
  from root: Root
) -> Value? {
  func reflect(_ root: Root) -> ([String?], Value)? {
    let mirror = Mirror(reflecting: root)
    guard let child = mirror.children.first else { return nil }
    if let value = child.value as? Value { return ([child.label], value) }

    let newMirror = Mirror(reflecting: child.value)
    guard let newChild = newMirror.children.first else { return nil }
    if let value = newChild.value as? Value { return ([child.label, newChild.label], value) }

    return nil
  }

  guard let (path, value) = reflect(root) else { return nil }
  guard let (newPath, _) = reflect(`case`(value)) else { return nil }
  guard path == newPath else { return nil }

  return value
}
```
"""#
  ),
]
