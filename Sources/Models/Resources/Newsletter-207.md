We are excited to announce that [DebugSnapshots] is now in public beta! It is a library for
debugging and testing the state of your models, with a particular focus on reference types such as
`@Observable` classes.

[DebugSnapshots]: https://github.com/pointfreeco/swift-debug-snapshots

This is also a milestone for our recently announced [Beta Previews]. DebugSnapshots was one of the
first two libraries we made available privately to Point-Free Max members, and now it is the first
library to graduate from those previews to a public beta.

That private preview gave us a chance to put the library in the hands of people building real apps,
iterate on the API, and make sure the core ideas held up before opening things up more broadly. And
now everyone can try it out.

## Debug your classes with @DebugSnapshot

Classes are necessary when building applications because they allow the state of your features to
evolve over time. Further, the `@Observable` macro only works on classes, which is the de facto tool
for extracting logic and behavior out of SwiftUI views and into a testable unit.

But when a class holds a lot of state, it can be difficult to understand exactly what changed after
an action was performed. You can set breakpoints, sprinkle print statements around, or inspect the
object in the debugger, but none of those tools give you a concise, focused view of the before and
after.

DebugSnapshots gives you a tool that helps with this, and a lot more. Apply the `@DebugSnapshot` 
macro with the `.logChanges` option:

```swift:1
@DebugSnapshot(.logChanges)
@Observable
final class FeatureModel {
  var count = 0
  var favoriteNumbers: [Int] = []

  func incrementButtonTapped() {
    count += 1
  }

  func saveButtonTapped() {
    favoriteNumbers.append(count)
  }
}
```

The macro generates a simple, inert snapshot value that represents the data in your model. And with
`.logChanges` enabled, every method invocation logs a diff of what changed:

```swift
model.incrementButtonTapped()
// incrementButtonTapped():
//     #1 FeatureModel.DebugSnapshot(
//   -   count: 0,
//   +   count: 1,
//       favoriteNumbers: []
//     )
```

> Note: Changes are logged to an `OSLog` so that they are easy to filter for (or filter out), and
> logging only happens in DEBUG mode and never for release builds.

This becomes even more useful when a method changes a collection or some larger value:

```swift
model.saveButtonTapped()
// saveButtonTapped():
//     #1 FeatureModel.DebugSnapshot(
//       count: 1,
//       favoriteNumbers: [
//   +     [0]: 1
//       ]
//     )
```

Under the hood this uses our [CustomDump] library, so diffs stay focused even when your state is
large. If an array contains 100 elements and only one of them changed, the log focuses on the
changed element instead of dumping the entire collection.

[CustomDump]: https://github.com/pointfreeco/swift-custom-dump

If logging every method is too noisy, you can be more precise. Apply `@LogChanges` to a single
method

```swift
@DebugSnapshot
@Observable
final class FeatureModel {
  var count = 0
  var favoriteNumbers: [Int] = []

  @LogChanges
  func incrementButtonTapped() {
    count += 1
  }
}
```

And to be even more precise you can invoke `$logChanges()` anywhere inside the method to see how 
state has changed up to that point:

```swift
@LogChanges
func onAppear() async {
  data = await client.fetch()
  $logChanges("Fetch responded")
  for await value in client.stream() {
    values.append(value)
    $logChanges("Value emitted")
  }
}
```

This makes DebugSnapshots useful even before you write a single test. You can drop it onto a model
and immediately get a running log of how its state evolves.

But testing is where the library really shines…

## Exhaustive tests for classes

Once you have a snapshot of your model's data, you can unlock testing superpowers from the library.

Classes are awkward to test exhaustively. It is not generally correct to make a class `Equatable`
by comparing its stored properties (we talked a lot about that [here]). Classes have identity and
behavior, references can be shared, and equality can quickly become a footgun. But in tests, you
often still want to say: "After this button is tapped, this is exactly how the model's state
changed, and nothing else."

[here]: /collections/back-to-basics/equatable-and-hashable

DebugSnapshots gives you that tool with the `expect` function:

```swift
@Test func increment() async {
  let model = FeatureModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
  }
}
```

This assertion is exhaustive. If some other piece of state changes and you do not account for it,
the test fails with a focused diff. And if you assert the wrong thing, the failure points directly
at the mismatch:

```swift:7:fail
@Test func increment() async {
  let model = FeatureModel()

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
>     #1 FeatureModel.DebugSnapshot(
>   -   count: 2,
>   +   count: 1,
>       favoriteNumbers: []
>     )
>
> (Expected: -, Actual: +)
> ```

This brings a style of testing to reference types that was previously much easier to get with value
types: a single assertion that describes the full state transition of a feature.

## Snapshots you control

The generated snapshot is designed to track the data you usually care about while avoiding things
that are not meaningful to compare. By default, DebugSnapshots ignores private properties,
underscored properties, computed properties, and closures.

You can override those defaults when you need to. Use `@DebugSnapshotTracked` to include a computed
or private property in the generated snapshot:

```swift
@DebugSnapshot
@Observable
final class FeatureModel {
  var count = 0

  @DebugSnapshotTracked
  var countIsEven: Bool {
    count.isMultiple(of: 2)
  }

  func incrementButtonTapped() {
    count += 1
  }
}
```

This will force you to assert on `countIsEven` in tests:

```swift:7,13
@Test func basics() {
  let model = FeatureModel()
  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
    $0.countIsEven = false
  }
  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 2
    $0.countIsEven = true
  }
}
```

And use `@DebugSnapshotIgnored` to leave out data that is not deterministic or not relevant to the
behavior you want to test:

```swift
@DebugSnapshotIgnored var id = UUID()
```

DebugSnapshots also handles nested models. If a model holds on to other debug-snapshottable models,
mark those properties with `@DebugSnapshotConvertible`:

```swift
@DebugSnapshot
@Observable
final class AppModel {
  @DebugSnapshotConvertible var settings: SettingsModel
  @DebugSnapshotConvertible var profile: ProfileModel
}
```

Now a test can make an assertion across the whole tree:

```swift
expect(model) {
  model.disableNotificationsButtonTapped()
} changes: {
  $0.settings.isEmailOn = false
  $0.settings.isPushOn = false
  $0.settings.isTextOn = false
}
```

Enums are supported, too, so you can snapshot navigation state, destinations, and other sum types
alongside your models.

## Try the public beta

DebugSnapshots is available today from its public GitHub repository:

```swift
.package(
  url: "https://github.com/pointfreeco/swift-debug-snapshots",
  from: "0.0.1"
)
```

Then add the `DebugSnapshots` product to any target that wants to define snapshots, log changes, or
write tests with `expect`.

This is still a beta. We expect the API to continue changing as we gather feedback, polish the
documentation, and exercise the library against more real-world code bases. But the core idea has
already proven itself through [Beta Previews], and we are excited for more people to try it out.

Please open [discussions] for questions and API feedback, and [issues] for bugs or documentation
fixes.

[Beta Previews]: /beta-previews
[discussions]: https://github.com/pointfreeco/swift-debug-snapshots/discussions
[issues]: https://github.com/pointfreeco/swift-debug-snapshots/issues
