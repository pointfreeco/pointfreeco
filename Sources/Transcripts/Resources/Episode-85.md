## Introduction

@T(00:00:05)
So we've now demonstrated that not only is the Composable Architecture we have been developing super testable, but it can also test deep aspects of our application, and it can be done with minimal set up and ceremony. This is key if people are going to be motivated to write tests. There should be as little friction as possible to writing tests, and we should be confident we are testing some real world aspects of our application.

@T(00:00:34)
But no matter how cool this is, we always like to end a series of episodes on Point-Free by asking "what's the point?". Because although we've built some great testing tools and gotten lots of test coverage, it also took quite a bit of work to get here. We are now on the 18th(!) episode of our architecture series, and we've built up a lot of machinery along the way. So was it necessary to do all of this work in order to gain this level of testability? And can we not do this type of testing in vanilla SwiftUI?

@T(00:00:56)
Unfortunately, we do indeed think it's necessary to do some amount of work to gain testability in a SwiftUI application. You don't necessarily need to use the Composable Architecture we've been building, but it seems that if you want to test your SwiftUI application you will be inevitably led to introducing some layers on top of SwiftUI to achieve this.

@T(00:01:17)
To see this, let's take a look at the vanilla SwiftUI application we wrote a long time ago, which was our introduction to SwiftUI and the whole reason we embarked on this series of architecture episodes.

## A tour of the vanilla SwiftUI code base

@T(00:01:48)
It begins with a class that holds our application's state:

```swift
class AppState: ObservableObject {
  @Published var count = 0
  @Published var favoritePrimes: [Int] = []
  @Published var loggedInUser: User? = nil
  @Published var activityFeed: [Activity] = []

  struct Activity {
    let timestamp: Date
    let type: ActivityType

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

struct PrimeAlert: Identifiable {
  let prime: Int
  var id: Int { self.prime }
}
```

@T(00:01:57)
This class conforms to the `ObservableObject` protocol so that views can automatically be notified changes are made and the view needs to be re-rendered. We also make all of the fields that should participate in this change notification process with `@Published`, which is possible thanks to some Swift runtime magic.

@T(00:02:22)
The `count` and array of `favoritePrimes` is the core data we want to persist across screens in our application. We later added some additional state just to explore other types of problems that need to be solved in an architecture. So we added a logged-in user and activity feed, even though we don't really use that information.

@T(00:02:41)
This class is like a less opinionated, more ad hoc version of the Composable Architecture's `Store`, which also conforms to `ObservableObject` and has a single `@Published` field for its entire state.

@T(00:03:03)
Next we have the `ContentView`, which is the root view of our application, and simply shows a choice of two things that can be done in the app:

```swift
struct ContentView: View {
  @ObservedObject var state: AppState

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: self.state)) {
          Text("Counter demo")
        }
        NavigationLink(
          destination: FavoritePrimesView(
            favoritePrimes: self.$state.favoritePrimes,
            activityFeed: self.$state.activityFeed
          )
        ) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}
```

@T(00:03:09)
We can either go to the `CounterView` or we can go to the `FavoritePrimesView`. This view is wrapped in a `NavigationView` so that we can do drill-ins to sub-screens. Inside the navigation view is a list so that we can easily show a few buttons stacked on top of each other. And then in the list is a few `NavigationLink`s, which is what allows us to drill down into sub-screens.

@T(00:03:18)
Let's start with the simpler of these two screens, the `FavoritePrimesView`. First take notice of how we create this view:

```swift
FavoritePrimesView(
  favoritePrimes: self.$state.favoritePrimes,
  activityFeed: self.$state.activityFeed
)
```

@T(00:03:22)
This strange `self.$state` syntax allows us to get at the underlying observable object of our app state, and then further chaining on `favoritePrimes` allows us to derive read-write bindings from the observable object. By passing down bindings to the `FavoritePrimesView` we allow that view to make changes to these value and have those mutations propagate back up. If we only passed the raw values:

@T(00:03:55)
If we only passed the raw values...

```swift
FavoritePrimesView(
  favoritePrimes: self.state.favoritePrimes,
  activityFeed: self.state.activityFeed
)
```

...then the `FavoritePrimesView` wouldn't be able to mutate those values and have those mutations observable by anyone else.

@T(00:04:05)
Scrolling down a bit we will find the implementation of the `FavoritePrimesView`:

