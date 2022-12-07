import Foundation

public let post0087_YIR2022 = BlogPost(
  author: .pointfree,
  blurb: """
    Point-Free year in review: 43 episodes, 150k visitors, dozens of open source releases, and more!
    """,
  contentBlocks: [
    .init(
      content: #"""
        It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of
        everything we produced for 2022, so join us for a quick review of some of our favorite
        highlights.

        We are also offering [25% off][eoy-discount] the first year for first-time subscribers. If
        you’ve been on the fence on whether or not to subscribe, now is the time!

        ## Highlights

        2022 was our biggest year yet:

        * **150k** unique vistors to the site.
        * **45** episodes released for a total of **31** hours of video, and **15** blog posts
        published.
        * Over **200k** video views, **6 years** watching time, and over **44 terabytes** of video
        streamed.
        * **1** new project open sourced and dozens of updates to our other libraries.

        But these high-level stats don’t even scratch the surface of what we covered in 2022:

        ## Episodes and open source

        This years episodes were action packed, to say the least. We made use of many new, advanced
        features of Swift 5.7, especially result builders, existentials, and constrained opaque
        types, in order to push the Swift language and SwiftUI to the limits of what it can
        accomplish. And along the way we released one brand new open source library, as well as
        many significant updates to some of our most popular libraries.

        ### Parsers

        The first 17 episodes of 2022 brought 3 substantial improvements to our
        [Parsing][swift-parsing-gh] library:

        * A builder syntax that allows one to concisely build complex parsers. For example,
        before parser builders we could construct a parser of a comma-separated lists of users
        like so:

          ```swift
          let user = Int.parser()
            .skip(",")
            .take(Prefix { $0 != "," }.map(String.init))
            .skip(",")
            .take(Bool.parser())
            .map(User.init(id:name:isAdmin:))
          let users = Many(user, separator: "\n")
          ```

          While not bad, there is a lot of superfluous noise when using the `take` and `skip`
        operators in order to incrementally parser from the beginning of an input string. Using
        parser builders this becomes:

          ```swift
          let users = Many {
            Parse(User.init(id:name:role:)) {
              Int.parser()
              ","
              Prefix { $0 != "," }.map(String.init)
              ","
              Bool.parser()
            }
          } separator: {
            "\n"
          }
          ```

        * We added error messaging for when a parser fails on some input. For example, using the
        above parser to parse a string in which the boolean "true" is mispelled:

          ```swift
          try users.parse("""
            1,Blob,true
            2,Blob Jr.,false
            3,Blob Sr.,tru
            """)
          ```

          …causes the following error to be thrown:

          ```
          caught error: "error: multiple failures occurred

          error: unexpected input
           --> input:3:11
          3 | 3,Blob Jr,tru
            |           ^ expected "true" or "false"
          ```

        * And last, but not least, we added the ability for parsers to be "inverted" so that they
        can print well-structured data types back into their raw input format, such as strings.
        There is only one small change that needs to be made to the above `users` parser to
        magically turn it into a parser-printer:

          ```diff
           let users = Many {
          -  Parse(User.init(id:name:role:)) {
          +  Parse(.memberwise(User.init(id:name:role:))) {
               Int.parser()
               ","
               Prefix { $0 != "," }.map(String.init)
               ","
               Bool.parser()
             }
           } separator: {
             "\n"
           }
          ```

          With that one change you can now print an array of `User` values back into a string:

          ```swift
          try users.print([
            User(id: 1, "Blob", isAdmin: true),
            User(id: 2, "Blob Jr.", isAdmin: false),
            User(id: 3, "Blob Sr.", isAdmin: true),
          ])
          // 1,Blob,true
          // 2,Blob Jr.,false
          // 3,Blob Sr.,true
          ```

        If you want to learn more about parsers, be sure to check out our [collection of
        episodes][parsers-collection] (including the _free_ [5-part tour][parsers-tour]), and
        give the [library][swift-parsing-gh] a spin today!

        ### Concurrency

        We devoted a [5-part series][concurrency-collection] of episodes to uncovering many of
        Apple's concurrency tools from the past, present and into the future. We started by diving
        deep into threads and queues, which have been around on Apple's platforms for many years.
        Thosem tools are powerful for running concurrent code, but can be difficult to wield
        correctly, and the compiler does nothing to help you out.

        [concurrency-collection]: /collections/concurrency/threads-queues-and-tasks
        [clocks-collection]: /collections/concurrency/clocks

        ### The Composable Architecture

        We had two separate series of episodes dedicated to improving nearly every facet of our
        popular SwiftUI architecture library:

        * First, we more tightly integrated Swift's new concurrency tools into the library but
        making it possible to use structured concurrency in your feature's effects. This makes it
        much easier to construct effects, including complex, long-living effects.

         We also showed how one can tie the lifecycle of effects to the lifecycle of views. This
        makes it possible to have a feature's async work be automatically torn down when a view
        disappears.

        * Reducer protocol

        ### Clocks

        ### SwiftUI Navigation

        ### Modern SwiftUI

        <!--
        * episodes
          * parser builders, errors and invertibility
            * free tour
          * concurrency
          * tca
            * async
              * existential digression
            * reducer protocol
            * dependency management
          * clocks
          * swiftui nav
          * modern swiftui
        -->

        ## Blog posts

        We wrote 15 blog posts this year, but there were 3 main standouts.

        #### [Unobtrusive runtime warnings][runtime-warning-blog]

        Xcode has a wonderful that can notify you of subtle problems in your code by showing a
        prominent, yet unobtrusive, purple warning on the problematic line of code. This happens
        if Xcode detects a threading porblem in your code, and if you mutate UI code on a non-main
        thread, and more.

        These warnings are incredibly useful, but sadly Apple does not make it possible to create
        them from 3rd party libraries… well, at least not without some trickery. In our blog post,
        ["Unobtrusive runtime warnings for libraries"][runtime-warning-blog], we show how to create
        these warnings, allowing library maintainers to notify users when certain invariants are
        broken.

        #### [Reverse engineering `NavigationPath`][nav-path-blog]

        iOS 16 brought a whole new suite of navigation APIs for dealing with stack-based navigation.
        One of those tools, `NavigationPath`, seemed like complete magic when inspected closely.
        It allows you to drive navigation from a type-erased collection of `Hashable` data, and
        interestingly it allows you to encode the path to raw data _and_ decode the data back
        into a type-erased collection.

        This somehow works even though all of the type information of the elements has been erased.
        We make use of hidden, but public, Swift functions `_mangledTypeName` and `_typeByName` as
        well as Swift 5.7's new existential type features in order to [reverse engineer how
        `NavigationPath` works][nav-path-blog].

        <!--
        ### [Better SwiftUI navigation APIs][better-swiftui-blog]

        SwiftUI navigation can be complex, but it doesn't have to be. That's why we devoted [many
        episodes][swiftui-nav-collection] to the topic, and even
        [rebuilt][modern-swiftui-collection] one of Apple's
        -->

        <!--
        * open source
          * top level stats (starts for TCA, stars for all repos)
          * parsers
            * error handling
            * parser builder
            * parser-printer
            * routing
          * TCA
            * async
            * reducer protocol
            * dependency management
            * non-exhaustive test store
          * Clocks
          * SwiftUINav
        -->

        ## See you in 2023! 🥳
        <!--
        * 2023
          * TCA nav
          * live streams
        -->

        [eoy-discount]: /discounts/eoy-2022
        [runtime-warning-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [nav-path-blog]: /blog/posts/78-reverse-engineering-swiftui-s-navigationpath-codability
        [better-swiftui-blog]: /blog/posts/84-better-swiftui-navigation-apis
        [swiftui-nav-collection]: /collections/swiftui/navigation
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [swift-parsing-gh]: http://github.com/pointfreeco/swift-parsing
        [parsers-collection]: /collections/parsing
        [parsers-tour]: /collections/parsing/tour-of-parser-printers









        <!--
        ## SwiftUI Navigation

        By far, the most ambitious series of episodes we tackled in 2021 was [SwiftUI Navigation](/collections/swiftui/navigation). Over the course of 9 episodes we gave a precise definition of what navigation means in an application, explored SwiftUI's navigation tools (including tabs, alerts, modal sheets, and links), and then showed how to build new navigation tools that allow us to model our domains more concisely and correctly.

        After completing that series we [open sourced](/blog/posts/66-open-sourcing-swiftui-navigation) a [library](https://github.com/pointfreeco/swiftui-navigation) with all the tools discussed in the series. This makes it easy to model navigation in your application using optionals and enums, and makes it straightforward to drive deep-linking with your domain's state.

        We also used the application built in the series to explore two additional topics at the end of the year. First, we rebuilt the application in UIKit ([part 1](/episodes/ep169-uikit-navigation-part-1), [part 2](/episodes/ep170-uikit-navigation-part-2)), all without making a single change to the view model layer. This shows just how powerful it is to drive navigation off of state. Second, we explored modularity ([part 1](/episodes/ep171-modularization-part-1), [part 2](/episodes/ep172-modularization-part-2)) by breaking down the application into many modules. Along the way to explored different types of modularity, how to structure a modern Xcode project with SPM, and how to build preview apps that allow you to run small portions of your code base without building the entire application.

        <div id="open-source"></div>

        ## Open Source

        Since launching Point-Free in 2018 we have open sourced over [20 projects](https://github.com/pointfreeco), and this year alone we released 5 new projects (3 of which were extracted from our [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) library):

        ### [isowords](https://github.com/pointfreeco/isowords)

        In May of this year we released a word game for iOS called [isowords](https://www.isowords.xyz). Alongside the release we also open sourced the entire code base. Both the client and server code are written in Swift, and the client code shows how to build a large, modularized application in SwiftUI and the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). We also released a [4-part series](/collections/tours/isowords) of episodes showing off some of the cooler aspects of the code base.

        ### [xctest-dynamic-overlay](https://github.com/pointfreeco/xctest-dynamic-overlay)

        It is very common to write test support code for libraries and applications, but due to how Xcode works one cannot do this easily. If you import `XCTest` in a file, then that file cannot be compiled to run on a simulator or device. This forces you to extract test helper code into its own target/module, even though ideally the code should live right next to your library code.

        The `xctest-dynamic-overlay` library makes it possible to use the `XCTFail` assertion function from the `XCTest` framework in library and application code. It will dynamically find the `XCTFail` implementation in tests, and act as a no-op outside of tests.

        ### [swift-identified-collections](https://github.com/pointfreeco/swift-identified-collections)

        When modeling a collection of elements in your application's state, it is easy to reach for a standard `Array`. However, as your application becomes more complex, this approach can break down in many ways, including accidentally making mutations to the wrong elements or even crashing. 😬

        Identified collections are designed to solve all of these problems by providing data structures for working with collections of identifiable elements in an ergonomic, performant way.

        ### [swift-custom-dump](https://github.com/pointfreeco/swift-custom-dump)

        Swift comes with a wonderful tool for debug-printing the contents of any value to a string, and it's called `dump`. It prints all the fields and sub-fields of a value into a tree-like description. However, the output is less than ideal: dictionaries are printed in non-deterministic order, values are printed with superfluous extra type information, and some types don't print any useful information at all.

        The [swift-custom-dump](https://github.com/pointfreeco/swift-custom-dump) library ships with a function that emulates the behavior of dump, but provides a more refined output of nested structures, optimizing for readability. Further, it uses the more refined output to provide two additional tools. One for outputting a nicely formatted diff between two values of the same type, and another that acts as a drop-in replacement for `XCTAssertEqual` with a much better error message when a test fails.

        ### [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation)

        A collection of tools for making SwiftUI navigation simpler, more ergonomic and more precise. The library allows you to model your application's navigation as optionals and enums, and then provides the tools for driving alerts, modal sheets, and navigation links from state.

        # 🎉 2022 🎉

        We're thankful to all of our subscribers for supporting us and helping us create this content and these libraries. We could not do it without you.

        Next year we have even more planned, including a deep dive into Swift's new concurrency tools, improvements to the Composable Architecture to play better with concurrency and SwiftUI navigation, as well as all new parsing episodes (including result builders, reversible parsing, routing) and more!

        To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

        See you in 2022!
        -->

        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 87,
  publishedAt: Date(timeIntervalSince1970: 1671429600),
  title: "2022 Year-in-review"
)

// todo: double check 2021 mentions
