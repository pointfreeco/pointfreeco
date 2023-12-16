It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we 
produced for 2023, so join us for a quick review of some of our favorite highlights.

We are also offering [25% off 🎁][eoy-discount] the first year for first-time subscribers. If you’ve 
been on the fence on whether or not to subscribe, now is the time!

[eoy-discount]: /discounts/2023-eoy

[[Subscribe today!]](/discounts/2023-eoy)

## Highlights

2023 was our biggest year yet:

* **200k** unique visitors to the site.
* **45** episodes released for a total of **31** hours of video, and **27** blog posts
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
more…) in order to push the Swift language and SwiftUI to the limit of what they can accomplish. 

<div id="modern-swiftui"></div>

### Modern SwiftUI

We began the year with a [7-part series][modern-swiftui-collection] discussing modern SwiftUI 
techniques. This includes proper domain modeling for navigation, properly handling side effects,
controlling dependencies, and writing extensive tests for features, including how multiple features
integrate together. 

We demonstrated these principles by rebuilding one of Apple's more interesting demo apps, the
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

And at the end of the series we even [open-sourced][syncups-gh] the app, built in two different 
styles: one using what we call ["tree-based" navigation][tree-based-syncups] (i.e. when navigation 
is driven by optional state) and the other using ["stack-based" navigation][stack-based-syncups] 
(i.e. when navigation is  driven by a collection).

We even made a [call-to-action][syncups-cta] to the community to rebuild the app in the style that
they enjoy the most. Architecture debates in the community tend to be a lot of abstract platitudes
and hand wringing, but there's no better way to show off your ideas that to build it concretely
and share with the world.

[modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[modern-swiftui-blog]: https://www.pointfree.co/blog/posts/99-modern-swiftui
[syncups-gh]: https://github.com/pointfreeco/syncups
[syncups-cta]: https://github.com/pointfreeco/syncups#call-to-action

### First ever live stream

This year we also had our first ever [live stream][live-stream] where we discussed our newly
released [dependencies][dependencies-gh] library, and we live refactored how navigation was 
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

### Composable Architecture navigation



https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation
https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation
[what-is-nav]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/whatisnavigation
https://www.pointfree.co/collections/composable-architecture/navigation

### Reliably testing async

In 2022 we posted a seemingly innocent question about [how to reliably test async code in 
Swift][reliably-testing-async-forums]. Well, 1.5 years later, 126 replies and 20k views later… there
still is no official word from Apple on how to accomplish this.  

Even something as straightfoward as this:

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
space and seeing why it is essentially impossible to determinstically test any moderately complex 
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

### Tour of the Composable Architecture 1.0

It's hard to believe, but it was only this year that we finally released 1.0 of our popular library,
the [Composable Architecture][tca-gh]. To celebrate we released a brand new [tour of the 
library][tca-1.0-collection] where we rebuilt Apple's demo application, the 
[Scrumdinger][scrumdinger], using the Composable Architecture. (Incidentally we also rebuilt this
app without the Composable Architecture, and using only [modern, vanilla SwiftUI 
techniques](#modern-swiftui).)

Along the way we uncovered many benefits to using the Composable Architecture over vanilla SwiftUI,
such as:

* The ability to use value types for our domain rather than being forward to use reference types
and incur the complexity that comes with them.
* Easy integration of features together so that they can easily communicate with each other. 
* Immediate ability to deep-link into any state of our application.
* Instant testability, including how features integrate together and exhaustively proving how
state involves in the app and how effects feed data back into the system.

…and more.

[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[tca-1.0-collection]: https://www.pointfree.co/collections/composable-architecture/composable-architecture-1-0

### Deep dive into Swift's observation tools

https://www.pointfree.co/collections/swiftui/observation

### Case paths revolution

https://www.pointfree.co/episodes/ep258-macro-case-paths-part-2
https://www.pointfree.co/episodes/ep257-macro-case-paths-part-1
https://www.pointfree.co/blog/posts/117-macro-bonanza-case-paths

### Observable Architecture

https://www.pointfree.co/collections/composable-architecture/observable-architecture

## Open source

### Dependencies

[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
https://www.pointfree.co/blog/posts/92-a-new-library-to-control-dependencies-and-avoid-letting-them-control-you

### Concurrency extras

https://www.pointfree.co/blog/posts/109-announcing-concurrency-extras-useful-testable-swift-concurrency
[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras

### Inline snapshot testing

https://www.pointfree.co/blog/posts/113-inline-snapshot-testing
https://github.com/pointfreeco/swift-snapshot-testing/releases/tag/1.13.0

### Swift macro testing

https://github.com/pointfreeco/swift-macro-testing
https://www.pointfree.co/blog/posts/114-a-new-tool-for-testing-macros-in-swift
https://www.pointfree.co/blog/posts/115-macrotesting-0-2-0-test-more-with-less

### Observable architecture beta

https://www.pointfree.co/blog/posts/125-observable-architecture-beta

## Blog posts

### Modern SwiftUI

https://www.pointfree.co/blog/posts/99-modern-swiftui

### Being a good citizen in the land of Swift Syntax

https://www.pointfree.co/blog/posts/116-being-a-good-citizen-in-the-land-of-swiftsyntax

### Macro bonanza

https://www.pointfree.co/blog/posts/121-macro-bonanza

## Point-Free community

http://pointfree.co/slack-invite


## See you in 2024! 🥳

We're thankful to all of our subscribers for supporting us and helping us create this
content and these libraries. We could not do it without you!

Next year we have even more planned, including TODO

To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year
for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now
is the time!

See you in 2023!


[eoy-discount]: /discounts/2023-eoy