```swift
struct FavoritePrimesView: View {
  @Binding var favoritePrimes: [Int]
  @Binding var activityFeed: [AppState.Activity]

  var body: some View {
    List {
      ForEach(self.favoritePrimes, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        for index in indexSet {
          let prime = self.favoritePrimes[index]
          self.favoritePrimes.remove(at: index)
          self.activityFeed.append(
            .init(
              timestamp: Date(),
              type: .removedFavoritePrime(prime)
            )
          )
        }
      }
    }
    .navigationBarTitle(Text("Favorite Primes"))
    .navigationBarItems(
      trailing: HStack {
        Button("Save", action: self.saveFavoritePrimes)
        Button("Load", action: self.loadFavoritePrimes)
      }
    )
  }

  func saveFavoritePrimes() {
    let data = try! JSONEncoder().encode(self.favoritePrimes)
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    )[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl
      .appendingPathComponent("favorite-primes.json")
    try! data.write(to: favoritePrimesUrl)
  }

  func loadFavoritePrimes() {
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    )[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl
      .appendingPathComponent("favorite-primes.json")
    guard
      let data = try? Data(contentsOf: favoritePrimesUrl),
      let favoritePrimes = try? JSONDecoder()
        .decode([Int].self, from: data)
    else { return }
    self.favoritePrimes = favoritePrimes
  }
}
```

@T(00:04:09)
Notice that this struct requires two bindings in order to be initialized, but we are using the `@Binding` property wrapper. This allows us to treat these fields as normal values, while under the hood it is actually using the machinery of bindings in order to re-render the UI when a value changes.

@T(00:04:30)
The body is a `List` with a `ForEach` nested inside, which allows us to render a row for each item in a collection. We also have this `onDelete` action which allows us to execute some code whenever a delete action takes place on a row. And further we add some navigation bar items to hold the "Save" and "Load" buttons, and their respective actions call out to some side-effecting methods we have on this view.

@T(00:05:04)
Next, let's scroll up a bit to see the `CounterView`:

```swift
struct CounterView: View {
  @ObservedObject var state: AppState
  @State var isPrimeModalShown: Bool = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false

  var body: some View {
    VStack {
      HStack {
        Button(action: { self.state.count -= 1 }) {
          Text("-")
        }
        Text("\(self.state.count)")
        Button(action: { self.state.count += 1 }) {
          Text("+")
        }
      }
      Button(action: { self.isPrimeModalShown = true }) {
        Text("Is this prime?")
      }
      Button(action: self.nthPrimeButtonAction) {
        Text("What is the \(ordinal(self.state.count)) prime?")
      }
      .disabled(self.isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
    .sheet(isPresented: self.$isPrimeModalShown) {
      IsPrimeModalView(
        activityFeed: self.$state.activityFeed,
        count: self.state.count,
        favoritePrimes: self.$state.favoritePrimes
      )
    }
    .alert(item: self.$alertNthPrime) { alert in
      Alert(
        title: Text(
          "The \(ordinal(self.state.count)) prime is \(alert.prime)"
        ),
        dismissButton: .default(Text("OK"))
      )
    }
  }

  func nthPrimeButtonAction() {
    self.isNthPrimeButtonDisabled = true
    nthPrime(self.state.count) { prime in
      self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
      self.isNthPrimeButtonDisabled = false
    }
  }
}
```

@T(00:05:09)
Definitely the biggest and most complicated view in our app. First, note that it takes all of the application state as an observed object:

```swift
@ObservedObject var state: AppState
```

That's because it needs access to pretty much all of this state to do its job.

@T(00:05:16)
It also has all of these additional fields:

```swift
@State var isPrimeModalShown: Bool = false
@State var alertNthPrime: PrimeAlert?
@State var isNthPrimeButtonDisabled = false
```

@T(00:05:20)
This is local state that only this view cares about. These values don't need to be passed down when this view is created, it has sensible defaults that it can start out with.

@T(00:05:29)
The body of the view itself has a lot going on. We use an `HStack` to get the main parts of the view stacked on top of each other, which includes the counter UI, the "Is this prime?" button, and the "What is the nth prime?" button. We also have logic for showing alerts and modals, both of which use the `$` syntax in order to access the `Binding` that powers the corresponding `@State` field.

@T(00:06:08)
And finally we have the `IsPrimeModalView`:

