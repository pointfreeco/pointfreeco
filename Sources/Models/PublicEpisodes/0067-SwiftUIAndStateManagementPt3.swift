import Foundation

public let ep67 = Episode(
  blurb: """
With our moderately complex SwiftUI application complete we can finally ask ourselves: "what's the point!?" What does SwiftUI have to say about app architecture? What questions are left unanswered? What can we do about it?
""",
  codeSampleDirectory: "0067-swiftui-and-state-management-pt3",
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 24833339,
    downloadUrl: "https://player.vimeo.com/external/349951622.hd.mp4?s=0db48a857039fc8d9da71cac13c8c1d48be96345&profile_id=175&download=1",
    streamingSource: "https://player.vimeo.com/video/349951722"
  ),
  id: 67,
  image: "https://i.vimeocdn.com/video/801296903.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0067-swiftui-and-state-management-pt3/itunes-poster.jpg",
  length: 27 * 60 + 2,
  permission: .free,
  previousEpisodeInCollection: 66,
  publishedAt: .init(timeIntervalSince1970: 1564380000),
  references: [
    .swiftUiTutorials,
    .insideSwiftUIAboutState
  ],
  sequence: 67,
  title: "SwiftUI and State Management: Part 3",
  trailerVideo: .init(
    bytesLength: 353885387,
    downloadUrl: "https://player.vimeo.com/external/349951707.hd.mp4?s=2dc0ab7f48e343ec1ef1540d1cb2607f857c37e6&profile_id=175&download=1",
    streamingSource: "https://player.vimeo.com/video/349951622"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  // todo
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a lot has changed in recent betas. While we note these changes inline below, we also went over them in detail [on our blog](/blog/posts/30-swiftui-and-state-management-corrections).
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: (0*60 + 5),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've now got a moderately complex application built in SwiftUI. It's honestly kind of amazing. There is absolutely no way we would have been able to build this application in the amount of time we did using UIKit. There would have been a maze of protocols to implement and delegates to set up and probably a huge number of bugs introduced along the way.
""",
    timestamp: (0*60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But as cool as this may be, at the end of each topic on Point-Free we like to ask the question "What's the point?" in order to bring things down to earth so that we can see the forest from the trees. This episode has been pretty practical already, but there are some very important lessons to take away.
""",
    timestamp: (0*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What we want to do is list out all the things we love about SwiftUI and all the things that don't seem to be quite there yet. Finally, we'll explore what we can do to close the gaps that SwiftUI has left open.
""",
    timestamp: (0*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start by enumerating all of the things that we really like.
""",
    timestamp: (0*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What’s to like?",
    timestamp: (1*60 + 17),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
To begin with, the concept of declarative views for describing UI is completely awesome. This is leaps and bounds better than how we used to do things in UIKit. It is incredibly powerful to have a single entry point for describing a view, which is the `body` computed var, and that forces us to think of our views as just a simple function from the state in our view to the SwiftUI view DSL values. We are very happy that Apple took this stance on view construction.
""",
    timestamp: (1*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Next, we love that SwiftUI gives us a few tools for managing state in our applications. First, for those times that a view has purely local state that does not need to travel any further up the view hierarchy, we have the `@State` attribute that gives us a simple bindable value such that any changes to that value will trigger a re-render of the view.
""",
    timestamp: (1*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Then, for those times that local state isn't enough, there's the `@ObjectBinding` attribute, which allows you to provide your own storage for the state so that multiple views can all share the same data. This means that any mutation made to the state in one view can be observed by another view, and it's exactly what allowed us to persist state across multiple screens, even when drilling in and out of a screen.
""",
    timestamp: (2*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And finally, another thing we love about SwiftUI is that it is giving a pretty strong opinion on how applications should be architected. In the UIKit world things were pretty loose a lot of the concepts are muddied with interpretations. For example, what is the difference between a `UIView` and a `UIViewController`? They both get user events and can layout subviews, yet some think `UIView`s should be concerned only with drawing the view and all the logic should be left to the view controller. In practice that leads to a lot of messiness because you are often needing to shuffle data back and forth between the view and controller, and eventually you start to wonder whether these two objects really just serve the same purpose.
""",
    timestamp: (2*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Further, UIKit gives lots of ways of listening for state changes so that you can update your UI, but they all stop short of creating a consistent way of updating all of your UI from state. Certainly you can listen for notifications, subscribe to KVO, delegates, target action and add callback closures to objects and even subclassing, but at the end of all of the notification mechanisms you are left with just executing a bunch of imperative states, e.g. hide this button, disable this text field, set the text of this label, etc. Maybe some people like how fast and loose UIKit is with its design, but I think it's fair to say that in the vacuum of opinions from UIKit there has been a proliferation of ideas on how to do app architecture in our community, all of them subtly different and incompatible.
""",
    timestamp: (3*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In contrast to UIKit, SwiftUI is providing a lot more opinions on how one should structure their application. First, if you want a view to show on the screen you have no choice but to create a view struct that conforms to the `View` protocol, and render your entire view inside the `body` computed property. Full stop, that is simply how you create views. Then, if you want that view to be able to update dynamically you must add some state to your view, and although there are a few ways to do that, they are fundamentally the same in principle.
""",
    timestamp: (4*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So that is some really positive, awesome stuff that SwiftUI has brought to the table. It has solved a bunch of problems that plagued UIKit. Apple has really made SwiftUI very opinionated in how certain tasks should be done, and has given us some excellent tools to do things in that way.
""",
    timestamp: (5*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Cumbersome persistent state API",
    timestamp: (5*60 + 14),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
However, we think there are still some problems that have been left unsolved. There are some things that SwiftUI does not do for us that we think are necessary for creating a large, complex application that is scalable in terms of new features being added and many developers working on the codebase.
""",
    timestamp: (5*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, let's talk about those for a moment so that we can discuss some potential solutions.
""",
    timestamp: (5*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Although it was easy enough to add the `AppState` class, make it a `BindableObject`, and hook into the passthrough subject, it isn't exactly something that is going to scale well.
""",
    timestamp: (5*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Right now we only have two properties, but this state class could easily grow to be dozens of properties, or even better, have many sub-state classes with their own fields.
""",
    timestamp: (6*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, we could introduce the concept of a logged-in user by adding a struct.
""",
    timestamp: (6*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct User {
  let id: Int
  let name: String
  let bio: String
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And by adding an optional user property to our app state.
""",
    timestamp: (6*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var loggedInUser: User? = nil {
  didSet { self.didChange.send() }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3. In later betas, SwiftUI's `BindableObject` protocol was deprecated in favor of an `ObservableObject` protocol that was introduced to the Combine framework. This protocol utilizes an `objectWillChange` property of `ObservableObjectPublisher`, which is pinged _before_ (not after) any mutations are made to your model. Because of this, `willSet` should be used instead of `didSet`:

```
var loggedInUser: User? {
  willSet { self.objectWillChange.send() }
}
```

Even better, we can remove this boilerplate entirely by using a `@Published` property wrapper:

```
@Published var loggedInUser: User?
```
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
We need to make sure that we add the `didSet` logic, because if we forget then future changes to the logged in user will not be reflected in the UI.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And then say later we want an activity feed of everything that the user does in the app. Again this is more state to add to our `AppState` class, including an associated data type.
""",
    timestamp: (7*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct Activity {
  let timestamp: Date
  let type: ActivityType

  enum ActivityType {
    case addedFavoritePrime(Int)
    case removedFavoritePrime(Int)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And yet another property:
""",
    timestamp: (7*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var activityFeed: [Activity] = [] {
  didSet { self.didChange.send() }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Again we need to make sure to add the `didSet` logic. We need to always add this boilerplate, and forgetting it can cause some very subtle UI bugs that would be hard to track down.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Also our state class is starting to look really messy, because every field needs addition lines for this `didSet` stuff:
""",
    timestamp: (7*60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var count = 0 {
  didSet { self.didChange.send() }
}

var favoritePrimes: [Int] = [] {
  didSet { self.didChange.send() }
}

var activityFeed: [Activity] = [] {
  didSet { self.didChange.send() }
}

var loggedInUser: User? = nil {
  didSet { self.didChange.send() }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It just feels like the core description of our state is being obscured by all of these annotations.
""",
    timestamp: (8*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's actually possible to create a universal solution to this problem by wrapping a value type in a class that is a bindable object, and tapping into that value's `didSet` in order to notify of changes that happen to any part of the value. However, the point here is that Apple has yet to give us a solution for truly modeling our global app state in a scaleable way, we must come up with our own solutions.
""",
    timestamp: (8*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3. Later betas introduced changes to dramatically reduce this boilerplate:

- The observable object publisher is now synthesized automatically.
- Properties wrapped with `@Published` will automatically be subscribed to by SwiftUI and do not need to do the `willSet` dance.

```
class AppState: ObservableObject {
  @Published var count = 0
  @Published var favoritePrimes: [Int] = []
  @Published var activityFeed: [Activity] = []
  @Published var loggedInUser: User?

  ...
}
```
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: "Scattered state mutation",
    timestamp: (8*60 + 47),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
The next problem we see is that although it is easy to make mutations to our state and have those changes reverberate throughout our UI, it is not exactly clear how we should organize our mutations. Right now we just have mutations scattered throughout our views. The worst offender right now is the `Counter` view, where we have no less than 7 mutations:
""",
    timestamp: (8*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.state.count -= 1 }) {
…
Button(action: { self.state.count += 1 }) {
…
Button(action: { self.showModal = true }) {
…
Button(action: {
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
  }
}) {
…
onDismiss: { self.showModal = false }
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Also some of these mutations are happening on the global state and some on local state, which is a bit of misdirection to always think about. Some are even hidden away inside 2-way bindings, like the alert binding.
""",
    timestamp: (9*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.presentation(self.$alertNthPrime) { n in
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The above APIs have been renamed to `alert(isPresented:content:)` and `alert(item:content:)`.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
This allows SwiftUI to reset this value to `nil` once the alert is dismissed. That's a hidden mutation that you have to know about!
""",
    timestamp: (10*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There really is no rhyme or reason to how these mutations are done, we just kind of sprinkled them in where needed.
""",
    timestamp: (10*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The problem is that when a newcomer walks into this codebase, they have no obvious place to begin looking for how state is mutated in our application. It could be hidden in a multitude of places, and so we feel that doesn't create a very welcoming environment for new contributors, and it's a significant problem to be solved.
""",
    timestamp: (10*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Another problem with this is that the more mutations that are added to a view, the less declarative it becomes. And that's because the mutations are not declarative themselves, they are just little closures holding a bunch of imperative commands to execute.
""",
    timestamp: (10*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's a really wonderful thing when the `body` property of a view is purely concerned with transforming your state into the view hierarchy to display on the screen. That is super understandable, super easy to make changes to, and super easy to test.
""",
    timestamp: (11*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's demonstrate this by adding two new features to our app. The first will be to disable the "nth prime" button while the Wolfram Alpha API request is inflight. SwiftUI makes this straightforward to do because it provides a `disabled` modifier that takes a boolean to determine whether or not a UI control is disabled.
""",
    timestamp: (11*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.disabled(<#disabled: Bool#>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's create some local state to hold a boolean that determines if the API request is in flight:
""",
    timestamp: (12*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@State var isNthPrimeButtonDisabled = false
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we hook into our button action to set it to `true` and `false` during the lifecycle of the API request:
""",
    timestamp: (12*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
self.isNthPrimeButtonDisabled = true
nthPrime(self.state.count) { prime in
  self.alertNthPrime = prime
  self.isNthPrimeButtonDisabled = false
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Finally we can use this state value to drive whether or not our button is enabled:
""",
    timestamp: (12*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.disabled(self.isNthPrimeButtonDisabled)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This button action has gotten a bit longer, but let's test it out.
""",
    timestamp: (13*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It works, however, it's just not looking great that we have so much logic crammed into this action closure. It's starting to detract from the declarative nature of this view in which we would like for it to mostly be focused on transforming state into view hierarchy.
""",
    timestamp: (13*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We could of course extract this out to a helper method instead:
""",
    timestamp: (13*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func nthPrimeButtonAction() {
  self.isNthPrimeButtonDisabled = true
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
    self.isNthPrimeButtonDisabled = false
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we could pass it directly to the button.
""",
    timestamp: (13*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: self.nthPrimeButtonAction) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But now our mutations are scattered in two ways: some are inline in the view, and some are stuff into a helper method. The team working on this code should probably come up with some guidelines around when it's appropriate to break out mutations into a helper method, but even then it's just extra process around doing something that should be very simple.
""",
    timestamp: (13*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But even worse, having mutations scattered all about means it can be easier to have mutations get out of sync. For example, I'm going to implement the changes necessary to keep track of that activity feed state I added. I'll go to my `CounterView` and update the button actions like so:
""",
    timestamp: (14*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: {
  self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
  self.state.activityFeed.append(.init(type: .removedFavoritePrime(self.state.count)))
})
…
Button(action: {
  self.state.favoritePrimes.append(self.state.count)
  self.state.activityFeed.append(.init(type: .addedFavoritePrime(self.state.count)))
})
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Very easy! But unfortunately completely wrong. There's a pretty serious bug here, because there is another way of removing primes from your favorites. You can do it from the favorite primes list view:
""",
    timestamp: (15*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.onDelete(perform: { indexSet in
  for index in indexSet {
    self.state.favoritePrimes.remove(at: index)
  }
})
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So we need to also update this logic:
""",
    timestamp: (15*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.onDelete(perform: { indexSet in
  for index in indexSet {
    let prime = self.state.favoritePrimes[index]
    self.state.favoritePrimes.remove(at: index)
    self.state.activityFeed.append(Activity(type: .removedFavoritePrime(prime)))
  }
})
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now this fix was easy, but probably the better fix would be to move these mutations into `AppState` so that we can better coalesce them:
""",
    timestamp: (16*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension AppState {
  func addFavoritePrime() {
    self.favoritePrimes.append(self.count)
    self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
  }

  func removeFavoritePrime(_ prime: Int) {
    self.favoritePrimes.removeAll(where: { $0 == prime })
    self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
  }

  func removeFavoritePrime() {
    self.removeFavoritePrime(self.count)
  }

  func removeFavoritePrimes(at indexSet: IndexSet) {
    for index in indexSet {
      self.removeFavoritePrime(self.favoritePrimes[index])
    }
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This will definitely do the trick, but now we have _three_ ways of mutating state: either inline in an action block, as a method on a view, or on a bindable object. And again it is up to your team to adopt guidelines of how to extract mutations out of views in a sensible manner, and it still doesn't guarantee against future mutations happening in your view that should be coalesced but aren't. And Apple is not giving any guidance on how to solve this problem in SwiftUI.
""",
    timestamp: (17*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "No story for side effects",
    timestamp: (17*60 + 55),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
The next problem we see is that Apple is not yet providing a story for how to handle side effects. We've talked about side effects a few times on Point-Free, and in fact [the 2nd episode](https://www.pointfree.co/episodes/ep2-side-effects) a year and a half ago was dedicated to side effects and understanding why they are so complicated.
""",
    timestamp: (17*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In our app we only have one external side effect, and that is our call to the Wolfram Alpha API. We did it in the most direct way we could think of, but is it the right way?
""",
    timestamp: (18*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func nthPrimeButtonAction() {
  self.isNthPrimeButtonDisabled = true
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
    self.isNthPrimeButtonDisabled = false
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Right now the effect is kinda just being fired off into the void. We have no way to cancel it if we decided we needed to do that, we have no way of debouncing it if it was something that could potentially be executed many times, and we certainly have no way to test it.
""",
    timestamp: (18*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
These observations are getting at the fact that this effect is simply not controlled. We are just executing this effect directly in a closure, and what we want instead is a data type representation of the effect so that we can manipulate the effect just like we would any type of value.
""",
    timestamp: (18*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And unfortunately Apple has not given us any guidance of how this should be done. There is hope that the Combine framework would be able to help us, but there still isn't a ton of information on how Combine can be used with SwiftUI.
""",
    timestamp: (19*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "State management isn't composable",
    timestamp: (19*60 + 37),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
The final problem we see with how SwiftUI wants us to deal with state is that it does not give us an easy way of breaking up large states into small states so that we could potentially have modular code.
""",
    timestamp: (19*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, let's look at our `FavoritePrimes` view:
""",
    timestamp: (19*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct FavoritePrimes: View {
  @ObjectBinding var state: AppState
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This view takes the entire `AppState`, but it only ever reads or mutates the `favoritePrimes` array.
""",
    timestamp: (20*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What we would like is to do is have this view only know about the data it cares about.
""",
    timestamp: (20*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
If we could do something like this then we could maybe even conceivably extract out this view into its own Swift package so that it could be used with other applications. Being able to do that is the pinnacle of modular application design. To be able to completely isolate this view into its own module while still allowing it to be plugged into other UIs means you can really start to understand components in complete isolation.
""",
    timestamp: (20*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Unfortunately, it is not yet known how this can be accomplished in SwiftUI. The closest we have come up with is to create a wrapper class that conforms to `ObjectBinding` and exposes only a bit of sub-state. We need to define our own initializer and we need to expose the global state's `didChange` with a computed property.
""",
    timestamp: (21*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
class FavoritePrimesState: BindableObject {
  var didChange: PassthroughSubject<Void, Never> {
    self.state.didChange
  }

  private var state: AppState
  init(state: AppState) {
    self.state = state
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we need to route the sub-state we care about through more computed properties. First, we can expose the `favoritePrimes`.
""",
    timestamp: (21*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var favoritePrimes: [Int] {
  get { self.state.favoritePrimes }
  set { self.state.favoritePrimes = newValue }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Next, we can expose the `activityFeed`.
""",
    timestamp: (22*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var activityFeed: [AppState.Activity] {
  get { self.state.activityFeed }
  set { self.state.activityFeed = newValue }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now we have a wrapper around global app state that exposes some local state.
""",
    timestamp: (22*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
class FavoritePrimesState: BindableObject {
  var didChange: PassthroughSubject<Void, Never> {
    self.state.didChange
  }

  private var state: AppState
  init(state: AppState) {
    self.state = state
  }

  var favoritePrimes: [Int] {
    get { self.state.favoritePrimes }
    set { self.state.favoritePrimes = newValue }
  }

  var activityFeed: [AppState.Activity] {
    get { self.state.activityFeed }
    set { self.state.activityFeed = newValue }
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Unfortunately, it came with a _lot_ of boilerplate, but let's make sure it actually works. First, we can replace the object binding in our favorite primes view.
""",
    timestamp: (22*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3. While it allowed you to derive `Binding`s of sub-state from observable bindings, a bug prevented it from propagating this mutable state over presentation boundaries, like navigation links and modal sheets. This bug has since been fixed in Xcode 11 beta 5, and state is now much more composable.

Rather than define `FavoritePrimesState`, we can instead pass two bindings to `FavoritesPrimeView`:

```
struct FavoritePrimesView: View {
  @Binding var favoritePrimes: [Int]
  @Binding var activityFeed: [AppState.Activity]
```
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
Let's make sure it works. First, we can replace the object binding in our favorite primes view.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct FavoritePrimesView: View {
  @ObjectBinding var state: FavoritePrimesState
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And no more changes need to be made to this view because it only relies on the state that we pipe through.
""",
    timestamp: (22*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
To instantiate this view in our root view, we now need to pass it this localized state.
""",
    timestamp: (23*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
NavigationLink(destination: FavoritePrimesView(state: FavoritePrimesState(state: self.state))) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This compiles and works as it did before, but we've been able to chip away a lot of global state and leave the little pieces of state that our view actually cares about.
""",
    timestamp: (23*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Unfortunately, we don't think this solution solves the problem. There's far too much boilerplate, and there's no way to isolate these components into their own modules. But as far as we know, this is the most direct way of getting an `ObjectBinding` of sub-state from an `ObjectBinding` of global state. There doesn't appear to be an easier way of doing this. There are maybe Swift features coming in the future that would make this easier, but as of now we don't have them.
""",
    timestamp: (23*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We consider this problem very important to solve because one of the biggest problems we encounter in code bases stems from an inability to split out components and fully encapsulate them in their own modules, isolated from the rest of their code, which leads to a bunch of complexity.
""",
    timestamp: (23*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "SwiftUI isn’t testable",
    timestamp: (24*60 + 24),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
And finally, we should quickly remark on testability. As it stands, SwiftUI is not super testable because Apple has not given us guidance or the tools to test a SwiftUI view. Right now all of our state and mutations are tangled up inside our view, and so there is no simple way to test that tapping the plus button does indeed increment the count, or that tapping the "add favorite prime" does indeed add it to our list of favorite primes.
""",
    timestamp: (24*60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And testing is very important for software developer, so we should have a story here. Testing allows us to verify that what we hope is true about our programs is indeed true, and means in the future we can refactor or relearn what the code does by looking at the tests. We definitely need to know how to test our application's logic.
""",
    timestamp: (25*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Conclusion",
    timestamp: (25*60 + 16),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
So, this is why we feel there is a point in exploring the problem space of state management, and using SwiftUI as a means to do that. There are some very important problems that need to be solved in an application architecture, namely:

- How to manage and mutate state
- How to execute side effects
- How to decompose large applications into small ones, and
- How to test our application.
""",
    timestamp: (25*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, in the next series of episodes we are going to show what functional programming has to say about state management. We are going to show that with just a little bit of upfront infrastructure work, we can come up with a mechanism to unify our app state, our app mutations, and the effects that can be executed into one simple package. It still heavily leverages all of the wonderful technology that SwiftUI gives us, but it gives us the opportunity to solve some of the problems that Apple has chosen not to solve. And the best part, the solution is not a SwiftUI-only solution. It works great with UIKit applications too, which is necessary for dealing with applications that need to mix legacy UIKit with their new SwiftUI views.

Till next time!
""",
    timestamp: (26*60 + 10),
    type: .paragraph
  ),
]
