## What’s the point?

> Correction: This episode was recorded with Xcode 11 beta 3, and a lot has changed in recent betas. While we note these changes inline below, we also went over them in detail [on our blog](/blog/posts/30-swiftui-and-state-management-corrections).

@T(00:00:05)
We've now got a moderately complex application built in SwiftUI. It's honestly kind of amazing. There is absolutely no way we would have been able to build this application in the amount of time we did using UIKit. There would have been a maze of protocols to implement and delegates to set up and probably a huge number of bugs introduced along the way.

@T(00:00:29)
But as cool as this may be, at the end of each topic on Point-Free we like to ask the question "What's the point?" in order to bring things down to earth so that we can see the forest from the trees. This episode has been pretty practical already, but there are some very important lessons to take away.

@T(00:00:57)
What we want to do is list out all the things we love about SwiftUI and all the things that don't seem to be quite there yet. Finally, we'll explore what we can do to close the gaps that SwiftUI has left open.

@T(00:00:14)
Let's start by enumerating all of the things that we really like.

## What’s to like?

@T(00:01:17)
To begin with, the concept of declarative views for describing UI is completely awesome. This is leaps and bounds better than how we used to do things in UIKit. It is incredibly powerful to have a single entry point for describing a view, which is the `body` computed var, and that forces us to think of our views as just a simple function from the state in our view to the SwiftUI view DSL values. We are very happy that Apple took this stance on view construction.

@T(00:01:47)
Next, we love that SwiftUI gives us a few tools for managing state in our applications. First, for those times that a view has purely local state that does not need to travel any further up the view hierarchy, we have the `@State` attribute that gives us a simple bindable value such that any changes to that value will trigger a re-render of the view.

@T(00:02:08)
Then, for those times that local state isn't enough, there's the `@ObjectBinding` attribute, which allows you to provide your own storage for the state so that multiple views can all share the same data. This means that any mutation made to the state in one view can be observed by another view, and it's exactly what allowed us to persist state across multiple screens, even when drilling in and out of a screen.

@T(00:02:23)
And finally, another thing we love about SwiftUI is that it is giving a pretty strong opinion on how applications should be architected. In the UIKit world things were pretty loose a lot of the concepts are muddied with interpretations. For example, what is the difference between a `UIView` and a `UIViewController`? They both get user events and can layout subviews, yet some think `UIView`s should be concerned only with drawing the view and all the logic should be left to the view controller. In practice that leads to a lot of messiness because you are often needing to shuffle data back and forth between the view and controller, and eventually you start to wonder whether these two objects really just serve the same purpose.

@T(00:03:10)
Further, UIKit gives lots of ways of listening for state changes so that you can update your UI, but they all stop short of creating a consistent way of updating all of your UI from state. Certainly you can listen for notifications, subscribe to KVO, delegates, target action and add callback closures to objects and even subclassing, but at the end of all of the notification mechanisms you are left with just executing a bunch of imperative states, e.g. hide this button, disable this text field, set the text of this label, etc. Maybe some people like how fast and loose UIKit is with its design, but I think it's fair to say that in the vacuum of opinions from UIKit there has been a proliferation of ideas on how to do app architecture in our community, all of them subtly different and incompatible.

@T(00:04:24)
In contrast to UIKit, SwiftUI is providing a lot more opinions on how one should structure their application. First, if you want a view to show on the screen you have no choice but to create a view struct that conforms to the `View` protocol, and render your entire view inside the `body` computed property. Full stop, that is simply how you create views. Then, if you want that view to be able to update dynamically you must add some state to your view, and although there are a few ways to do that, they are fundamentally the same in principle.

@T(00:05:05)
So that is some really positive, awesome stuff that SwiftUI has brought to the table. It has solved a bunch of problems that plagued UIKit. Apple has really made SwiftUI very opinionated in how certain tasks should be done, and has given us some excellent tools to do things in that way.

## Cumbersome persistent state API

@T(00:05:14)
However, we think there are still some problems that have been left unsolved. There are some things that SwiftUI does not do for us that we think are necessary for creating a large, complex application that is scalable in terms of new features being added and many developers working on the codebase.

