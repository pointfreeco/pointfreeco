This is the first of two [Beta Previews](/beta-previews) we are launching today as part of our new
[Point-Free Max](/pricing) membership tier. Read the
[announcement post](/blog/posts/204-introducing-point-free-beta-previews) for more on what Beta
Previews are and how to get access.

---

**DebugSnapshots** is a brand new library that solves a problem that comes up constantly when
building apps with reference types, such as `@Observable` classes: how do you test them?

Classes cannot be meaningfully made `Equatable` due to their reference characteristics. It is
_not correct_ to use their underlying data for the `Equatable` conformance (and doing so can cause
[many problems](/collections/back-to-basics/equatable-and-hashable)), but they often hold data that
you do want to assert on as it changes over time. DebugSnapshots gives you a way to assert on the
_content_ of your models, not their identity.

Once you apply the `@DebugSnapshot` macro to your class, the library generates test-friendly
snapshot of the class's underlying data. You can then use the `expect` function to
exhaustively assert how the data changes in the class after an action takes place.

Take for instance a feature model that allows you to increment a count and then fetch a fact
for that number:

```swift
@DebugSnapshot
@Observable
final class NumberFactModel {
  var count = 0
  var fact: String?
  var isLoading = false

  func incrementButtonTapped() {
    count += 1
    fact = nil
  }

  func factButtonTapped() async throws {
    isLoading = true
    defer { isLoading = false }
    fact = try await factClient.fetch(count)
  }
}
```

> Note: We are assuming we have a `factClient` dependency that can fetch facts for a number. You
may want to use our [Dependencies] library to control that dependency.

[Dependencies]: https://github.com/pointfreeco/swift-dependencies

Now you can write tests that exhaustively describe how the model changes when its various methods
are invoked:

```swift
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
  }
}
```

The first trailing closure allows you to execute any logic in your model, and the second trailing
closure allows you to assert how the underlying data in the model changed from _before_ that logic
to _after_ that logic. The `$0` handed to the closure is actually a test-friendly representation of
the data in the class, and that's how you can exhaustively assert on this state even though it's
held in a reference type.

If you forget to assert a change, the test fails with a clear diff showing exactly what you missed:

```swift:7:fail
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 2
  }
}
```

> Failed: Issue recorded: Expected changes do not match: ...
>
> ```
>     #1 NumberFactModel.DebugSnapshot(
>   −   count: 2,
>   +   count: 1,
>       fact: nil,
>       isLoading: false
>     )
>
> (Expected: −, Actual: +)
> ```

This is giving you exhaustive testing for classes, something that was previously only possible with
value types.

The macro is also smart about what it includes. It automatically skips private properties,
underscored properties, and computed properties. But, you can use `@DebugSnapshotTracked` to include
any of those properties if you wish. This can be incredibly powerful to gain exhaustive testing on
even computed properties:

```swift
@DebugSnapshot
@Observable
final class NumberFactModel {
  …
  @DebugSnapshotTracked
  var countIsEven: Bool {
    count.isMultiple(of: 2)
  }
}
```

Now when using `expect` you must assert how the computed property changes, otherwise you will
get a test failure:

```swift
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
    $0.countIsEven = false
  }
}
```

You can also apply the `@DebugSnapshotConvertible` macro to reference-type properties in order to
recursively snapshot nested `@DebugSnapshot` models:

```swift
@DebugSnapshot
@Observable
final class AppModel {
  @DebugSnapshotConvertible var settings: SettingsModel
  @DebugSnapshotConvertible var profile: ProfileModel
  …
}
```

Then in tests you can perform a nested mutation to assert how state changes:

```swift
expect(model) {
  model.disableNotificationsButtonTapped()
} changes: {
  $0.settings.isEmailOn = false
  $0.settings.isPushOn = false
  $0.settings.isTextOn = false
}
```

<!--
## SwiftData

DebugSnapshots also works seamlessly with SwiftData. If you aren't ready to adopt
[SQLiteData](https://github.com/pointfreeco/sqlite-data) just yet, we've got your back.

Just apply `@DebugSnapshot` alongside `@Model`, mark your relationships with
`@DebugSnapshotConvertible`, and use `@DebugSnapshotIgnored` on inverse relationships to avoid
circular references:

```swift
@DebugSnapshot
@Model final class RemindersList {
  var title: String

  @DebugSnapshotConvertible
  @Relationship(deleteRule: .cascade, inverse: \Reminder.list)
  var reminders: [Reminder] = []
}

@DebugSnapshot
@Model final class Reminder {
  var title: String
  var isCompleted: Bool
  var notes: String
  @DebugSnapshotIgnored var list: RemindersList?
}
```

Now you can exhaustively test how your SwiftData models change, including across relationships:

```swift
@Test func addReminder() throws {
  let schema = Schema([
    Reminder.self,
    RemindersList.self,
  ])
  let container = try ModelContainer(
    for: schema,
    configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
  )
  let context = ModelContext(container)

  let list = RemindersList(title: "Groceries", color: "blue")
  context.insert(list)

  let reminder = Reminder(
    title: "Oat milk",
    isCompleted: false,
    notes: "The good kind"
  )
  context.insert(reminder)

  expect(list) {
    list.reminders.append(reminder)
  } changes: {
    $0.reminders = [
      Reminder.DebugSnapshot(
        title: "Oat milk",
        isCompleted: false,
        notes: "The good kind"
      )
    ]
  }
}
```

The diff output even traces through nested relationships, so if you forget to assert on a change
in a related model you'll get a clear failure showing exactly what was missed.
-->

---

This is only a small preview of what the library is capable of. Join the
[beta preview](/beta-previews) to try it out and help shape the API before it goes public.
