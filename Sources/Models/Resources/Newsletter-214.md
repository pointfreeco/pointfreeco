> Preamble: This week we are running a Point-Free blog bonanza to highlight new things happening
> across our ecosystem.
> * [**DebugSnapshots now logs SwiftUI bindings**](/blog/posts/214-debugsnapshots-now-logs-swiftui-bindings)
>
> Coming soon:
> * New macros for SwiftNavigation<!--](/blog/posts/215-new-macros-for-swiftnavigation)-->
> * Trait-ifying our libraries<!--](/blog/posts/216-trait-ifying-our-libraries)-->
> * Proposing task-local test traits for Swift Testing<!--](/blog/posts/217-proposing-task-local-test-traits-for-swift-testing)-->
> * Shipping Xcode 27 support<!--](/blog/posts/218-shipping-xcode-27-support)-->

Earlier this year we announced [DebugSnapshots][debug-snapshots-gh], first in private preview for
Point-Free Max members and then more broadly in [public beta][debug-snapshots-beta-post]. It is a
tool for exhaustively testing reference types and for getting focused diffs of how your models
change over time.

Today we are happy to highlight a new addition in [DebugSnapshots 0.3.0][debug-snapshots-030]:
the library can now log changes made to your model through SwiftUI bindings.

## A better view into binding-driven changes

DebugSnapshots already made it possible to log how a model changed after a method call:

```swift
@DebugSnapshot(.logChanges)
@Observable
final class SettingsModel {
  var displayName = ""
  var notificationsEnabled = false

  func resetButtonTapped() {
    displayName = ""
  }
}
```

Each time `resetButtonTapped` is called it will log to the console exactly what changed:

```diff
 resetButtonTapped():
   #1 SettingsModel.DebugSnapshot(
-    displayName: "Blob",
+    displayName: "",
     notificationsEnabled: false
   )
```

This works great for methods, but many state changes in a SwiftUI app come from bindings instead
of methods.

Typing into a `TextField`, toggling a `Toggle`, or scrubbing a `Slider` mutate model state directly
without going through a named method on your type. Those edits can be important, and now 
DebugSnapshots can show them to you too.

For example, suppose a view binds directly to the model:

```swift
struct SettingsView: View {
  @Bindable var model: SettingsModel

  var body: some View {
    Form {
      TextField("Display name", text: $model.displayName)
    }
  }
}
```

With DebugSnapshots 0.3.0, edits made through that `TextField` can now produce the same focused
diffs you get from method calls:

```diff
 Binding:
   #1 SettingsModel.DebugSnapshot(
-    displayName: "Blo",
+    displayName: "Blob",
     notificationsEnabled: false
   )
```

This can be quite helpful when working with large observable models in SwiftUI.

## A reminder that DebugSnapshots exists!

This feature is a good excuse to remind everyone what DebugSnapshots is all about. It brings two 
big ideas to reference types:

* It can log precise diffs of how a model changes as methods are called and bindings mutated.
* It can power exhaustive tests that assert exactly how a class changed, and nothing more.

Both of these are difficult to do, in general, for reference types because their state cannot 
easily be inspected before and after an action takes place so that one can see exactly what changed.
Value types are naturally easy to compare in tests, but reference types are not. DebugSnapshots 
generates a snapshot of the data you care about so that you can exhaustively test exactly
what happens in a reference:

```swift
@Test func increment() {
  let model = CounterModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
  }
}
```

This test will only pass if the `count` of the model changes to 1 and if nothing else in the model
changes. It is an incredibly powerful tool for anyone building modern SwiftUI features around 
reference types, as is the case with `@Observable`, and it deserves more attention than we have 
given it so far!

## Born in beta previews

DebugSnapshots also represents something broader for us. It was born out of our new
[Point-Free Beta Previews][beta-previews-post], which are available to all [Point-Free Max]
members. That program lets us get new tools into the hands of people building real applications,
learn from their feedback, and iterate before a public release.

[Point-Free Max]: /pricing

DebugSnapshots was one of the first libraries we previewed there, and it has already helped shape
another major preview we currently have underway: the [next generation of the Composable
Architecture][tca2-post].

So if you have not tried DebugSnapshots yet, now is a great time. Update to
[version 0.3.0][debug-snapshots-030], drop it onto one of your models, and see how much easier it
becomes to understand your state transitions.

[beta-previews-post]: /blog/posts/204-introducing-point-free-beta-previews
[debug-snapshots-beta-post]: /blog/posts/207-debugsnapshots-public-beta
[debug-snapshots-gh]: https://github.com/pointfreeco/swift-debug-snapshots
[debug-snapshots-030]: https://github.com/pointfreeco/swift-debug-snapshots/releases/tag/0.3.0
[tca2-post]: /blog/posts/206-beta-preview-composablearchitecture-2-0
