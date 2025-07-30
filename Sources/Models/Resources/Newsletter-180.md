More than one and a half years ago we [open-sourced Perception], a back-port of Swift's Observation
tools that works on iOS 13+ and macOS 10.15+. This has allowed thousands of developers to use
Swift's amazing observation tools in SwiftUI (and [UIKit]!) much earlier than if they were to
wait to drop support for iOS 16.

Today we are releasing a big update that brings many of the recent advancements in the Observation
framework to Perception, and of course it is all back-ported to iOS 13+ and macOS 10.15+. Join
us for a quick overview of what is new in [Perception].

## Observations: async sequences of changes

Swift 6.2 has brought a new tool to the Observation framework: [`Observations`]. This tool
allows you to construct an async sequence of changes to an observable model. As a very basic
example, if an observable model holds onto an integer, then you can construct an async 
sequence of messages that describe changes to that number like so:

```swift
@Observable
class Model {
  var count = 0
}

let model = Model()
let messages = Observations { "Your count is \(model.count)" }

for await message in messages {
  print(message)
}
```

However, the `Observations` API is limited to the 26 era of Apple platforms, _i.e._ iOS 26, 
macOS 26, watchOS 26, _etc._ This means you realistically will not be able to use the tool for a few
more years once you feel that the vast majority of your users are no longer on iOS 18.

But with [Perception], you get access to this tool _today_, and it's called `Perceptions`. It works
in **iOS 13+** and **Xcode 16+**, and so you don't even have to wait until Xcode 26 is released.
Just two small changes to the above code snippet is all it takes to ship this code immediately
to your users.

```diff
-@Observable
+@Perceptible
 class Model {
   var count = 0
 }
 
 let model = Model()
-let messages = Observations {
-let messages = Perceptions {
   "Your count is \(model.count)"
 }
 
 for await message in messages {
   print(message)
 }
```

Further, if you are targeting iOS 17 or 18, then you can even use `Perceptions` with `@Observable`
models.

## Short circuit observer notifications

The newest version of the Observation framework employs an interesting trick to skip notifying
observers if the mutated value has not actually changed. Prior to this change something as seemingly
innocuous as this: 

```swift
model.count = model.count
```

…would cause the SwiftUI view displaying this data to re-render.

Now, the `@Observable` macro (and `@Perceptible`) macro implements `shouldNotifyObservers` functions
in your model that allow it to efficiently check if the value changing is equatable, and if so
it performs an equality comparison before notifying observers.

The trick to accomplish this is that the `@Observable` macro implements 
[_multiple_][macro-expansion] `shouldNotifyObservers` methods: one that takes an `Equatable` value, 
and one that does not:

```swift
nonisolated func shouldNotifyObservers<T>(_ lhs: T, _ rhs: T) -> Bool {
  true
}

nonisolated func shouldNotifyObservers<T: Equatable>(_ lhs: T, _ rhs: T) -> Bool {
  lhs != rhs
}
```

Then at compile time Swift will choose the `Equatable` version if possible, and otherwise will 
choose the fully generic version, which causes all mutations to trigger notifications to observers.
This is even a [trick we've employed] in the Composable Architecture for over a year and a half
to increase the performance of the library. 

## Memory leak fix

Since Observation's first release in Swift 5.9 there has been a subtle way to accidentally introduce
a memory leak into your app. Due to how `withObservationTracking` works, subscriptions cannot
be cleaned up unless a final mutation is made to state. Now, the newest version of Observation
listens for the deallocation of observers and uses that moment to unsubscribe from observations.
And we have also ported those changes to Perception 2.0.

## Improved perception checking

When using [Perception] in SwiftUI, one must wrap the body of your views in 
`WithPerceptionTracking`. This allows the view to properly observe changes to your model and
re-render:

```swift:4
struct CounterView: View {
  let model: CounterModel
  var body: some View {
    WithPerceptionTracking {
      Form {
        Text("\(model.count)")
        Button("Increment") { model.count += 1 }
      }
    }
  }
}
```

If you forget to use `WithPerceptionTracking`, your view will not properly update when state in
the model changes. In order to help you to remember to always do this the library emits a runtime
warning if you ever access a field of a `@Perceptible` model from a view without being inside
`WithPerceptionTracking`.

This check only happens in debug builds, but it sometimes showed false positives and could sometimes
be slow to compute. In Perception 2.0 we have greatly improved the performance of the check,
and reduced the number of false positives, making it more dependable to rely on.

## Get started today

It looks like our [Perception] library has a little bit of life left in it yet! We're excited
to get these improvements into the hands of everyone using Perception. Be sure to update to 
2.0 today!

[trick we've employed]: https://github.com/pointfreeco/swift-composable-architecture/blob/af0a2c74087aea4aa305eaac332d106fb0bb625e/Sources/ComposableArchitecture/Observation/ObservableState.swift#L106-L134
[macro-expansion]: https://github.com/pointfreeco/swift-perception/blob/main/Tests/PerceptionMacrosTests/PerceptionMacrosTests.swift#L73-L87
[UIKit]: https://swiftpackageindex.com/pointfreeco/swift-navigation/main/documentation/uikitnavigation
[open-sourced Perception]: /blog/posts/129-perception-a-back-port-of-observable
[Perception]: http://github.com/pointfreeco/swift-perception
[`Observations`]: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0475-observed.md