```swift
struct IsPrimeModalView: View {
  @Binding var activityFeed: [AppState.Activity]
  let count: Int
  @Binding var favoritePrimes: [Int]

  var body: some View {
    VStack {
      if isPrime(self.count) {
        Text("\(self.count) is prime 🎉")
        if self.favoritePrimes.contains(self.count) {
          Button(action: {
            self.favoritePrimes.removeAll(where: { $0 == self.count })
            self.activityFeed.append(
              .init(
                timestamp: Date(),
                type: .removedFavoritePrime(self.count)
              )
            )
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: {
            self.favoritePrimes.append(self.count)
            self.activityFeed.append(
              .init(
                timestamp: Date(),
                type: .addedFavoritePrime(self.count)
              )
            )
          }) {
            Text("Save to favorite primes")
          }
        }
      } else {
        Text("\(self.count) is not prime :(")
      }
    }
  }
}
```

@T(00:06:17)
This view takes two `@Binding`s because that is state this view wants to be able to mutate and have the changes propagate up to the parent, and it takes one immutable value because that is data that will not change in this view.

@T(00:06:44)
Everything else in this view is pretty standard, although it does contain quite a bit of logic and nuance.

## Testing vanilla SwiftUI

@T(00:06:56)
So, that's the basics of the application we built last time. Its design and architecture is based purely off the documentation Apple has given us (both online and in WWDC videos), and it is very straightforward.

@T(00:07:09)
In contrast, the architecture we have been building over the past many weeks had quite a few opinions on how to structure things that SwiftUI alone does not. It demanded that we no longer sprinkle mutations throughout our views. Instead, we describe all of the actions a user can take as an enum, and we create a reducer to describe how state should be mutated given a user action. Then, in the view, instead of performing mutations we are only allowed to send actions to the store. Most importantly, those actions very simply described what the user did, not what we expect to happen after the action took place. They were described like `saveButtonTapped` or `incrButtonTapped`, not like `fetchNthPrime` or `incrementCount`.

@T(00:07:59)
As we saw in the previous 3 episodes, this set up made it very easy to write tests. It took a little bit of investment for us to get our architecture in place, but once it was there the tests were trivial to write, and they allowed us to test very deep aspects of our application's logic.

@T(00:08:07)
So the question is: what does it look like to test a vanilla SwiftUI? We've clearly saved quite a bit of work by just using plain SwiftUI and not putting an additional layer of architecture on top, but do we still have the ability to test?

@T(00:08:17)
Well, unfortunately there isn't a ton we can directly test if we keep our usage of SwiftUI as dead-simple as possible. Let's try to write some tests to see why.

## Testing the prime modal

@T(00:08:28)
Let's start by writing some tests for the `IsPrimeModalView`, which has the basic functionality of allowing us to save and remove primes from our list of favorites. Let's hop over to our test file, and add a test:

```swift
import XCTest
@testable import VanillaPrimeTime

class VanillaPrimeTimeTests: XCTestCase {
  func testIsPrimeModalView() {
  }
}
```

@T(00:08:40)
So, what does it take to test our view? Well, we only have the actual view at our disposal, no other ancillary objects that we interact with. So let's try to create one:

```swift
let view = IsPrimeModalView(
  activityFeed: <#Binding<[AppState.Activity]>#>,
  count: <#Int#>,
  favoritePrimes: <#Binding<[Int]>#>
)
```

@T(00:08:51)
Looks like we need to provide two bindings, one for the activity feed and one for the favorite primes, as well as an integer. When we created this view in the context of a SwiftUI view it was really easy to derive these bindings, because we had an observable object at our disposal, and we could just do:

```swift
IsPrimeModalView(
  activityFeed: self.$state.activityFeed,
  count: self.state.count,
  favoritePrimes: self.$state.favoritePrimes
)
```

@T(00:09:11)
However, we don't have any of that SwiftUI machinery at our disposal in an `XCTest`, and so we gotta recreate this from scratch ourselves. The only initializer on `Binding` that is actually useful is this one:

```swift
Binding(
  get: <#() -> _#>,
  set: <#(_) -> Void#>
)
```

Which allows us to provide our own getter and setter.

@T(00:09:37)
So how can we use this to create, say, an activity feed binding?

```swift
let activityFeed = Binding(
  get: {  },
  set: { newValue in }
)
```

@T(00:09:49)
What are we going to get and set inside these closures? Well, we need to keep some additional mutable state on the outside that we can use on the inside:

```swift
var _activityFeed: [AppState.Activity] = []
let activityFeed = Binding(
  get: { _activityFeed },
  set: { newValue in _activityFeed = newValue }
)
```

