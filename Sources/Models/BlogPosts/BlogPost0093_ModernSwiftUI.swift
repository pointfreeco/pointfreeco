import Foundation

public let post0093_ModernSwiftUI = BlogPost(
  author: .pointfree,  
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: ###"""
This week we finished our ambituous, [7-part series][modern-swiftui-collection] exploring modern,
best practices for SwiftUI development. In those episodes we re-built Apple’s
”[Scrumdinger][scrumdinger]” application, which is a great showcase for many of the problems one
encounters in a real life application. Every step of the way we challenged ourselves to write the
code in the most scalable and future-proof way possible, including:

1. We eschew plain arrays for lists and instead embrace [identified
arrays][identified-collections-gh].
1. All of navigation is state-driven and concisely modeled.
1. All side effects and dependencies are controlled.
1. A full test suite is provided to test many complex and nuanced user flows.

…and a whole bunch more.

Join us for a quick overview of the series, and consider [subscribing][pricing] today to get access
to the [full series][modern-swiftui-collection]!

* [The Standups app](#the-standups-app)
* [Identified arrays](#identified-arrays)
* [State-driven navigation](#state-driven-navigation)
* [Controlled dependencies](#controlled-dependencies)
* [Test suite](#test-suite)
* [A call for help!](#a-call-for-help)

<div id="the-standups-app"></div>

## The Standups app

During the course of 7 episodes we built Standups ([full source here][standups-source]), which is
an app for creating and managing daily standup meetings. Once a standup is created you can start
the meeting, which shows a helpful UI for how much time is left in the standup, whose turn it is,
and it will even transcribe the audio from the meeting so that it can be later referenced.

This app is a port of Apple’s “[Scrumdinger][scrumdinger]” application. The Scrumdinger app is a
wonderful example of a real world app that needs to deal with many complex scenarious, for example
lots of navigation flows and complex effects (timers, speech recognizers, and data persistence).

However, while Srumdinger is a great demonstration of a real world app, it is not necessarily built
in the most ideal way. It uses mostly fire-and-forget style navigation, which means you can't easily
deep link into any screen of the app, which is handy for push notifications and opening URLs. It
also uses uncontrolled dependencies, including file system access, timers and a speech recognizer,
which makes it nearly impossible to write automated tests and even hinders the ability to preview
the app in Xcode previews.

But, the simplicity of Apple's Scrumdinger codebase is not a defect. In fact, it's a feature!
Apple's sample code is viewed by hundreds of thousands of developers across the world, and so its
goal is to be as approachable as possible in order to teach the basics of SwiftUI. But, that doesn't
mean there isn't room for improvement.

<div id="identified-arrays"></div>

## Identified arrays

SwiftUI is well aware of the problems of using positional indices in lists of data, and that's
why `ForEach` forces data types to have a stable identifier via the `Identifable` protocol.
Unfortunately, there is no type that ships with the Swift standard library to embrace this pattern
in your domain modeling. That's precisely the gap that [IdentifiedArray][identified-collections-gh]
aims to fill.

This is why the first improvement we made to the Standups app over the Scrumdinger app is to scrap
plain arrays when modeling data for lists. Instead, we made use of our [IdentifiedArray] data type,
which allows referencing elements by their stable ID rather than their unstable positional index.

For example, because SwiftUI deals primarily with `Identifable` types, it is common that we have
the stable ID of an element and then we have to perform work to compute its positional index, say,
for removing the element:

```swift
func deleteStandup(id: Standup.ID) {
  guard let index = self.standups.firstIndex(where: { $0.id == id })
  else { return }
  self.standups.remove(at: index)
}
```

Try searching your code base for "`.firstIndex(where`" to see how many times you do this yourself.
Unfortunately, this code is both inefficient _and_ dangerous.

It is a potential performance problem because you are linearly scanning an array to find an element
by its ID. If your collection has thousands or hundreds of thousands of elements, this can be a
serious problem.

Further, this code is not safe. Suppose that we have an API service to communicate with when
deleting the standup. If we do this naively:

```swift
func deleteStandup(id: Standup.ID) async throws {
  guard let index = self.standups.firstIndex(where: { $0.id == id })
  else { return }

  try await self.apiClient.delete(id: id)

  self.standups.remove(at: index)
}
```

…then we can accidentally update the wrong standup or even crash. While the `apiClient.delete(id:)`
endpoint is suspending, it is possible for the `standups` array to shuffle its elements or even
remove some elements. So, when the suspension the `index` may no longer correspond to the correct
element, or may even fall outside the bounds of the array.

To fix this you must always compute indices _after_ suspension points, and if there are multiple
suspension points then you must compute the index multiple times. Or… you can use our
[IdentifiedArray][identified-collections-gh] data type. 🙂

In practice, this simply means changing code like this:

```swift
var standups: [Standup] = []
```

…to code like this:

```swift
import IdentifiedCollections

var standups: IdentifiedArrayOf<Standup> = []
```

Even with that change, all code should continue to compile because identified arrays mostly behave
like regular arrays. However, they come with additional API that allow for the safe and efficient
reading and modifying of elements by their ID. Such as removing an element by its ID:

```swift
self.standups.remove(id: id)
```

…or udpating an element by its ID:

```swift
self.standups[id: standup.id] = standup
```


<div id="state-driven-navigation"></div>

## State-driven navigation

Navigation is one of the most difficult aspects of SwiftUI, and it's why we have a [big series of
episodes][swiftui-nav-collection] dedicated to the topic. You can get really far in SwiftUI using
what we call "fire-and-forget" navigation, where there is no representation of the navigation in
your state.

However, as soon as you need to support push notifications, URL deep linking, or want to be able
to test your navigation, you _must_ start using state-driven navigation. This means using SwiftUI's
navigation APIs that make use of bindings.

Such APIs are a little more complex, but also incredibly powerful. However, most of SwiftUI's APIs
are built with structs and optionals in mind, which means if you screen has multiple places it can
navigate to, then you must use multiple optionals, which leads to an explosion of invalid states.

For example, the ["standup detail" screen][standup-detail-source] in Standups has 4 possible
places it can navigate to: an alert for deleting the standup, a sheet for editing the standup,
a drill-down to a previously recorded meeting, and a drill-down to record a new meeting. If we model
all of that state as optionals:

```swift
@Published var alert: AlertState<AlertAction>?
@Published var edit: EditStandupModel?
@Published var meeting: Meeting?
@Published var record: RecordMeetingModel?
```

…we have 2⁴=16 states to contend with, of which only 5 are actually valid (either exactly 1 is
non-`nil` or all or `nil`).

That kind of imprecision in the domain starts to leak complexity throughout the entire code base.
You can never be sure of what screen is actually visible because you must check multiple pieces of
state to see if they are `nil`, and if new destinations are added then existing code can all the
sudden become incorrect.

For this reason we prefer to model this kind of state as an enum, which automatically bakes in
compile-time proof that only one value can be instantiated at a time. This is [how it
looks][standup-detail-destination-enum] in the actual `StandupDetailModel` that powers the screen:

```swift
class StandupDetailModel: ObservableObject {
  @Published var destination: Destination?

  enum Destination {
    case alert(AlertState<AlertAction>)
    case edit(EditStandupModel)
    case meeting(Meeting)
    case record(RecordMeetingModel)
  }

  // ...
}
```

And then, [in the view][standup-detail-destinations-view], we can make use of the tools that ship
in our [SwiftUINavigation][swiftui-nav-gh] library, which allows you to perform all styles of
navigation (alerts, sheets, popovers, drill-downs, etc.) with a single, unified style of API:

```swift
.navigationDestination(
  unwrapping: self.$model.destination,
  case: /StandupDetailModel.Destination.meeting
) { $meeting in
  MeetingView(meeting: meeting, standup: self.model.standup)
}
.navigationDestination(
  unwrapping: self.$model.destination,
  case: /StandupDetailModel.Destination.record
) { $model in
  RecordMeetingView(model: model)
}
.alert(
  unwrapping: self.$model.destination,
  case: /StandupDetailModel.Destination.alert
) { action in
  await self.model.alertButtonTapped(action)
}
.sheet(
  unwrapping: self.$model.destination,
  case: /StandupDetailModel.Destination.edit
) { $editModel in
  EditStandupView(model: editModel)
}
```

With that little bit of upfront work, navigating to a particular screen is as easy as just
constructing a piece of state. For example, when the ["Edit" button is
tapped][standup-detail-edit-button-tapped], we can show the edit sheet by simply populating the
`destination` state:

```swift
self.destination = .edit(
  withDependencies(from: self) {
    EditStandupModel(standup: self.standup)
  }
)
```

Or when the ["Start a meeting" button is tapped][standup-detail-start-meeting-tapped], we can
drill down to the record meeting screen by populating the `destination` state:

```swift
self.destination = .record(
  withDependencies(from: self) {
    RecordMeetingModel(standup: self.standup)
  }
)
```

Or when the ["Cancel" button is tapped][standup-detail-cancel-tapped], we can dismiss the sheet
by simply `nil`-ing out the `destination` state:

```swift
func cancelEditButtonTapped() {
  self.destination = nil
}
```

This makes navigation incredibly simple, and we can let SwiftUI handle the hard part of actually
performing the animations and displaying the new UI.

But the best part is that deep linking, whether it be from push notifications or URLs or something
else, can be implemented by simply constructing a deeply nested piece of state, handing it to
SwiftUI, and letting it do it's thing.

For example, if we wanted to deep link into the app so that we are drilled down to the standup
detail screen, and then further drill down to a new meeting, it is as easy as this:

```swift
StandupsList(
  model: StandupsListModel(
    destination: .detail(
      StandupDetailModel(
        destination: .record(
          RecordMeetingModel(standup: standup)
        ),
        standup: standup
      )
    )
  )
)
```

It is incredibly powerful!

<div id="controlled-dependencies"></div>

## Controlled dependencies

It doesn't matter how much time you spend writing "clean" code with precisely modeled domains if
you don't also control your dependencies. Uncontrolled dependencies make it difficult to run your
application in Xcode previews, simulators and devices, make it difficult to write tests, and just
make your code base harder to understand.

So, we made use of our new [Dependencies][dependencies-gh] library to take control of our
dependencies rather than letting them control us. With very little work we were able to use
some of the dependencies that ship with the library, such as the `continuousClock` dependency to
stop reaching out to `Task.sleep` and instead use `clock.sleep`. That made it possible to write
a test for our timer feature without having to literally wait for real world time to pass.

But, to unlock extra superpowers from our application, we modeled our dependence on Apple's Speech
framework and the file system as dedicated clients, and registered them with our
[Dependencies][dependencies-gh] library. This gave us instant access to those dependencies every
where in the code base, and the ability to override them with controlled behavior for tests and
even Xcode previews.

For example, not only does Apple's Speech framework not work in Xcode previews, but the act of
asking for speech permissions suspends forever, preventing our feature's logic from ever executing.
This effectively made previews useless for testing our feature.

But, by controlling the dependency we were able to fake a speech recognition client that acts as if
authorization was granted, allow our feature to function normally.

<div id="test-suite"></div>

## Test suite

And last, but not least, the Standups application comes with a [full test
suite][standups-test-suite], exercising many nuanced user flows that execute effects and complex
logic.

For example, [we have a test][bad-data-test] that determines what happens when the application
starts up and the previously saved data on disk can't be loaded. We can do this by overriding our
`dataManager` dependency and forcing it to load non-sense data:

```swift
func testLoadingDataDecodingFailed() throws {
  let model = withDependencies {
    $0.mainQueue = .immediate
    $0.dataManager = .mock(
      initialData: Data("!@#$ BAD DATA %^&*()".utf8)
    )
  } operation: {
    StandupsListModel()
  }

  let alert = try XCTUnwrap(model.destination, case: /StandupsListModel.Destination.alert)

  XCTAssertNoDifference(alert, .dataFailedToLoad)

  model.alertButtonTapped(.confirmLoadMockData)

  XCTAssertNoDifference(model.standups, [.mock, .designMock, .engineeringMock])
}
```

This shows that when the data cannot be loaded an alert will be shown to the user.

For a more complicated example, the following test exercises the flow of drilling down to a standup,
tapping its delete button, confirming an alert is shown, and then confirming deletion. The
test will confirm that we are popped back to the root _and_ the standup is deleted from the root
list:

```swift
func testDelete() async throws {
  let model = try withDependencies { dependencies in
    dependencies.dataManager = .mock(
      initialData: try JSONEncoder().encode([Standup.mock])
    )
    dependencies.mainQueue = mainQueue.eraseToAnyScheduler()
  } operation: {
    StandupsListModel()
  }

  model.standupTapped(standup: model.standups[0])

  let detailModel = try XCTUnwrap(model.destination, case: /StandupsListModel.Destination.detail)

  detailModel.deleteButtonTapped()

  let alert = try XCTUnwrap(detailModel.destination, case: /StandupDetailModel.Destination.alert)

  XCTAssertNoDifference(alert, .deleteStandup)

  await detailModel.alertButtonTapped(.confirmDeletion)

  XCTAssertNil(model.destination)
  XCTAssertEqual(model.standups, [])
  XCTAssertEqual(detailModel.isDismissed, true)
}
```

These tests run in a fraction of a second (usually less than 0.01 seconds!) and typically you can
run hundreds (if not thousands) of these kinds of tests in the time it takes to run a single UI
test.

Speaking of UI tests, [we also have one of those][standup-list-ui-test]. We don't recommend focusing
all of your attention on UI tests, since they are slow and flakey, but it can be good to have a bit
of full integration testing, and so we wanted to show how it is possible.

<div id="a-call-for-help"></div>

## A call for help!

We hope that you find some of the topics discussed above exciting, and if you want to learn more,
be sure to check out our [7-part series][modern-swiftui-collection] on “Modern SwiftUI.”

We do have a favor to ask you. While we have built the Standups application in the style that makes
the most sense to us, we know that some of these ideas aren't for everyone. We would love if others
would fork the Standups code base and re-build it in the style of their choice.

Don't like to use an `ObservableObject` for each screen? Prefer to use `@StateObject` instead of
`@ObservedObject`? Want to use an architectural pattern such as VIPER? Have a different way
of handling dependencies? **Please show us!**

We will collect links to the other ports so that there can be a single place to reference many
different approaches for building the same application.

[pricing]: /pricing
[modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
[swiftui-collection]: https://www.pointfree.co/collections/swiftui
[swiftui-nav-collection]: https://www.pointfree.co/collections/swiftui/navigation
[standups-source]: https://github.com/pointfreeco/swiftui-navigation/tree/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[tagged-gh]: http://github.com/pointfreeco/swift-tagged
[identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
[swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
[standup-detail-destination-enum]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L24-L29
[standup-detail-destinations-view]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L217-L255
[standup-detail-edit-button-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L75-L81
[standup-detail-start-meeting-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L98-L102
[standup-detail-cancel-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L83-L85
[standup-detail-source]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/Standups/StandupDetail.swift#L83-L85
[standups-test-suite]: https://github.com/pointfreeco/swiftui-navigation/tree/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/StandupsTests
[bad-data-test]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/StandupsTests/StandupsListTests.swift#L184-L201
[standup-list-ui-test]: https://github.com/pointfreeco/swiftui-navigation/blob/f3ccc0b3a104d4afc911d8e7f41c009e3187c45d/Examples/Standups/StandupsUITests/StandupsListUITests.swift
"""###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 93,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-17")!,
  title: "Modern SwiftUI"
)
