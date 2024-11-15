We do this only a few times a year: we‘re having a 
[rare, Point-Free sale](/discounts/black-friday-2024)
this Black Friday by offering 30% off the first year of your subscription!

@Button(/discounts/black-friday-2024) {
  Subscribe today!
}

Once subscribed you'll get instant access to all [304 episodes][pf] (190 hours of video and
growing!) of original Point-Free content. This includes popular [collections][collections] that were
created or expanded this year, as well as all of the material we have planned for 2025!

We offer some of the most advanced and original Swift content that will help bring your expertise
of the Swift language to the next level. Here are just a few of our additions from this year:

<!--
SQLite
Back to basics: Equatable and Hashable
Cross-Platform Swift
Modern UIKit
Shared State
-->

## [Back to Basics: Equatable & Hashable][eq-hash-collection]

This year we began a new type of episode arc on Point-Free called "Back to Basics". In these 
episodes we will break down a foundational concept in Swift into its simplest components so that
we can achieve an expertise understanding of the topic. We began with a seemingly simple subject:
the [`Equatable` and `Hashable`][eq-hash-collection] protocols in Swift.

However, looks can be deceiving. These protocols are not like most other protocols in the language.
They have a very formal, mathematical specification, and if your implementation runs afoul of its
semantics you will be in for a world of hurt. Reasonable looking code will have very unreasonable
behavior.

[eq-hash-collection]: /collections/back-to-basics/equatable-and-hashable
[back-to-basics]: /collections/back-to-basics

## [SQLite][sqlite-collection]

At the end of the year we turned our attention to advanced topics in data persistence, starting
with an [introduction to SQLite][sqlite-collection]. Thanks to Swift's wonderful interoperability 
with C, we get immediate access to everything SQLite has to offer. Our series serves as a crash
course in calling C libraries from Swift, including dealing with pointers, as well as the basics
of what SQLite has to offer.

After covering the basics of the SQLite C library we move onto a more modern way of dealing with 
SQLite in Swift projects by exploring the [GRDB](http://github.com/groue/GRDB.swift) library
by [Gwendal Roué](http://github.com/groue). This library provides a modern Swift interface over
the SQLite C library, and gives one easy and safe access to some of SQLite's most advanced
functionality.

[sqlite-collection]: /collections/back-to-basics/sqlite

## [Cross-Platform Swift][cross-platform-collection]

Our personal favorite series from the year, we explored what Swift looks like on [platforms other
than Apple's][cross-platform-collection]. The primary platform we explore is WebAssembly (Wasm) 
where we show how to build a Swift application that runs in a web browser. The application involves 
complex side effects (timers and network requests) as well as navigation (alerts and modals), and 
it's built in 100% pure, cross-platform Swift. This means that with a little bit of extra work the 
application could be further ported to Windows, Linux, and beyond!

And while this series may seem like it is merely about writing code that runs in a browser, the
true impetus of this series is to explore advance domain modeling techniques. By writing the logic
and behavior of your features in a way that is quarantined from view-related concerns we instantly
unlock the ability to run that features in a variety of mediums. It doesn't take much work to do,
but the payoffs are huge.  

[cross-platform-collection]: /collections/cross-platform-swift 

## [Modern UIKit][uikit-collection]

Most people didn't expect us to dedicate a series of episodes on ["Modern UIKit"][uikit-collection]
in the year 2024, but that's exactly what we did. SwiftUI may be all the rage these days, but that 
doesn't mean you won't occassionally need to dip your toes into the UIKit waters. Whether it be to 
access some functionality not yet available in SwiftUI, or for performance reasons 
(`UICollectionView` 😍), you will eventually find yourself subclassing `UIViewController`, and then
the question becomes: what is the most modern way to do this?

Our "Modern UIKit" covers a variety of topics to help you modernize your usage of UIKit and get
the most out of the framework. This includes how to use Swift's powerful Obervation framework with
UIKit (including the `@Observable` macro), state-driven navigation that looks similar to SwiftUI
(including stack-based navigation), and bindings for UI controls. By the end of this series we
can write UIKit applications in a style that looks quite similar to SwiftUI and removes a lot of
the pain when dealing with UIKit.

[uikit-collection]: /collections/uikit

## [Shared State in the Composable Architecture][sharing-collection]

This year we added a powerful tool that our viewers were clamoring for, and that is sharing state
amongst features in a [Composable Architecture][tca-gh] application. Sharing state in Composable
Architecture applications can be tricky because the library prefers one to model domains with
value types rather than reference types. The benefits of doing so are huge (no spooky actions at a
distance, easy testing, …), but it does complicate sharing state since value types are copied when 
passed around.

So, we built a tool called [`@Shared`][sharing-docs] that allows one to still embrace value types 
while getting many of the benefits of reference types. And even better, we further built the notion
of persistence into `@Shared` so that you can also immediately persist your state in user defaults,
the file system, or any storage system of your choice.  

[sharing-collection]: /collections/composable-architecture/sharing-and-persisting-state
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sharing-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate

## Subscribe today!

This only scratches the surface of what we covered in 2024, and we have plenty of exciting topics 
planned for 2025, TODO 

<!--including bringing `@Observable` to the Composable Architecture, a new fundamental -->
<!--change to the Composable Architecture that will unlock capabilities currently impossible, and -->
<!--perhaps we will even start to explore some server-side Swift. 😀-->

Be sure to [subscribe today][black-friday-sale] to get access to all of this and more. The
offer is valid for only a few days, so you better hurry!

[observation-collection]: /collections/swiftui/observation
[tca-1.0-blog]: /blog/posts/112-composable-architecture-1-0
[tca-1.0-collection]: /collections/composable-architecture/composable-architecture-1-0
[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras
[reliable-testing-blog]: https://www.pointfree.co/blog/posts/110-reliably-testing-async-code-in-swift 
[reliable-testing]: https://www.pointfree.co/collections/concurrency/testing-async-code
[concurrency-collection]: https://www.pointfree.co/collections/concurrency
[realiable-testing-forums]: https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text
[syncups]: http://github.com/pointfreeco/syncups 
[modern-swiftui]: https://www.pointfree.co/collections/swiftui/modern-swiftui
[observation-in-practice]: https://www.pointfree.co/collections/swiftui/observation/ep256-observation-in-practice
[pf]: /
[black-friday-sale]: http://pointfree.co/discounts/black-friday-2024
[collections]: /collections

@Button(/discounts/black-friday-2024) {
  Subscribe today!
}