@T(00:10:18)
This dance is probably just a simplified version of what the `@Binding` property wrapper does, but unfortunately we cannot use property wrappers at this scope:

```swift
@Binding var _activityFeed: [AppState.Activity] = []
```

> Error: Property wrappers are not yet supported on local properties

@T(00:10:31)
Further, we can't even use this as an instance variable of the test case:

```swift
class FavoritePrimesTests: XCTestCase {
  @Binding var _activityFeed: [AppState.Activity] = []
```

> Error: Argument labels '(wrappedValue:)' do not match any available overloads

@T(00:10:42)
And this is because the `@Binding` property wrapper doesn't allow initialization with an underlying value like `@State` does. We also can't take away the initial value:

```swift
class FavoritePrimesTests: XCTestCase {
  @Binding var _activityFeed: [AppState.Activity]
```

> Error: Class 'FavoritePrimesTests' has no initializers

@T(00:10:53)
Because then we need to provide an initializer, and we do not control initializing `XCTestCase` objects. That's something the `XCTest` framework and Xcode handle for us.

@T(00:11:03)
So it looks like we really have no choice but to create a binding directly, not using any of SwiftUI's fancy property wrappers. Fortunately, there is one small thing we can do to clean up the two step process we have right now for creating bindings. We can provide our own initializer that hides this little local mutable value away from us:

```swift
extension Binding {
  init(initialValue: Value) {
    var value = initialValue
    self.init(get: { value }, set: { value = $0 })
  }
}
```

@T(00:11:21)
And now we can simply do:

```swift
let activityFeed = Binding<[AppState.Activity]>(initialValue: [])
```

@T(00:11:40)
And we can even inline it:

```swift
let view = IsPrimeModalView(
  activityFeed: Binding<[AppState.Activity]>(initialValue: []),
  count: 2,
  favoritePrimes: Binding<[Int]>(initialValue: [2, 3, 5])
)
```

@T(00:12:00)
That's quite a bit nicer, and if we ever want to get the value out of the view we can simply do:

```swift
view.activityFeed
view.favoritePrimes
```

@T(00:12:10)
Phew, ok, we still haven't written any tests! We've only explored what it means to create a SwiftUI view that takes bindings in a test case.

@T(00:12:18)
So, what is there to test? Well, there is a ton of logic in this view around whether or not the current count is a prime and whether or not that prime is in our favorites:

```swift
var body: some View {
  VStack {
    if isPrime(self.count) {
      Text("\(self.count) is prime 🎉")
      if self.favoritePrimes.contains(self.count) {
        Button(action: { … }) {
          Text("Remove from favorite primes")
        }
      } else {
        Button(action: { … }) {
          Text("Save to favorite primes")
        }
      }
    } else {
      Text("\(self.count) is not prime :(")
    }
  }
}
```

@T(00:12:37)
However, all of that logic is trapped inside our `body` property, and there is nothing domain-specific in there:

```swift
view.body.<#⎋#>
```

@T(00:12:45)
We only see SwiftUI APIs in there for modifying this view. There's no way to actually get access on the subviews inside this view so that we can assert on what is happening. Essentially, everything that happens on the inside of these `body` properties should be thought of as a black box.

@T(00:13:05)
So, if we are going to test any of the logic in here we need to extract it out somewhere else. One thing we could do is move the logic that does the saving and removing of a favorite prime to methods on the view:

```swift
Button(action: self.removeFavoritePrime) {
}
…
Button(action: self.saveFavoritePrime) {
}
…
func removeFavoritePrime() {
  self.favoritePrimes.removeAll(where: { $0 == self.count })
  self.activityFeed.append(
    .init(
      timestamp: Date(),
      type: .removedFavoritePrime(self.count)
    )
  )
}

func saveFavoritePrime() {
  self.favoritePrimes.append(self.count)
  self.activityFeed.append(
    .init(
      timestamp: Date(),
      type: .addedFavoritePrime(self.count)
    )
  )
}
```

@T(00:13:40)
And now we are finally ready to write our first asserts:

```swift
view.removeFavoritePrime()

XCTAssertEqual(view.favoritePrimes, [3, 5])

view.saveFavoritePrime()

XCTAssertEqual(view.favoritePrimes, [3, 5, 2])
```

@T(00:14:22)
And these assertions pass! We can simply invoke a few of the methods on the view for mutating the state and then assert that the state mutated the way we expected.

@T(00:14:25)
Just to make sure these tests are actually running let's demonstrate a failure:

