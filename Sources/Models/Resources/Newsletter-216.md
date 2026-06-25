> Preamble: This week we are running a Point-Free blog bonanza to highlight new things happening
> across our ecosystem.
> * [DebugSnapshots now logs SwiftUI bindings](/blog/posts/214-debugsnapshots-now-logs-swiftui-bindings)
> * [New macros for SwiftNavigation](/blog/posts/215-new-macros-for-swiftnavigation)
> * [**“Trait-ifying” our libraries to reduce transitive dependencies**](/blog/posts/216-trait-ifying-our-libraries-to-reduce-transitive-dependencies)
> * [Proposing task-local test traits for Swift Testing](/blog/posts/217-proposing-task-local-test-traits-for-swift-testing)
>
> Coming soon:
> * Shipping Xcode 27 support

One of the recurring pieces of feedback we get on our libraries is that when you add a dependency
on one of our packages, a bunch of our other libraries come in transitively.

We personally have never viewed this as a major problem because we only depend on our own libraries.
We do not have a sprawling web of 3rd party dependencies, and our libraries mostly aim to fill 
fundamental gaps in the Apple ecosystem that we think should some day be a part of Swift or SwiftUI
natively (we love being Sherlocked!). And we find that managing an ecosystem of small, reusable
libraries is better than us repeatedly copying and pasting snippets into our various projects. 

Luckily thanks to SwiftPM traits we can have our cake and eat it to. We can continue maintaining
our ecosystem of libraries while giving our users more control over what bits of functionality they
need from our other libraries.

> Note: We recently wrote about another use of traits in the [Composable Architecture][tca-traits], 
> where they can help stage large migrations.

[tca-traits]: /blog/posts/203-hard-deprecations-and-soft-landings-with-swiftpm-traits

## How to use traits to slim down transitive dependencies

We are in the process of “trait-ifying” our libraries to make it possible to slim down transitive
dependencies on our other libraries. For example, our [SwiftNavigation] library, which provides
improved navigation tools for SwiftUI as well as SwiftUI-inspired navigation tools for UIKit, now
comes with [traits][swift-nav-traits] to opt out of certain behavior.

[swift-nav-traits]: https://github.com/pointfreeco/swift-navigation/blob/5c16d3a4645c3f51083bd6c12821fe57a0b455c5/Package.swift#L38-L59
[SwiftNavigation]: https://github.com/pointfreeco/swift-navigation

When depending on SwiftNavigation in a SwiftPM package you can specify the traits for the 
functionality you want. For example, if you are deploying to pre-iOS 17 devices you will need
the `Perception` trait, and if you want to drive navigation off of enums you will need the 
`CasePaths` trait, which can both be specified like so in your Package.swift:

```swift:5
dependencies: [
  .package(
    url: "https://github.com/pointfreeco/swift-navigation", 
    from: "2.10.0", 
    traits: ["CasePaths", "Perception"]
  ),
]
```

That small change will prevent transitive dependencies on our [CustomDump], [IssueReporting],
and [Sharing] libraries.

[CustomDump]: https://github.com/pointfreeco/swift-custom-dump
[IssueReporting]: https://github.com/pointfreeco/swift-issue-reporting
[Sharing]: https://github.com/pointfreeco/swift-sharing

If using Xcode, then there is a new interface to specify traits in the Package Dependencies tab:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/355e9e27-6299-41fd-1c44-629139506e00/public)

You can use this drop down menu to turn off the defaults and enable any traits that are important
to you, such as `Perception` and `CasePaths`. 

And if you prefer the most minimal, core version of the library, you can disable all traits. Once 
that is done your dependencies sidebar in Xcode will go from looking like this:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/73c19bce-142a-43be-782e-252ece726d00/public)

…to this:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/e4b4e321-7b71-4b38-4ecb-c44aca797b00/public)

## “Trait-ified” SwiftNavigation and Dependencies

The libraries of ours that have most fully gotten the “trait-ified” treatment are 
[SwiftNavigation] and [Dependencies], as well as the highly anticipated 2.0 of our popular
[ComposableArchitecture](/beta-previews) library. The Dependencies library provides 
[traits][swift-deps-traits] to omit the registered dependencies for dealing with clocks and Combine 
schedulers, and even provides a trait for avoiding Foundation and  FoundationNetworking, which can 
be important for Wasm and Android development so as to avoid hefty binaries on those platforms.

[swift-deps-traits]: https://github.com/pointfreeco/swift-dependencies/blob/8dc1fbf2f6255a73dec53b4648164884898db4c5/Package.swift#L28-L35
[Dependencies]: https://github.com/pointfreeco/swift-dependencies

Going forward we will update more libraries to use traits for transitive dependencies, and we will
build new libraries with traits in mind from the very beginning.

So if you have ever hesitated to add one of our libraries because of the other packages it brings
along, hopefully we have assuaged your fears a bit! We still think it's the right decision for
us to manage many small, reusable libraries in our ecosystem that are free to depend on each other,
but we can now use traits to reduce transitive dependencies for functionality that you do not need.
