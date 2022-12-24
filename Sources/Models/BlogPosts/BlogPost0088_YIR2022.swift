import Foundation

public let post0088_YIR2022 = BlogPost(
  author: .pointfree,
  blurb: """
    Point-Free year in review: 45 episodes, 150K visitors, dozens of open source releases, and more!
    """,
  contentBlocks: [
    .init(
      content: #"""
        It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of
        everything we produced for 2022, so join us for a quick review of some of our favorite
        highlights.

        We are also offering [25% off 🎁][eoy-discount] the first year for first-time subscribers.
        If you’ve been on the fence on whether or not to subscribe, now is the time!

        ## Highlights

        2022 was our biggest year yet:

        * **150k** unique visitors to the site.
        * **45** episodes released for a total of **31** hours of video, and **15** blog posts
        published.
        * Over **200k** video views, **6 years** watching time, and over **44 terabytes** of video
        streamed.
        * **1** new project open sourced and dozens of updates to our other libraries.

        But these high-level stats don’t even scratch the surface of what we covered in 2022:

        ## Episodes and open source

        This year's episodes were action-packed, to say the least. We made use of many new, advanced
        features of Swift 5.7, especially result builders, existentials, and constrained opaque
        types, in order to push the Swift language and SwiftUI to the limit of what they can
        accomplish. And along the way we released one brand new open source library, as well as
        many significant updates to some of our most popular libraries.

        #### Parsers

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
              Parse(User.init(id:name:isAdmin:)) {
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
            above parser to parse a string in which the boolean "true" is misspelled:

            ```swift
            try users.parse("""
              1,Blob,true
              2,Blob Jr.,false
              3,Blob Sr.,tru
              """)
            ```

            …causes the following error to be thrown:

            ```
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
            -  Parse(User.init(id:name:isAdmin:)) {
            +  Parse(.memberwise(User.init(id:name:isAdmin:))) {
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

        <!-- todo: routing -->

        #### Concurrency

        We devoted a [5-part series][concurrency-collection] of episodes to uncovering many of
        Apple's concurrency tools from the past, present, and into the future. We started by diving
        deep into threads and queues, which have been around on Apple's platforms for many years.
        Those tools are powerful for running concurrent code, but can be difficult to wield
        correctly, and the compiler does nothing to help you out.

        Understanding the tools of the past helps us understand why Swift's new concurrency tools
        take the form they do. The new tools are meant to allow us to write concurrent code in a
        style that looks like "regular" code, and do so in a way that allows the compiler to catch
        race conditions at compile time rather than runtime.

        #### The Composable Architecture

        We had two separate series of episodes dedicated to improving nearly every facet of our
        popular SwiftUI architecture library: the [Composable Architecture][tca-gh].

          * First, we more [tightly integrated Swift's new concurrency tools][async-tca-collection]
            into the library by making it possible to use structured concurrency in your feature's
            effects. This makes it much easier to construct effects, including complex, long-living
            ones, and makes it possible to tie the lifecycle of effects to the lifecycle of views.

            While covering these topics we also had a fun [digression into Swift 5.7's new
            existential type features][existential-digression] (starts at 18:12, subscription
            required). It shows how one can think of existential types as a kind of "infinite" enum,
            which helps build intuition of why protocols seem so different from regular, concrete
            types.

          * Second, [we revamped the fundamental unit][reducer-protocol-collection] that defines a
            feature in the Composable Architecture: the reducer. It changed from being a struct that
            wraps a function to a protocol. This allows one to create all new types for
            encapsulating the logic for a feature, which unlocks new ways of structuring and
            composing features, and even a whole new way of managing dependencies.

            While covering these topics we also had a fun [digression into improving type inference
            in result builders][type-inference-builders] (starts at 21:34, subscription required).
            We showed that a combination of generic result builders and `buildExpression` can allow
            types to more fully propogate to all parts of the builder, greatly enhancing its
            ergnomics.

          * In addition to those improvements, we also made a massive improvement to the testing
            facilities of the library, thanks to a collaboration with [Krzysztof
            Zabłocki][merowing.info]. We introduced the concept of ["non-exhaustive
            `TestStore`"][nets-blog] to the library, which allows you to write high level
            integration tests between many features without needing to assert on _everything_ that
            happens in the feature. This can make it possible to write powerful tests that are not
            brittle and difficult to maintain.

        #### Clocks

        One of the most common forms of asynchrony is time-based asynchrony, and Swift 5.7
        introduced the `Clock` protocol as a means of abstracting over the concept of "sleeping" in
        an async context. This protocol even makes it possible to write controllable, testable async
        code, and can even make Xcode previews more responsive for fast, iterative UI design.

        Our [2-part deep dive][clocks-collection] into the `Clock` protocol explains why this
        tool is so important, and shows how to make a few new conformances, such as the "immediate
        clock" and "test clock". We even [open sourced a brand new library][clocks-gh] that brings
        these tools, and more, to everyone's codebase.

        #### SwiftUI navigation and modern SwiftUI

        SwiftUI navigation can be complex, but it doesn't have to be. That's why we devoted [12
        episodes][swiftui-nav-collection] to the topic where we give a precise definition of what
        navigation means in an application, explored SwiftUI's navigation tools (including tabs,
        alerts, modal sheets, and links), and then showed how to build new navigation tools that
        allow us to model our domains more concisely and correctly.

        This year we updated that series of episodes to include iOS 16's new navigation tools,
        including `NavigationStack`, `NavigationPath`, and the new `navigationDestination` view
        modifier. After those episodes we [released an update][better-swiftui-blog] to our
        [SwiftUI Navigation library][swiftu-nav-gh] that makes it possible to drive _all_ forms of
        navigation from a single piece of enum state, with a case for each possible destination in
        your feature. This can massively simplify your navigation logic, and prevent a large class
        of bugs from ever appearing in your code.

        Once all of those tools were under our belt we started a [brand new series of
        episodes][modern-swiftui-collection] (still ongoing at the time of publishing this article)
        covering best, modern SwiftUI practices. We do this by rebuilding one of Apple's most
        interesting demo applications, the [“Scrumdinger”][scrumdinger-tutorial]. This application
        shows off many navigation flows, interesting user interactions, and some complex effects
        such as timers, persistence, and even a speech recognizer.

        ## Blog posts

        We wrote 15 blog posts this year, but there were 3 main standouts.

        #### [Unobtrusive runtime warnings][runtime-warning-blog]

        Xcode has a wonderful feature that can notify you of subtle problems in your code by showing
        a prominent, yet unobtrusive, purple warning on the problematic line of code. This happens
        if Xcode detects a threading problem in your code, if you mutate UI code on a non-main
        thread, and more.

        These warnings are incredibly useful, but sadly Apple does not make it possible to create
        them from 3rd party libraries…well, at least not without some trickery. In our blog post,
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

        #### [Non-exhaustive testing in the Composable Architecture][nets-blog]

        Testing is by far the #1 priority of the [Composable Architecture][tca-gh]. The library
        provides a tool, the [`TestStore`][test-store-docs], that makes it possible to
        _exhaustively_ prove how your features evolve over time. This not only includes how state
        changes with every user action, but also how effects are executed, and how data is fed back
        into the system.

        The testing tools in the library haven't changed much in the two and a half years since
        release, but thanks to close collaboration with [Krzysztof Zabłocki][merowing.info] and
        support from his employer, [The Browser Company](https://thebrowser.company), the
        Composable Architecture was updated to bring first class support for "non-exhaustive"
        test stores.

        Read our article, ["Non-exhaustive testing in the Composable Architecture"][nets-blog],
        for an overview of the "why" and "how" of exhaustive testing, as well as when it breaks
        down, and how non-exhaustive testing can help.

        ## See you in 2023! 🥳

        We're thankful to all of our subscribers for supporting us and helping us create this
        content and these libraries. We could not do it without you!

        Next year we have even more planned, including powerful new navigation tools in the
        Composable Architecture, deep dives into existential types and other powerful type system
        concepts, and we plan exploring new forms of content (live streams!).

        To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year
        for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now
        is the time!

        See you in 2023!

        [eoy-discount]: /discounts/eoy-2022
        [runtime-warning-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [nav-path-blog]: /blog/posts/78-reverse-engineering-swiftui-s-navigationpath-codability
        [better-swiftui-blog]: /blog/posts/84-better-swiftui-navigation-apis
        [swiftui-nav-collection]: /collections/swiftui/navigation
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [swift-parsing-gh]: http://github.com/pointfreeco/swift-parsing
        [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
        [parsers-collection]: /collections/parsing
        [parsers-tour]: /collections/parsing/tour-of-parser-printers
        [concurrency-collection]: /collections/concurrency/threads-queues-and-tasks
        [clocks-collection]: /collections/concurrency/clocks
        [reducer-protocol-collection]: /collections/composable-architecture/reducer-protocol
        [async-tca-collection]: /collections/composable-architecture/async-composable-architecture
        [clocks-gh]: http://github.com/pointfreeco/swift-clocks
        [swiftu-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
        [existential-digression]: /episodes/ep196-async-composable-architecture-tasks#t1092
        [nets-blog]: /blog/posts/83-non-exhaustive-testing-in-the-composable-architecture
        [merowing.info]: http://merowing.info
        [scrumdinger-tutorial]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [test-store-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/teststore
        [type-inference-builders]: /episodes/ep204-reducer-protocol-composition-part-2#t1294
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 88,
  publishedAt: Date(timeIntervalSince1970: 1_671_429_600),
  title: "2022 Year-in-review"
)