```swift
view.saveFavoritePrime()
XCTAssertEqual(favoritePrimes.wrappedValue, [3, 5])
```

> Failed: XCTAssertEqual failed: ("[3, 5, 2]") is not equal to ("[3, 5]")

@T(00:14:30)
So, we are actually testing some logic in this view. However, we have lost something when compared to how we tested our architecture. When we first tested this feature a few episodes back we were able to exhaustively check every field on the state:

```swift
func testRemoveFavoritesPrimesTapped() {
  var state = (count: 3, favoritePrimes: [3, 5])
  let effects = primeModalReducer(
    state: &state,
    action: .removeFavoritePrimeTapped
  )

  let (count, favoritePrimes) = state
  XCTAssertEqual(count, 3)
  XCTAssertEqual(favoritePrimes, [5])
  XCTAssert(effects.isEmpty)
}
```

@T(00:14:55)
This line in particular...

```swift
let (count, favoritePrimes) = state
```

...will fail if we ever add more fields to this state. This is excellent for making sure we continue asserting against the whole of the state, that way we don't accidentally miss something that is happening. For example, if I did something silly in the `saveFavoritePrime` method like this:

```swift
func removeFavoritePrime() {
  self.favoritePrimes.removeAll(where: { $0 == self.count })
  self.activityFeed.append(
    .init(
      timestamp: Current.date(),
      type: .removedFavoritePrime(self.count)
    )
  )
  self.activityFeed = []
}
```

@T(00:15:16)
Our tests will still pass. If we only test the things we think will change then we miss out on unrelated state being changed on accident.

@T(00:15:26)
There is one thing we can do to regain exhaustive assertions, but it comes with some boilerplate. We would need to introduce a new struct that holds only the state from `AppState` that we care about, and use it for our binding:

```swift
struct IsPrimeModalView: View {
  struct State {
    var activityFeed: [AppState.Activity]
    let count: Int
    var favoritePrimes: [Int]
  }
  @Binding var state: State

  // @Binding var activityFeed: [AppState.Activity]
  // let count: Int
  // @Binding var favoritePrimes: [Int]
```

@T(00:15:44)
And then we would need to create a getter/setter property on `AppState` for deriving this substate:

```swift
extension AppState {
  var isPrimeModalViewState: IsPrimeModalView.State {
    get {
      IsPrimeModalView.State(
        activityFeed: self.activityFeed,
        count: self.count,
        favoritePrimes: self.favoritePrimes
      )
    }
    set {
      (
        self.activityFeed,
        self.count,
        self.favoritePrimes
      ) = (
        newValue.activityFeed,
        newValue.count,
        newValue.favoritePrimes
      )
    }
  }
}
```

@T(00:16:07)
Which would allow us to create the prime modal view like this:

```swift
IsPrimeModalView(
  state: self.$state.isPrimeModalViewState
)
```

@T(00:16:19)
It's worth mentioning that this little bit of glue code we had to write is essentially identical to what we needed to write to make use of our architecture:

```swift
extension AppState {
  var isPrimeModalViewState: IsPrimeModalView.State {
    get { … }
    set { … }
  }
}
```

@T(00:16:26)
We needed to do something like this a few times in our architecture. We did it so that we could write reducers that work on just local state and actions and pull them back to work on global state and actions. So what we are seeing here is that even if we want to use SwiftUI in the plainest, most straightforward way, there are times that we are not going to be able to get around writing a bit of extra boilerplate. Here we are being forced to write this extra code if we want to squeeze out a bit of extra testability in SwiftUI.

@T(00:16:53)
Let's back out of this refactor though. We just wanted to demonstrate a possible route for gaining exhaustivity, and we don't want to go update all of our tests.

## Testing the favorite primes view

@T(00:17:13)
Although the prime modal view was not super testable out of the box, we were able to gain testability through a few helper methods. While views that take bindings are testable, we learned that testing exhaustively requires bundling up a view's state in a single, testable binding, which required a bunch of additional work.

@T(00:17:51)
Let's see what it takes to test the other views.

@T(00:17:57)
We can start by quickly taking a look at the `FavoritePrimesView`. It is similar to the `IsPrimeModal` in that it only needs a few binding values to do its job:

```swift
struct FavoritePrimesView: View {
  @Binding var favoritePrimes: [Int]
  @Binding var activityFeed: [AppState.Activity]
```

@T(00:18:04)
So based off of our work with the prime modal, we should be able to instantiate one of these views in a test quite easily. If we look around to see what is testable we will see a bit of logic stuffed into this `onDelete` closure:

