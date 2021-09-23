import Foundation

extension Episode {
  static let ep71_composableStateManagement_higherOrderReducers = Episode(
    blurb: """
We will explore a form of reducer composition that will take our applications to the _next level_. Higher-order reducers will allow us to implement broad, cross-cutting functionality on top of our applications with very little work, and without littering our application code with unnecessary logic. And, we'll finally answer "what's the point?!"
""",
    codeSampleDirectory: "0071-composable-state-management-hor",
    exercises: _exercises,
    id: 71,
    length: 32*60 + 38,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1566799200),
    references: [
      .pointFreePullbackAndContravariance,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 71,
    subtitle: "Higher-Order Reducers",
    title: "Composable State Management",
    trailerVideo: .init(
      bytesLength: 54187542,
      vimeoId: 355452269,
      vimeoSecret: "56afb7b0c522691a881fd757ead9eff17c34ac49"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // todo: now favoritePrimesReducer no longer needs activity feed
  // todo: now primeModalReducer no longer needs activity feed
  // todo: simplify states
  .init(
    problem: #"""
Create a higher-order reducer with the following signature:

```swift
func filterActions<Value, Action>(_ predicate: @escaping (Action) -> Bool)
  -> (@escaping (inout Value, Action) -> Void)
  -> (inout Value, Action) -> Void {
  fatalError("Unimplemented")
}
```

This allows you to transform any reducer into one that only listens to certain actions.
"""#,
    solution: #"""
```swift
func filterActions<Value, Action>(_ predicate: @escaping (Action) -> Bool)
  -> (@escaping (inout Value, Action) -> Void)
  -> (inout Value, Action) -> Void {
    return { reducer in
      return { value, action in
        if predicate(action) {
          reducer(&value, action)
        }
      }
    }
}
```
"""#),
  .init(
    problem: #"""
Create a higher-order reducer that adds the functionality of undo to any reducer. You can start by providing new types to augment the existing state and actions of a reducer:

```swift
struct UndoState<Value> {
  var value: Value
  var history: [Value]
  var canUndo: Bool { !self.history.isEmpty }
}

enum UndoAction<Action> {
  case action(Action)
  case undo
}
```

And then implement the following function to implement the functionality:

```swift
func undo<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
  fatalError("Unimplemented")
}
```
"""#,
    solution: #"""
```
func undo<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
  return { undoState, undoAction in
    switch undoAction {
    case let .action(action):
      var currentValue = undoState.value
      reducer(&currentValue, action)
      undoState.history.append(currentValue)
    case .undo:
      guard undoState.canUndo else { return }
      undoState.value = undoState.history.removeLast()
    }
  }
}
```
"""#),
  .init(
    problem: #"""
Enhance the undo higher-order reducer so that it limits the size of the undo history.
"""#,
    solution: #"""
```swift
func undo<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void,
  limit: Int
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
  return { undoState, undoAction in
    switch undoAction {
    case let .action(action):
      var currentValue = undoState.value
      reducer(&currentValue, action)
      undoState.history.append(currentValue)
      if undoState.history.count > limit {
        undoState.history.removeFirst()
      }
    case .undo:
      guard undoState.canUndo else { return }
      undoState.value = undoState.history.removeLast()
    }
  }
}
```
"""#),
  .init(
    problem: #"""
Enhance the undo higher-order reducer to also allow redoing.
"""#,
    solution: #"""
In order to keep track of redoes, the state can be modified to track what's been undone and whether or not there are things to be redone:

```swift
struct UndoState<Value> {
  var value: Value
  var history: [Value]
  var undone: [Value]
  var canUndo: Bool { !self.history.isEmpty }
  var canRedo: Bool { !self.undone.isEmpty }
}
```

Meanwhile, we need a new action to redo:

```swift
enum UndoAction<Action> {
  case action(Action)
  case undo
  case redo
}
```

And finally, the higher-order reducer must handle the `redo`:

```swift
func undo<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void,
  limit: Int
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
  return { undoState, undoAction in
    switch undoAction {
    case let .action(action):
      var currentValue = undoState.value
      reducer(&currentValue, action)
      undoState.history.append(currentValue)
      undoState.undone = []
      if undoState.history.count > limit {
        undoState.history.removeFirst()
      }
    case .undo:
      guard undoState.canUndo else { return }
      undoState.undone.append(undoState.value)
      undoState.value = undoState.history.removeLast()
    case .redo:
      guard undoState.canRedo else { return }
      undoState.history.append(undoState.value)
      undoState.value = undoState.undone.removeFirst()
    }
  }
}
```
"""#),
  .init(problem: """
Add undo and redo buttons to the `CounterView`, and make them undo and redo only the counter actions on that screen.
""")
]
