9 weeks ago we began an ambitious new [series of episodes][shared-state-collection] to bring 
first-class state sharing tools to the [Composable Architecture][tca-gh], and at the same time we 
released a [public beta][shared-state-beta-discussion] of those tools. Over the course of those 9 
weeks we had hundreds of conversations with our viewers, fixed dozens of bugs, and implemented a 
few new features that we didn't have time to cover in episodes.

And we are now proud to officially release [version 1.10][tca-1.10] of the Composable Architecture
that includes a brand new `@Shared` property wrapper for sharing state between many features, as 
well as a few persistence strategies for saving the data to external systems, such as user defaults
and the file system.

Join us for a quick overview of the new tools in this release, and be sure to read the 
[migration guide][migration-guide-1.10] and [documentation][sharing-state-article] to best 
wield the new tools.

[shared-state-collection]: /collections/composable-architecture/sharing-and-persisting-state
[shared-state-beta-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2857
[tca-1.10]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.10.0
[migration-guide-1.10]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.10/
[sharing-state-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture/

## @Shared

The core tool added to the Composable Architecture is the `@Shared` property wrapper. It allows you
to introduce state to your features that can be shared with other features, all while embracing
value types and not sacrificing testablity. One can think of it as being similiar to `Binding`
in vanilla SwiftUI, except it is tuned specifically for the Composable Architecture.

To share state in one feature with another feature, simply use the `@Shared` property wrapper:

```swift
struct State {
  @Shared var signUpData: SignUpData
  // ...
}
```

This will require that `SignUpData` be passed in from the parent, and any changes made to this state
will be instantly observed by all features holding onto it, and if any other feature makes changes
to the state our feature will instantly see those changes.

This sounds like we are introducing a reference type to our domain, and reference types are 
notoriously tricky to understand in isolation and test since they can be mutated by anyone at 
anytime and can't be copied. However, the Composable Architecture does extra work to make shared
state as undestandable as possible by making it fully testable, and even _exhaustively_ testable.

## Persistence strategies

But we went above and beyond with `@Shared`. Not only does it allow you to seamlessly share state
with multiple parts of your application, but it also allows you to seamlessly persist state to 
any external system. The library now comes with 2 primary persistence strategies right out of the
box, including `.appStorage` and `.fileStorage`:

```swift
struct State {
  @Shared(.appStorage("hasSeenOnboarding")) var hasSeenOnboarding = false
  @Shared(.fileStorage()
}
```
