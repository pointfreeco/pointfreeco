import Foundation

public let post0064_AppleEvent = BlogPost(
  author: .pointfree,
  blurb: """
We're celebrating the release of Xcode 13 by making all of our WWDC 2021 videos free! Explore SwiftUI's new `.refreshable` and `@FocusState` APIs, both in the context of vanilla SwiftUI and the Composable Architecture, and learn how to build a map-powered application from scratch using the new `.searchable` API.
""",
  contentBlocks: [
  .init(
    content: #"""
We're celebrating the release of Xcode 13 by making all of our [WWDC 2021](/collections/wwdc) videos free! Explore SwiftUI's new `.refreshable` and `@FocusState` features, both in the context of vanilla SwiftUI and the Composable Architecture, and learn how to build a map-powered application from scratch using the new `.searchable` API:

* [Async Refreshable: SwiftUI](/collections/wwdc/wwdc-2021/ep153-async-refreshable-swiftui)
* [Async Refreshable: Composable Architecture](/collections/wwdc/wwdc-2021/ep154-async-refreshable-composable-architecture)
* [SwiftUI Focus State](/collections/wwdc/wwdc-2021/ep155-swiftui-focus-state)
* [Searchable SwiftUI: Part 1](/collections/wwdc/wwdc-2021/ep156-searchable-swiftui-part-1)
* [Searchable SwiftUI: Part 2](/collections/wwdc/wwdc-2021/ep157-searchable-swiftui-part-2)

## .refreshable

iOS 15's new `.refreshable` API is a great example of how the conciseness of SwiftUI's declarative syntax and Swift's new concurrency tools can pack a huge punch in a small package. We [begin]((/collections/wwdc/wwdc-2021/ep153-async-refreshable-swiftui)) by exploring how the API works in a vanilla SwiftUI application, including how to cancel in-flight asynchronous work.

[Then](/collections/wwdc/wwdc-2021/ep153-async-refreshable-swiftui) we show how the API works in the Composable Architecture. At first it's not clear how to use `.refreshable` with the Composable Architecture because the library did not immediately have support for any of Swift's new concurrency tools. Luckily the library is extensible enough that we were able to add support for `.refreshable` without a single change to the internals of the library.

Watch [part 1](/collections/wwdc/wwdc-2021/ep153-async-refreshable-swiftui) and [part 2](/collections/wwdc/wwdc-2021/ep154-async-refreshable-composable-architecture) to learn more.

## @FocusState

iOS 15 introduced a declarative API for changing and observing focus in SwiftUI applications. By adding some `@FocusState` to your view and making use of a simple view modifier you can instantly control the focus of UI controls on screen.

However, as soon as you need complex logic to control the focus of your feature, the simplicity starts to break down. Ideally we could model focus state in observable objects, so that we update focus after asynchronous work and write tests, but sadly that is not possible:

```swift
class LoginViewModel: ObservableObject {
  @FocusState var field: Field // 🛑 Does not work outside of View

  enum Field { case email, password }
}
```

So, in the [episode](/collections/wwdc/wwdc-2021/ep155-swiftui-focus-state) we develop techniques that allow us to model focus state in our view models and synchronize that state with the focus state held in views. This allows us to craft nuanced logic to guide how focus changes and we can even write tests.

We also discover that the techniques developed for making vanilla SwiftUI focus state more understandable and testable fit in perfectly with the Composable Architecture. We can model focus state in our domain's state struct, and then use our new [binding helpers](/blog/posts/63-the-composable-architecture-%EF%B8%8F-swiftui-bindings) to replay changes back and forth between the store and view.

Watch the [episode](/collections/wwdc/wwdc-2021/ep155-swiftui-focus-state) to learn more.

## .searchable

Last, but not least, the `.searchable` API in iOS 15 makes it super easy to introduce a searching interface on top of any view. It even supports quick access suggestion results that can be displayed on top of the view while searching.

We took two episodes ([part 1](/collections/wwdc/wwdc-2021/ep156-searchable-swiftui-part-1) and [part 2](/collections/wwdc/wwdc-2021/ep157-searchable-swiftui-part-2)) to explore this API, and in the process built a map searching application from scratch. We used Apple's [`MKLocalSearchCompleter`](https://developer.apple.com/documentation/mapkit/mklocalsearchcompleter) to load search suggestions as the user types, and [`MKLocalSearch`](https://developer.apple.com/documentation/mapkit/mklocalsearch) to search the map for points-of-interest. Along the way we cooked up some tools to help bridge Swift concurrency with the Composable Architecture, and even wrote a full test suite that proves how the application interacts with its complex dependencies.

Watch [part 1](/collections/wwdc/wwdc-2021/ep156-searchable-swiftui-part-1) and [part 2](/collections/wwdc/wwdc-2021/ep157-searchable-swiftui-part-2) to learn more.

## Check it out today

Jump-start your explorations into some of iOS 15's most exciting new APIs by watching our deep dives!

* [Async Refreshable: SwiftUI](/collections/wwdc/wwdc-2021/ep153-async-refreshable-swiftui)
* [Async Refreshable: Composable Architecture](/collections/wwdc/wwdc-2021/ep154-async-refreshable-composable-architecture)
* [SwiftUI Focus State](/collections/wwdc/wwdc-2021/ep155-swiftui-focus-state)
* [Searchable SwiftUI: Part 1](/collections/wwdc/wwdc-2021/ep156-searchable-swiftui-part-1)
* [Searchable SwiftUI: Part 2](/collections/wwdc/wwdc-2021/ep157-searchable-swiftui-part-2)

"""#,
    type: .paragraph
  )
  ],
  coverImage: nil,
  id: 64,
  publishedAt: Date(timeIntervalSince1970: 1631682000),
  title: "Point Freebies: Swift Concurrency and More"
)
