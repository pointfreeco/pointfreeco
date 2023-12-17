A few months ago we opened a [Swift forum discussion](https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588) to express some concerns we had about the adoption of SwiftSyntax in the larger Swift ecosystem. The concerns can be roughly summarized as follows:

- SwiftSyntax is a large project taking 20 seconds to build in the debug configuration and over 4 minutes in release. That adds significant compilation time to any project using the library.
- SwiftSyntax has an interesting versioning scheme where major versions correspond to minor versions of Swift (i.e. SwiftSyntax 509.0 corresponds to Swift 5.9). This complicates how libraries can depend on SwiftSyntax.
- SwiftSyntax has often had breaking changes in its minor releases, and the documentation and examples are currently lacking.

Typically these problems are not a huge deal because not many client-side applications depended directly on SwiftSyntax or even used libraries that depend on SwiftSyntax. 

But that all changed with Swift 5.9 and the introduction of macros. Now applications will commonly depend on libraries that use SwiftSyntax, causing them to incur build time penalties and increasing the likelihood of an unresolvable dependency graph due to multiple libraries needing different major versions of SwiftSyntax.

In this post we would like to outline what you can do to be a good citizen in the new world of SwiftSyntax proliferation to minimize these problems. This advice is primarily directed at Swift library authors, but we think everyone should be familiar with these ideas.

## Be as flexible as possible in your dependency on SwiftSyntax

In order to avoid dependency graph nightmares, where you are unable to update or use a package due to conflicting dependency versions, we suggest being as flexible in your dependency on SwiftSyntax as possible. 

This means that rather than depending on SwiftSyntax by saying you are willing to accept any minor version within a particular major version, as Xcode’s macro template does by default:

```swift
.package(
  url: "https://github.com/apple/swift-syntax",
  from: "509.0.0"
)
```

…you should instead accept a range of major versions like so:

```swift
.package(
  url: "https://github.com/apple/swift-syntax",
  "508.0.0"..<"510.0.0"
)
```

This allows people to depend on your package who are still stuck on version 508 of SwiftSyntax, while also allowing those who can target 509 to use your library.

In practice it can be quite difficult to support multiple major versions of SwiftSyntax. After all, SwiftSyntax has complete freedom to make as many breaking changes as it wants between 508 and 509. However, there are a few things you can do to mitigate these complexities.

