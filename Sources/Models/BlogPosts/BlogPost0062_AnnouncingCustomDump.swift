import Foundation

public let post0062_AnnouncingCustomDump = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open sourcing Custom Dump, a collection of tools for debugging, diffing, and testing your application's data structures.
""",
  contentBlocks: [
    .init(
      content: #"""
The ability to dump data structures into nicely formatted, human readable strings is important for debugging applications. Swift's `dump` function can help with this, but there's some room for improvement.

That's why we are excited to announce the open sourcing of [Custom Dump](https://github.com/pointfreeco/swift-custom-dump), a collection of tools for debugging, diffing, and testing your application's data structures. It comes with three tools:

* [`customDump`](#customDump): dump any data type into a nicely formatted string.
* [`diff`](#diff): visually represent the difference between two values.
* [`XCTAssertNoDifference`](#XCTAssertNoDifference): an alternative to `XCTAssertEqual` with better failure messages.

## Motivation

Swift comes with a wonderful tool for dumping the contents of any value to a string, and it's called `dump`. It prints all the fields and sub-fields of a value into a tree-like description:

```swift
struct User {
  var favoriteNumbers: [Int]
  var id: Int
  var name: String
}

let user = User(
  favoriteNumbers: [42, 1729],
  id: 2,
  name: "Blob"
)

dump(user)
```
```text
▿ User
  ▿ favoriteNumbers: 2 elements
    - 42
    - 1729
  - id: 2
  - name: "Blob"
```

This is really useful, and can be great for building debug tools that visualize the data held in runtime values of our applications, but sometimes its output is not ideal.

For example, dumping dictionaries leads to a verbose output that can be hard to read (also note that the keys are unordered):

```swift
dump([1: "one", 2: "two", 3: "three"])
```
```text
▿ 3 key/value pairs
  ▿ (2 elements)
    - key: 2
    - value: "two"
  ▿ (2 elements)
    - key: 3
    - value: "three"
  ▿ (2 elements)
    - key: 1
    - value: "one"
```

Similarly enums have a very verbose output:

```swift
dump(Result<Int, Error>.success(42))
```
```text
▿ Swift.Result<Swift.Int, Swift.Error>.success
  - success: 42
```

It gets even harder to read when dealing with deeply nested structures:

```swift
dump([1: Result<User, Error>.success(user)])
```
```text
▿ 1 key/value pair
  ▿ (2 elements)
    - key: 1
    ▿ value: Swift.Result<User, Swift.Error>.success
      ▿ success: User
        ▿ favoriteNumbers: 2 elements
          - 42
          - 1729
        - id: 2
        - name: "Blob"
```

There are also times that `dump` simply does not print useful information, such as enums imported from Objective-C:

```swift
import UserNotifications

dump(UNNotificationSetting.disabled)
```
```text
- __C.UNNotificationSetting
```

So, while the `dump` function can be handy, it is often too crude of a tool to use. This is the motivation for the `customDump` function.

<div id="customDump"></div>

## `customDump`

The `customDump` function emulates the behavior of `dump`, but provides a more refined output of nested structures, optimizing for readability. For example, structs are dumped in a format that more closely mimics the struct syntax in Swift, and arrays are dumped with the indices of each element:

```swift
import CustomDump

customDump(user)
```
```text
User(
  favoriteNumbers: [
    [0]: 42,
    [1]: 1729
  ],
  id: 2,
  name: "Blob"
)
```

Dictionaries are dumped in a more compact format that mimics Swift's syntax, and automatically orders the keys:

```swift
customDump([1: "one", 2: "two", 3: "three"])
```
```text
[
  1: "one",
  2: "two",
  3: "three"
]
```

Similarly, enums also dump in a more compact, readable format:

```swift
customDump(Result<Int, Error>.success(42))
```
```text
Result.success(42)
```

And deeply nested structures have a simplified tree-structure:

```swift
customDump([1: Result<User, Error>.success(user)])
```
```text
[
  1: Result.success(
    User(
      favoriteNumbers: [
        [0]: 42,
        [1]: 1729
      ],
      id: 2,
      name: "Blob"
    )
  )
]
```

<div id="diff"></div>

## `diff`

Using the output of the `customDump` function we can build a very lightweight way to textually diff any two values in Swift:

```swift
var other = user
other.favoriteNumbers[1] = 91

print(diff(user, other)!)
```
```diff
  User(
    favoriteNumbers: [
      [0]: 42,
-     [1]: 1729
+     [1]: 91
    ],
    id: 2,
    name: "Blob"
  )
```

Further, extra work is done to minimize the size of the diff when parts of the structure haven't changed, such as a single element changing in a large collection:

```swift
let users = (1...5).map {
  User(
    favoriteNumbers: [$0],
    id: $0,
    name: "Blob \($0)"
  )
}

var other = users
other.append(
  .init(
    favoriteNumbers: [42, 1729],
    id: 100,
    name: "Blob Sr."
  )
)

print(diff(users, other)!)
```
```diff
  [
    … (4 unchanged),
+   [5]: User(
+     favoriteNumbers: [
+       [0]: 42,
+       [1]: 1729
+     ],
+     id: 100,
+     name: "Blob Sr."
+   )
  ]
```

For a real world use case we modified Apple's [Landmarks](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls) tutorial application to print the before and after state when favoriting a landmark:

```diff
  [
    [0]: Landmark(
      id: 1001,
      name: "Turtle Rock",
      park: "Joshua Tree National Park",
      state: "California",
      description: "This very large formation lies south of the large Real Hidden Valley parking lot and immediately adjacent to (south of) the picnic areas.",
-     isFavorite: true,
+     isFavorite: false,
      isFeatured: true,
      category: Category.rivers,
      imageName: "turtlerock",
      coordinates: Coordinates(…)
    ),
    … (11 unchanged)
  ]
```

<div id="XCTAssertNoDifference"></div>

## `XCTAssertNoDifference`

The `XCTAssertEqual` function from `XCTest` allows you to assert that two values are equal, and if they are not the test suite will fail with a message:

```swift
var other = user
other.name += "!"

XCTAssertEqual(user, other)
```
```text
XCTAssertEqual failed: ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob")") is not equal to ("User(favoriteNumbers: [42, 1729], id: 2, name: "Blob!")")
```

Unfortunately this failure message is quite difficult to visually parse and understand. It takes a few moments of hunting through the message to see that the only difference is the exclamation mark at the end of the name. The problem gets worse if the type is more complex, consisting of nested structures and large collections.

This library also ships with an `XCTAssertNoDifference` function to mitigate these problems. It works like `XCTAssertEqual` except the failure message uses the nicely formatted diff to show exactly what is different between the two values:

```swift
XCTAssertNoDifference(user, other)
```
```text
XCTAssertNoDifference failed: …

    User(
      favoriteNumbers: […],
      id: 2,
  -   name: "Blob"
  +   name: "Blob!"
    )

(First: -, Second: +)
```

## Case Studies

The Custom Dump library was first conceived as a tool for our other library, the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). That library ships with a debugging helper on reducers that prints the diff of state changes every time an action is sent into the system, as well as an assertion helper that helps you write comprehensive tests on your features, giving you a nicely formatted failure message when an assertion fails.

When we decided to extract that functionality into its own library, [Custom Dump](https://github.com/pointfreeco/swift-custom-dump), we knew we wanted to make a lot of improvements. The output of the debug and assertion helpers, while helpful, is very verbose. If your feature's state is large, then every single field and sub-field is printed, even if nothing changed.

We have greatly improved the ergonomics of dumping and diffing in the Custom Dump library, which now the Composable Architecture leverages, and below we have just a few examples of how the ergonomics of the debug and assertion helpers has improved.

### Tic-Tac-Toe

The [Tic-Tac-Toe](https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/TicTacToe) example application shows how to build a multi-screen, modularized application with the Composable Architecture.

The state of the application holds a puzzle board, which consists of a two dimension array of X's and O's, representing the players' moves. Previously, the full two dimensional array would be dumped when using the reducer debug helper, even if only a single element was changed. For example, when a cell was tapped:

```diff
received action:
  AppAction.newGame(
    NewGameAction.game(
      GameAction.cellTapped(
        row: 1,
        column: 1
      )
    )
  )
  AppState.newGame(
    NewGameState(
      game: GameState(
        board: Three<Three<Optional<Player>>>(
          first: Three<Optional<Player>>(
            first: nil,
            second: nil,
            third: nil
          ),
          second: Three<Optional<Player>>(
            first: nil,
-           second: nil,
+           second: Player.x,
            third: nil
          ),
          third: Three<Optional<Player>>(
            first: nil,
            second: nil,
            third: nil
          )
        ),
-       currentPlayer: Player.x,
+       currentPlayer: Player.o,
        oPlayerName: "Blob Jr.",
        xPlayerName: "Blob Sr."
      ),
      oPlayerName: "Blob Jr.",
      xPlayerName: "Blob Sr."
    )
  )
```

With the improvements that Custom Dump brings a lot of that state is now collapsed so that we can focus on just the small piece of state that did change:

```diff
received action:
  AppAction.newGame(
    NewGameAction.game(
      GameAction.cellTapped(
        row: 1,
        column: 1
      )
    )
  )
  AppState.newGame(
    NewGameState(
      game: GameState(
        board: Three(
          first: Three(…),
          second: Three(
            first: nil,
-           second: nil,
+           second: Player.x,
            third: nil
          ),
          third: Three(…)
        ),
-       currentPlayer: Player.x,
+       currentPlayer: Player.o,
        oPlayerName: "Blob Jr.",
        xPlayerName: "Blob Sr."
      ),
      oPlayerName: "Blob Jr.",
      xPlayerName: "Blob Sr."
    )
  )
```

### Todos

The [Todos](https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/Todos) demo shows how to build a classic application using the Composable Architecture. The state of the todos application can potentially hold many, many todos, and so previously when using the debug helper the entire collection would be dumped to the console.

For example, if we had 4 todos in our list and we checked one of them off, the diff output would be the following 40 lines, which barely fits on the screen at once:

```diff
received action:
  AppAction.todo(
    id: UUID(
      uuid: "2294C632-5F71-4F7D-B303-FEFCD0FFB9FD"
    ),
    action: TodoAction.checkBoxToggled
  )
  AppState(
    editMode: EditMode.inactive,
    filter: Filter.all,
    todos: [
      Todo(
        description: "Seltzer",
        id: UUID(
          uuid: "7845CAE9-F98B-492F-A182-886C8328A114"
        ),
        isComplete: false
      ),
      Todo(
        description: "Bread",
        id: UUID(
          uuid: "F333D9BE-2D56-4456-AF06-F74DA098CA88"
        ),
        isComplete: false
      ),
      Todo(
        description: "Eggs",
        id: UUID(
          uuid: "2294C632-5F71-4F7D-B303-FEFCD0FFB9FD"
        ),
-       isComplete: false
+       isComplete: true
      ),
      Todo(
        description: "Milk",
        id: UUID(
          uuid: "065A2A8E-1D61-4DFA-B49B-3D9AB57D1BAC"
        ),
        isComplete: false
      ),
    ]
  )
```

But now, with the new Custom Dump library, extra work is done to collapse elements of collections that do not change, leading to much shorter, more concise outputs and diffs. Checking off the same todo results in only 18 lines of diff, making it very clear exactly what changed:

```diff
received action:
  AppAction.todo(
    id: UUID(4A101EDB-B9BF-4DBD-871D-3D72CBE1E8CE),
    action: TodoAction.checkBoxToggled
  )
  AppState(
    editMode: EditMode.inactive,
    filter: Filter.all,
    todos: [
      … (2 unchanged),
      [2]: Todo(
        description: "Eggs",
        id: UUID(4A101EDB-B9BF-4DBD-871D-3D72CBE1E8CE),
-       isComplete: false
+       isComplete: true
      ),
      [3]: Todo(…)
    ]
  )
```

### isowords

[isowords](https://www.isowords.xyz) is a word game built in SwiftUI and the Composable Architecture, which we [open sourced](https://github.com/pointfreeco/isowords) earlier this year. It is a large application, consisting of many screens and the game domain is quite complex, making use of a 3-dimensional array of values to represent a cube of letters.

Printing the state for every action sent in this application massively bloated our logs. Each action resulted in nearly 2,000 lines being printed to the console, even if just a tiny bit of state changed. The diff is so massive that we have hidden a sample of it below:

<details>
  <summary>Click to see diff!</summary>

```diff
received action:
  AppAction.currentGame(
    GameFeatureAction.game(
      GameAction.tap(
        UIGestureRecognizerState.UIGestureRecognizerState,
        IndexedCubeFace(
          index: LatticePoint(
            x: Index.one,
            y: Index.two,
            z: Index.two
          ),
          side: Side.left
        )
      )
    )
  )
  AppState(
    game: GameState(
      activeGames: ActiveGamesState(
        savedGames: SavedGamesState(
          dailyChallengeUnlimited: nil,
          unlimited: InProgressGame(
            cubes: Three<Three<Three<Cube>>>(
              rawValue: [
                Three<Three<Cube>>(
                  rawValue: [
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "F",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "G",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "X",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "E",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "C",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "R",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "Z",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "O",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "C",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "C",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "V",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "N",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "F",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "Z",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "T",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "T",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "T",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "X",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "T",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "G",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "I",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "R",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "N",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "I",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "A",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "D",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                  ]
                ),
                Three<Three<Cube>>(
                  rawValue: [
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "R",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "K",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "D",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "V",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "G",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "I",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "G",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "C",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "S",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "I",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "I",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "E",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "N",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "R",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "S",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "E",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "T",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "I",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "R",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "A",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "B",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "M",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "V",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "G",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                  ]
                ),
                Three<Three<Cube>>(
                  rawValue: [
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "O",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "S",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "I",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "S",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "E",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "L",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "R",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "R",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "K",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "H",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "W",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "N",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "O",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "C",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                    Three<Cube>(
                      rawValue: [
                        Cube(
                          left: CubeFace(
                            letter: "N",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "C",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "E",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "K",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "E",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "N",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                        Cube(
                          left: CubeFace(
                            letter: "O",
                            side: Side.left,
                            useCount: 0
                          ),
                          right: CubeFace(
                            letter: "S",
                            side: Side.right,
                            useCount: 0
                          ),
                          top: CubeFace(
                            letter: "S",
                            side: Side.top,
                            useCount: 0
                          ),
                          wasRemoved: false
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            gameContext: GameContext.solo,
            gameMode: GameMode.unlimited,
            gameStartTime: 2021-08-20T22:08:25Z,
            _language: Language.en,
            moves: Moves(
              rawValue: [
              ]
            ),
            secondsPlayed: 0
          )
        ),
        turnBasedMatches: [
        ]
      ),
      alert: nil,
      bottomMenu: nil,
      cubes: Three<Three<Three<Cube>>>(
        rawValue: [
          Three<Three<Cube>>(
            rawValue: [
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "F",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "G",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "X",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "E",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "C",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "R",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "Z",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "O",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "C",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "C",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "V",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "N",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "F",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "Z",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "T",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "T",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "T",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "X",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "T",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "G",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "I",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "R",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "N",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "I",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "A",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "D",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
            ]
          ),
          Three<Three<Cube>>(
            rawValue: [
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "R",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "K",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "D",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "V",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "G",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "I",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "G",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "C",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "S",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "I",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "I",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "E",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "N",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "R",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "S",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "E",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "T",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "I",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "R",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "A",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "B",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "M",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "V",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "G",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
            ]
          ),
          Three<Three<Cube>>(
            rawValue: [
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "O",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "S",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "I",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "S",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "E",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "L",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "R",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "R",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "K",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "H",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "W",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "N",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "O",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "C",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
              Three<Cube>(
                rawValue: [
                  Cube(
                    left: CubeFace(
                      letter: "N",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "C",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "E",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "K",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "E",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "N",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                  Cube(
                    left: CubeFace(
                      letter: "O",
                      side: Side.left,
                      useCount: 0
                    ),
                    right: CubeFace(
                      letter: "S",
                      side: Side.right,
                      useCount: 0
                    ),
                    top: CubeFace(
                      letter: "S",
                      side: Side.top,
                      useCount: 0
                    ),
                    wasRemoved: false
                  ),
                ]
              ),
            ]
          ),
        ]
      ),
      cubeStartedShakingAt: nil,
      gameContext: GameContext.solo,
      gameCurrentTime: 2021-08-20T22:16:37Z,
      gameMode: GameMode.unlimited,
      gameOver: nil,
      gameStartTime: 2021-08-20T22:08:25Z,
      isDemo: false,
      isGameLoaded: true,
      isOnLowPowerMode: false,
      isPanning: false,
      isSettingsPresented: false,
      isTrayVisible: false,
      language: Language.en,
      moves: Moves(
        rawValue: [
        ]
      ),
-     optimisticallySelectedFace: nil,
+     optimisticallySelectedFace: IndexedCubeFace(
+       index: LatticePoint(
+         x: Index.one,
+         y: Index.two,
+         z: Index.two
+       ),
+       side: Side.left
+     ),
      secondsPlayed: 14,
      selectedWord: [
+       IndexedCubeFace(
+         index: LatticePoint(
+           x: Index.one,
+           y: Index.two,
+           z: Index.two
+         ),
+         side: Side.left
+       ),
      ],
      selectedWordIsValid: false,
      upgradeInterstitial: nil,
      wordSubmitButton: WordSubmitButtonState(
        areReactionsOpen: false,
        favoriteReactions: [
          Reaction(
            rawValue: "😇"
          ),
          Reaction(
            rawValue: "😡"
          ),
          Reaction(
            rawValue: "😭"
          ),
          Reaction(
            rawValue: "😕"
          ),
          Reaction(
            rawValue: "😏"
          ),
          Reaction(
            rawValue: "😈"
          ),
        ],
        isClosing: false,
        isSubmitButtonPressed: false
      )
    ),
    onboarding: nil,
    home: HomeState(
      changelog: nil,
      dailyChallenges: nil,
      hasChangelog: false,
      hasPastTurnBasedGames: false,
      nagBanner: nil,
      route: nil,
      savedGames: SavedGamesState(
        dailyChallengeUnlimited: nil,
        unlimited: InProgressGame(
          cubes: Three<Three<Three<Cube>>>(
            rawValue: [
              Three<Three<Cube>>(
                rawValue: [
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "F",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "G",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "X",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "E",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "C",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "R",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "Z",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "O",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "C",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "C",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "V",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "N",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "F",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "Z",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "T",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "T",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "T",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "X",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "T",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "G",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "I",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "R",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "N",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "I",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "A",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "D",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                ]
              ),
              Three<Three<Cube>>(
                rawValue: [
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "R",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "K",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "D",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "V",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "G",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "I",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "G",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "C",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "S",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "I",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "I",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "E",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "N",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "R",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "S",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "E",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "T",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "I",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "R",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "A",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "B",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "M",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "V",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "G",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                ]
              ),
              Three<Three<Cube>>(
                rawValue: [
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "O",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "S",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "I",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "S",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "E",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "L",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "R",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "R",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "K",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "H",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "W",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "N",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "O",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "C",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                  Three<Cube>(
                    rawValue: [
                      Cube(
                        left: CubeFace(
                          letter: "N",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "C",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "E",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "K",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "E",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "N",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                      Cube(
                        left: CubeFace(
                          letter: "O",
                          side: Side.left,
                          useCount: 0
                        ),
                        right: CubeFace(
                          letter: "S",
                          side: Side.right,
                          useCount: 0
                        ),
                        top: CubeFace(
                          letter: "S",
                          side: Side.top,
                          useCount: 0
                        ),
                        wasRemoved: false
                      ),
                    ]
                  ),
                ]
              ),
            ]
          ),
          gameContext: GameContext.solo,
          gameMode: GameMode.unlimited,
          gameStartTime: 2021-08-20T22:08:25Z,
          _language: Language.en,
          moves: Moves(
            rawValue: [
            ]
          ),
          secondsPlayed: 0
        )
      ),
      settings: SettingsState(
        alert: nil,
        buildNumber: nil,
        cubeShadowRadius: 50.0,
        developer: DeveloperSettings(
          currentBaseUrl: BaseUrl.production
        ),
        enableCubeShadow: true,
        enableNotifications: false,
        fullGameProduct: nil,
        fullGamePurchasedAt: nil,
        isPurchasing: false,
        isRestoring: false,
        sendDailyChallengeReminder: true,
        sendDailyChallengeSummary: true,
        showSceneStatistics: false,
        stats: StatsState(
          averageWordLength: nil,
          gamesPlayed: 0,
          highestScoringWord: nil,
          highScoreTimed: nil,
          highScoreUnlimited: nil,
          isAnimationReduced: false,
          isHapticsEnabled: true,
          longestWord: nil,
          route: nil,
          secondsPlayed: 0,
          wordsFound: 0
        ),
        userNotificationSettings: nil,
        userSettings: UserSettings(
          appIcon: nil,
          colorScheme: ColorScheme.system,
          enableGyroMotion: true,
          enableHaptics: true,
          enableReducedAnimation: false,
          musicVolume: 1.0,
          soundEffectsVolume: 1.0
        )
      ),
      turnBasedMatches: [
      ],
      weekInReview: nil
    )
  )
```

</details>

<br>

With the new improvements from [Custom Dump](https://github.com/pointfreeco/swift-custom-dump) this diff is now only 40 lines!

```diff
received action:
  AppAction.currentGame(
    GameFeatureAction.game(
      GameAction.tap(
        UIGestureRecognizer.State.began,
        1.2.2@left
      )
    )
  )
  AppState(
    game: GameState(
      activeGames: ActiveGamesState(…),
      alert: nil,
      bottomMenu: nil,
      cubes: […],
      cubeStartedShakingAt: nil,
      gameContext: GameContext.solo,
      gameCurrentTime: Date(2021-08-20T22:08:32.917Z),
      gameMode: GameMode.unlimited,
      gameOver: nil,
      gameStartTime: Date(2021-08-20T22:08:25.312Z),
      isDemo: false,
      isGameLoaded: true,
      isOnLowPowerMode: false,
      isPanning: false,
      isSettingsPresented: false,
      isTrayVisible: false,
      language: Language.en,
      moves: Moves(rawValue: []),
-     optimisticallySelectedFace: nil,
+     optimisticallySelectedFace: 1.2.2@left,
      secondsPlayed: 7,
      selectedWord: [
+       [0]: 1.2.2@left
      ],
      selectedWordIsValid: false,
      upgradeInterstitial: nil,
      wordSubmitButton: WordSubmitButtonState(…)
    ),
    onboarding: nil,
    home: HomeState(…)
  )
```

This makes it much easier to see exactly what changed when an action is sent.

## Try it today

We've already started to get a lot of use out of [Custom Dump](https://github.com/pointfreeco/swift-custom-dump), but we think there is so much more than can be done. Give it a spin today to develop new, creative debugging and testing tools for your team and others today!
"""#,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 62,
  publishedAt: Date(timeIntervalSince1970: 1629694800),
  title: "Open Sourcing: Custom Dump"
)
