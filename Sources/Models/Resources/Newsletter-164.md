We are excited to announce [Sharing 2][sharing-gh], an update to our popular library that introduces
brand new tools for error handling and asynchrony.

## Brand new async throwing tools

The `@Shared` property wrapper allows you to almost magically share state among your app's features
and various persistence layers, like user defaults, the file system, and even external APIs:

```swift
@Shared(.todos) var todos: [Todo] = []
```

But prior to 2.0, library users had very little insight into the interactions made between the
shared property and its backing strategy, including the status of loading a value, as well as any
errors that may have occurred.

Sharing 2.0 comes with a suite of new APIs that allow you to communicate these states to your users.

For example, the property wrapper's `load()` method is now asynchronous and throwing, which means
you can instantly tie loading a value to SwiftUI's refreshable view modifier:

```swift
.refreshable {
  try? await $todos.load()
}
```

And load/error states are available directly on the projected value, giving you fine-grained
control over your UI:

```swift
if $todos.isLoading {
  ProgressView()
} else if let loadError = $todos.loadError {
  ContentUnavailableView {
    Label(
      "Failed to load todos",
      systemImage: "checkmark.circle.badge.xmark"
    )
  } description: {
    Text(loadError.localizedDescription)
  }
} else {
  // ...
}
```

For a full, working example, see the repo's new [API Client Demo][api-client-demo].

## Custom async throwing strategies

Sharing's persistence strategies are powered by the `SharedKey` and `SharedReaderKey` protocols, and
both have been revamped to allow for error handling and concurrency in their requirements:
[`load`][load-docs], [`subscribe`][subscribe-docs], and [`save`][save-docs]:

### Updates to loading

The `load` requirement of `SharedReaderKey` in 1.0 was as simple as this:

```swift
func load(initialValue: Value?) -> Value?
```

Its only job was to return an optional `Value` that represent loading the value from the external
storage system (_e.g._, user defaults, file system, _etc._). However, there were a few problems with
this signature:

 1. It does not allow for asynchronous or throwing work to load the data.
 2. The `initialValue` argument is not very descriptive and it wasn't clear what it represented.
 3. It wasn't clear why `load` returned an optional, nor was it clear what would happen if one 
    returned `nil`.

These problems are all fixed with the following updated signature for `load` in `SharedReaderKey`:

```swift
func load(
  context: LoadContext<Value>,
  continuation: LoadContinuation<Value>
)
```

This fixes the above 3 problems in the following way:

 1. One can now load the value asynchronously, and when the value is finished loading it can be
    fed back into the shared state by invoking a `resume` method on `LoadContinuation`. Further,
    there is a `resume(throwing:)` method for emitting a loading error.
 2. The `context` argument knows the manner in which this `load` method is being invoked, _i.e._ the
    value is being loaded implicitly by initializing the `@Shared` property wrapper, or the value is
    being loaded explicitly by invoking `load()`.
 3. The `LoadContinuation` makes explicit the various ways one can resume when the load is complete.
    You can either invoke `resume(returning:)` if a value successfully loaded, or invoke
    `resume(throwing:)` if an error occurred, or invoke `resumeReturningInitialValue()` if no value
    was found in the external storage
    and you want to use the initial value provided to `@Shared` when it was created.

### Updates to subscribing

The `subscribe` requirement of `SharedReaderKey` has undergone changes similar to `load`. In 1.0 the
requirement was defined like so:

```swift
func subscribe(
  initialValue: Value?, 
  didSet receiveValue: @escaping @Sendable (Value?) -> Void
) -> SharedSubscription
```

This allows a conformance to subscribe to changes in the external storage system, and when a change
occurs it can replay that change back to `@Shared` state by invoking the `receiveValue` closure.

This method has many of the same problems as `load`, such as confusion of what `initialValue`
represents and what `nil` represents for the various optionals, as well as the inability to throw
errors when something goes wrong during the subscription.

These problems are all fixed with the new signature:

```swift
func subscribe(
  context: LoadContext<Value>, 
  subscriber: SharedSubscriber<Value>
) -> SharedSubscription
```

This new version of `subscribe` is handed the `LoadContext` that lets you know the context of the
subscription's creation, and the `SharedSubscriber` allows you to emit errors by invoking the
`yield(throwing:)` method.

### Updates to saving

And finally, `save` also underwent some changes that are similar to `load` and `subscribe`. Its
prior form looked like this:

```swift
func save(_ value: Value, immediately: Bool)
```

This form has the problem that it does not support asynchrony or error throwing, and there was 
confusion of what `immediately` meant. That boolean was intended to communicate to the implementor
of this method that the value should be saved right away, and not be throttled.

The new form of this method fixes these problems:

```swift
func save(
  _ value: Value,
  context: SaveContext,
  continuation: SaveContinuation
)
```

The `SaveContext` lets you know if the `save` is being invoked merely because the value of the
`@Shared` state changed, or because of user initiation by explicitly invoking `save()`. It is the
latter case that you may want to bypass any throttling logic and save the data immediately.

And the `SaveContinuation` allows you to perform the saving logic asynchronously by resuming it
after the saving work has finished. You can either invoke `resume()` to indicate that saving
finished successfully, or `resume(throwing:)` to indicate that an error occurred.

## A mostly backwards-compatible release

If you are using Sharing's built-in strategies, including `appStorage`, `fileStorage`, and
`inMemory`, Sharing 2.0 is for the most part a backwards-compatible update, with a few exceptions
related to new functionality that mostly affect third-party persistence strategies.

## Upgrade today

[Sharing 2.0][sharing-gh] is available to use in your projects today. Simply update your dependency
to the latest release.

[sharing-gh]: https://github.com/pointfreeco/swift-sharing
[api-client-demo]: https://github.com/pointfreeco/swift-sharing/blob/main/Examples/APIClientDemo/ContentView.swift
[load-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/sharedreaderkey/load(context:continuation:)
[subscribe-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/sharedreaderkey/subscribe(context:continuation:)
[save-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/sharedkey/save(_:context:continuation)
