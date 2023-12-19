It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we 
produced for 2023, so join us for a quick review of some of our favorite highlights.

We are also offering [25% off 🎁][eoy-discount] the first year for first-time subscribers. If you’ve 
been on the fence on whether or not to subscribe, now is the time!

[eoy-discount]: /discounts/2023-eoy

[[Subscribe today!]](/discounts/2023-eoy)

## Highlights

2023 was our biggest year yet:

* **200k** unique visitors to the site.
* **45** episodes released for a total of **34** hours of video, and **27** blog posts
published.
* Over **180k** video views, **6 years** watching time, and over **67 terabytes** of video
streamed.
* **4** new projects open sourced and dozens of updates to our other libraries.

But these high-level stats don’t even scratch the surface of what we covered in 2023:

* [Episodes](#)
  * [Modern SwiftUI](#)
  * [First ever live stream](#)
  * [Composable Architecture navigation](#)
  * [Reliably testing async](#)
  * [Tour of the Composable Architecture 1.0](#)
  * [Testing & Debugging Macros](#)
  * [Deep dive into Swift's observation tools](#)
  * [Case paths revolution](#)
  * [Observable Architecture](#)
* [Open source](#)
  * [Dependencies](#)
  * [Concurrency extras](#)
  * [Inline snapshot testing](#)
  * [Swift macro testing](#)
  * [Observable architecture beta](#)
* [Blog posts](#)
  * [Modern SwiftUI](#)
  * [Being a good citizen in the land of Swift Syntax](#)
  * [Macro bonanza](#)
* [Point-Free community](#)
* [See you in 2024! 🥳](#)

## Episodes

This year's episodes were action-packed, to say the least. We made use of many new, advanced
features of Swift 5.8 and 5.9, including concurrency tools, executors, observation, macros (and 
more…) in order to push the Swift language and SwiftUI to the limit of what they can accomplish: 

<div id="modern-swiftui"></div>

### [Modern SwiftUI][modern-swiftui-collection]

We began the year with a [7-part series][modern-swiftui-collection] discussing modern SwiftUI 
techniques. This includes proper domain modeling for navigation, properly handling side effects,
controlling dependencies, and writing extensive tests for features, including how multiple features
integrate together. 

We demonstrated these principles by rebuilding one of Apple's more interesting demo apps,
[Scrumdinger][scrumdinger]. We recreated the entire app from scratch, but using modern techniques
each step of the way. If you put in a little bit of upfront work while building your applications 
you get a ton of benefits down the road, such as easy deep-linking, simple communication patterns
between features, a [unified API for navigation][gut-syncups]:

[gut-syncups]: https://github.com/pointfreeco/syncups/blob/a9a60da0b7f163acaeef863b5e5aa70831466400/SyncUps-TreeBased/SyncUps/SyncUpDetail.swift#L238-L247

```swift
.navigationDestination(item: self.$model.destination.meeting) { meeting in
  MeetingView(meeting: meeting, syncUp: self.model.syncUp)
}
.navigationDestination(item: self.$model.destination.record) { recordModel in
  RecordMeetingView(model: recordModel)
}
.sheet(item: self.$model.destination.edit) { editModel in
  SyncUpFormView(model: editModel)
}
.alert(self.$model.destination.alert) { action in
  await self.model.alertButtonTapped(action)
}
```

…and a lot more.

At the end of the series we even [open-sourced][syncups-gh] the app, built in two different styles:
one using what we call ["tree-based" navigation][tree-based-syncups] (_i.e._ when navigation is
driven by optional state) and the other using ["stack-based" navigation][stack-based-syncups] 
(_i.e._ when navigation is driven by a collection).

<div id="call-to-action"></div>

We even made a [call-to-action][syncups-cta] to the community to rebuild the app in the style that
they enjoy the most. Architecture debates in the community tend to be a lot of abstract platitudes
and hand waving, but there's no better way to show off your ideas that to build it concretely and
share with the world.

[modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[modern-swiftui-blog]: https://www.pointfree.co/blog/posts/99-modern-swiftui
[syncups-gh]: https://github.com/pointfreeco/syncups
[syncups-cta]: https://github.com/pointfreeco/syncups#call-to-action

### [First ever live stream][live-stream]

This year we also had our first ever [live stream][live-stream] where we discussed our newly
released [dependencies library][dependencies-gh], and we live-refactored how navigation was 
modeled in the SyncUps application we built for our [Modern SwiftUI][modern-swiftui-collection] 
series.

In that series we modeled the navigation of the app in what we like to call the ["tree-based" 
style][tree-based-syncups]. This is where each feature models the places it can navigate to with a 
single piece of optional enum state, where each case of the enum is a possible destination. The 
nesting of those enums form a tree-like structure.

This style is different from what we like to call ["stack-based" navigation][stack-based-syncups], 
where drill-down navigation is modeled as a single flat array of destinations. Each style has their 
[pros and cons][what-is-nav],  but we still wanted to show how it would look to build the app with 
stack-based navigation, so we did it [live][nav-live-stream]!

[tree-based-syncups]: https://github.com/pointfreeco/syncups/tree/a9a60da0b7f163acaeef863b5e5aa70831466400/SyncUps-TreeBased#syncups-tree-based-navigation
[stack-based-syncups]: https://github.com/pointfreeco/syncups/tree/a9a60da0b7f163acaeef863b5e5aa70831466400/SyncUps-StackBased#syncups-stack-based-navigation
[live-stream]: https://www.pointfree.co/episodes/ep221-point-free-live-dependencies-stacks
[nav-live-stream]: https://www.pointfree.co/episodes/ep221-point-free-live-dependencies-stacks

### [Composable Architecture navigation][tca-nav-collection]

Early in the year we embarked on a [very long series][tca-nav-collection] of episodes to build
first class navigation tools into the Composable Architecture. We didn't plan on it being that long
from the outset, but we kept finding new interesting tools that we wanted to discuss.

By the end of the series we built everything necessary to model your domains concisely for 
navigation. We also talked at length about the two major styles of navigation, 
[tree-based][tree-based-nav-docs] versus [stack-based][stack-based-nav-docs], as well as their
pros and cons.

For a comprehensive overview of this topic be sure to check out the [documentation][tca-nav-docs] 
in the library, and if you want to know how to apply these techniques to a vanilla SwiftUI app,
be sure to checkout our [SwiftUINavigation][swiftui-nav-gh] library.

[swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[tca-nav-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/navigation
[tree-based-nav-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation
[stack-based-nav-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation
[what-is-nav]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/whatisnavigation
[tca-nav-collection]: https://www.pointfree.co/collections/composable-architecture/navigation

### [Reliably testing async][testing-async-code-collection]

In 2022 we posted a seemingly innocent question about [how to reliably test async code in 
Swift][reliably-testing-async-forums]. Well, 1.5 years later, 126 replies and 20k views later… there
still is no official word from Apple on how to accomplish this.  

Even something as straightforward as this:

```swift
func buttonTapped() async throws {
  self.isLoading = true 
  defer { self.isLoading = false }
  
  self.data = nil
  self.data = try await self.apiClient.fetch()
}
```

…is not easy to test. There just are no tools that allow us to deterministically assert on what 
happens in between units of async work. We have to sprinkle in some `Task.yield`s in our tests and 
hope that it’s enough, but we'll never know for sure.

So, this year we took matters into our own hands by releasing a 
[5-part series][testing-async-code-collection] exploring how one can embrace the amazing concurrency 
tools of Swift while not sacrificing testability. We start with two free(!) episodes 
([here][testing-async-the-problem-1] and [here][testing-async-the-problem-2]) exploring the problem 
space and seeing why it is essentially impossible to deterministically test any moderately complex 
Swift code that uses `await`. And by the end of the series we built a tool that allows one to test
async code in a style that is more familiar to testing synchronous and Combine/reactive code. And we 
[released a library][concurrency-extras-gh] to give everyone access to this tool.

Be sure to also check out our full [concurrency collection][concurrency-collection] of episodes that
discusses topics that haven't gotten much attention in the community, such as a full past-to-future
deep dive into concurrency, as well as clocks and time-based asynchrony.

[testing-async-the-problem-1]: https://www.pointfree.co/collections/concurrency/testing-async-code/ep238-reliable-async-tests-the-problem
[testing-async-the-problem-2]: https://www.pointfree.co/collections/concurrency/testing-async-code/ep239-reliable-async-tests-more-problems
[reliably-testing-async-forums]: https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
[testing-async-code-collection]: https://www.pointfree.co/collections/concurrency/testing-async-code
[concurrency-collection]: https://www.pointfree.co/collections/concurrency

### [Tour of the Composable Architecture 1.0][tca-1.0-collection]

It's hard to believe, but it was only this year that we finally released 1.0 of our popular library,
the [Composable Architecture][tca-gh]. To celebrate we released a brand new
[tour of the library][tca-1.0-collection] where we rebuilt Apple's demo application,
[Scrumdinger][scrumdinger], using the Composable Architecture. (Incidentally we also rebuilt this
app without the Composable Architecture, and using only
[modern, vanilla SwiftUI techniques](#modern-swiftui).)

Along the way we uncovered many benefits to using the Composable Architecture over vanilla SwiftUI,
such as:

  * The ability to use value types for our domain rather than being forced to use reference types
    and incur the complexity that comes with them.
  * Easy integration of features together so that they can easily communicate with each other. 
  * Immediate ability to deep-link into any state of our application.
  * Instant testability, including how features integrate together and exhaustively proving how
    state involves in the app and how effects feed data back into the system.

…and a whole bunch more.

[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[tca-1.0-collection]: https://www.pointfree.co/collections/composable-architecture/composable-architecture-1-0

### [Testing & Debugging Macros][testing-debugging-macros-1]

Macros were by far the biggest new feature in Swift 5.9, and we devoted two full episodes 
([here][testing-debugging-macros-1] and [here][testing-debugging-macros-2]) to understanding
how to debug and test them.

The biggest complication to writing macros in Swift is becoming familiar with SwiftSyntax. We
show off some techniques for exploring the syntax tree of your Swift code, including using 
breakpoints while running your macro in tests, and copious amounts of lldb printing. 😆

The second biggest complication to writing macros in Swift is dealing with all of the edge cases
that come up in everyday, real Swift code. For example, did you know that enum cases can all be
listed on the same line if desired:

```swift
struct Destination {
  case add(ItemFormModel), detail(ItemDetailModel), delete(AlertState)
}
```

And the syntax tree for this is different than if the cases are all on their own line. So if you 
have a macro dealing with enums you better deal with this situation.

Also if your macro deals with closures in some manner, then you also better make sure to deal with
the wide variety of closure annotations, such as `@Sendable`, `@escaping`, `@autoclosure`, and more.

And this is why it can be very important to write tests for your macros, and write as many as 
possible to cover each strange nuance and edge case. But the default testing tool that comes with
SwiftSyntax is a little cumbersome, and so we built a testing tool that makes it very easy to 
assert how your macro expands, as well as how it's diagnostics and fix-its are emitted.

[testing-debugging-macros-1]: https://www.pointfree.co/episodes/ep251-testing-debugging-macros-part-2
[testing-debugging-macros-2]: https://www.pointfree.co/episodes/ep250-testing-debugging-macros-part-1

### [Deep dive into Swift's observation tools][observation-collection]

We released a [collection][observation-collection] of episodes that dive deep into Swift 5.9's 
observation tools, including the new `@Observable` macro and the `withObservationTracking` function. 
While it's clear that the tools are built primarily with SwiftUI in mind, they are still quite 
powerful.

We broke the series up into 5 major parts:

  * We begin with a look at the tools of the past, including the `@State` and `@ObservedObject` 
    property wrappers that were in SwiftUI since it's first release. They were handy, but they also 
    came with some gotchas, and forced you to write your features in an unnatural style.
  * Next we move onto the new observation tools in Swift 5.9, and show how they improve upon every
    aspect of the `@State` and `@ObservedObject` property wrappers. We even dive into some of the
    code in the open source Swift repository.
  * Then we show that although the new tools are amazing, even ✨magical✨, they do come with some
    gotchas. It is very important to be familiar with these subtleties in order to best wield these
    tools.
  * Next we show off a very theoretical _future_ direction of observation in Swift, and that is 
    "observable structs." Now unfortunately Swift's observation tools do not work with structs, and
    for good reason. But that doesn't mean we can't try!
  * And finally we demonstrate "observation in practice" by taking the application we built during 
    our [Modern SwiftUI][modern-swiftui-collection] series and refactoring it to use the new 
    `@Observable` macro.

[observation-collection]: https://www.pointfree.co/collections/swiftui/observation

### Case paths revolution

Key paths are an amazing feature of Swift. They allow you to abstractly isolate a particular field
from the whole of a struct, and they unlock a lot of amazing capabilities that we all probably take
for granted these days. But to our knowledge, Swift is the _only_ modern programming language 
that has first class support for something like key paths. 

However, there is a crucial part of the story missing from Swift. If key paths are great for 
isolating a property from a struct, what about isolating a _case_ from an enum? Certainly there has
to be many uses for such a concept considering how powerful enums are for concisely modeling 
domains.

This is why we introduced the concept of "case paths" nearly [4 years ago][case-paths-first-ep]. 
Since then they have found use cases in many places, such as in the Composable Architecture, our
[parsing library][parsing-gh], vanilla [SwiftUI navigation][swiftui-nav-gh], and more.

However, the ergonomics were never quite right. That all changed with Swift 5.9 was released, which
brought with it macros. They allow us to generate more correct and more performant case paths for
any enum, and we dedicated 2 episodes ([part 1][macro-case-paths-1] and 
[part 2][macro-case-paths-2]) to exploring how.

[swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[parsing-gh]: http://github.com/pointfreeco/swift-parsing
[case-paths-first-ep]: https://www.pointfree.co/episodes/ep87-the-case-for-case-paths-introduction
[macro-case-paths-1]: https://www.pointfree.co/episodes/ep258-macro-case-paths-part-2
[macro-case-paths-2]: https://www.pointfree.co/episodes/ep257-macro-case-paths-part-1

### [Observable Architecture][obs-arch-collection]

We finished the year with a bang! 💥

We started a brand new series on [Observable Architecture][obs-arch-collection], which aims to
bring Swift 5.9's observation tools to the Composable Architecture, and we [released a public 
beta][obs-arch-beta-blog] of the tools so that people can test them out today while we polish them
for the final release.

The observation tools of Swift 5.9 are going to completely revolutionize the library. We are able
to remove many superfluous concepts that were necessary pre-observation, such as `ViewStore`, 
`WithViewStore`, `IfLetStore`, `ForEachStore`, `SwitchStore`, binding helpers, navigation
view modifiers, and even more! It allows us to write our features in a style that looks closer
to vanilla SwiftUI, while still getting all of the benefits from the library, such as getting
to use value types for our domains, concise domain modeling tools, easy testing, and more.

[obs-arch-beta-blog]: https://www.pointfree.co/blog/posts/125-observable-architecture-beta
[obs-arch-collection]: https://www.pointfree.co/collections/composable-architecture/observable-architecture

## Open source

On average, our [open source libraries][pf-gh] are cloned over **120,000 times** per day! They are
used by thousands of developers and companies all across the globe. It's a lot of work to main them,
but it's all made possible thanks to our wonderful [subscribers][eoy-discount].

<!--
38000+175000+48000+12000+52000+620000+18000+56000+85000+58000+112000
-->

[eoy-discount]: /discounts/2023-eoy

This year we released 4 new open source libraries, two of which were incubated in the
[Composable Architecture][tca-gh] and later split out, as well as dozens of updates to our
existing libraries:

[pf-gh]: http://github.com/pointfreeco

### [Dependencies][dependencies-gh]

In October of last year we released a [large update][reducer-protocol-blog] to the Composable 
Architecture, introducing the `Reducer` protocol to the library. That simple change to the library
unlocked a whole new way to managing, controlling and propagating dependencies. It was extremely
powerful, and we soon realized that we could extract it out to its own library so that it could be
used in vanilla SwiftUI applications too.

And that's [exactly what we did][dependencies-blog] this year. We extracted the dependency 
management tool from the Composable Architecture, and open sourced it as its own standalone library:
[Dependencies][dependencies-gh]. It allows you to add dependencies to an observable object much like
you would with the environment in SwiftUI views.

The library even comes with a few dependencies you can use right away:

```swift
@Observable
final class FeatureModel {
  @Dependency(\.continuousClock) var clock  // Controllable way to sleep a task
  @Dependency(\.date.now) var now           // Controllable way to ask for current date
  @Dependency(\.mainQueue) var mainQueue    // Controllable scheduling on main queue
  @Dependency(\.uuid) var uuid              // Controllable UUID creation

  …
}
```

Then, in your feature's logic you will use these dependencies rather than reaching out to their 
"live", uncontrollable versions:

```swift
@Observable
final class FeatureModel {
  …

  func addButtonTapped() async throws {
    try await self.clock.sleep(for: .seconds(1))  // 👈 Don't use 'Task.sleep'
    self.items.append(
      Item(
        id: self.uuid(),  // 👈 Don't use 'UUID()'
        name: "",
        createdAt: self.now  // 👈 Don't use 'Date()'
      )
    )
  }
}
```

And in tests you can override the dependencies so that that return something that you 
control rather than be at the mercy of the vagaries of the outside world. It's as easy as 1️⃣, 2️⃣,
3️⃣: 

```swift
func testAdd() async throws {
  let model = withDependencies {
    // 1️⃣ Override any dependencies that your feature uses.
    $0.clock = ImmediateClock()
    $0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
    $0.uuid = .incrementing
  } operation: {
    // 2️⃣ Construct the feature's model
    FeatureModel()
  }

  // 3️⃣ The model now executes in a controlled environment of dependencies,
  //    and so we can make assertions against its behavior.
  try await model.addButtonTapped()
  XCTAssertEqual(
    model.items,
    [
      Item(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        name: "",
        createdAt: Date(timeIntervalSinceReferenceDate: 1234567890)
      )
    ]
  )
}
```

[reducer-protocol-blog]: https://www.pointfree.co/blog/posts/81-announcing-the-reducer-protocol
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
[dependencies-blog]: https://www.pointfree.co/blog/posts/92-a-new-library-to-control-dependencies-and-avoid-letting-them-control-you

### [Concurrency extras][concurrency-extras-gh]

After finishing our series of episodes on [testing async code][testing-async-code-collection], we
[open sourced][concurrency-extras-gh] the tool we built during that series, as well as a few other 
tools.

The most improtant tool provided is [`withMainSerialExecutor`][withMainSerialExecutor-docs]. It 
serializes all async work in a scope so that you can predict how your feature will behave in tests: 

```swift
func testFeature() async {
  await withMainSerialExecutor {
    …
  }
}
```

This makes it possible to write tests for features using async that pass deterministically 100%
of the time.

[withMainSerialExecutor-docs]: https://pointfreeco.github.io/swift-concurrency-extras/main/documentation/concurrencyextras/withmainserialexecutor(operation:)-79jpc
[concurrency-extras-blog]: https://www.pointfree.co/blog/posts/109-announcing-concurrency-extras-useful-testable-swift-concurrency
[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras

### [Inline snapshot testing][inline-snapshot-testing-blog]

We released our popular [snapshot testing][snapshot-testing-gh] library over 5 years ago, but this
year we added a huge new feature: [inline snapshot testing][inline-snapshot-testing-blog]. It
allows you to record the textual snapshot of your types directly into the test file.

[snapshot-testing-gh]: https://github.com/pointfreeco/swift-snapshot-testing
[inline-snapshot-testing-blog]: https://www.pointfree.co/blog/posts/113-inline-snapshot-testing

For example, if you wanted to test the JSON encoding of a `user` value, you could do it like so: 

```swift
func testUserJSON() {
  assertInlineSnapshot(of: user, as: .json)
}
```

Upon running this test a snapshot of the `user` value will be made as JSON and automatically 
recorded directly into the test file:

```swift
func testUserJSON() {
  assertInlineSnapshot(of: user, as: .json)  {
    """
    {
      "id" : 42,
      "isAdmin": true,
      "name" : "Blob"
    }
    """
  }
}
```

It feels almost magical, but unfortunately static text in a blog post does not do it justice. This
is what it looks like when you run the test in Xcode:

![fullWidth](https://pointfreeco-blog.s3.amazonaws.com/posts/0113-inline-snapshot-testing/inline-snapshot.gif)

It's an extremely powerful testing tool, and it's even extensible so that you can build you own
testing tools on top of it. And in fact, that's exactly what we did for 
[testing macros](#Swift-macro-testing) in Swift. 👇

[snapshot-testing-gh]: https://github.com/pointfreeco/swift-snapshot-testing
[inline-snapshot-testing-blog]: https://www.pointfree.co/blog/posts/113-inline-snapshot-testing

<div id="Swift-macro-testing"></div>

### [Swift macro testing][swift-macro-testing-blog-1]

One of the major new features of Swift 5.9 is macros. They are compiler plugins that can generate
code to be inserted into your code during the compilation process. It's an incredibly powerful tool
for removing boilerplate from your code and unlocking new techniques that would have previously
been too cumbersome.

Apple even ships a tool for testing macros, called `assertMacroExpansion`, but it can be cumbersome
to use. So we open sourced a new library, [MacroTesting][swift-macro-testing], that utilizes our
inline snapshot testing library to make testing macros super easy.

You can use the `assertMacro` function to provide a string of Swift code that makes use of a 
macro:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
}
```

When this test runs the expanded macro code will be automatically inserted into the test file. And
further, if the macro emits any diagnostics and/or fix-its, those too will be expanded and inserted
into the test file:

```swift
assertMacro {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
    return b
  }
  """
} diagnostics: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) -> String {
  ┬───
  ╰─ 🛑 can only add a completion-handler variant to an 'async' function
     ✏️ add 'async'
    return b
  }
  """
} fixes: {
  """
  @AddCompletionHandler
  func f(a: Int, for b: String) async -> String {
    return b
  }
  """
} expansion: {
  """
  func f(a: Int, for b: String) async -> String {
    return b
  }

  func f(a: Int, for b: String, completionHandler: @escaping (String) -> Void) {
    Task {
      completionHandler(await f(a: a, for: b, value))
    }
  }
  """
}
```

This makes it incredibly easy to test macros, which is important because macros can be very 
difficult to implement correctly. You have to deal with many of the edge cases of Swift syntax, 
and so it's a good idea to get as many tests as possible on the various subtle edge cases of the 
macro.

[swift-macro-testing]: https://github.com/pointfreeco/swift-macro-testing
[swift-macro-testing-blog-1]: https://www.pointfree.co/blog/posts/114-a-new-tool-for-testing-macros-in-swift
[swift-macro-testing-blog-2]: https://www.pointfree.co/blog/posts/115-macrotesting-0-2-0-test-more-with-less

### [Observable architecture beta][obs-arch-beta-blog]

In unison with the beginning of our new [Observable Architecture][obs-arch-collection] series (and
coincidentally the same day the library hit 10,000 stars on GitHub) we launched a [public 
beta][obs-arch-beta-blog] of the new observation tools. One can simply point their existing
Composable Architecture project to the observation-beta branch and start using the new tools.

[obs-arch-collection]: https://www.pointfree.co/collections/composable-architecture/observable-architecture

We like to have these public beta periods because it allows people to give the new tools for a spin
and find any problems with them or backwards compatibility problems when upgrading. The community
has also been great in helping fix problems. We already have 6 outside contributors to the 
[observation-beta PR][observation-beta-pr], and there are still a few weeks left of the beta period.

We will release the final version of the tools sometime in January, and at that time it will be
the biggest revolution to the library since its release 3 years ago. Even better, it will be a 
fully backwards compatibile release, so people will be able to upgrade immediately. _And_ the 
tools include a backport of Swift 5.9's obesrvation machinery so that you can use the new tools
even if you are targeting an older version of iOS, going all the way back to iOS 13! 

[observation-beta-pr]: https://github.com/pointfreeco/swift-composable-architecture/pull/2593
[obs-arch-beta-blog]: https://www.pointfree.co/blog/posts/125-observable-architecture-beta

## Blog posts

This year we published 27 blog posts, most of which cover things already discussed above, but 
there were 3 specific posts we wanted to call out.

### [Modern SwiftUI][modern-swiftui-blog-summary]

When we finished our [Modern SwiftUI][modern-swiftui-collection] series of episodes we released
a [blog-post-a-day][modern-swiftui-blog-summary] for an entire week to highlight some of the 
techniques that we think go into building a modern SwiftUI application. We focused on:

[modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui

* [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
* [Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)
* [Modern SwiftUI: State-driven
navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)
* [Modern SwiftUI: Dependencies](/blog/posts/97-modern-swiftui-dependencies)
* [Modern SwiftUI: Testing](/blog/posts/98-modern-swiftui-testing)

Be sure to check out the blog series if you do have time to watch all of the videos.

[modern-swiftui-blog-summary]: https://www.pointfree.co/blog/posts/99-modern-swiftui

### [Being a good citizen in the land of Swift Syntax][swift-syntax-citizen]

When Swift macros were officially released we jumped into the head first. But we quickly noticed a
few big issues with doing so, primarily due to [using SwiftSyntax][swift-syntax-concerns-forums].

After much research and experimentation we came up with a few guiding principles that could be 
followed to mitigate the problems of using SwiftSyntax in your project. We wrote up our findings
to help everyone be a better citizen in the land of Swift Syntax.

[swift-syntax-citizen]: https://www.pointfree.co/blog/posts/116-being-a-good-citizen-in-the-land-of-swiftsyntax
[swift-syntax-concerns-forums]: https://forums.swift.org/t/macro-adoption-concerns-around-swiftsyntax/66588

### [Macro bonanza][macro-bonanza]

When macros were released in Swift 5.9 we kinda went bonanza with them. We released big updates to
4 of our libraries to bring all new capabilities with macros, and we released a brand new library
to make testing macros easier. We catalogued these big releases in our [Macro Bonanza blog 
post][macro-bonanza]:

* We revolutionized our CasePaths library with the new `@CasePathable` macro.
* We heavily integrated the new case path capabilities into the Composable Architecture, along 
with a new `@Reducer` macro.
* We made navigation in vanilla SwiftUI even easier in our SwiftUINavigation library.
* We introduced a `@DependencyClient` macro that makes it very easy to design dependencies in a way
that is flexible and ergonomic.
* And finally we released a new library, [Macro Testing][swift-macro-testing], for testing macros,
including their diagnostics and fix-its.

[macro-bonanza]: https://www.pointfree.co/blog/posts/121-macro-bonanza

## Point-Free community

This year we launched our first big community initiative: the [Point-Free Slack][pf-slack]. In
the 10 months since then over **2,000 people** have joined and over **42k messages** have been sent.
It has become an incredible supportive place to get questions answered about any of our open source
libraries, and we are thankful to all the community members that spend their time helping out.

[Join today][pf-slack] to learn more about our libraries or to help out someone out!

[pf-slack]: http://pointfree.co/slack-invite

## See you in 2024! 🥳

We're thankful to all of our subscribers for [supporting us](/pricing) and helping us create our 
episodes and support our open source libraries. We could not do it without you!

Next year we have even more planned, including the final release of the observation tools in the
Composable Architecture, more advanced content on how to best leverage the library (including
new techniques for modeling shared state), a deep dive into value types versus reference types, 
and more that we are not yet ready to reveal. 😉

To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year
for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now
is the time!

[eoy-discount]: /discounts/2023-eoy

[[Subscribe today!]](/discounts/2023-eoy)
