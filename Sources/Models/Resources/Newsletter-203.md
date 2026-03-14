SwiftPM traits are typically thought of as a way to opt in to extra functionality, but we have
been using them for something a little different: library evolution.

When preparing a library for a major release, there is often a tension between two competing goals.
On the one hand, you want to start steering users away from APIs that are going to change or be
removed. On the other hand, you do not necessarily want every user of the library to be flooded
with warnings the moment you begin that work.

SwiftPM traits give us a nice middle ground. A library can "soft" deprecate APIs by default, while
also offering an opt-in trait that upgrades those deprecations into hard deprecations. That gives
users a compiler-assisted migration path when they are ready, without forcing the migration on
everyone all at once.

We think this is a novel and powerful use of SwiftPM traits, and we are now using it in
preparation for the next major release of the [Composable Architecture][tca-gh].

## A case study: preparing for Composable Architecture 2.0

The next major release of the Composable Architecture will be our biggest yet. Some APIs from the
1.x series are changing shape, and some are going away entirely. Composable Architecture 2.0 does
not yet have a release date, but there is work you can do today to prepare your application.

To get a head start, update your dependency to [version 1.25][tca-1.25-release] and enable the
`ComposableArchitecture2Deprecations` trait (see below for how to do that in SwiftPM and Xcode 
26.4+). Doing so upgrades a collection of soft deprecations into hard deprecations, allowing Xcode 
and SwiftPM to point out the code you should modernize now.

If you work through those warnings incrementally, your eventual move to 2.0 will be much smoother.

## How the trait works

Inside the Composable Architecture we use the trait to upgrade soft deprecations into hard
deprecations for APIs that are changing or going away in 2.0:

```swift
#if ComposableArchitecture2Deprecations
  @available(*, deprecated, message: "Use 'EffectOf<Feature>' instead")
#else
  @available(iOS, deprecated: 9999.0, message: "Use 'EffectOf<Feature>' instead")
  @available(macOS, deprecated: 9999.0, message: "Use 'EffectOf<Feature>' instead")
  @available(tvOS, deprecated: 9999.0, message: "Use 'EffectOf<Feature>' instead")
  @available(watchOS, deprecated: 9999.0, message: "Use 'EffectOf<Feature>' instead")
#endif
public typealias Effect = _Effect
```

This gives us a few benefits all at once:

- The library remains source compatible by default.
- The APIs are silently marked deprecated in documentation and in the type system.
- Users who want to prepare early can opt in to much hard deprecations.
- The migration can happen gradually by enabling and disabling the trait when needed, rather than 
  all at once at the moment 2.0 ships.

## Trying it in Composable Architecture today

### SwiftPM

If you manage dependencies in `Package.swift`, update your dependency like this:

```swift
.package(
  url: "https://github.com/pointfreeco/swift-composable-architecture",
  from: "1.25.0",
  traits: ["ComposableArchitecture2Deprecations"]
)
```

### Xcode 26.4 beta

If you manage packages in Xcode, Xcode 26.4 beta adds support for package traits directly in
project settings. Select the `swift-composable-architecture` package dependency in your project and
enable the `ComposableArchitecture2Deprecations` trait.

![Xcode 26.4 beta package settings showing the ComposableArchitecture2Deprecations trait enabled for the swift-composable-architecture dependency.](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/4588676c-4e46-43b6-15e8-e051384d4c00/public)

## The kinds of migrations this enables

Here are a few examples of API transitions that become much easier to stage with this technique.

The `Effect<Action>` type alias is being replaced by `EffectOf<Feature>`:

```diff
-func sharedHelper(state: inout State) -> Effect<Action> {
+func sharedHelper(state: inout State) -> EffectOf<Self> {
   .none
 }
```

This paves the way for a more powerful `Effect` type in the Composable Architecture.

The older `onChange` style is also being replaced with a more streamlined form:

```diff
 BindingReducer()
-  .onChange(of: \.settings.enableHaptics) { oldValue, newValue in
-    Reduce { state, action in
-      .run { send in
-        // Persist the new value...
-      }
-    }
-  }
+  .onChange(of: \.settings.enableHaptics) { oldValue, state in
+    .run { [newValue = state.settings.enableHaptics] send in
+      // Persist the new value...
+    }
+  }
```

This requires less indentation, and `onChange` in 2.0 will behave more like `onChange` in SwiftUI,
where it reacts to _any_ change made in feature state, not just changes made by the reducer it is
attached to.

Other trait-driven deprecations include:

- `Send<Action>` becoming `SendOf<Feature>`
- `store.publisher` being replaced by observation tools such as `observe` and `Observations`
- Older `$store.scope(state: \.destination, ...)` forms giving way to the APIs that will remain in
  2.0

For the full list of changes, including everything that was hard deprecated in 1.25, see the
[1.25 migration guide][1.25-migration-guide].

## Get started today

If you maintain a library, we think this pattern is worth considering whenever you need to prepare
users for a major release. And if you use the Composable Architecture, you can try this approach 
right now: update to [1.25][tca-1.25-release], enable `ComposableArchitecture2Deprecations`, and 
start working through the warnings at your own pace.

[1.25-migration-guide]: https://github.com/pointfreeco/swift-composable-architecture/blob/main/Sources/ComposableArchitecture/Documentation.docc/Articles/MigrationGuides/MigratingTo1.25.md
[tca-1.25-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.25.0
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