@T(00:05:42)
So, let's talk about those for a moment so that we can discuss some potential solutions.

@T(00:05:55)
Although it was easy enough to add the `AppState` class, make it a `BindableObject`, and hook into the passthrough subject, it isn't exactly something that is going to scale well.

@T(00:06:29)
Right now we only have two properties, but this state class could easily grow to be dozens of properties, or even better, have many sub-state classes with their own fields.

@T(00:06:40)
For example, we could introduce the concept of a logged-in user by adding a struct.

```swift
struct User {
  let id: Int
  let name: String
  let bio: String
}
```

@T(00:06:46)
And by adding an optional user property to our app state.

```swift
var loggedInUser: User? = nil {
  didSet { self.didChange.send() }
}
```

> Correction: This episode was recorded with Xcode 11 beta 3. In later betas, SwiftUI's `BindableObject` protocol was deprecated in favor of an `ObservableObject` protocol that was introduced to the Combine framework. This protocol utilizes an `objectWillChange` property of `ObservableObjectPublisher`, which is pinged _before_ (not after) any mutations are made to your model. Because of this, `willSet` should be used instead of `didSet`:
>
> ```swift
> var loggedInUser: User? {
>   willSet { self.objectWillChange.send() }
> }
> ```
>
> Even better, we can remove this boilerplate entirely by using a `@Published` property wrapper:
>
> ```swift
> @Published var loggedInUser: User?
> ```

We need to make sure that we add the `didSet` logic, because if we forget then future changes to the logged in user will not be reflected in the UI.

@T(00:07:17)
And then say later we want an activity feed of everything that the user does in the app. Again this is more state to add to our `AppState` class, including an associated data type.

```swift
struct Activity {
  let timestamp: Date
  let type: ActivityType

  enum ActivityType {
    case addedFavoritePrime(Int)
    case removedFavoritePrime(Int)
  }
}
```

@T(00:07:35)
And yet another property:

```swift
var activityFeed: [Activity] = [] {
  didSet { self.didChange.send() }
}
```

Again we need to make sure to add the `didSet` logic. We need to always add this boilerplate, and forgetting it can cause some very subtle UI bugs that would be hard to track down.

@T(00:07:57)
Also our state class is starting to look really messy, because every field needs addition lines for this `didSet` stuff:

```swift
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
```

@T(00:08:12)
It just feels like the core description of our state is being obscured by all of these annotations.

@T(00:08:16)
It's actually possible to create a universal solution to this problem by wrapping a value type in a class that is a bindable object, and tapping into that value's `didSet` in order to notify of changes that happen to any part of the value. However, the point here is that Apple has yet to give us a solution for truly modeling our global app state in a scaleable way, we must come up with our own solutions.

> Correction: This episode was recorded with Xcode 11 beta 3. Later betas introduced changes to dramatically reduce this boilerplate:
>
> - The observable object publisher is now synthesized automatically.
> - Properties wrapped with `@Published` will automatically be subscribed to by SwiftUI and do not need to do the `willSet` dance.
>
> ```swift
> class AppState: ObservableObject {
>   @Published var count = 0
>   @Published var favoritePrimes: [Int] = []
>   @Published var activityFeed: [Activity] = []
>   @Published var loggedInUser: User?
>   …
> }
> ```

## Scattered state mutation

@T(00:08:47)
The next problem we see is that although it is easy to make mutations to our state and have those changes reverberate throughout our UI, it is not exactly clear how we should organize our mutations. Right now we just have mutations scattered throughout our views. The worst offender right now is the `Counter` view, where we have no less than 7 mutations:

```swift
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
```

@T(00:09:47)
Also some of these mutations are happening on the global state and some on local state, which is a bit of misdirection to always think about. Some are even hidden away inside 2-way bindings, like the alert binding.

```swift
.presentation(self.$alertNthPrime) { n in
```

