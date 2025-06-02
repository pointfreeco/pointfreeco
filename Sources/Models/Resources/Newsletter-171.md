There is a long-standing problem in the Apple ecosystem that makes using of one of Swift’s most powerful features, macros, incur a tremendous cost on your build times. To use macros one must first build [SwiftSyntax](http://github.com/swiftlang/swift-syntax/) from scratch, which takes approximately ~20 seconds in development and over 4 minutes in release. This cost is too much for many to bear, and so many developers simply cannot use any libraries that make use of macros or introduce macros into their own codebase.

Well, that was until Xcode 16.4! This most recent release of Xcode has brought [pre-compiled binaries of SwiftSyntax][swift-forums-post] to the toolchain so that macros no longer need to build SwiftSyntax. Join us for a quick overview of how to take advantage of this new feature of Swift to slim down your build times.

[swift-forums-post]: https://forums.swift.org/t/preview-swift-syntax-prebuilts-for-macros/80202

# Pre-built SwiftSyntax

To take advantage of pre-built SwiftSyntax in Xcode one has to use Xcode 16.4 and enable the 
following defaults value: 

```
defaults write com.apple.dt.Xcode IDEPackageEnablePrebuilts YES
```

After that Xcode should skip compiling SwiftSyntax from source and start using the pre-compiled 
version that can be downloaded from the internet.

If you are building or testing your library from the command line, then you must further
pass the `--enable-experimental-prebuilts` flag to your command:

```
swift build --enable-experimental-prebuilts
```

That's all it takes! 

# Benchmark and caveats

As quick demonstration of how the pre-compiled SwiftSyntax we timed how long it takes to build the demo application we are building in our “[Modern Persistence](https://www.pointfree.co/collections/modern-persistence)” series of episodes. It uses our [Structured Queries](https://github.com/pointfreeco/swift-structured-queries) library, which leverages macros to build type-safe and schema-safe SQL queries.

Building the app from scratch currently takes about **37 seconds**, and building with the precompiled SwiftSynax takes only **15 seconds**. And one can clearly see the how the build timeline dramatically changed:

| Before | After |
|--------|-------|
| ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7e218e7f-65bb-44d0-af53-3019f8e90300/public) | ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/12a34ace-6b3b-4dbb-0eef-60fd7411e000/public) |

The large yellow segments in the first image is the compilation of SwiftSyntax, and those segments are completely gone in the second.

It is worth mentioning a number of caveats with this. You will not necessarily immediately see 20+ seconds shaved off your build times just because you drop in a precompiled SwiftSyntax. Typically the amount of code compiled in an app far outweighs the amount of code in SwiftSyntax, and a lot of that code can be compiled in parallel with SwiftSyntax. So the savings you see from a static SwiftSyntax may be less than 20 seconds.

However, where the precompiled SwiftSyntax will *really* shine is when building smaller feature modules for tests and Xcode previews. These are situations in which the time to compile SwiftSyntax is much greater than the feature code being compiled, and so you can expect much faster feedback loops.


# Being a good citizen in the land of SwiftSyntax

Now that one of the biggest hindrances to macros has been fixed we expect the ecosystem of 
macros to thrive much more. And because of that we want to remind all developers who are thinking
about packaging up a macro to distribute to the community to please take the time to 
[Be a good citizen in the land of SwiftSyntax][citizen]. We wrote about this at length nearly 2
years ago, but we have repeated the most important parts below:  

[citizen]: /blog/posts/116-being-a-good-citizen-in-the-land-of-swiftsyntax

## Be as flexible as possible in your dependence on SwiftSyntax

SwiftSyntax has an interesting versioning scheme where major versions correspond to minor
versions of Swift (_i.e._ SwiftSyntax 600.0 corresponds to Swift 6.0 and SwiftSyntax 601.0
corresponds to Swift 6.1). This can complicate how libraries depend on SwiftSyntax.

In order to avoid dependency graph nightmares, where you are unable to update or use a package due
to conflicting dependency versions, we suggest being as flexible in your dependency on SwiftSyntax
as possible. 

This means that rather than depending on SwiftSyntax by saying you are willing to accept any minor
version within a particular major version, as Xcode’s macro template does by default:

```swift:3
.package(
  url: "https://github.com/apple/swift-syntax",
  from: "510.0.0"
)
```

…you should instead accept a range of major versions like so:

```swift:3
.package(
  url: "https://github.com/apple/swift-syntax",
  "508.0.0"..<"602.0.0"
)
```

This allows people to depend on your package who are still stuck on version 508 of SwiftSyntax,
while also allowing those who can target 509, 600 and 601 to use your library.

