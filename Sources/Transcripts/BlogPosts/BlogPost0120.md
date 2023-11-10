To celebrate the release of Swift macros we are releasing updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
[Dependencies][dependencies-gh]. Each day this week we will detail how macros have allowed us to 
massively simplify one of these libraries, and increase their powers.

And today we are discussing our [Dependencies][sui-nav-gh] library, which gives you the tools
necessary to model and control dependencies in your applications so that you can more easily
preview and test your features.

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

## Designing dependencies

While our [Dependencies][dependencies-gh] library is just a dependency _management_ library, we do
highly encourage users of the library to design their dependencies in a specific way. We recommend
avoiding protocols for modeling the interfaces of things like API clients, database clients, audio 
players, and more, for a few reasons:

* These interfaces tend to have a very specific set of conformances, typically a live and test
implementation. They are not similar to the popular protocols in the Swift ecosystem, such as 
`Collection`, `View`, `Reducer`, and others. Those protocols have hundreds or thousands of 
conformances.
* One does not typically use the full power of protocols with these kinds of interfaces, such as 
primary associated types, operators for transforming conformances, static type preservation, etc.
*  For dependencies in particular, it can be useful to override a single endpoint in tests while
leaving all other endpoints unimplemented. This gives you exhaustive test coverage on exactly what
parts of your dependencies are used in a particular execution flow.

For these reasons, and more, we think using structs with closure properties to model dependencies
is typically a far better choice. We have talked extensively about it in 
[episodes][designing-dependencies-pf] and we wrote about it in the 
[documentation][designing-dependencies-docs] for our [Dependencies][dependencies-gh] library.

And so rather than designing the interface of a audio player dependency like this:

```swift
protocol AudioPlayer {
  func loop(url: URL) async throws
  func play(url: URL) async throws
  func setVolume(_ volume: Float) async
  func stop() async
}
```

…we recommend designing it like this:

```swift
struct AudioPlayerClient {
  var loop: (_ url: URL) async throws -> Void
  var play: (_ url: URL) async throws -> Void
  var setVolume: (_ volume: Float) async -> Void
  var stop: () async -> Void
}
```

The main benefit to this style of dependency is that you get the ability to individually override
the endpoints of the client. The biggest use case of this is in tests and previews, where you can
start your client in a kind of default, "mocked" state where each endpoint does nothing. And then
selectively override the endpoints that you think will be used in the test or preview.

For example, it is common to maintain an "unimplemented" version of the dependency that simply
causes an XCTest failure when invoked. We even ship a tool called `unimplemented` that helps with 
this:

```swift
extension AudioPlayerClient {
  static let unimplemented = Self(
    loop: unimplemented("loop"),
    play: unimplemented("play"),
    setVolume: unimplemented("setVolume"),
    stop: unimplemented("stop"),
  )
}
```

Then you can start with an unimplemented client and override the endpoints you think will be used.
If you were testing the flow of someone starting and stopping the audio player, you could do so
like this:

```swift
let player = AudioPlayerClient.unimplemented
player.play = { _ in }
player.stop = { }
let model = Feature(player: player)
model.playButtonTapped()
model.stopButtonTapped()
```

If this test passes, then it definitively proves that `loop` and `setVolume` were not invoked in
your feature, because otherwise the test would have failed.

So, we think struct interfaces are a great way of modeling dependencies, but they do have one 
unfortunate consequence. And that is that you lose argument labels. The `play` endpoint, because 
it's just a closure, must be invoked like this:

```swift
player.play(URL(…))
```

…and not like this:

```swift
player.play(url: URL(…))
```

That is unfortunate, but luckily we can fix this problem and a lot more…
  
## Introducing the @DependencyClient macro

The [`@DependencyClient`][dependency-client-docs] macro can be applied to any dependency interface
built in the "struct-of-closures" style. Using the `AudioPlayerClient` from above, we can simply
do:

```swift
import DependenciesMacros

@DependencyClient
struct AudioPlayerClient {
  var loop: (_ url: URL) async throws -> Void
  var play: (_ url: URL) async throws -> Void
  var setVolume: (_ volume: Float) async -> Void
  var stop: () async -> Void
}
```

That one change comes with lots of benefits. First of all, it provides a default to each endpoint
that simply throws an error and triggers an XCTest failure. This means the `unimplemented` instance
we defined now comes for free by applying the macro:

```diff
 extension AudioPlayerClient {
   static let unimplemented = Self(
-    loop: unimplemented("loop"),
-    play: unimplemented("play"),
-    setVolume: unimplemented("setVolume"),
-    stop: unimplemented("stop"),
   )
 }
```

Further, when the closures in the client are provided with argument labels, a corresponding method
is added to the client with proper argument labels:

```swift
let client = AudioPlayerClient()
client.play(url: URL(…))
```

This greatly improves the ergonomics of invoking endpoints on the client.

And finally, when separating the interface and implementation of dependencies into separate modules
(see [here][separating-interface] for more information), one is forced to define an initializer
on the client struct so that it can be created outside the module. This is just a Swift limitation
in general, and not related to the struct-of-closures style of dependency design, but it is annoying
nonetheless.

This is a common use case for management dependencies, and that is why we have made the 
`@DependencyClient` automatically generate this initializer for you. This means in a different
module you can immediately create an `AudioPlayerClient` with no additional work:

```swift
extension AudioPlayerClient: DependencyKey {
  static let liveValue = AudioPlayerClient(
    loop: { _ in }
    play: { _ in }
    setVolume: { _ in }
    stop: { }
  )
}
```

## @DependencyClient in practice

<!--
todo: show how this improved isowords and pointfreeco
-->

## Get started today


[designing-dependencies-pf]: https://www.pointfree.co/collections/dependencies
[designing-dependencies-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/designingdependencies
[dependency-client-docs]: todo
[separating-interface]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Separating-interface-and-implementation