> Correction: This episode was recorded with Xcode 11 beta 3, and a change has been made to the presentation APIs in beta 4 and later versions of Xcode. The above APIs have been renamed to `alert(isPresented:content:)` and `alert(item:content:)`.

@T(00:10:01)
This allows SwiftUI to reset this value to `nil` once the alert is dismissed. That's a hidden mutation that you have to know about!

@T(00:10:17)
There really is no rhyme or reason to how these mutations are done, we just kind of sprinkled them in where needed.

@T(00:10:24)
The problem is that when a newcomer walks into this codebase, they have no obvious place to begin looking for how state is mutated in our application. It could be hidden in a multitude of places, and so we feel that doesn't create a very welcoming environment for new contributors, and it's a significant problem to be solved.

@T(00:10:54)
Another problem with this is that the more mutations that are added to a view, the less declarative it becomes. And that's because the mutations are not declarative themselves, they are just little closures holding a bunch of imperative commands to execute.

@T(00:11:27)
It's a really wonderful thing when the `body` property of a view is purely concerned with transforming your state into the view hierarchy to display on the screen. That is super understandable, super easy to make changes to, and super easy to test.

@T(00:11:54)
Let's demonstrate this by adding two new features to our app. The first will be to disable the "nth prime" button while the Wolfram Alpha API request is inflight. SwiftUI makes this straightforward to do because it provides a `disabled` modifier that takes a boolean to determine whether or not a UI control is disabled.

```swift
.disabled(<#disabled: Bool#>
```

@T(00:12:23)
Let's create some local state to hold a boolean that determines if the API request is in flight:

```swift
@State var isNthPrimeButtonDisabled = false
```

@T(00:12:36)
And then we hook into our button action to set it to `true` and `false` during the lifecycle of the API request:

```swift
self.isNthPrimeButtonDisabled = true
nthPrime(self.state.count) { prime in
  self.alertNthPrime = prime
  self.isNthPrimeButtonDisabled = false
}
```

@T(00:12:56)
Finally we can use this state value to drive whether or not our button is enabled:

```swift
.disabled(self.isNthPrimeButtonDisabled)
```

@T(00:13:03)
This button action has gotten a bit longer, but let's test it out.

@T(00:13:16)
It works, however, it's just not looking great that we have so much logic crammed into this action closure. It's starting to detract from the declarative nature of this view in which we would like for it to mostly be focused on transforming state into view hierarchy.

@T(00:13:35)
We could of course extract this out to a helper method instead:

```swift
func nthPrimeButtonAction() {
  self.isNthPrimeButtonDisabled = true
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
    self.isNthPrimeButtonDisabled = false
  }
}
```

@T(00:13:47)
And then we could pass it directly to the button.

```swift
Button(action: self.nthPrimeButtonAction) {
```

@T(00:13:53)
But now our mutations are scattered in two ways: some are inline in the view, and some are stuff into a helper method. The team working on this code should probably come up with some guidelines around when it's appropriate to break out mutations into a helper method, but even then it's just extra process around doing something that should be very simple.

@T(00:14:16)
But even worse, having mutations scattered all about means it can be easier to have mutations get out of sync. For example, I'm going to implement the changes necessary to keep track of that activity feed state I added. I'll go to my `CounterView` and update the button actions like so:

```swift
Button(action: {
  self.state.favoritePrimes.removeAll(where: {
    $0 == self.state.count
  })
  self.state.activityFeed.append(
    .init(type: .removedFavoritePrime(self.state.count))
  )
})
…
Button(action: {
  self.state.favoritePrimes.append(self.state.count)
  self.state.activityFeed.append(
    .init(type: .addedFavoritePrime(self.state.count))
  )
})
```

@T(00:15:35)
Very easy! But unfortunately completely wrong. There's a pretty serious bug here, because there is another way of removing primes from your favorites. You can do it from the favorite primes list view:

```swift
.onDelete(perform: { indexSet in
  for index in indexSet {
    self.state.favoritePrimes.remove(at: index)
  }
})
```

@T(00:15:50)
So we need to also update this logic:

