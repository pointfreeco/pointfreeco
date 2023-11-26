We do this only a few times a year: we‘re having a 
[rare, Point-Free sale](/discounts/cyber-monday-2023)
through this Cyber Monday by offering 30% off the first year of your subscription!

[[Subscribe today!]](/discounts/cyber-monday-2023)

Once subscribed you'll get instant access to all [259 episodes][pf] (163 hours of video and
growing!) of Point-Free content. This includes popular [collections][collections] that were
created or expanded this year, as well as all of the material we have planned for 2024!

Here are just a few of our additions from this year:

## [Observable Architecture][observable-architecture-collection]

In conjunction with our Cyber Monday sale we are beginning a 
[new series of episodes][observable-arch-first-ep] that brings Swift 5.9's observation tools to the 
Composable Architecture. This revolutionizes nearly every aspect of the library, and allows us to 
remove many superfluous concepts and helpers that are just no longer needed.

And we were able to accomplish all of this without breaking existing apps depending on the 
Composable Architecture. When the final version of the tools are eventually released it will be a
minor release of the library, and so people can adopt the new tools immediately.

But even better, we backported the tools to work on iOS 13 and later. That's right. You can start
using the new observation tools immediately, even if you cannot yet target iOS 17.

Be sure to [check out the full series][observable-architecture-collection] to see how we 
accomplished this, and we are currently [running a beta][obs-arch-beta] of the new observation tools 
while we put the finishing touches to it.  

[obs-arch-beta]: todo
[observable-architecture-collection]: /collections/composable-architecture/observable-architecture
[observable-arch-first-ep]: /episodes/ep259-observable-architecture-sneak-peek

## [Modern SwiftUI][modern-swiftui]

At the beginning of the year we finished our [7-part series][modern-swiftui] on what we feel it 
takes to build a modern SwiftUI application. We took inspiration from one of Apple's own moderately 
complex demos, [Scrumdinger][scrumdinger], and we rebuilt it with a focus on domain modeling for 
navigation, side effects, dependencies and testing. By the end we were able to accomplish things in 
our code base that were not so easy in Apple's, such as deep-linking, more cohesive previews, and 
simple unit testing.

We ended up open-sourcing the application we built, which we call [SyncUps][syncups]. We also 
encouraged others to share how they like to build modern, complex SwiftUI applications by rebuilding
Apple's Scrumdinger in the style of their choice, and sharing with the community.

Our [Modern SwiftUI][modern-swiftui] series ended long before the release of Swift 5.9's Observation
framework, and so we could not use any of those tools during the episodes. But we later had a 
[dedicated episode][observation-in-practice] to refactoring the SyncUps app to use the new 
`@Observable` macro. We found that we could delete a lot of code and simplify a lot of things, 
although we did run into one gnarly gotcha with the Observation framework.

## [Composable Architecture 1.0][tca-1.0-collection]

After more than 3 years of development we [finally released 1.0][tca-1.0-blog] of the Composable 
Architecture. To celebrate we released a [7-part series of episodes][tca-1.0-collection] to 
build a moderately complex app from scratch and show how to best make use of many of the tools
that come with the library.

And the app we built was directly inspired from our [Modern SwiftUI][modern-swiftui] series where
we rebuilt Apple's [Scrumdinger][scrumdinger] application. But this time we rebuilt it with the
Composable Architecture, and saw a number of benefits, including the ability to use value types
for domain modeling instead of reference types, simpler composition and navigation APIs, and
truly powerful and exhaustive testing.

## [Deep dive into @Observable][observation-collection]

Most recently this year we dove _deep_ into the new Observation framework in Swift 5.9 in a 
[4-part series][observation-collection]:

* We showed off the past tools, pre-Observation, and demonstrated that while they got the job done 
  there was a lot to be desired. 
* Then we showed off what the new tools were capable of, and it was quite amazing. You can build 
  your SwiftUI features in a simpler, more naive manner, and everything somehow just magically
  works! We even dipped our toes into the actual open source code in the Observation framework so
  that we could get a better understanding of how everything works.
* However, the Observation tools do have some gotchas, so we dedicated an entire episode to just 
  that so that you can best wield the tools. Otherwise you run the risk of over-observing state or 
  glitchy views.
* And finally we explored a theoretical future of what `@Observable` could look like if it were
  allowed to be applied to structs. There are a lot of reasons to want that, but unfortunately it's
  just not quite possible in Swift today.

## [Reliable Async Testing][reliable-testing]

One of the best new features to be added to Swift in the past few years was concurrency. It makes 
complex asynchronous code short and succinct, it provides all new tools for making concurrent code 
safe, and it unlocks all new patterns that were previously difficult to imagine.

However, testing code involving Swift's new asynchronous tools remained elusive. It seems the moment
you introduce the `async` or `await` keyword to your code you open up Pandora's box of
non-determinism and flakiness in your code that is nearly impossible to test. You are forced to
sprinkle `Task.yield`s or `Task.sleep`s throughout your tests just to push things forward and assert
on how your feature is behaving.

Reliably testing async code was such a problem that we started a 
[discussion][realiable-testing-forums] on the Swift forums to see what could be done about the 
situation…and unfortunately there's not much. At least not much in the way of official tools 
provided by Swift.

But, over the course of [5 episodes][reliable-testing] we broken down why testing async code in 
Swift is so difficult, and provided a solution. We even packaged the tool up into an
[open-source library][concurrency-extras-gh] that can help any code base test their async code
in a fast and non-deterministic manner.

## Subscribe today!

This only scratches the surface of what we covered in 2023, and we have plenty of exciting topics 
planned for 2024, including bringing `@Observable` to the Composable Architecture, a new fundamental 
change to the Composable Architecture that will unlock capabilities currently impossible, and 
perhaps we will even start to explore some server-side Swift. 😀

Be sure to [subscribe today][cyber-monday-sale] to get access to all of this and more. The
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
[cyber-monday-sale]: http://pointfree.co/discounts/cyber-monday-2023
[collections]: /collections

[[Subscribe today!]](http://pointfree.co/discounts/cyber-monday-2023)
