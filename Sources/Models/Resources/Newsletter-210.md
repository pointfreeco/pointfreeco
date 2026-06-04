We have added a new macro to [Dependencies], `@DependencyEntry`, that makes it easier than ever 
to register new dependencies with the library:

[Dependencies]: https://github.com/pointfreeco/swift-dependencies

It gives you the simplest way yet to register a dependency with the library:

```swift
import Dependencies
import DependenciesMacros

extension DependencyValues {
  @DependencyEntry
  var apiClient: any APIClient = TestAPIClient()
}
```

That one declaration synthesizes a private key type behind the scenes and wires up the computed
property on `DependencyValues` for you. But getting to this design took quite a bit longer than you
may expect.

## Why it took us so long to add this macro?

This macro is heavily inspired by SwiftUI's [`@Entry` macro] for the SwiftUI environment, which was 
released a few years ago. Since then we have gotten a few requests to bring something similar to
dependencies (for example [here][discussion-116] and [here][discussion-258]), but we were reluctant
due to the differences between `@Depenedency` and `@Environment`.

[`@Entry` macro]: https://developer.apple.com/documentation/swiftui/entry%28%29
[discussion-116]: https://github.com/pointfreeco/swift-dependencies/discussions/116
[discussion-258]: https://github.com/pointfreeco/swift-dependencies/discussions/258

SwiftUI's `EnvironmentKey` has only a single `defaultValue` requirement, which makes it quite
easy to do things like this:

```swift
extension EnvironmentValues {
  @Entry
  var theme = Theme.liquid
}
```

But in Dependencies we separated the concepts of the "live" dependency you want to use when running
your app in the simulator or on device, from the "preview" dependency you want to use in Xcode
previews (that serve up reasonable mock data), and the "test" dependency you want to use during
testing. This separation makes previews easy to use because it reduces how often you need to
explicitly override dependencies for previews, and makes tests safer because you are guarnateed to
never access live dependencies in a testing environment.

But with that power comes complications when porting something like `@Entry` to Dependencies. We
need to somehow allow one to specify 3 possible values for the dependency, not just one, and we
need to make sure that it is still possible to separate the interface of a dependency from its
live implementation so that one can still modularize their codebase without incurring the cost of
building heavyweight dependencies.

## How @DependencyEntry works

After sitting with the problem for a long time, we landed on the following design:

```swift
extension DependencyValues {
  @DependencyEntry(liveValue: LiveAPIClient(), previewValue: PreviewAPIClient())
  var apiClient: any APIClient = TestAPIClient()
}
```

The rules of this macro are:

* The property's initializer becomes the dependency's `testValue`.
* If you provide a `liveValue:` argument, the synthesized key also gets a `liveValue`.
* If you provide a `previewValue:` argument, the synthesized key also gets a `previewValue`.

So this:

```swift
extension DependencyValues {
  @DependencyEntry(liveValue: LiveAPIClient(), previewValue: PreviewAPIClient())
  var apiClient: any APIClient = TestAPIClient()
}
```

…expands to rougly the equivalent of:

```swift
extension DependencyValues {
  var apiClient: APIClient {
    get { self[__Key_apiClient.self] }
    set { self[__Key_apiClient.self] = newValue }
  }

  private enum __Key_apiClient: DependencyKey {
    static let liveValue: any APIClient = LiveAPIClient()
    static let previewValue: any APIClient = PreviewAPIClient()
    static let testValue: any APIClient = TestAPIClient()
  }
}
```

And if you omit `liveValue`, then the synthesized key conforms only to `TestDependencyKey`. That
allows you to continue separating your dependency's interface from its live implementation, while
still allowing one to fully specify a dependency's live/preview/test value inline when appropriate.

And we decided to make the value specified for the property to be the `testValue` because the
main reason to control your dependencies is to make your code testable, and we want to make that 
clear by baking it into the defaults of the library.

## Get started

Update Dependencies to version 1.13 to get access to this new macro. It lives in the 
`DependenciesMacros` module, and once imported, you can start with the smallest possible form:

```swift
import Dependencies
import DependenciesMacros

extension DependencyValues {
  @DependencyEntry
  var audioPlayer: any AudioPlayer = TestAudioPlayer()
}
```