1. First, SwiftSyntax provides an empty library for every minor version of Swift less than or equal to the one that SwiftSyntax is currently targeting. For example, in version 509 right now there is a [SwiftSyntax509 module](https://github.com/apple/swift-syntax/tree/27db1374d173cb595b52e75a6821bcb6d088873a/Sources/SwiftSyntax509). And once version 510 is released there will be both a SwiftSyntax509 and SwiftSyntax510 module provided.

    This gives you the ability to conditionally write code depending on which version of SwiftSyntax is currently being compiled using `#if canImport`. For example, the [`SourceLocationConverter`](https://github.com/apple/swift-syntax/blob/27db1374d173cb595b52e75a6821bcb6d088873a/Sources/SwiftSyntax/SourceLocation.swift#L160) API had a slight naming change in its API between version 508 and 509, and so in order to support both we can do the following:
    
    ```swift
    #if canImport(SwiftSyntax509)
    let converter = SourceLocationConverter(fileName: filePath, tree: sourceFile)
    #else
    let converter = SourceLocationConverter(file: filePath, tree: sourceFile)
    #endif
    ```
    
    Note that in version 509 the initializer uses the `fileName` argument name, whereas in 508 it uses just `file`.
    
    This does mean that you will need to sprinkle in liberal helpings of `canImport` to get your code compiling for all versions, but as library authors we are already used to that since we often need to use `#if swift(<=)` for similar reasons.
    
2. Second, if it is too complex to update all uses of SwiftSyntax so that you are using the correct APIs across multiple versions, you can always omit entire swaths of functionality in your library using `canImport`. For example, if your library uses SwiftSyntax for just a small bit of added functionality, but it is not critical to the core of your library, then you can consider guarding the entire functionality behind `#if canImport(SwiftSyntax509)`. That way SPM can continue resolving the dependency graph, and people can use your library, but they just won't have access to all of its functionality unless they can use the newest version of SwiftSyntax.

In fact, we have had these exact situations come up in just the past few days. Gwendal Roué, maintainer of the very popular open source library [GRDB](https://github.com/groue/GRDB.swift), released a [new project](https://github.com/groue/GRDBSnapshotTesting) that added support for our [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library to GRDB. In essence it allows you to snapshot test your database contents, schemas, migrations, and queries.

In theory this works out just fine, but Gwendal quickly came across a [problem](https://github.com/pointfreeco/swift-snapshot-testing/discussions/794) when trying to use his new library in a personal project of his. Our SnapshotTesting library depended on SwiftSyntax 509 in order to provide an [inline snapshot testing tool](https://www.pointfree.co/blog/posts/113-inline-snapshot-testing), but Gwendal also depended on Apple’s [OpenAPIGenerator](https://github.com/apple/swift-openapi-generator) library, which [depended](https://github.com/apple/swift-openapi-generator/blob/4c8ed5cec75ccf7f3c48f744b44bafb93235f492/Package.swift#L56-L59) on SwiftSyntax 508. That means that our library and Apple’s can never be used at the same time.

Luckily there was an easy fix that makes both libraries better citizens in the land of SwiftSyntax. The OpenAPIGenerator library’s dependence on SwiftSyntax could be relaxed to `508..<510` with one small change to the library ([see the PR here](https://github.com/apple/swift-openapi-generator/pull/331)). And our SnapshotTesting library’s dependence on SwiftSyntax could also be relaxed to `508..<510`, but we decided to omit the inline snapshot testing functionality for people who were not able to target version 509 ([see the PR here](https://github.com/pointfreeco/swift-snapshot-testing/pull/795)). It was simply too big of a burden to support both 508 and 509 at the same time in this case, and so we felt omitting it in 508 was a reasonable compromise.

With those changes, both libraries are now better citizens in the Swift ecosystem. They are compatible with each other, and there is a much smaller chance of them conflicting with a 3rd library that also needs access to SwiftSyntax.

## Update your libraries to new versions of SwiftSyntax as soon as possible

When new, major versions of SwiftSyntax come out, you should release a new version of your library as soon as possible supporting the new version. In the coming months we will inevitably see a release of Swift 5.10, and there is already [work being done](https://github.com/apple/swift-syntax/compare/release/5.10...main) to support new syntax in the SwiftSyntax library.

When version 510 of the library is finally [released](https://github.com/apple/swift-syntax/releases), you should update your library to support a larger range of SwiftSyntax versions. If you currently support version 508, then you would update like so:

```swift
.package(
  url: "https://github.com/apple/swift-syntax",
  "508.0.0"..<"511.0.0"
)
```

And if you currently only support 509, like if you are a macro library, then you would update like so:

```swift
.package(
  url: "https://github.com/apple/swift-syntax",
  "509.0.0"..<"511.0.0"
)
```

That will help prevent your library from being a bottleneck when users try to update their packages or add a new package to their project.

## Create separate libraries that depend on SwiftSyntax

The above tips all have to do with preventing dependency graph resolution problems. There is also the problem of build times when depending on SwiftSyntax, whether directly or indirectly.

Library authors can also help in this situation. Unless SwiftSyntax is absolutely crucial to your core library, you should consider moving any code that uses SwiftSyntax into its own opt-in library within your package. That allows people to use your core library without incurring the SwiftSyntax compilation costs, and only if they want access to the tools that need SwiftSyntax will they incur that cost.

This is what we did in our SnapshotTesting library. When we released our [new inline snapshot testing tool](https://www.pointfree.co/blog/posts/113-inline-snapshot-testing), we decided to put it into a [separate library](https://github.com/pointfreeco/swift-snapshot-testing/blob/bb0ea08db8e73324fe6c3727f755ca41a23ff2f4/Package.swift#L27-L38) from the core snapshot testing library. That means people using our library will not unwittingly incur a compilation cost when they update to the newest version of SnapshotTesting. They will incur that cost only if they want access to InlineSnapshotTesting.

This advice does not apply to libraries whose primary reason to exist is to provide a macro. In such libraries you have no choice but to depend on SwiftSyntax directly. However, if a macro is being *added* to an existing library, and that macro is not 100% necessary to use your library, then putting it into its own target will go a long way.

## The same goes for SwiftFormat

Everything said above also applies to Apple’s [SwiftFormat library](https://github.com/apple/swift-format/), which has the same versioning style and even greater compilation costs, but depending on this library in application code is far less common. If you do need to depend on SwiftFormat, be as flexible with the major versions as possible (you can still use `#if canImport(SwiftSyntaxXYZ)` syntax since SwiftFormat depends on SwiftSyntax), and consider splitting it out into its own library if its functionality is not crucial to the core functionality of your package.

## A healthier Swift ecosystem

If you follow these few tips in your libraries, you will help keep the greater Swift ecosystem healthy and thriving. There will be fewer unresolvable dependency graphs, fewer forked projects, less time spent compiling unneeded code, and more happy developers! 😀
