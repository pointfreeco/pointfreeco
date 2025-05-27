There is a long-standing problem in the Apple ecosystem that makes using of one of Swift’s most powerful features, macros, incur a tremendous cost on your build times. To use macros one must first build [SwiftSyntax](http://github.com/swiftlang/swift-syntax/) from scratch, which takes approximately ~20 seconds in development and over 4 minutes in release. This cost is too much for many to bear, and so many developers simply cannot use any libraries that make use of macros or introduce macros into their own codebase.

We [brought this to the attention](https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588) of the greater Swift community before macros were officially released, and [subsequent threads](https://forums.swift.org/t/compilation-extremely-slow-since-macros-adoption/67921) have become a hotbed for members of the community to vent their frustrations. But, while we wait for an official solution from Apple, a few Swift community members took matters into their own hands.

# Static SwiftSyntax

[Vatsal Manot](https://github.com/vmanot) and [John Holdsworth](https://github.com/johnno1962) are both prolific open source contributors and maintainers, and with the help of a few other community members ([Kohki Miki](https://github.com/giginet), [Kabir Oberai](https://github.com/kabiroberai), [Yume](https://github.com/yume190)) they have figured out a way to provide a [statically built SwiftSyntax](https://github.com/swift-precompiled/swift-syntax) to a project that achieves 3 main goals:

- Xcode and SPM will use the statically built SwiftSyntax framework instead of building from scratch.
- It does not require 3rd party libraries to make any changes to their code. They will continue depending on swiftlang/swift-syntax in their Package.swift.
- 1st parties wanting to use the statically built SwiftSyntax need to perform only one step a single time.

Sound too good to be true? Well, they seem to have achieved the impossible, and Vatsal Manot has been generous enough to maintain an open source repo of precompiled Swift frameworks: [swift-precompiled/swift-syntax](https://github.com/swift-precompiled/swift-syntax).

The steps to integrate this statically built version of SwiftSyntax into your project depends on how your project is set up:

- If you have an SPM package in your Xcode project, then you can simply add a dependency on swift-precompiled/swift-syntax pointed to the “release/6.1” branch:
    
    ```swift
    dependencies: [
      .package(
        url: "https://github.com/swift-precompiled/swift-syntax",
        branch: "release/6.1"
      )
      …
    ]
    ```
    
    Other releases of SwiftSyntax are also provided besides just 6.1.
    
- If you do not have an SPM package in your Xcode project, then navigate to the “Package Dependencies” tab of your project settings, and add a dependency on https://github.com/swift-precompiled/swift-syntax:
    
    ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f6c98d3d-6811-4eb8-f9b3-81d57e549600/public)
    
    **Note:** You do not need to add any of SwiftSyntax’s libraries to your app targets. It is only necessary to have a dependency on this specific repository.
    

Once that is done Xcode will stop depending on swiftlang/swift-syntax and instead depend on swift-precompiled/swift-syntax. This means the source code of SwiftSyntax is no longer in your project, and could not be compiled even if Xcode wanted. Instead, Xcode will not use the pre-built frameworks provided by swift-precompiled/swift-syntax.

> Important: We have found that it is sometimes necessary to reset package caches after adding swift-precompiled/swift-syntax in order for Xcode to correctly pick up the new static library.

You can see this directly in Xcode by expanding the swift-syntax package in the sidebar to see that it only contains the prebuilt frameworks:

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f6da3769-2ece-4a8a-9958-94a791fdfb00/public)

That is all takes to get Xcode and SPM to use prebuilt binaries for SwiftSyntax and greatly reduce the compile times of your projects.

# Benchmark and caveats

As quick demonstration of how the pre-compiled SwiftSyntax we timed how long it takes to build the demo application we are building in our “[Modern Persistence](https://www.pointfree.co/collections/modern-persistence)” series of episodes. It uses our [Structured Queries](https://github.com/pointfreeco/swift-structured-queries) library, which leverages macros to build type-safe and schema-safe SQL queries.

Building the app from scratch currently takes about **37 seconds**, and building with the precompiled SwiftSynax takes only **15 seconds**. And one can clearly see the how the build timeline dramatically changed:

| Before | After |
|--------|-------|
| ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7e218e7f-65bb-44d0-af53-3019f8e90300/public) | ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/12a34ace-6b3b-4dbb-0eef-60fd7411e000/public) |

The large yellow segments in the first image is the compilation of SwiftSyntax, and those segments are completely gone in the second.

It is worth mentioning a number of caveats with this. You will not necessarily immediately see 20+ seconds shaved off your build times just because you drop in a precompiled SwiftSyntax. Typically the amount of code compiled in an app far outweighs the amount of code in SwiftSyntax, and a lot of that code can be compiled in parallel with SwiftSyntax. So the savings you see from a static SwiftSyntax may be less than 20 seconds.

However, where the precompiled SwiftSyntax will *really* shine is when building smaller feature modules for tests and Xcode previews. These are situations in which the time to compile SwiftSyntax is much greater than the feature code being compiled, and so you can expect much faster feedback loops.

# What’s the catch?

You may be wondering what the catch is. This seems too good to be true!

As of writing this, there are only two gotchas to be aware of:

- First of all, this trick only works for Apple platforms and does not work for Linux, Windows, etc. Those platforms will need to continue building SwiftSyntax from scratch for the time being. If you have a cross-platform project, then you will need to conditionally include the precompiled SwiftSyntax repo only on Apple platforms:
    
    ```swift
    var platformSpecificDependencies: [Package.Dependency] {
      var dependencies: [Package.Dependency] = []
      #if canImport(Darwin)
        dependencies.append(
          .package(
            url: "https://github.com/swift-precompiled/swift-syntax",
            branch: "release/6.1"
          )
        )
      #endif
      return dependencies
    }
    ```
    
- Second, this trick does currently generate an SPM warning that seems scary at first:
    
    > Warning: 'swift-structured-queries' dependency on 'swiftlang/swift-syntax' conflicts with dependency on 'swift-precompiled/swift-syntax' which has the same identity 'swift-syntax'. this will be escalated to an error in future versions of SwiftPM.
    
    The problem is that the project is now depending on two repositories with the swift-syntax name. However, Xcode and SPM seem to consistently take the one that is defined at the highest level, such as the app target, and that is why swift-precompiled/swift-syntax is chosen over swiftlang/swift-syntax.
    
    It is possible that someday in the future SPM may become more strict and turn this warning into an error. That would simply mean this trick no longer works, and you will have to remove your dependence on swift-precompiled/swift-syntax on go back to building SwiftSyntax from scratch. Or perhaps Apple will have a solution to this problem by then!

# Tips

A few things to keep in mind when using swift-precompiled/SwiftSyntax:

- Do not use swift-precompiled/swift-syntax in library code. Library code should continue using swiftlang/swift-syntax, and really only Xcode app targets should ever depend on swift-precompiled/swift-syntax.
- If the expanded swift-syntax package in the Xcode side bar does not look like the above screenshot, then try reseting the caches in Xcode (right click “Package Dependencies” in sidebar, and click “Reset Package Caches”).

# Save time today!

We feel that this trick for using a statically compiled SwiftSyntax is stable enough that we recommend you giving it a shot in your own codebases. We have started using it in the [Point-Free codebase](https://github.com/pointfreeco/pointfreeco/pull/968), and we will use it more moving forward.