```swift
.onDelete(perform: { indexSet in
  for index in indexSet {
    let prime = self.state.favoritePrimes[index]
    self.state.favoritePrimes.remove(at: index)
    self.state.activityFeed.append(
      Activity(type: .removedFavoritePrime(prime))
    )
  }
})
```

@T(00:16:11)
Now this fix was easy, but probably the better fix would be to move these mutations into `AppState` so that we can better coalesce them:

```swift
extension AppState {
  func addFavoritePrime() {
    self.favoritePrimes.append(self.count)
    self.activityFeed.append(
      Activity(
        timestamp: Date(),
        type: .addedFavoritePrime(self.count)
      )
    )
  }

  func removeFavoritePrime(_ prime: Int) {
    self.favoritePrimes.removeAll(where: { $0 == prime })
    self.activityFeed.append(
      Activity(
        timestamp: Date(),
        type: .removedFavoritePrime(prime)
      )
    )
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
```

@T(00:17:07)
This will definitely do the trick, but now we have _three_ ways of mutating state: either inline in an action block, as a method on a view, or on a bindable object. And again it is up to your team to adopt guidelines of how to extract mutations out of views in a sensible manner, and it still doesn't guarantee against future mutations happening in your view that should be coalesced but aren't. And Apple is not giving any guidance on how to solve this problem in SwiftUI.

## No story for side effects

@T(00:17:55)
The next problem we see is that Apple is not yet providing a story for how to handle side effects. We've talked about side effects a few times on Point-Free, and in fact [the 2nd episode](https://www.pointfree.co/episodes/ep2-side-effects) a year and a half ago was dedicated to side effects and understanding why they are so complicated.

@T(00:18:24)
In our app we only have one external side effect, and that is our call to the Wolfram Alpha API. We did it in the most direct way we could think of, but is it the right way?

```swift
func nthPrimeButtonAction() {
  self.isNthPrimeButtonDisabled = true
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
    self.isNthPrimeButtonDisabled = false
  }
}
```

@T(00:18:44)
Right now the effect is kinda just being fired off into the void. We have no way to cancel it if we decided we needed to do that, we have no way of debouncing it if it was something that could potentially be executed many times, and we certainly have no way to test it.

@T(00:18:58)
These observations are getting at the fact that this effect is simply not controlled. We are just executing this effect directly in a closure, and what we want instead is a data type representation of the effect so that we can manipulate the effect just like we would any type of value.

@T(00:19:14)
And unfortunately Apple has not given us any guidance of how this should be done. There is hope that the Combine framework would be able to help us, but there still isn't a ton of information on how Combine can be used with SwiftUI.

## State management isn't composable

@T(00:19:37)
The final problem we see with how SwiftUI wants us to deal with state is that it does not give us an easy way of breaking up large states into small states so that we could potentially have modular code.

@T(00:19:56)
For example, let's look at our `FavoritePrimes` view:

```swift
struct FavoritePrimes: View {
  @ObjectBinding var state: AppState
```

@T(00:20:08)
This view takes the entire `AppState`, but it only ever reads or mutates the `favoritePrimes` array.

@T(00:20:20)
What we would like is to do is have this view only know about the data it cares about.

@T(00:20:31)
If we could do something like this then we could maybe even conceivably extract out this view into its own Swift package so that it could be used with other applications. Being able to do that is the pinnacle of modular application design. To be able to completely isolate this view into its own module while still allowing it to be plugged into other UIs means you can really start to understand components in complete isolation.

@T(00:21:01)
Unfortunately, it is not yet known how this can be accomplished in SwiftUI. The closest we have come up with is to create a wrapper class that conforms to `ObjectBinding` and exposes only a bit of sub-state. We need to define our own initializer and we need to expose the global state's `didChange` with a computed property.