```swift
.onDelete { indexSet in
  for index in indexSet {
    let prime = self.favoritePrimes[index]
    self.favoritePrimes.remove(at: index)
    self.activityFeed.append(
      .init(
        timestamp: Date(),
        type: .removedFavoritePrime(prime)
      )
    )
  }
}
```

@T(00:18:20)
If we want this logic to be testable we must extract it out into a method so that it can be invoked directly.

@T(00:18:32)
We also have these save and load methods on the view:

```swift
func saveFavoritePrimes() {
  …
}

func loadFavoritePrimes() {
  …
}
```

@T(00:18:43)
And they can be tested in much the same way too, assuming we control the side effects happening in here somehow.

@T(00:18:59)
We're not going to write any tests for this view because testing it should go mostly the same as testing the `FavoritePrimesView`. We'll leave the tests as an exercise for the viewer.

@T(00:19:07)
However, it's worth repeating the lessons we've learned. First of all, nothing done in the body of a view is testable. We should consider that a blackbox that we simply have no access to. So we have to do extra work to try to move work out of the body and into methods that can actually be tested.

@T(00:19:18)
Secondly, if we want to strengthen our tests so that they exhaustively cover the domain model of the view we seem to have no choice but to introduce intermediate structs so that we can assert against it all at once.

## Testing the counter view: @ObservedObject

@T(00:19:36)
Let's now see what it takes to write tests for our `CounterView`. Here we are encountering something that we didn't see in the previous two views:

```swift
struct CounterView: View {
  @ObservedObject var state: AppState
  @State var isPrimeModalShown: Bool = false
  @State var alertNthPrime: PrimeAlert?
  @State var isNthPrimeButtonDisabled = false
```

@T(00:19:47)
This view has some state expressed as `@ObservedObject` and other state as `@State`. We haven't written tests for either of these types of state yet. The `@ObservedObject` is the easier part to test, it's even easier than testing `@Binding`s. However, in order for anything to be testable at all we have to make sure to move state mutations out of the view's body and into dedicated methods. Let's do that with the increment and decrement buttons:

```swift
struct CounterView: View {
  …
  func incrementCount() {
    self.state.count += 1
  }

  func decrementCount() {
    self.state.count -= 1
  }

  var body: some View {
    …
    Button(action: self.decrementCount) {
      Text("-")
    }
    …
    Button(action: self.incrementCount) {
      Text("+")
    }
    …
  }
}
```

@T(00:20:36)
And then to test this logic we can construct a view, invoke those endpoints, and assert that state changed the way we expected. Except instead of constructing bindings we can pass along the app state directly:

```swift
func testCounterView() {
  let view = CounterView(state: AppState())

  view.incrementCount()

  XCTAssertEqual(view.state, AppState(count: 1))
}
```

> Error: Argument passed to call that takes no arguments

@T(00:21:13)
Unfortunately, we can't do this. `AppState` as an `ObservableObject` must be a class, and classes do not have a default memberwise initializer that we can call out to. We could create our own initializer to get access to these helpers, but we can't even have Xcode generate a memberwise initializer _for_ us because they do not play nicely with default properties.

@T(00:21:58)
One thing we could do is create a new value and mutate it to our expectations.

```swift
func testCounterView() {
  let view = CounterView(state: AppState())

  view.incrementCount()

  let expected = AppState()
  expected.count = 1
  XCTAssertEqual(view.state, expected)
}
```

> Error: Global function '`XCTAssertEqual(_:_:_:file:line:)`' requires that 'AppState' conform to 'Equatable'

@T(00:22:09)
Even this doesn't work, because `AppState` doesn't conform to `Equatable`. Unfortunately, we can't even automatically synthesize equatability on `AppState` because it's a class, which means we'd have to maintain our own custom conformance, which would break and we would need to remember to update it whenever we add or remove fields from our state.

@T(00:22:50)
So none of this is right, really. The only easy step forward is to pluck the count off of state and test it directly.

```swift
func testCounterView() {
  let view = CounterView(state: AppState())

  view.incrementCount()

  XCTAssertEqual(view.state.count, 1)
}
```

@T(00:23:04)
It passes, but remember, we've lost that strong exhaustivity in our testing. If `incrementCount` started doing something else to `AppState`, we wouldn't have coverage keeping that in check.

@T(00:23:26)
Regardless, let's flesh out this test by exercising its methods a bit more.