In practice it can be quite difficult to support multiple major versions of SwiftSyntax. After all,
SwiftSyntax has complete freedom to make as many breaking changes as it wants between 508 and 509.
However, there are a few things you can do to mitigate these complexities.

 1. First, SwiftSyntax provides an empty library for every minor version of Swift less than or equal
    to the one that SwiftSyntax is currently targeting. For example, in version 509 right now there
    is a
    [SwiftSyntax509 module](https://github.com/apple/swift-syntax/tree/27db1374d173cb595b52e75a6821bcb6d088873a/Sources/SwiftSyntax509).
    And once version 510 is released there will be both a SwiftSyntax509 and SwiftSyntax510 module
    provided.

    This gives you the ability to conditionally write code depending on which version of SwiftSyntax
    is currently being compiled using `#if canImport`. For example, the
    [`SourceLocationConverter`](https://github.com/apple/swift-syntax/blob/27db1374d173cb595b52e75a6821bcb6d088873a/Sources/SwiftSyntax/SourceLocation.swift#L160)
    API had a slight naming change in its API between version 508 and 509, and so in order to
    support both we can do the following:
    
    ```swift
    #if canImport(SwiftSyntax509)
      let converter = SourceLocationConverter(
        fileName: filePath, tree: sourceFile
      )
    #else
      let converter = SourceLocationConverter(
        file: filePath, tree: sourceFile
      )
    #endif
    ```
    
    Note that in version 509 the initializer uses the `fileName` argument name, whereas in 508 it
    uses just `file`.
    
    This does mean that you will need to sprinkle in liberal helpings of `canImport` to get your
    code compiling for all versions, but as library authors we are already used to that since we
    often need to use `#if swift(<=)` for similar reasons.
    
 2. Second, if it is too complex to update all uses of SwiftSyntax so that you are using the correct
    APIs across multiple versions, you can always omit entire swaths of functionality in your library
    using `canImport`. For example, if your library uses SwiftSyntax for just a small bit of added
    functionality, but it is not critical to the core of your library, then you can consider
    guarding the entire functionality behind `#if canImport(SwiftSyntax509)`. That way SPM can
    continue resolving the dependency graph, and people can use your library, but they just won't
    have access to all of its functionality unless they can use the newest version of SwiftSyntax.

In fact, we have had these exact situations come up in just the past. Gwendal Roué,
maintainer of the very popular open source library [GRDB](https://github.com/groue/GRDB.swift),
released a [new project](https://github.com/groue/GRDBSnapshotTesting) that added support for our
[SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library to GRDB. In essence
it allows you to snapshot test your database contents, schemas, migrations, and queries.

In theory this works out just fine, but Gwendal quickly came across a
[problem](https://github.com/pointfreeco/swift-snapshot-testing/discussions/794) when trying to use
his new library in a personal project of his. Our SnapshotTesting library depended on SwiftSyntax
509 in order to provide an
[inline snapshot testing tool](https://www.pointfree.co/blog/posts/113-inline-snapshot-testing), but
Gwendal also depended on Apple’s
[OpenAPIGenerator](https://github.com/apple/swift-openapi-generator) library, which
[depended](https://github.com/apple/swift-openapi-generator/blob/4c8ed5cec75ccf7f3c48f744b44bafb93235f492/Package.swift#L56-L59)
on SwiftSyntax 508. That means that our library and Apple’s can never be used at the same time.

Luckily there was an easy fix that makes both libraries better citizens in the land of SwiftSyntax.
The OpenAPIGenerator library’s dependence on SwiftSyntax could be relaxed to `508..<510` with one
small change to the library
([see the PR here](https://github.com/apple/swift-openapi-generator/pull/331)). And our
SnapshotTesting library’s dependence on SwiftSyntax could also be relaxed to `508..<510`, but we
decided to omit the inline snapshot testing functionality for people who were not able to target
version 509 ([see the PR here](https://github.com/pointfreeco/swift-snapshot-testing/pull/795)). It
was simply too big of a burden to support both 508 and 509 at the same time in this case, and so we
felt omitting it in 508 was a reasonable compromise.

With those changes, both libraries are now better citizens in the Swift ecosystem. They are
compatible with each other, and there is a much smaller chance of them conflicting with a 3rd
library that also needs access to SwiftSyntax.

## Update your libraries to new versions of SwiftSyntax as soon as possible

When new, major versions of SwiftSyntax come out, you should release a new version of your library
as soon as possible supporting the new version. In the coming months we will inevitably see a
release of Swift 5.10, and there is already
[work being done](https://github.com/apple/swift-syntax/compare/release/5.10...main) to support new
syntax in the SwiftSyntax library.

When version 510 of the library is finally
[released](https://github.com/apple/swift-syntax/releases), you should update your library to
support a larger range of SwiftSyntax versions. If you currently support version 508, then you
would update like so:

```swift:3
.package(
  url: "https://github.com/apple/swift-syntax",
  "508.0.0"..<"511.0.0"
)
```

And if you currently only support 509, like if you are a macro library, then you would update like
so:

```swift:3
.package(
  url: "https://github.com/apple/swift-syntax",
  "509.0.0"..<"511.0.0"
)
```

That will help prevent your library from being a bottleneck when users try to update their packages
or add a new package to their project.
