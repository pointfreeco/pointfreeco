> Preamble: This week we are running a Point-Free blog bonanza to highlight new things happening
> across our ecosystem.
> * [DebugSnapshots now logs SwiftUI bindings](/blog/posts/214-debugsnapshots-now-logs-swiftui-bindings)
> * [New macros for SwiftNavigation](/blog/posts/215-new-macros-for-swiftnavigation)
> * [“Trait-ifying” our libraries](/blog/posts/216-trait-ifying-our-libraries)
> * [Proposing task-local test traits for Swift Testing](/blog/posts/217-proposing-task-local-test-traits-for-swift-testing)
> * [**Xcode 27 support in the Point-Free ecosystem**](/blog/posts/218-xcode-27-support-in-the-point-free-ecosystem)

While WWDC is an exciting time, where we learn of all the new APIs and tools Apple has
been working on for the past, open source maintainers know all too well the stress and pressure
this brings. 

As soon as the first Xcode beta drops, every developer wants to instantly be able to
open their project and run their project. But very often Xcode betas and new versions of Swift
bring small incompatibilies or regresions that prevent one from building their project. And as
maintainers of open source libraries, we never want to be the reason that someone can't build
their project.

## IssueReporting

[IssueReporting] is a foundational library in our ecosystem that brings unobtrusive, yet visible,
runtime warnings to Apple platforms. Further, it turns runtime warnings into test failures when
they are triggered in a testing context. This is great for catching potential problems in your
test suite.

In order to unlock this kind of functionality we need to be able to interact with Swift Testing
code from non-test targets, which is not allowed in Swift. To work around this we 
[dynamically interact] with Swift Testing's APIs so that we don't need to explicitly link Swift
Testing.

That is powerful, however with great power comes great responsibility. Because we are loading 
these symbols dynamically, we will not be notified if they ever change in the future. And
we take the responsibility seriously. This year's Xcode 27 beta 1 brought some small changes to
the Swift Testing API that we needed to account for, and less than 24 hours after the best
release we had a [fix] in place.

[dynamically interact]: https://github.com/pointfreeco/swift-issue-reporting/blob/401bf70d95bfe8db2a1dc619f9e175a85c089321/Sources/IssueReporting/Internal/SwiftTesting.swift#L103
[fix]: https://github.com/pointfreeco/swift-issue-reporting/pull/186
[IssueReporting]: https://github.com/pointfreeco/swift-issue-reporting/

## Swift 6.4 regressions

Swift 6.4 has brought a lot of improvements and new features to Swift, but has also brought some
regressions in type checking. Code that compiles just fine in 6.3 no longer compiles in 6.4.
We have opened issues on these problems, but that doesn't help our users. So in the meantime we have
implemented workarounds so that people are not prevented from using Xcode 27 betas:

### StructuredQueries

[StructuredQueries] is our type-safe and schema-safe SQL building library. It employs some of the
most advanced parts of Swift, including macros, parameter packs, static dynamic member lookup, and
more. But, by push Swift to its limits we are more susceptible to small regressions introduced in
new versions of Swift.

In particular, Swift 6.4 seems to have introduced a small type checking regression that prevents
`@Table` macro code from compiling. The fix was [simple], and we got a release out in just 2 days.

[simple]: https://github.com/pointfreeco/swift-structured-queries/pull/290
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

### Sharing

[Sharing] is our library for general persistence tools in SwiftUI and UIKit applications. 
It uses opaque types in a particular fashion that seems to no longer compile in Swift 6.4,
and rather waiting around for a fix in Swift, we applied a [fix][sharing-pr] ourselves.

[Sharing]: https://github.com/pointfreeco/swift-sharing
[sharing-pr]: https://github.com/pointfreeco/swift-sharing/pull/216

### ComposableArchitecture

[ComposableArchitecture] is our popular library for building complex animations in a way
that embraces value types of reference types, provides tools for concise domain modeling, and
helps wrangle in asynchronous behavior in features. Due to a regression in isolation checking in
Swift 6.4 we needed to mark something as `@MainActor` that should have been `@MainActor` isolated
already. But it was no big deal to [tca-pr], and we got out a release right away.

[ComposableArchitecture]: https://github.com/pointfreeco/swift-composable-architecture/ 
[tca-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/3931/

### ComposableArchitecture 2.0

[ComposableArchitecture 2.0] is the next generation of our ComposableArchitecture library, 
currently in beta preview. This library embraces all of the most modern tools in Swift's 
concurrency arsenal, including [NonisolatedNonsendingByDefault], but Swift 6.4 seems to have
started catching more problems in async code related to this setting. This surfaced an issue
in our library that we were quick to [fix][tca26-pr] for our beta users. 
  
[NonisolatedNonsendingByDefault]: https://docs.swift.org/compiler/documentation/diagnostics/nonisolated-nonsending-by-default/
[tca26-pr]: https://github.com/pointfreeco/TCA26/pull/148/

## @DependencyEntry

Sometimes in an Xcode beta we learn of a new trick being employed by SwiftUI that we can use in
our own libraries. This year we noticed that SwiftUI's `@Entry` macro added a `_modify` access
to its computed property, and we just recently we added our [own version][dep-entry] of this macro 
to our [Dependencies] library.

So, we decided to [improve our macro][dep-entry-modify] with the `_modify` accessor, and released
an update just one week after WWDC.

[Dependencies]: https://github.com/pointfreeco/swift-dependencies 
[dep-entry]: /blog/posts/213-introducing-dependencyentry 
[dep-entry-modify]: https://github.com/pointfreeco/swift-dependencies/pull/449

## Thanks to our subscribers!

The honest truth is that this kind of support and turnaround for our open source projects is only
thanks to the support of our [subscribers](/pricing). We are able to treat our open source as a
full time job (along side [video](/episodes) creation), and that means we have ample time to 
receive feedback and bug reports for our community, and act upon it quickly.

So, thank you [subscribers](/pricing)! 