```swift
func testCounterView() {
  let view = CounterView(state: AppState())

  view.incrementCount()

  XCTAssertEqual(view.state.count, 1)

  view.incrementCount()

  XCTAssertEqual(view.state.count, 2)

  view.decrementCount()

  XCTAssertEqual(view.state.count, 1)
}
```

@T(00:23:41)
So this test was a bit easier to write because observable objects are quite easier to create than bindings, but unfortunately we came across other annoyances, like the fact that there's no easy way to create memberwise initializers, nor is there an easy way to make observable objects equatable, which means we're kind of forced to test slices of app state rather than the whole thing exhaustively.

## Testing the counter view: @State

@T(00:24:15)
We also want to be able to test those `@State` fields because there was some nuanced logic that guides their behavior. For example, as soon as you tap the "What is the nth prime?" button we disable the nth prime button, and then only when we get a response from the API do we re-enable it. We also only show the alert when we get a successful response from the API:

```swift
func nthPrimeButtonAction() {
  self.isNthPrimeButtonDisabled = true
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
    self.isNthPrimeButtonDisabled = false
  }
}
```

@T(00:24:50)
We should be able to write some assertions that the nth prime button starts enabled and then toggles to disabled when the nth prime button is pressed.

```swift
XCTAssertEqual(view.isNthPrimeButtonDisabled, false)

view.nthPrimeButtonAction()

XCTAssertEqual(view.isNthPrimeButtonDisabled, true)
```

And then we can run our test:

> Failed: XCTAssertEqual failed: ("false") is not equal to ("true")

@T(00:25:29)
That doesn't seem right. Literally the first thing the `nthPrimeButtonAction` method does is flip this boolean to `true`. Let's try to get some insight into what is happening inside this method by adding some `print` statements before and after the state is mutated :

```swift
func nthPrimeButtonAction() {
  print(self.isNthPrimeButtonDisabled)
  self.isNthPrimeButtonDisabled = true
  print(self.isNthPrimeButtonDisabled)
```

@T(00:25:46)
And when we run this test we will see:

```txt
false
false
```

@T(00:25:57)
This seems bizarre. We are directly mutating this value on one line, and then the very next line it's as if nothing happened.

@T(00:26:08)
While we don't know exactly why this is happening, it almost certainly has to do with the fact that this value is stored in a `@State` field, which is what gives SwiftUI the powers to automatically re-render this view when any value is changed. However, it seems that whatever machinery powers this simply does not work unless it is run in the right context, such as a `UIHostingController`.

@T(00:26:30)
As far as we know, there is no way around this. Essentially any state that is modeled using the `@State` property wrapper is simply untestable. Maybe you don't care about testing this logic, but if you do, you have no choice but to move it into your application state.

@T(00:26:47)
So let's do that real quick. We can add these fields to `AppState`:

```swift
class AppState: ObservableObject {
  …
  @Published var alertNthPrime: PrimeAlert? = nil
  @Published var isNthPrimeButtonDisabled = false
```

@T(00:27:00)
And then remove those fields from our view, while also fixing references to those fields:

```swift
struct CounterView: View {
  …
  // @State var alertNthPrime: PrimeAlert?
  // @State var isNthPrimeButtonDisabled = false
```

We just need to fix a few compiler errors along the way by reaching through the `state` property when accessing this state.

@T(00:27:23)
Once we do, our test will actually pass:

```swift
XCTAssertEqual(view.state.isNthPrimeButtonDisabled, false)

view.nthPrimeButtonAction()

XCTAssertEqual(view.state.isNthPrimeButtonDisabled, true)
```

@T(00:27:28)
So, although `@State` fields were not directly testable, we could at least extract them out to the app state to make them testable.

@T(00:27:37)
However, even with that done we still haven't recovered them same testing capabilities as we had with our architecture. When we wrote tests for this screen with the Composable Architecture we saw that we could easily add an integration test, that is, a test that exercises multiple independent pieces of the application at once. We were able to write a test for the prime modal logic as it is embedded in the counter logic, just to make sure that those two features play nicely together.

@T(00:28:06)
This is not possible to do currently. Since the prime modal is presented within the body of the counter view, we just have no access to it in our test. We can't invoke the methods we created earlier to simulate what would happen if they user interacted with the prime modal when presented from the counter screen.

@T(00:28:45)
We could probably recover some semblance of an integration test, but it would mean yet again moving logic out to somewhere more testable. Previously we moved logic out of the view body and into view methods, but now that isn't even enough, we probably need to move logic out into the app state directly somehow. But that also seems difficult because we aren't even using the app state in the prime modal view, we only pass down bindings, not the full observable object.

