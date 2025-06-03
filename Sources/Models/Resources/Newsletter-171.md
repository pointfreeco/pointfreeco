There is a long-standing problem in the Apple ecosystem that makes using of one of Swift’s most powerful features, macros, incur a tremendous cost on your build times. To use macros one must first build [SwiftSyntax](http://github.com/swiftlang/swift-syntax/) from scratch, which takes approximately ~20 seconds in development and over 4 minutes in release. This cost is too much for many to bear, and so many developers simply cannot use any libraries that make use of macros or introduce macros into their own codebase.

Well, that was until Xcode 16.4! This most recent release of Xcode has brought [pre-compiled binaries of SwiftSyntax][swift-forums-post] to the toolchain so that macros no longer need to build SwiftSyntax. Join us for a quick overview of how to take advantage of this new feature of Swift to slim down your build times.

[swift-forums-post]: https://forums.swift.org/t/preview-swift-syntax-prebuilts-for-macros/80202

## Pre-built SwiftSyntax

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

## Benchmark and caveats

As quick demonstration of how the pre-compiled SwiftSyntax we timed how long it takes to build the demo application we are building in our “[Modern Persistence](https://www.pointfree.co/collections/modern-persistence)” series of episodes. It uses our [Structured Queries](https://github.com/pointfreeco/swift-structured-queries) library, which leverages macros to build type-safe and schema-safe SQL queries.

Building the app from scratch in debug mode currently takes about **37 seconds**, while building with the precompiled SwiftSyntax takes only **15 seconds**. And one can clearly see the how the build timeline dramatically changed:

| Before | After |
|--------|-------|
| ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7e218e7f-65bb-44d0-af53-3019f8e90300/public) | ![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/12a34ace-6b3b-4dbb-0eef-60fd7411e000/public) |

The large yellow segments in the first image is the compilation of SwiftSyntax, and those segments are completely gone in the second.

It is worth mentioning a number of caveats with this. You will not necessarily immediately see 20+ seconds shaved off your build times just because you drop in a precompiled SwiftSyntax. Typically the amount of code compiled in an app far outweighs the amount of code in SwiftSyntax, and a lot of that code can be compiled in parallel with SwiftSyntax. So the savings you see from a static SwiftSyntax may be slightly less.

However, where the precompiled SwiftSyntax will *really* shine is when building smaller feature modules for tests and Xcode previews. These are situations in which the time to compile SwiftSyntax is much greater than the feature code being compiled, and so you can expect much faster feedback loops.

And the benefits are even greater when it comes to release builds. Building the above app for release takes about **226 seconds** (almost 4 minutes!) without precompiled SwiftSyntax, whereas _with_ precompiled takes just **45 seconds**. And this is on fast, local hardware. You will see even more time saved in build-constrained environments, like Xcode Cloud and other continuous integration options.

Finally, precompiled SwiftSyntax was built for release, and so the macros built from it should perform better than before in day-to-day coding.

## Try it today!

If you or your team has had reservations about adopting macros or packages that employ them, now is the perfect time to reconsider! Take this preview for a spin and try building your app or packages with precompiled SwiftSyntax today. And let Apple know if you encounter any issues in [the forum thread](https://forums.swift.org/t/preview-swift-syntax-prebuilts-for-macros/80202).
