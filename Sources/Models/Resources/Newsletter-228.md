We are excited to announce that [LazyState] has officially graduated from [Beta Previews] and is
now available for everyone to use as version **1.0**.

This year Apple announced that `@State` had been changed to a macro in order to fix a long-standing
problem with the tool in a backwards compatible manner. However, Apple specifically chose to not
fix one problem, that of dynamically created state, and so our LazyState library fills that last
remaining hole. Thanks to the feedback from our [Max members] it is now ready for wider use.

[Max members]: /subscribe/personal?plan=max
[LazyState]: https://github.com/pointfreeco/swiftui-lazy-state
[Beta Previews]: /beta-previews

## The problem

SwiftUI views are value types. They can be initialized again and again while SwiftUI preserves the
identity and storage of their state behind the scenes. This means the following innocent-looking
code used to perform more work than expected:

```swift
struct LocationSearchSheet: View {
  @State private var completer = LocationSearchCompleter()
  // ...
}
```

Before the new `@State` macro, the `LocationSearchCompleter` would be created every time the view
was re-initialized, only for SwiftUI to discard the new value and keep using the original state.
The macro fixes this for inline defaults by making the state lazy, so the initial value is created
only once per view lifetime.

But many real models cannot be created with a static inline default. They need data from the parent
view, such as the map region to search:

```swift
struct LocationSearchSheet: View {
  @State private var completer: LocationSearchCompleter

  init(region: MKCoordinateRegion?) {
    _completer = State(wrappedValue: LocationSearchCompleter(region: region))
  }
}
```

Initializing state using `State.init(wrappedValue:)` still falls back to the old, eagerly
evaluated style of state, which brings the old problem right back.

Apple's recommended workaround is to make the state optional and initialize it later, often in
`onAppear`:

```swift:2,3,7,11-13
struct LocationSearchSheet: View {
  @State private var completer: LocationSearchCompleter?
  var region: MKCoordinateRegion?

  var body: some View {
    List {
      ForEach(completer?.results ?? []) { result in
        // ...
      }
    }
    .onAppear {
      completer = LocationSearchCompleter(region: region)
    }
  }
}
```

This preserves laziness, but at a cost:

* The model becomes optional even when the view cannot meaningfully render without it.
* The initialization inputs have to be stored as extra properties just so they can be used later.
* Optional chaining, `if let`, and nil coalescing spread through the body.
* Bindings become harder to derive, often pushing you toward `Binding(get:set:)`, which can lose
  important SwiftUI behavior such as transaction and animation context.
* Views can need extra containers merely to have somewhere to attach lifecycle modifiers.

That is a lot of incidental complexity just to create a piece of state dynamically and lazily.

## The solution

LazyState gives this pattern a name and a tiny API:

```swift
import LazyState

struct LocationSearchSheet: View {
  @LazyState private var completer: LocationSearchCompleter

  init(region: MKCoordinateRegion?) {
    _completer = LazyState { LocationSearchCompleter(region: region) }
  }
  
  …
}
```

The model is created lazily, exactly once for the lifetime of the view's identity, while still
being configured from data passed in by the parent. The view gets to hold the model as a
non-optional value, access it directly, and derive bindings in the normal way through
`$completer`.

This is especially useful for observable models, controllers, delegates, formatters, search
completers, expensive caches, and any other stateful object whose construction depends on an input
that is known at initialization time but should not be rebuilt every time the view value is rebuilt.

## Vanilla SwiftUI

LazyState does not rely on private API, runtime tricks, or fragile reflection. The library is a
macro that expands to the same basic shape used by SwiftUI's own `@State` macro, but it exposes the
initializer form that `@State` does not:

```swift
private var model: Model { _model.wrappedValue }
private var _model: LazyState<Model>
private var $model: Binding<Model> { _model.projectedValue }
```

The underlying `LazyState` type has shipped in SwiftUI since the iOS 17 generation of Apple's
platforms, which is how Apple's own `@State` macro can back-deploy its laziness.

## Try it today

LazyState 1.0 is available now from its public GitHub repository:

@Button(https://github.com/pointfreeco/swiftui-lazy-state) {
  Get LazyState 1.0
}

To add it to a Swift package:

```swift
.package(url: "https://github.com/pointfreeco/swiftui-lazy-state", from: "1.0.0")
```

And if you want the full story of how we discovered the underlying tool inside SwiftUI, dissected
the new `@State` macro, and built `@LazyState`, check out the [original beta announcement] and our
two-part WWDC series on [the `@State` macro] and [the `@LazyState` macro].

[original beta announcement]: /blog/posts/223-beta-preview-lazystate
[the `@State` macro]: /episodes/ep378-wwdc26-the-state-macro
[the `@LazyState` macro]: /episodes/ep379-wwdc26-the-lazystate-macro
