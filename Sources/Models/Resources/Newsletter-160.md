It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we 
produced for 2024, so join us for a quick review of some of our favorite highlights.

We are also offering [25% off 🎁][eoy-discount] the first year for first-time subscribers. If you’ve 
been on the fence on whether or not to subscribe, now is the time!

[eoy-discount]: /discounts/2024-eoy

@Button(/discounts/2024-eoy) {
  Subscribe today!
}

[eoy-discount]: /discounts/2024-eoy

# Highlights

2024 was our biggest year yet:

* **292k** unique visitors to the site.
* **46** episodes released for a total of **28** hours of video, and **23** blog posts
published.
* **4** new projects open sourced and dozens of updates to our other libraries.
* **Redesign** of the [site](https://www.pointfree.co), including a dedicated page showcasing all
[**free episodes**](https://www.pointfree.co/episodes/free).

But these high-level stats don’t even scratch the surface of what we covered this year. Join us for 
an overview of some of our favorite episode arcs, open source updates, and blog posts from 2024:

* [Episodes](#episodes)
  * [Point-Free Live: Observation in Practice](#todo)
  * [Sharing and Persisting State in the Composable Architecture](#todo)
  * [Modern UIKit](#todo)
  * [Cross-platform Swift](#todo)
  * [Back to basics: Equatable and Hashable](#todo)
  * [SQLite](#todo)
  * [Tour of Sharing](#todo)
* [Open source](#open-source)
  * [Perception](#todo)
  * [Issue Reporting](#todo)
  * [Swift Navigation](#todo)
  * [Sharing](#todo)
* [Blog posts](#blog-posts)
  * [Building an app in the Composable Architecture, from scratch](#todo)
  * [This is what peak UIKit looks like](#todo)
  * [Composable Architecture Frequently Asked Questions](#todo)
  * [Swift Navigation: Powerful navigation tools for all Swift platforms](#todo)
  * [Cross-Platform Swift: Building a Swift app for the browser](#todo)
  * [Point-Free is Xcode 16 ready](#todo)
  * [Parsing and the Advent of Code](#todo)
  * [Simple state sharing and persistence in Swift](#todo)
* [See you in 2025! 🥳](#see-you-in-2025)

# Episodes

## [Point-Free Live: Observation in Practice][pf-live-obs-in-practice]

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

## [Modern UIKit][modern-uikit-collection]

No one asked us to do a ["Modern UIKit"][modern-uikit-collection] series in the year 2024, but that
doesn't mean there isn't a bunch of fascinating topics to explore! While SwiftUI may be powerful,
the fact of the matter is that you often need to interface with UIKit to accomplish certain things.
And if you do things the right way, you can leverage a lot of the niceties one gets from SwiftUI,
such as automatic state observation for updating UI, state-driven navigation, and 2-way bindings for
UI controls.

[modern-uikit-collection]: https://www.pointfree.co/collections/uikit/modern-uikit

## [Cross-platform Swift][cross-platform-collection]

Swift builds for a variety of non-Apple platforms, including Windows, Linux, and WebAssembly (Wasm),
which is exciting! But it does take work to write code that can actually run on non-Apple platforms.
In [this series][cross-platform-collection] we write cross-platform Swift code from scrach, and
show how by modeling your domains concisely and controlling your dependencies, you can run an
app on iOS devices and in browsers with a single codebase. 

[cross-platform-collection]: https://www.pointfree.co/collections/cross-platform-swift
[focus-areas-2025]: https://forums.swift.org/t/swift-language-focus-areas-heading-into-2025/76611

## [Back to basics: Equatable and Hashable][back-to-basics]

While we enjoy discussing advanced topics in Swift on Point-Free, it is nice to get 
[back to basics][eq-hash-collection] every once in awhile. This year we explored everything
there is to know about the `Equatable` and `Hashable` protocols, including their mathematical
foundations. This makes it easy to understand why providing an "unfaithful" conformance to these
protocols are going to lead you to code with subtle bugs, or even code that will crash at runtime.

[eq-hash-collection]: https://www.pointfree.co/collections/back-to-basics/equatable-and-hashable

## [SQLite][sqlite-collection]

[sqlite-collection]: https://www.pointfree.co/collections/back-to-basics/sqlite

## [Tour of Sharing][sharing-tour-collection]

[sharing-tour-collection]: https://www.pointfree.co/collections/tours/tour-of-swift-sharing

# See you in 2025! 🥳

TODO
