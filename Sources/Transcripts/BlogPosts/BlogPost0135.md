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

## @Shared

The core tool added to the Composable Architecture is the `@Shared` property wrapper. It allows you
to introduce state to your features that can be shared with other features, all while embracing
value types and not sacrificing testability. One can think of it as being similar to `Binding`
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

This sounds like we are introducing a reference type to our domain, and technically we are, but
while reference types are notoriously tricky to understand in isolation and test since they can be
mutated by anyone at anytime and can't be copied, the Composable Architecture does extra work to
make shared state as understandable as possible by making it fully testable, and even _exhaustively_
testable.

## Persistence strategies

But we went above and beyond with `@Shared`. Not only does it allow you to seamlessly share state
with multiple parts of your application, but it also allows you to seamlessly persist state to 
any external system. The library now comes with 2 primary persistence strategies right out of the
box, including `.appStorage` and `.fileStorage`:

```swift
struct State {
  @Shared(.appStorage("hasSeenOnboarding")) 
  var hasSeenOnboarding = false
  
  @Shared(.fileStorage(.currentUserURL))
  var currentUser: User?
}
```

The above use of the `.appStorage` persistence strategy allows multiple features to hold onto the
same boolean value, and any changes made to it will be automatically synchronized to user defaults
on the device. Similarly, the `.fileStorage` persistence strategy allows all features to see the
currently logged-in user, and any changes to the user will be automatically saved to disk.

Further, one can define their own persistence strategies for allowing shared state to be driven from
an external system. Really the sky is the limit! With just a little bit of work you can integrate
`@Shared` into a remote config and feature flag system so that you have a simple way  of determining
when to show certain features:

```swift
struct State {
  @Shared(.remoteConfig("showEndOfYearPromotionBanner"))
  var showBanner = false
  
  @Shared(.featureFlag("creatorDashboardV2"))
  var showNewCreatorDashboard = false
}
``` 

And of course, if done with care, everything will be 100% testable so that you can make sure your
features continue to work correctly even when certain remote config values and feature flags are
turned on.

## A new tutorial

We have also released a [brand new tutorial][syncups-tutorial] for building a moderately complex 
application from scratch, using the Composable Architecture. The app is called 
[SyncUps][syncups-tca], and it was originally built for our [tour of the 1.0 release][tour-1.0].
It features multiple navigation patterns, subtle validation logic, complex side effects, and it
comes with a complete test suite.

It's a long tutorial! 😄 But if you are willing to put in the work you will be exposed to a lot of
the most important concepts in the library, such as domain modeling, sharing state, navigation,
dependencies, and testing.

[syncups-tca]: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/SyncUps
[tour-1.0]: https://www.pointfree.co/collections/composable-architecture/composable-architecture-1-0

## Get started today

We feel that this is one of the most exciting releases we've had in the Composable Architecture, and
that it solves real problems that users have had from the beginning. Update your apps to version
1.10 of the library to start using the tools today, and be sure to check out the
[migration guide][migration-guide-1.10] and [documentation][sharing-state-article] to best 
wield the new tools.

[shared-state-collection]: /collections/composable-architecture/sharing-and-persisting-state
[shared-state-beta-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2857
[tca-1.10]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.10.0
[migration-guide-1.10]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.10/
[sharing-state-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture/
[syncups-tutorial]: https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/buildingsyncups