## Conclusion

@T(00:29:03)
I think what we are seeing here is that there really is no such thing as testing a vanilla SwiftUI application. It appears that you always need to do a little bit of upfront work in order to unlock testability.

@T(00:29:17)
- At a bare minimum you need to move as much of your logic out of the `body` property of your view as possible, and either put it in methods on the view or as methods on your state. This allows you to at the very least invoke those methods and assert that the state was changed in the way you expect.

    - But, this is quite similar to what we did in the Composable Architecture. We decided we did not want to perform mutations directly in the view, and instead described the mutations via enums and wrote reducers to actually perform the mutations.

@T(00:29:43)
- If you want to take a step further, you should also think about what SwiftUI features you use to model your state. It is convenient to project out a few fields of your big blob of state into bindings, but if you do that you lose the ability to exhaustively assert how state changes in a test. And if you want to recover the exhaustivity you have to bundle up those fields into a struct of its own and create a computed property on your app state to derive that sub-state.

    - But again, this is quite similar to what we did in the Composable Architecture. We created little state structs to hold the state specific to a view, and created the composability tools necessary to plug it back into the global state, and because we did that we got exhaustive testing for free.

@T(00:30:50)
- It is also convenient to use `@State` to model local state in a view. But this comes at the cost of essentially being untestable. There appears to be nothing we can do to make those values change as we invoke various methods on the view. The only way to gain testability is to move that state out of local `@State` bindings and into your app state, which means converting to either `@Binding` or `@ObservedObject`.

    - And yet again, this is exactly what we did in the Composable Architecture. We needed to move a few of these `@State` fields out of the view and into our global app state, like the alert state and button disabled state. At the time we did this because the logic that controlled that state was subtle, and we wanted to move it to our reducers. But then later we showed it gave us the ability to write some really amazing tests, including the ability to play out a full script of user actions (such as tapping a button, running an effect, triggering an alert, and dismissing the alert) and make sure the state changes how we expect.

@T(00:31:23)
And this is the point of all the work we've been doing on the Composable Architecture for the past 18 episodes of Point-Free. We claim that there really is no such thing as a "vanilla SwiftUI" app if you want that app to be testable. Although SwiftUI solves some of the hardest problems when it comes to building an application, there are many problems it does not attempt to solve. The moment you start to solve these problems, you are inevitably led to needing to add a layer on top of SwiftUI that Apple has not officially sanctioned or provided guidance on. Further, if you do not construct that extra layer in a principled way the tests will be difficult to write, and you may not be able to write integration tests that test many layers of your application at once.

@T(00:31:49)
And so if we accept all that, then we can see that the Composable Architecture we have been building feels right at home in SwiftUI. It doesn't really go against the grain of how SwiftUI wants to handle our applications, it only enhances it. We are just preemptively moving mutations and side effects out of the view and into a dedicated, testable place.

@T(00:32:08)
Further, it gives us a nice mental model for thinking about our applications. Rather than thinking in terms of mutations, things like "increment the count", "add the favorite prime" or "fetch the nth prime from Wolfram", we instead think in terms of user actions, "user tapped increment button", "user swiped delete on a row at an index", "user tapped the nth prime button". This forces us to think about our application from the viewpoint of what the user is doing, and mutations and effects only happen as a result of a user action taking place.

@T(00:32:37)
OK! That actually concludes our introductory series of episodes on the Composable Architecture. I don't think we planned on spending 18 weeks on this topic when we started, but it's an incredibly deep topic. And honestly, we've only barely scratched the surface of this topic.

@T(00:32:49)
There are so many more questions to answers and things to explore. Things like:

@T(00:32:55)
- How to properly handle alerts, modals and popovers in the Composable Architecture?

@T(00:33:01)
- Can we use this architecture for screens that are still built in plain UIKit?

@T(00:33:10)
- How is the performance of this architecture? Is there anything we should watch out for?

@T(00:33:13)
- Can we improve the ergonomics of the architecture? We've done this a few times but there is still more to be done.

@T(00:33:14)
- What is the best way to handle dependencies in this architecture? We did a little bit of this with our environment, but can it be improved?

@T(00:33:16)
And that's only the beginning of it!

@T(00:33:18)
But, we'll leave things here for now. This was our last episode of the year, so happy holidays to everyone and see you in 2020!
