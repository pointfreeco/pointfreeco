!> [preamble]: To celebrate the release of Swift macros we releasing updates to 4 of our popular 
> libraries to greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
> [ComposableArchitecture][tca-gh], [SwiftUINavigation][sui-nav-gh], and 
> [Dependencies][dependencies-gh]. Each day this week we will detail how macros have allowed us to 
> massively simplify one of these libraries, and increase their powers.
> * [Macro Bonanza: CasePaths](/blog/posts/117-macro-bonanza-case-paths)
> * [Macro Bonanza: Composable Architecture](/blog/posts/118-macro-bonanza-composable-architecture)
> * [Macro Bonanza: SwiftUINavigation](/blog/posts/119-macro-bonanza-swiftui-navigation)
> * [**Macro Bonanza: Dependencies**](/blog/posts/120-macro-bonanza-dependencies)
> 
> [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
> [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
> [sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
> [dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

Today we are releasing [version 1.1][dependencies-1.1] of our popular [Dependencies][sui-nav-gh] 
library, which introduces a new [`@DependencyClient`][dependency-client-docs] macro for making it 
easier to design your dependencies. The library now provides a complete toolkit for designing _and_ 
controlling your dependencies, and makes it easy to preview and test your features in isolation.

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

## Designing dependencies

While our [Dependencies][dependencies-gh] library is just a dependency _management_ library, we do
highly encourage users of the library to design their dependencies in a specific way. We recommend
avoiding protocols for modeling the interfaces of things like API clients, database clients, audio 
players, and more, for a few reasons:

  * These interfaces tend to have a very specific, limited set of conformances, typically just live
    and test implementations. They are not similar to the popular protocols in the Swift ecosystem,
    such as `Collection`, `View`, `Reducer`, and others, which may have hundreds or thousands of 
    conformances.
  * One does not typically use the full power of protocols with these kinds of interfaces, such as 
    primary associated types, operators for transforming conformances, static type preservation,
    and more.
  * For dependencies in particular, it can be useful to override a single endpoint in tests while
    leaving all other endpoints unimplemented. This gives you exhaustive test coverage on exactly
    what parts of your dependencies are used in a particular execution flow.

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

That is unfortunate, but luckily we can fix this problem and a whole lot more…
  
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
-  static let unimplemented = Self(
-    loop: unimplemented("loop"),
-    play: unimplemented("play"),
-    setVolume: unimplemented("setVolume"),
-    stop: unimplemented("stop"),
-  )
+  static let unimplemented = Self()
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
[`@DependencyClient`][dependency-client-docs] automatically generate this initializer for you. This 
means in a different module you can immediately create an `AudioPlayerClient` with no additional 
work:

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

We have used this macro to massively clean up the code in our open-source word game, 
[isowords][isowords-gh], as well as the code that powers this very site, which is 
[open-source][pf-gh] and completely written in Swift. Each of those code bases have multiple large
and complex dependencies which we had to manually maintain both a public initializer and 
`testValue`, which meant that each time we added a new feature to the dependency we had multiple 
places in our code we had to update.

For example, in the Point-Free codebase we have a database client that has over 50 endpoints for
making various queries on this site. Previously we had to maintain a [public 
initializer][database-init] for this client so that it could be constructed outside its module.
And we maintained a ["failing" version][database-failing] of the client that triggered an XCTest 
failure for each endpoint. This was useful for exhaustively testing features and explicitly proving
which database endpoints were used in a specific user flow, but this was a ton of code to maintain
and a huge pain.

By appling the [@DependencyClient][database-dependency-client] macro to the database interface we
can now delete all of that code, and anytime we add a new endpoint to our database we will not have
to update any existing code. And we get nice methods with argument labels automatically:

```diff
-try await database.addUserIdToSubscriptionId(
-  currentUser.id, 
-  subscription.id
-)
+try await database.addUser(
+  id: currentUser.id, 
+  toSubscriptionID: subscription.id
+)
```

This gives us important information about the dependency endpoint so that we don't accidentally
mix something up.


[database-init]: https://github.com/pointfreeco/pointfreeco/blob/e7a2dbb2716459f13e7c67873c0a400aeaff92d1/Sources/Database/Database.swift#L76-L193
[database-failing]: https://github.com/pointfreeco/pointfreeco/blob/e7a2dbb2716459f13e7c67873c0a400aeaff92d1/Sources/Database/Failing.swift#L4-L68
[database-dependency-client]: https://github.com/pointfreeco/pointfreeco/blob/4c0a8f83f16f2b86996a59b9e1686476308ad8fc/Sources/Database/Database.swift#L13-L14

## Get started today

Starting using the [`@DependencyClient`][dependency-client-docs] macro today by updating or adding 
[Dependencies 1.1][dependencies-1.1] to your project today. It can help you write safer application 
code and stronger tests with less code.

[pf-gh]: http://github.com/pointfreeco/pointfreeco
[isowords-gh]: http://www.github.com/pointfreeco/isowords
[designing-dependencies-pf]: https://www.pointfree.co/collections/dependencies
[designing-dependencies-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/designingdependencies
[dependency-client-docs]: todo
[separating-interface]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Separating-interface-and-implementation
[dependencies-1.1]: https://github.com/pointfreeco/swift-dependencies/releases/tag/1.1.0
