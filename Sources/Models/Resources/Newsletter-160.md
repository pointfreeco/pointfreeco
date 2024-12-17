It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we 
produced for 2024, so join us for a quick review of some of our favorite highlights.
We are also offering [25% off][eoy-discount] the first year for first-time subscribers. If you’ve 
been on the fence on whether or not to subscribe, now is the time!

[eoy-discount]: /discounts/2024-eoy

@Button(/discounts/2024-eoy) {
  Subscribe today!
}

[eoy-discount]: /discounts/2024-eoy

# Highlights

2024 was a big year for us:

* **292k** unique visitors to the site.
* **46** episodes released for a total of **28** hours of video, and **23** blog posts
published.
* **4** new projects open sourced and dozens of updates to our other libraries.
* **Redesign** of the [site](https://www.pointfree.co), including a dedicated page showcasing all
[**free episodes**](https://www.pointfree.co/episodes/free).

But these high-level stats don’t even scratch the surface of what we covered this year. Join us for 
an overview of some of our favorite episode arcs, open source updates, and blog posts from 2024:

* [Episodes](#episodes)
  * [Point-Free Live: Observation in Practice](#point-free-live-observation-in-practice)
  * [Sharing and Persisting State in the Composable Architecture](#sharing-and-persisting-state-in-the-composable-architecture)
  * [Modern UIKit](#modern-uikit)
  * [Cross-platform Swift](#cross-platform-swift)
  * [Back to basics: Equatable and Hashable](#back-to-basics-equatable-and-hashable)
  * [SQLite](#sqlite)
  * [Tour of Sharing](#tour-of-sharing)
* [Open source](#open-source)
  * [Perception](#perception)
  * [Issue Reporting](#issue-reporting)
  * [Swift Navigation](#swift-navigation)
  * [Sharing](#sharing)
* [Blog posts](#blog-posts)
  * [Observation comes to the Composable Architecture](#observation-comes-to-the-composable-architecture)
  * [Sharing state in the Composable Architecture](#sharing-state-in-the-composable-architecture)
  * [Building an app in the Composable Architecture, from scratch](#building-an-app-in-the-composable-architecture-from-scratch)
  * [This is what peak UIKit looks like](#this-is-what-peak-uikit-looks-like)
  * [Composable Architecture Frequently Asked Questions](#composable-architecture-frequently-asked-questions)
  * [Swift Navigation: Powerful navigation tools for all Swift platforms](#swift-navigation-powerful-navigation-tools-for-all-swift-platforms)
  * [Cross-Platform Swift: Building a Swift app for the browser](#cross-platform-swift-building-a-swift-app-for-the-browser)
  * [Point-Free is Xcode 16 ready](#point-free-is-xcode-16-ready)
  * [Parsing and the Advent of Code](#parsing-and-the-advent-of-code)
* [See you in 2025! 🥳](#see-you-in-2025)

# Episodes

## Point-Free Live: Observation in Practice

We began the year by celebrating our [6th birthday][pf-6] with a 
[livestream][pf-live-obs-in-practice]. We showed off more superpowers from adding Observation tools 
to the Composable Architecture, including how it plays nicely with UIKit. And then we live released 
a powerful new feature of the library: the `@Reducer` macro. This tool massively simplifies many 
common patterns in applications, such as driving navigation from an enum. And then finally, we gave 
a sneak peek at some upcoming tools coming to the library that improve how one shares state amongst 
many features.

[pf-6]: /blog/posts/131-point-free-turns-6
[perception-blog]: /blog/posts/129-perception-a-back-port-of-observable
[pf-live-obs-in-practice]: /episodes/ep267-point-free-live-observation-in-practice

## [Sharing and Persisting State in the Composable Architecture][shared-state-collection]

Our first [meaty series of episodes][shared-state-collection] for 2024 built the tools for easily
sharing state amongst features in Composable Architecture applications. One of the benefits of the
Composable Architecture is that it allows you to fully embrace value types for your domain (in 
contrast to the reference types SwiftUI and Swift Data often lead you towards), but that does
make it difficult to _share_ state.

The tools we build (from scratch) in the series solve this problem, and further make it possible to
even persist the state with external storage systems, such as `UserDefaults`, the file system, 
and more.  

[shared-state-collection]: https://www.pointfree.co/collections/composable-architecture/sharing-and-persisting-state

## Modern UIKit

No one asked us to do a ["Modern UIKit"][modern-uikit-collection] series in the year 2024, but that
doesn't mean there isn't a bunch of fascinating topics to explore! While SwiftUI may be powerful,
the fact of the matter is that you often need to drop down to UIKit to accomplish certain things.
And if you do things the right way, you can leverage a lot of the niceties one gets from SwiftUI,
such as automatic state observation for updating UI, state-driven navigation, and 2-way bindings for
UI controls.

[modern-uikit-collection]: https://www.pointfree.co/collections/uikit/modern-uikit

## Cross-platform Swift

Swift builds for a variety of non-Apple platforms, including Windows, Linux, and WebAssembly (Wasm),
which is exciting! But it does take work to write code that can actually run on non-Apple platforms.
In [this series][cross-platform-collection] we write cross-platform Swift code from scratch, and
show how by modeling your domains concisely and controlling your dependencies, you can run an
app on iOS devices and in browsers with a single codebase. 

[cross-platform-collection]: https://www.pointfree.co/collections/cross-platform-swift
[focus-areas-2025]: https://forums.swift.org/t/swift-language-focus-areas-heading-into-2025/76611

## Back to basics: Equatable and Hashable

While we enjoy discussing advanced topics in Swift on Point-Free, it is nice to get 
[back to basics][eq-hash-collection] every once in awhile. This year we explored everything
there is to know about the `Equatable` and `Hashable` protocols, including their mathematical
foundations. This makes it easy to understand why providing an "unfaithful" conformance to these
protocols are going to lead you to code with subtle bugs, or even code that will crash at runtime.

[eq-hash-collection]: https://www.pointfree.co/collections/back-to-basics/equatable-and-hashable

## SQLite

In anticipation of episodes we have planned for the future, we decided to give a quick 
[introduction to SQLite][sqlite-collection]. This includes how to interact directly with the SQLite
C library directly (unsafe pointers galore!), as well as how to use the popular Swift library 
[GRDB][grdb-gh] to more safely and concisely interact with SQLite.

[grdb-gh]: http://github.com/groue/GRDB.swift
[sqlite-collection]: https://www.pointfree.co/collections/back-to-basics/sqlite

## Tour of Sharing

Our final series of the year gives a [tour][sharing-tour-collection] of an open source library that
we also released at the end of the year: [Swift Sharing][swift-sharing-gh]. The tour builds a 
small application that uses the `appStorage` and `fileStorage` persistence strategies from the 
library, which allows you to hold onto persisted state in your features as if it's just regular
state.

[swift-sharing-gh]: http://github.com/pointfreeco/swift-sharing
[sharing-tour-collection]: https://www.pointfree.co/collections/tours/tour-of-swift-sharing

# Open source

## Perception

We kicked off the year with a bang by releasing [Perception][perception-gh], a library that 
back-ports Swift's observation tools to older Apple platforms, all the way back to iOS 13. This was
a big effort for us that originated from us wanting to support observation tools in the Composable
Architecture, but ultimately realized it would help anyone building SwiftUI applications.  

[perception-gh]: http://github.com/pointfreeco/swift-perception

## Issue Reporting

Reporting issues in apps is important, but the manner one reports can be difficult to get right.
We want to be able to report issues in a way that is immediately noticeable yet not annoying or
obtrusive. Our library tries to find the right balance, and is extensible allowing you to provide
your own custom issue reporters.

[issue-reporting-gh]: http://github.com/pointfreeco/swift-issue-reporting

## Swift Navigation

Released as a brand new library, [Swift Navigation][swift-navigation-gh] evolved from our older
library, SwiftUI Navigation. We realized that many of the tools we were builing for SwiftUI were
just as applicable to UIKit and even cross-platform Swift apps.

[swift-navigation-gh]: http://github.com/pointfreeco/swift-navigation

## Sharing

We ended the year by releasing a powerful new library, [Swift Sharing][sharing-gh], which provides
tools for sharing state amongst many features in an app and allowing that state to be persisted
to external systems, such as `UserDefaults` and the file system. It has become one of our most
quickly adopted libraries ever released, and the community has already built powerful tools on top
of its foundation.

[sharing-gh]: http://github.com/pointfreeco/swift-sharing
  
# Blog posts

## Building an app in the Composable Architecture, from scratch

To celebrate the 4 year birthday of the Composable Architecture we released a 
[brand new tutorial][tca-tutorial] that builds a moderately complex app from scratch using the
library. It focuses on a number of core tenets of the library, such as using value types for your 
domain, state-driven navigation, concise domain modeling, controlling dependencies, testing,
and a lot more.

[tca-tutorial]: https://pointfreeco.github.io/swift-composable-architecture/main/tutorials/buildingsyncups
[tca-tutorial-blog]: /blog/posts/138-building-an-app-in-the-composable-architecture-from-scratch

## This is what peak UIKit looks like

Our [sneak peek][peak-uikit-blog] at a suite of new tools that allows one to build powerful, modern
UIKit apps. This includes easy state observation for updating the UI, state-driven navigation,
and 2-way bindings for UI controls. Later in the year we ended up 
[open sourcing those tools][swift-nav-gh].

[peak-uikit-blog]: /blog/posts/140-this-is-what-peak-uikit-looks-like

## Composable Architecture Frequently Asked Questions

Much ink has been spilled from the community about the pros and cons of the Composable Architecture,
but often these articles are based on outdated information. We try to 
[set the record straight][tca-faq-blog-post] with a dedicated FAQ to addresses the most common
grievances and misunderstandings of the library.

[tca-faq-blog-post]: /blog/posts/141-composable-architecture-frequently-asked-questions

## Swift Navigation: Powerful navigation tools for all Swift platforms

The announcement [blog post][swift-nav-blog] for our new [Swift Navigation][swift-nav-gh] library.
Learn a little bit about the powerful tools it provides for all Swift applications, including
those using SwiftUI, UIKit, and even cross-platform apps running on non-Apple platforms.

[swift-nav-gh]: http://github.com/pointfreeco/swift-navigation
[swift-nav-blog]: /blog/posts/149-swift-navigation-powerful-navigation-tools-for-all-swift-platforms

## Cross-Platform Swift: Building a Swift app for the browser

In this [blog post][cross-platform-blog] we give a quick overview on what it takes to build 
cross-platform Swift code. In particular, we show how to build a Swift app for WebAssembly so that
we can run a pure Swift app in the browser.

[cross-platform-blog]: /blog/posts/151-cross-platform-swift-building-a-swift-app-for-the-browser

## Point-Free is Xcode 16 ready

From the first day of Xcode 16's release our libraries have been [ready][xcode-16-blog]. All of our 
libraries were audited for complete compatibility to the strict concurrency checking of Swift 6 
language mode. And all libraries that provided testing tools and helpers were updated to be 
simultaneously compatible with XCTest as well as Swift's new native Testing framework. 

[xcode-16-blog]: /blog/posts/152-point-free-is-xcode-16-ready

## Parsing and the Advent of Code

Just a fun, end-of-year [blog post][parsing-advent] where we show how to use our 
[Swift Parsing][parsing-gh] library to give a head start on solving Advent of Code problems. The 
majority of problems for the advent first involve parsing a text file of input data into first class
data types so that you can then actually solve the problem. This is something that our Parsing
library excels at!

[parsing-gh]: http://github.com/pointfreeco/swift-parsing
[parsing-advent]: /blog/posts/158-parsing-and-the-advent-of-code

# See you in 2025! 🥳

We're thankful to all of our subscribers for [supporting us](/pricing) and helping us create our 
episodes and support our open source libraries. We could not do it without you!

To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year
for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now
is the time!

[eoy-discount]: /discounts/2024-eoy

@Button(/discounts/2024-eoy) {
  Subscribe today!
}