> Correction: This episode was recorded with Xcode 11 beta 3. While it allowed you to derive `Binding`s of sub-state from observable bindings, a bug prevented it from propagating this mutable state over presentation boundaries, like navigation links and modal sheets. This bug has since been fixed in Xcode 11 beta 5, and state is now much more composable.
>
> Rather than define `FavoritePrimesState`, we can instead pass two bindings to `FavoritesPrimeView`:
>
> ```swift
> struct FavoritePrimesView: View {
>   @Binding var favoritePrimes: [Int]
>   @Binding var activityFeed: [AppState.Activity]
> ```

```swift
class FavoritePrimesState: BindableObject {
  var didChange: PassthroughSubject<Void, Never> {
    self.state.didChange
  }

  private var state: AppState
  init(state: AppState) {
    self.state = state
  }
}
```

@T(00:21:58)
And then we need to route the sub-state we care about through more computed properties. First, we can expose the `favoritePrimes`.

```swift
var favoritePrimes: [Int] {
  get { self.state.favoritePrimes }
  set { self.state.favoritePrimes = newValue }
}
```

@T(00:22:29)
Next, we can expose the `activityFeed`.

```swift
var activityFeed: [AppState.Activity] {
  get { self.state.activityFeed }
  set { self.state.activityFeed = newValue }
}
```

@T(00:22:37)
And now we have a wrapper around global app state that exposes some local state.

```swift
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
```

@T(00:22:47)
Unfortunately, it came with a _lot_ of boilerplate.

Now let's make sure it works. First, we can replace the object binding in our favorite primes view.

```swift
struct FavoritePrimesView: View {
  @ObjectBinding var state: FavoritePrimesState
```

@T(00:22:56)
And no more changes need to be made to this view because it only relies on the state that we pipe through.

@T(00:23:04)
To instantiate this view in our root view, we now need to pass it this localized state.

```swift
NavigationLink(
  destination: FavoritePrimesView(
    state: FavoritePrimesState(state: self.state)
  )
) {
```

@T(00:23:19)
This compiles and works as it did before, but we've been able to chip away a lot of global state and leave the little pieces of state that our view actually cares about.

@T(00:23:31)
Unfortunately, we don't think this solution solves the problem. There's far too much boilerplate, and there's no way to isolate these components into their own modules. But as far as we know, this is the most direct way of getting an `ObjectBinding` of sub-state from an `ObjectBinding` of global state. There doesn't appear to be an easier way of doing this. There are maybe Swift features coming in the future that would make this easier, but as of now we don't have them.

@T(00:23:58)
We consider this problem very important to solve because one of the biggest problems we encounter in code bases stems from an inability to split out components and fully encapsulate them in their own modules, isolated from the rest of their code, which leads to a bunch of complexity.

## SwiftUI isn’t testable

@T(00:24:24)
And finally, we should quickly remark on testability. As it stands, SwiftUI is not super testable because Apple has not given us guidance or the tools to test a SwiftUI view. Right now all of our state and mutations are tangled up inside our view, and so there is no simple way to test that tapping the plus button does indeed increment the count, or that tapping the "add favorite prime" does indeed add it to our list of favorite primes.

@T(00:25:04)
And testing is very important for software developer, so we should have a story here. Testing allows us to verify that what we hope is true about our programs is indeed true, and means in the future we can refactor or relearn what the code does by looking at the tests. We definitely need to know how to test our application's logic.

## Conclusion

@T(00:25:16)
So, this is why we feel there is a point in exploring the problem space of state management, and using SwiftUI as a means to do that. There are some very important problems that need to be solved in an application architecture, namely:

- How to manage and mutate state
- How to execute side effects
- How to decompose large applications into small ones, and
- How to test our application.

@T(00:26:10)
So, in the next series of episodes we are going to show what functional programming has to say about state management. We are going to show that with just a little bit of upfront infrastructure work, we can come up with a mechanism to unify our app state, our app mutations, and the effects that can be executed into one simple package. It still heavily leverages all of the wonderful technology that SwiftUI gives us, but it gives us the opportunity to solve some of the problems that Apple has chosen not to solve. And the best part, the solution is not a SwiftUI-only solution. It works great with UIKit applications too, which is necessary for dealing with applications that need to mix legacy UIKit with their new SwiftUI views.

Till next time!
