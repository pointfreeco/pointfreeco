The next major release of the [Composable Architecture][tca-gh] will be our biggest yet. We will
address many long-standing pain points reported over the past 6 years, add most of the features 
requested during that time, all the while bringing its tools more in line with SwiftUI and making 
everything more performant.

The Composable Architecture 2.0 does not have a release date yet, but we already know that some APIs
from the 1.x version are changing shape or going away entirely. Rather than wait for 2.0 to land
and tackle everything at once, there is work you can do today to prepare your app.

The easiest way to get started is to update your dependency to [version 1.25][tca-1.25-release]
and enable the `ComposableArchitecture2Deprecations` package trait. Doing so turns a large
collection of "soft" deprecations into "hard" deprecations, which means Xcode and SwiftPM will
actively point out the code you should modernize now. If you work through those warnings
incrementally, your eventual move to 2.0 will be much smoother.

## Enabling the trait

### SwiftPM

If you manage dependencies in `Package.swift`, update your dependency like this:

```swift
.package(
  url: "https://github.com/pointfreeco/swift-composable-architecture",
  from: "1.25.0",
  traits: ["ComposableArchitecture2Deprecations"]
)
```

That is all it takes. Once enabled, any APIs participating in the trait will start producing
deprecation warnings. You can pick off these deprecations slowly over time by enabling the
trait for a bit, and then disabling when you need a break.

### Xcode 26.4 beta

If you manage packages in Xcode, Xcode 26.4 beta adds support for package traits directly in
project settings. Select the `swift-composable-architecture` package dependency in your project
and enable the `ComposableArchitecture2Deprecations` trait. From there Xcode will surface the same
warnings you would get from the `Package.swift` configuration above.

![Xcode 26.4 beta package settings showing the ComposableArchitecture2Deprecations trait enabled for the swift-composable-architecture dependency.](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/4588676c-4e46-43b6-15e8-e051384d4c00/public)

## What gets deprecated?

Some deprecations in 1.25 are always active, and some are only activated by the trait. The
[1.25 migration guide][1.25-migration-guide] has the full list, including everything that was hard
deprecated in the release.

A few of the trait-driven deprecations include:

- `Effect<Action>` becoming `EffectOf<Feature>`
- `Send<Action>` becoming `SendOf<Feature>`
- `store.publisher` being replaced by observation tools such as `observe` and `Observations`
- Older `onChange` and `$store.scope(state: \.destination, ...)` forms giving way to the APIs
  that will remain in 2.0

For example, this helper will become deprecated when the trait is enabled:

```diff
-func sharedHelper(state: inout State) -> Effect<Action> {
+func sharedHelper(state: inout State) -> EffectOf<Self> {
   .none
 }
```

This will pave the way for a much more powerful `Effect` type in the Composable Architecture 2.0.

And the older `onChange` style will likewise get flagged:

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

## Using SwiftPM traits for soft+hard deprecations

The `ComposableArchitecture2Deprecations` trait is also quite unique! Traits are often discussed
as a way to opt in to extra functionality, but they can also be used to opt in to stricter
guidance.

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

This accomplishes 3 things at once:

* Ship a release of our library that remains source compatible for everyone.
* Silently deprecate APIs so that users do not add more usages of them and so that docs reflect
  their status correctly.
* And finally, allow our users to opt into _hard_ deprecations so that they can fix them on
  their own timeline.

It's the perfect fit for a major migration: you can turn the warnings on when you are ready, chip 
away at them over time, and leave your code base in a much better spot for the eventual 2.0 upgrade.

## Get started today

If you want to put your app in the best possible position for Composable Architecture 2.0, update
to [1.25][tca-1.25-release], enable `ComposableArchitecture2Deprecations`, and start working
through the warnings. Keep the [1.25 migration guide][1.25-migration-guide] handy so that you can
see the full list of hard deprecations and the recommended replacements.

[1.25-migration-guide]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.25
[tca-1.25-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.25.0
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
