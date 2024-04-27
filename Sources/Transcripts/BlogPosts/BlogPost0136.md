[Earlier this week][shared-state-blog-post] we released version 1.10 of the 
[Composable Architecture][tca-gh] that brought powerful state sharing tools to the library. These
tools allow you to seamlessly share state between multiple features, persist state to external
systems such as user defaults and the file system, _and_ your features remain 100% testable.

Today we are excited to announce that we are releasing a [brand new tutorial][syncups-tutorial] that 
shows step-by-step how to build a complex SwiftUI application using the Composable Architecture.
It is the same application we built during our [1.0 tour][tour-1.0] of the library, called 
SyncUps, and we also built this app in our ["Modern SwiftUI"][modern-swiftui] series and later
[open sourced][syncups-gh] it.

In the tutorial you will learn about many of the core tenets of the library, such as:

#### Use value types to model your domains.

In the Composable Architecture we prefer one to represent their features' domains with simple value 
types. This makes their logic easier to understand, more isolatable, and most testable.

#### Drive navigation from state.

Model the destinations a feature can navigate to in the feature's state. This makes deep linking
from push notifications, URLs, etc. as simple as constructing state, handing it off to SwiftUI, 
and letting SwiftUI do the heavy lifting.

#### Model your domains as concisely as possible.

The Composable Architecture gives you all of the tools you need to model your domains as concisely 
as possible. If a feature can navigate to 5 different places, there's no need to model that 
as 5 separate optionals, giving you 25 invalid states (`2^5 - 6 = 25`). Instead it should be one 
single optional enum with 5 cases, allowing you to prove that at most a single navigation
destination can be active at a time.

#### Control your dependencies rather than letting them control you.

Dependencies are by far the #1 source of complexity leaking into applications. With a little bit of 
upfront work you can take control over your dependencies so that you can run your app in completely
controlled environments, such as in Xcode previews, tests, and more. And the Composable 
Architecture gives you all the tools you need to model, control and propagate dependences in your 
app.

#### Test the subtle edge cases of your app's logic.

The Composable Architecture comes with [world class testing tools][tca-testing-article] that force 
you to prove how every bit of logic and behavior executes in your features, including asynchronous 
effects and dependencies! Test failures are printed with nicely formatted messages letting you know 
exactly what went wrong, and you can even control how exhaustive you want your tests to be.

## Start the tutorial today!

And that is only scratching the surface of what the tutorial covers and what the library is 
capable of. [Start the tutorial today][syncups-tutorial] to learn about the Composable Architecture!


[tca-testing-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing
[shared-state-blog-post]: /blog/posts/135-shared-state-in-the-composable-architecture
[syncups-tca]: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/SyncUps
[tour-1.0]: /collections/composable-architecture/composable-architecture-1-0
[shared-state-collection]: /collections/composable-architecture/sharing-and-persisting-state
[shared-state-beta-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2857
[tca-1.10]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.10.0
[migration-guide-1.10]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.10/
[sharing-state-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture/
[syncups-tutorial]: https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/buildingsyncups
[syncups-gh]: https://github.com/pointfreeco/syncups
[modern-swiftui]: /collections/swiftui/modern-swiftui
