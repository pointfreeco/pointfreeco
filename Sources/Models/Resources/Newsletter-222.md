We are excited to announce the newest addition to [Beta Previews](/beta-previews): **LazyState**, a
micro-library that closes a gap `@State` left open. It provides a `@LazyState` macro that allows
state in your SwiftUI views to be initialized dynamically, using data passed in from the parent view,
while still being initialized lazily and only once per view lifetime.

This is a problem that Apple explicitly decided not to solve, and their recommended workaround
leaks complexity into every view that needs it. We think the problem deserves a solution, and it 
turns out the tools to build it have been hiding in plain sight for a few years.

We covered all of the details in our [last] [two] episodes, but here's the gist.

[last]: /episodes/ep378-wwdc26-the-state-macro
[two]: /episodes/ep379-wwdc26-the-lazystate-macro

## What is fixed by the @State macro

In case you missed it, at WWDC this year it was announced that the `@State` property wrapper has 
been rewritten as a `@State` macro, and in doing so fixed a long-standing problem in SwiftUI. 
Previously, when declaring state with an initial value directly inline:

```swift
struct LocationSearchSheet: View {
  @State private var completer = LocationSearchCompleter()
  …
}
```

…the `LocationSearchCompleter` would be created every single time the view was re-initialized,
and then immediately discarded. `@State` storage lives for the lifetime of the view's identity, but
a view can be re-initialized many times while its identity stays fixed. The property
wrapper was eager, and so it had no choice but to construct a brand new object each time, only for
SwiftUI to throw it away.

With Xcode 27's `@State` macro, the object is now created lazily, and only once. Any work performed
in the initializer no longer executes needlessly. This is a great improvement, and it even deploys
all the way back to iOS 17.

## What is _not_ fixed by the @State macro

But there is a very common pattern the `@State` macro very specifically does _not_ address:
initializing state from data passed in by the parent view. For example, suppose the
`LocationSearchCompleter` can be configured with some options, say the region it searches. Then
you would not be able to provide a default for the state, and instead would need to delay its
initialization until you have the options, like this:

```swift:3-5
struct LocationSearchSheet: View {
  @State private var completer: LocationSearchCompleter
  init(region: MKCoordinateRegion?) {
    _completer = State(wrappedValue: LocationSearchCompleter(region: region))
  }
}
```

But doing so causes the macro to fall back to the old, eager behavior. A new 
`LocationSearchCompleter` is allocated and discarded every time the view is re-initialized.

Apple actively discourages this pattern, and instead sanctions a different one, which can be seen
in their WWDC sample code: hold the state as an optional, and initialize it in `onAppear`:

```swift
struct LocationSearchSheet: View {
  @State private var completer: LocationSearchCompleter?
  var region: MKCoordinateRegion?
  var body: some View {
    List {
      ForEach(completer?.results ?? []) { result in
        …
      }
    }
    .onAppear {
      completer = LocationSearchCompleter(region: region)
    }
  }
}
```

This "fixes" the laziness problem, but introduces all new problems:

- Your view must hold onto extra state, like `region` above, whose only purpose is to be passed
  along to the model at a later time.
- The optionality of the model infects every part of your view, forcing you to `if let` unwrap,
  optionally chain, and nil-coalesce (`completer?.results ?? []`) everywhere.
- You cannot derive bindings through an optional in the normal way, pushing you toward the
  `Binding(get:set:)` initializer, which can cause [animation and performance
  problems][binding-get-set].
- You will often be forced to wrap your view in a `VStack`, `HStack`, `ZStack`, etc., just to have 
  something to attach `onAppear` to.
  
[binding-get-set]: /clips/d9a1749e9668d3b3d44646afdf76f56e

That is a lot of complexity leaked into a view just to create some dynamic state.

## Introducing `@LazyState`

It turns out that the `@State` macro's laziness is powered by a type called `LazyState` that has
been public (though hidden and undocumented) in SwiftUI since iOS 17, which is how the new 
`@State` macro back-deploys to older platforms. And unlike `@State`, it is perfectly fine to create a 
`LazyState` in a view's initializer. In fact, this is exactly what the `@State` macro itself does 
under the hood if you expand the macro code and remove the superfluous details.

Our new library packages this pattern up into a single macro:

```swift
import LazyState

struct LocationSearchSheet: View {
  @LazyState private var completer: LocationSearchCompleter
  init(region: MKCoordinateRegion?) {
    _completer = LazyState { LocationSearchCompleter(region: region) }
  }
}
```

The model is created lazily, exactly once per view lifetime, using data handed to the view from
the outside. No optionals, no `onAppear`, no stashed-away `region` property, and no unstructured
`Binding(get:set:)`. You can even derive bindings the normal way, _via_ `$completer`, just as you
would with `@State`.

## Cleaning up Apple's WWDC demo

To see how `@LazyState` can improve a code base, look no further than Apple's [Sample Trips] demo
app from WWDC26. The `TripMap` view falls into all of the traps we mentioned above: optional state 
in the view, `onAppear` to create the state dynamically, `nil`-coalescing throughout the view, and 
ad hoc bindings with `Binding.init(get:set:)`.

[Sample Trips]: https://developer.apple.com/documentation/CoreData/adopting-swiftdata-for-a-core-data-app

`@LazyState` fixes all of that!

* Hold onto state as a non-optional, and initialize it in the view:

  ```diff
  -@State private var mapController: MapCameraController?
  +@LazyState private var mapController: MapCameraController
  ```

* Create the state in the view's initializer with data passed in from the parent:

  ```diff
   init(
     selection: Binding<Trip?>,
  +  modelContext: ModelContext
   ) {
     _selection = selection
  +  _mapController = LazyState { MapCameraController(modelContext: modelContext) }
   }
  ```
  
* Get rid of the `onAppear`:

  ```diff
  -.onAppear {
  -  self.mapController = MapCameraController(modelContext: modelContext)
  -}
  ```

* Get rid of the ad hoc binding:

  ```diff
  -private var cameraPosition: Binding<MapCameraPosition> {
  -  Binding(
  -    get: { mapController?.cameraPosition ?? .automatic },
  -    set: { mapController?.cameraPosition = $0 }
  -  )
  -}
  ```
  
* Derive bindings directly off the model in the usual way:

  ```diff
  -Map(position: cameraPosition, selection: $mapSelection) {
  +Map(position: $mapController.cameraPosition, selection: $mapSelection) {
     …
   }
  ```

* Access data off the model directly without optional-chaining and `nil`-coalescing:

  ```diff
  -ForEach(mapController?.trips ?? []) { trip in
  +ForEach(mapController.trips) { trip in
    …
  }
  ```

This code is simpler, easier to read, and minimizes the number of choices we have to make for
handling optional data.

## `@LazyState` is vanilla SwiftUI

We want to stress that our library does not employ any shenanigans, private APIs, or fragile
trickery to accomplish this. The `@LazyState` macro works exactly like the `@State` macro, except
it extends laziness to state that does not have a default. When you strip away all of the 
ornamentation from `@State`'s expansion, it is nothing more than:

```swift
private var model: Model { _model.wrappedValue }
private var _model: LazyState<Model>
private var $model: Binding<Model> { _model.projectedValue }
```

…which is exactly what `@LazyState` does too. The `LazyState` type above is what is doing the real
work here, and it has been in the SwiftUI framework since the iOS 17 era of Apple's platforms.
The only way for this code to stop being legitimate is if the `@State` macro itself changes how it 
expands, in which case we would simply follow suit.

And so you may wonder why Apple does not provide this tool if it is so easy to create ourselves.
Well, since Apple and SwiftUI are black boxes, we can't really know for sure. We have read 
comments in the Swift forums and Apple developer forums that one reason is that it may surprise 
people that if the parent view recreates the child with a new argument, that it will not propagate 
down to the state in the child. However, this behavior is clear if you understand how SwiftUI view 
lifecycles work, and this behavior is the same with the `onAppear` pattern that Apple promotes.

## Join the beta

`@LazyState` is available _today_ as a [Beta Preview](/beta-previews), exclusively for
[Point-Free Max](/pricing) members. Join the beta with a single click and you will receive a GitHub
invitation to the private repo, where you can pull the library into your projects, open issues,
and help shape its APIs before it goes public.

And if you want to see the full story of how we discovered `LazyState` by dissecting the guts of
the new `@State` macro, be sure to watch our [last] [two] episodes.

[last]: /episodes/ep378-wwdc26-the-state-macro
[two]: /episodes/ep379-wwdc26-the-lazystate-macro

