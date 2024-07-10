## Introduction

@T(00:00:05, Brandon)
We first began discussing the Composable Architecture long ago in an episode named innocently enough: “[Composable State Management: Reducers](https://www.pointfree.co/episodes/ep68-composable-state-management-reducers)”. And coincidentally that episode was released on August 5th, 2019, which is almost exactly 4 years ago.

@T(00:00:20)
[The library](https://github.com/pointfreeco/swift-composable-architecture) ended up becoming much bigger than we ever anticipated, both in terms of the kinds of tools we could provide for solving common, real world problems developers encounter in their day-to-day work, but also in terms of how many people have adopted the library. The project has over 9,000 stars on GitHub, every 2 weeks it is cloned over 30,000 times by over 3,000 unique cloners, and it is used by many teams, both big and small.

@T(00:00:44)
And today we are incredibly excited to *finally* announce that the Composable Architecture has entered [1.0](https://github.com/pointfreeco/swift-composable-architecture/releases/1.0.0). It’s a little wild to think it has taken us this long to release 1.0, but the navigation tools we released a few weeks back was really the last missing piece we wanted in the library before we felt it provided a cohesive story for building an application in the ways that we like, which consists of using value types to model your domain, managing your effects separately from state mutations, controlling your dependencies, and being able to test as much of your application as possible. Oh, and to do it all with ergonomics in mind.

@T(00:01:19, Stephen)
So, now that 1.0 is officially out we wanted to redo our [tour series of episodes](/collections/composable-architecture/a-tour-of-the-composable-architecture) that we released over 3 years ago since at this point it is looking quite long in the tooth. In that past series we built a small todo application, which was nice, but I think we can do better this time.

@T(00:01:35)
This time we are going to re-build one of Apple’s most interesting sample code projects, which they call “Scrumdinger”. It is a moderately complex application that has multiple kinds of navigation, such as sheets, alerts, and drill-downs, and it deals with some interesting side-effects, such as timers, speech recognizers and data persistence.

@T(00:01:53)
And this isn’t the first time we’ve discussed Scrumdinger on Point-Free. Earlier this year we rebuilt Scrumdinger in our “[Modern SwiftUI](/collections/swiftui/modern-swiftui)” series where we built the application in a completely vanilla manner, no Composable Architecture at all, but did so with an eye on modern techniques. This included concise domain modeling, state-driven navigation, controlled dependencies, and a full test suite.

@T(00:02:16)
So, we are going to build Scrumdinger *again*, this time in the Composable Architecture, and that will also give us the opportunity to compare and contrast what it means to build an application using our library versus doing things in a more vanilla way.

@T(00:02:27, Brandon)
It’s also worth mentioning that we are starting this tour series a mere month and a half after WWDC 23 where some pretty incredible new tools were announced, such as macros and the new `Observable` protocol. Those tools are going to have a huge effect on how Composable Architecture applications are written in the future, but this tour will still be relevant for years to come since most people cannot target iOS 17 anytime soon. Also, along the way we are going to give little teasers of how things will change in iOS 17 as we progress through this tour.

## A soft landing into the Composable Architecture

@T(00:03:00)
But, before we dive into the Scrumdinger application and start rebuilding it from scratch, let’s take a softer landing into the Composable Architecture and build something much simpler just so that we are familiar with the basic concepts. We are going to start with one of the most beloved applications in all of the iOS community: the humble counter. But, we are going to add a few bells and whistles along the way that make it a lot more interesting than your standard counter, and along the way we will learn the fundamentals of the library that will better prepare us for rebuilding the Scrumdinger application.

@T(00:03:31)
So, let’s get started.

@T(00:03:34)
I’ve got a fresh SwiftUI project opened for us to build this demo. There is typically two approaches one can take to building a feature in the Composable Architecture. You can start with a domain modeling exercise, where you figure out the state and actions your feature needs, and then implement the feature’s logic and behavior. Or you can start by sketching the view of the feature, and then let that lead you to the domain modeling of the feature.

@T(00:03:59)
We will do the latter. We are going to sketch out a bit of view hierarchy for the feature and then figure out how to implement the logic to power the view. We’ll start with a `Form` at the root of the view that holds onto a text view of the current count, as well as buttons to increment and decrement the count:

```swift
struct ContentView: View {
  var body: some View {
    Form {
      Section {
        Text(<#"0"#>)
        Button("Decrement") {
          <#Do something#>
        }
        Button("Increment") {
          <#Do something#>
        }
      }
    }
  }
}
```

@T(00:04:20)
Then we will have a section with a button that when tapped loads a fact about the current count from an external API service. This will give us the opportunity to show off how to execute side effects in a controllable and understandable manner:

```swift
Section {
  Button("Get fact") {}
  if <#let fact#> {
    Text(<#"Some fact"#>)
  }
}
```

@T(00:04:36)
And finally we will have a section with a button that when tapped starts a timer that ticks once a second, and with each tick the count value in the feature will increment by one. This will give us an opportunity to see how time-based asynchrony works and we will be able to see how one can cancel inflight effects:

```swift
Section {
  if <#isTimerOn#> {
    Button("Stop timer") {
      <#Do something#>
    }
  } else {
    Button("Start timer") {
      <#Do something#>
    }
  }
}
```

@T(00:04:55)
OK, that is the basics of the view, and we now see all the data our feature needs to populate the various fields in the UI, as well as all the various button action closures we need to implement.

@T(00:05:15)
So now we will start building the Composable Architecture feature to power this view. First we need access to the Composable Architecture, so let’s import it:

```swift
import ComposableArchitecture
```

@T(00:05:33)
And now we can start building our feature. It begins by defining a new type that conforms to the `Reducer` protocol, which encapsulates the state, actions, logic and behavior of your feature:

```swift
struct CounterFeature: Reducer {

}
```

@T(00:05:48)
There are 3 requirements. First, we define a type that represents the state of the feature, and it’s typically a struct but not always:

```swift
struct CounterFeature: Reducer {
  struct State {
  
  }
}
```

@T(00:05:58)
This is everything the feature needs to do its job, including all the state the view needs, as well as any state that may be used internally. We can even just look at the view to see exactly what is needed: a integer for the current count, an optional string for the fact if it is being shown, and a boolean that determines whether or not a timer is currently on:

```swift
struct CounterFeature: Reducer {
  struct State {
    var count = 0
    var fact: String?
    var isTimerOn = false
  }
}
```

@T(00:06:30)
The next requirement is a type for the actions of the feature. This is almost always an enum:

```swift
struct CounterFeature: Reducer {
  …
  enum Action {

  }
}
```

@T(00:06:37)
In this enum we will list out a case for each thing that the user can do in the UI, such as every button tap, every swipe gesture, and more. It will also hold cases for actions that side effects can send back into the system, but we will get to that later.

@T(00:06:53)
Looking at the UI we see quite a few button action closures, and each one will be sending an action to this reducer. So, we will create a case for tapping the increment and decrement buttons, tapping the “Get fact” button, as well as toggling the timer on and off:

```swift
enum Action {
  case decrementButtonTapped
  case getFactButtonTapped
  case incrementButtonTapped
  case toggleTimerButtonTapped
}
```

@T(00:07:23)
Note that we like to name our actions *literally* after what the user did in the UI rather than what logic will be executed by the reducer. So, rather than naming an action `incrementCount` or `loadFact`, we say `incrementButtonTapped` and `getFactButtonTapped`. This makes it clearer which action should be sent from where in the UI.

@T(00:07:48)
And further, by naming actions after the logic we want executed we run the risk of the description getting stale very quickly. In fact, if we used `loadFact` rather than `getFactButtonTapped`, what would we do if someday we started doing more for this action. Such as tracking analytics, or requiring authentication before performing the action, or any number of things. Are we going to encode all of that information in the action?

@T(00:08:13)
We just feel it’s a losing game to name actions in this way, so we prefer to keep things simple and name it after what the user is doing.

@T(00:08:23)
The final requirement of the `Reducer` protocol is to implement the body, much like one does in SwiftUI:

```swift
struct CounterFeature: Reducer {
  struct State {
    …
  }
  enum Action {
    …
  }
  var body: some Reducer<State, Action> {

  }
}
```

@T(00:08:41)
Though there is a handy type alias that can shorten this a bit:

```swift
var body: some ReducerOf<Self> {

}
```

@T(00:08:52)
The body is where you get to compose together many other kinds of reducers into one big reducer. Right now our feature is quite simple and we have no need to compose things. We just have the one single reducer that will implement the logic and behavior of the feature, called `Reduce`:

```swift
var body: some ReducerOf<Self> {
  Reduce(<#reduce: (inout State, Action) -> Effect<Action>#>)
}
```

@T(00:09:24)
However, once we get to rebuilding the Scrumdinger application we will find that many features are compromised of other smaller features. This allows you to build features in complete isolation, but then integrate them together so that they can communicate with one another.

@T(00:09:44)
`Reduce` takes a closure that is given the current state of the feature as an `inout` parameter, the action that was sent into the system, and must return what is called an `Effect`. We can open up the closure…

```swift
var body: some ReducerOf<Self> {
  Reduce { state, action in

  }
}
```

@T(00:09:53)
Where we have two responsibilities to accomplish:

@T(00:09:58)
First we can switch on the `action` to figure out what happened in the UI:
    
```swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .decrementButtonTapped:
      <#code#>
    case .getFactButtonTapped:
      <#code#>
    case .incrementButtonTapped:
      <#code#>
    case .toggleTimerButtonTapped:
      <#code#>
    }
  }
}
```

@T(00:10:07)
And we will implement the logic for the feature in each action. Since the state is `inout` we can mutate the state directly:

```swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .decrementButtonTapped:
      state.count -= 1

    case .getFactButtonTapped:
      // TODO: Perform network request
      break

    case .incrementButtonTapped:
      state.count += 1

    case .toggleTimerButtonTapped:
      state.isTimerOn.toggle()
      // TODO: Start a timer
    }
  }
}
```

@T(00:11:06)
If it worries you at all that the state is `inout`, then please rest assured that it is completely safe thanks to Swift’s value type semantics.
    
@T(00:11:18)
And the second responsibility is to return an instance of the `Effect` type, which represents a side effect that can be executed out in the real world and feed data back into the system. The most typical examples of this are API requests, but it can also include timers, analytics tracking, interactions with Apple’s frameworks such as core location or speech recognizers, and a whole bunch more. We’re not read for effects yet, so we can return a special kind of effect from each case that represents there is no effectful work to be done:
    
```swift
var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case .decrementButtonTapped:
      state.count -= 1
      return .none

    case .getFactButtonTapped:
      // TODO: Perform network request
      return .none

    case .incrementButtonTapped:
      state.count += 1
      return .none

    case .toggleTimerButtonTapped:
      state.isTimerOn.toggle()
      // TODO: Start a timer
      return .none
    }
  }
}
```

@T(00:12:08)
OK, that is the basics of implementing a feature in the Composable Architecture. There is still more to do in the feature, such as making network requests and managing a timer, but that will come a bit later.

@T(00:12:21)
For now let’s move over to the view. We want to power the view off of this new Composable Architecture feature, and the first step to doing that is providing what is known as a `Store` to the view:

```swift
struct ContentView: View {
  let store: Store<CounterFeature.State, CounterFeature.Action>
  …
}
```

@T(00:12:43)
But again we can shorten this a bit with a handy type alias that comes with the library:

```swift
struct ContentView: View {
  let store: StoreOf<CounterFeature>
  …
}
```

It can even be held onto as a `let` variable.

@T(00:12:52)
A `Store` represents the runtime of the feature. It is the thing that is responsible for actually mutating the feature’s state when actions are sent, executing the side effects, and feeding their data back into the system. 

@T(00:13:04)
It is a necessary component of the library because thus far our feature has been entirely defined in terms of value types. The reducer, state, and action types are all just structs and enums. That means they are inert, behavior-less values. On the one hand, that’s really amazing because value types are infinitely understandable since they have such well-defined semantics. But, on the other hand, applications are meant to change over time and are meant to interact with outside, unpredictable systems.

@T(00:13:43)
This is why eventually you need a reference type *somewhere* in the application, and for Composable Architecture applications, that is the `Store`. 

@T(00:14:00)
Now, as of 1.0 of the library you cannot directly read state from the store. This is because if done naively one can observe far too much state than is necessary and cause slow, under-performing views. So, there is one additional step you must take to actually observe the state inside inside the store, and that is construct what is known as a `ViewStore`. This can most easily be done using a SwiftUI helper view known as `WithViewStore`:

```swift
var body: some View {
  WithViewStore(
    self.store,
    observe: <#(CounterFeature.State) -> ViewState#>
  ) { viewStore in
    Form {
      …
    }
  }
}
```

@T(00:14:37)
You supply the `store` you want to observe, as well as an `observe` closure that allows you to decide which parts of state you actually want to observe. 

@T(00:15:09)
Typically features hold onto a lot more state than the view needs to do its job and so we would use this as an opportunity to whittle down the exact state the view needs to do its job. In this case the view basically needs everything, and so we can use an identity closure:

```swift
WithViewStore(self.store, observe: { $0 }) { viewStore in
  Form {
    …
  }
}
```

@T(00:15:29)
But just remember that it is usually best to whittle down state to the bare essentials the view needs, especially when you have lots of features composed together.

@T(00:15:33)
This doesn’t currently compile:

> Error: Referencing initializer 'init(_:observe:content:file:line:)' on 'WithViewStore' requires that 'CounterFeature.State' conform to 'Equatable'

@T(00:15:35)
And that’s just because the state we are observing must be equatable. This is so that the `ViewStore` can minimize the number of times the view is rendered.

@T(00:15:45)
So, let’s make the `State` type equatable:

```swift
struct State: Equatable {
  …
}
```

@T(00:15:48)
Now things are compiling, and we can start filling in the placeholders in our view since the `viewStore` has access to state and can send actions:

```swift
var body: some View {
  WithViewStore(self.store, observe: { $0 }) { viewStore in
    Form {
      Section {
        Text("\(viewStore.count)")
        Button("Decrement") {
          viewStore.send(.decrementButtonTapped)
        }
        Button("Increment") {
          viewStore.send(.incrementButtonTapped)
        }
      }
      
      Section {
        Button("Get fact") {
          viewStore.send(.getFactButtonTapped)
        }
        if let fact = viewStore.fact {
          Text(fact)
        }
      }
      
      Section {
        if viewStore.isTimerOn {
          Button("Stop timer") {
            viewStore.send(.toggleTimerButtonTapped)
          }
        } else {
          Button("Start timer") {
            viewStore.send(.toggleTimerButtonTapped)
          }
        }
      }
    }
  }
}
```

@T(00:16:43)
And just like that the view is compiling, and it is now being powered by a Composable Architecture feature.

@T(00:16:55)
It is worth noting that eventually we will be able to take advantage of the new tools in iOS 17 and Swift 5.9 to greatly simplify. In a future version of the Composable Architecture, and when you can target iOS 17, you will be able to entirely forget about the view store and just access state on the store and send actions:

```swift
struct ContentView: View {
  let store: StoreOf<CounterFeature>

  var body: some View {
    Form {
      Section {
        Text("\(self.store.count)")
        Button("Decrement") {
          self.store.send(.decrementButtonTapped)
        }
        Button("Increment") {
          self.store.send(.incrementButtonTapped)
        }
      }

      Section {
        Button("Get fact") {
          self.store.send(.getFactButtonTapped)
        }
        if let fact = self.store.fact {
          Text(fact)
        }
      }

      Section {
        if self.store.isTimerOn {
          Button("Stop timer") {
            self.store.send(.toggleTimerButtonTapped)
          }
        } else {
          Button("Start timer") {
            self.store.send(.toggleTimerButtonTapped)
          }
        }
      }
    }
  }
}
```

@T(00:17:30)
Internally SwiftUI can figure out what state you access in the view, and then only observe that state. It’s pretty amazing, and something to look forward to once you can target the newer platforms.

@T(00:17:44)
But, that’s the future, and we are stuck in the present, so let’s revert that.

@T(00:17:49)
Now the only compilation errors we have in the project are when constructing the `ContentView` because we now need to provide a store.

@T(00:17:59)
Let’s see what it takes to do that:

```swift
#Preview {
  ContentView(
    store: Store(
      initialState: <#State#>, 
      reducer: <#() -> Reducer#>
    )
  )
}
```

@T(00:18:04)
A store takes two arguments: the initial state to start the feature in, and a reducer that powers the logic of the feature, described as a trailing closure. Both arguments are easy enough to provide:

```swift
#Preview {
  ContentView(
    store: Store(initialState: CounterFeature.State()) {
      CounterFeature()
    }
  )
}
```

@T(00:18:30)
And we can do the same for the entry point of the application:

```swift
import ComposableArchitecture
import SwiftUI

@main
struct CounterApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(
          initialState: CounterFeature.State()
        ) {
          CounterFeature()
        }
      )
    }
  }
}
```

@T(00:18:40)
With that done we can run the preview or the app in the simulator to see that it that it partly works as we expect. We can count up and down, and we can toggle the timer button, but of course the timer doesn’t actually work. Nor does the “Get fact” functionality.

@T(00:19:08)
But before doing getting that to work we can quickly show off a super power of the library. Because all of the feature’s logic is modeled with value types and encapsulated in the reducer, we get an incredibly powerful tool for peering into everything happening on the inside.

@T(00:19:27)
All one has to do is tack on the `_printChanges` method to the reducer, like say in the preview:

```swift
#Preview {
  ContentView(
    store: Store(initialState: CounterFeature.State()) {
      CounterFeature()
        ._printChanges()
    }
  )
}
```

@T(00:19:36)
And then each action the reducer processes will print a nicely formatted string to the console letting you know exactly what happened.

@T(00:19:43)
For example, if we increment the count we see:

```diff
received action:
  CounterFeature.Action.incrementButtonTapped
  CounterFeature.State(
-   count: 0,
+   count: 1,
    fact: nil,
    isTimerOn: false
  )
```

…letting us know that the `incrementButtonTapped` action was received, and that the state changed by causing the `count` to go up by one. It even helpfully prints a diff of the state to draw our attention to exactly what changed.

@T(00:19:56)
And if we toggle the timer we get:

```diff
received action:
  CounterFeature.Action.toggleTimerButtonTapped
  CounterFeature.State(
    count: 1,
    fact: nil,
-   isTimerOn: false
+   isTimerOn: true
  )
```

…letting us know exactly what happened.

@T(00:20:03)
So this is pretty incredible. This is only possible thanks to the fact that we are modeling our domain with value types instead of reference types since value types have the specific property that you can copy them before a mutation and then compare the copy with the new value after the mutation. That is simply not possible with reference types, and so this tool cannot be provided in vanilla SwiftUI.

## Effects

@T(00:20:26)
So, we’ve now got a bit of footing when it comes to the Composable Architecture. You define a type that conforms to the `Reducer` protocol in order to model its domain and implement its logic and behavior. And then you integrate that reducer into your feature via a `Store`.

@T(00:20:39, Stephen)
But so far the logic in the feature is quite simple. In fact, it’s so simple that it really does not benefit from the abstractions provided by the Composable Architecture at all. The library really starts to shine once one wants to layer on behavior. That is, side effects. This is work that is typically async and needs to communicate with the outside world in order to feed data back into the system.

@T(00:20:58)
Our feature has two side effects, each quite unique. The first needs to make a network request to an external API for loading a random fact about a number. And the second needs to perform time-based asynchrony for starting a timer to increment the counter.

@T(00:21:12)
Let’s see what it takes to implement each of these.

@T(00:21:16)
Let’s start with the number fact. The fundamental way one introduces a side effect to a reducer is to return what is known as an `Effect` from the reduce closure:

```swift
case .getFactButtonTapped:
  return Effect.<#⎋#>
```

@T(00:21:27)
The library comes with a few helpers for constructing effects, and the most general is the `run` effect:

```swift
case .getFactButtonTapped:
  return .run(
    operation: <#(Send<Action>) async throws -> Void#>
  )
```

@T(00:21:36)
This creates an effect via a single trailing closure. The closure is handed a `send` value that is capable of sending actions back into the system, and the closure provides you an asynchronous context to perform work in. 

```swift
case .getFactButtonTapped:
  return .run { send in

  }
```

@T(00:21:51)
The work we want to perform is to execute a network request to an external service called the “[Numbers API](http://www.numbersapi.com)”. You can simply load a URL like <http://www.numbersapi.com/42> in a browser, and you get back a string with a fact about that number:

```
42 is the number of kilometers in a marathon.
```

@T(00:22:06)
So, we could try constructing a URL for the numbers API with the count and then try loading the URL with `URLSession`'s async/await API:

```swift
case .getFactButtonTapped:
  return .run { send in
    try await URLSession.shared.data(
      from: URL(
        string: "http://www.numbersapi.com/\(state.count)"
      )!
    )
  }
```

@T(00:22:28)
However this does lead to a compiler error:

> Error: Mutable capture of 'inout' parameter 'state' is not allowed in concurrently-executing code

@T(00:22:35)
And that’s because it is not allowed to capture an `inout` variable in a sendable closure. So we have to capture the `count` at the moment of creating the effect:

```swift
case .getFactButtonTapped:
  return .run { [count = state.count] send in
    try await URLSession.shared.data(
      from: URL(
        string: "http://www.numbersapi.com/\(count)"
      )!
    )
  }
```

@T(00:22:43)
…and then it works.

@T(00:22:45)
That method returns both data and a response, so we can destructure the data from that tuple:

```swift
case .getFactButtonTapped:
  return .run { [count = state.count] send in
    let (data, _) = try await URLSession.shared.data(
      from: URL(
        string: "http://www.numbersapi.com/\(count)"
      )!
    )
  }
```

@T(00:22:53)
And we can decode that data into a string

```swift
let fact = String(decoding: data, as: UTF8.self)
```

@T(00:23:02)
This is now the fact that we want to show in the UI. We can even print it:

```swift
print(fact)
```

@T(00:23:07)
And now when we run the preview, count up a few times, and get a fact, we see the following printed to the console:

```
3 is the number of spatial dimensions we perceive our universe to have.
```

@T(00:23:19)
Note that we did a little bit of upfront work in the project settings for this to work, since the numbers API uses HTTP and not HTTPS.

@T(00:23:30)
So, the effect does seem to be working, but how can we get that data back into the state of the feature so that it can be displayed in the view? We can’t simply mutate state right in the effect:

```swift
state.fact = fact
```

@T(00:23:43)
…because we get that same error about `inout` state in a concurrently-executing context:

> Error: Mutable capture of 'inout' parameter 'state' is not allowed in concurrently-executing code

@T(00:23:48)
This is simply the cost of dealing with value types in Swift. They are extremely easy to understand and provide great guarantees, but also they cannot be simply mutated from anywhere you want like reference types. There are rules you have to follow.

@T(00:23:59)
So, instead of trying to mutate the state directly in the effect, we can send a whole new action back into the system. That will allow the reducer to react to the action, and then it can mutate state or even execute more effects.

@T(00:24:12)
So, let’s add a new `Action` case that can be used to send the fact response back into the system:

```swift
enum Action {
  case factResponse(String)
  …
```

@T(00:24:25)
Typically we would want to also handle errors, but in the interesting of keeping things simple we aren't going to worry about that for now.

@T(00:24:31)
That immediately causes a compilation error, which can be fixed by handling this new action in our `switch`:

```swift
case let .factResponse(fact):
  state.fact = fact
  return .none
```

@T(00:24:49)
And then we can send this new action from the effect by using the `send` value provided to the trailing closure of the effect:

```swift
case .getFactButtonTapped:
  return .run { [count = state.count] send in
    let (data, _) = try await URLSession.shared.data(
      from: URL(
        string: "http://www.numbersapi.com/\(count)"
      )!
    )
    let fact = String(decoding: data, as: UTF8.self)
    await send(.factResponse(fact))
  }
```

@T(00:25:05)
That is all it takes. We can now count up to a number, tap “Get fact”, and we will immediately see the fact populated in the view.

@T(00:25:14)
We can even improve this a bit. Let’s also clear out the fact whenever we change the `count` or when we get a new fact:

```swift
case .decrementButtonTapped:
  state.count -= 1
  state.fact = nil
  return .none
…
case .getFactButtonTapped:
  state.fact = nil
  return .run { [count = state.count] send in
    let (data, _) = try await URLSession.shared.data(
      from: URL(
        string: "http://www.numbersapi.com/\(count)"
      )!
    )
    let fact = String(decoding: data, as: UTF8.self)
    await send(.factResponse(fact))
  }

case .incrementButtonTapped:
  state.count += 1
  state.fact = nil
  return .none
…
```

@T(00:25:35)
That way we don’t see a fact about an old number.

@T(00:25:43)
Also let’s improve the user experience of this behavior by adding a loading indicator. If the request took a long time, there would be nothing on the screen to let us know that something is loading.

@T(00:25:57)
For example, let’s add a sleep to the effect to simulate that:

```swift
return .run { [count = state.count] send in
  try await Task.sleep(for: .seconds(1))
  …
}
```

@T(00:26:13)
Now when we tap “Get fact” in the preview we see nothing happening until a moment later the fact magically appears.

@T(00:26:21)
To improve this we will add some state to our feature to track whether or not the fact is loading:

```swift
struct State: Equatable {
  var isLoadingFact = false
  …
}
```

@T(00:26:29)
And then we will toggle it on and off in the reducer:

```swift
case let .factResponse(fact):
  state.fact = fact
  state.isLoadingFact = false
  return .none

case .getFactButtonTapped:
  state.fact = nil
  state.isLoadingFact = true
  …
```

@T(00:26:41)
And finally we will use that state to figure out if we should should show a progress indicator in the view:

```swift
Button {
  viewStore.send(.getFactButtonTapped)
} label: {
  HStack {
    Text("Get fact")
    if viewStore.isLoadingFact {
      Spacer()
      ProgressView()
    }
  }
}
```

@T(00:26:57)
And now we have massively improved the user experience for this feature. While the user is waiting for a fact to come back from the network they will see a progress indicator letting them know something is happening in the background.

@T(00:27:07)
OK, that’s one effect down, one to go. Next we have the timer. Here we have two different kinds of effects. When toggling on we want to start a timer, but when toggling off we need to somehow stop the timer:

```swift
case .toggleTimerButtonTapped:
  state.isTimerOn.toggle()
  if state.isTimerOn {
    // Start the timer
  } else {
    // Stop the timer
    return .none
  }
```

@T(00:27:29)
We will handle each of these cases separately.

@T(00:27:31)
To start the timer we need an asynchronous context so that we can send actions back into the system at an interval, so sounds like we need to spin up another `run` effect:

```swift
if state.isTimerOn {
  return .run { send in

  }
```

@T(00:27:42)
And in this effect we can start up an infinite loop with a `Task.sleep` on the inside in order to simulate a timer:

```swift
return .run { send in
  while true {
    try await Task.sleep(for: .seconds(1))
  }
}
```

@T(00:27:51)
And each time we get past the sleep we want to increment the count by 1, but of course we can’t do that directly:

```swift:2:fail
try await Task.sleep(for: .seconds(1))
state.count += 1
```

@T(00:28:00)
Instead we need to send an action into the system so that the reducer can react, and so let’s add another case to the `Action` enum:

```swift
enum Action {
  …
  case timerTicked
}
```

@T(00:28:28)
And we can send that action from the effect:

```swift
try await Task.sleep(for: .seconds(1))
await send(.timerTicked)
```

@T(00:28:33)
And we can implement the logic for that new action:

```swift
case .timerTicked:
  state.count += 1
  return .none
```

@T(00:28:48)
With that we have a very basic timer implemented. We can start the timer and see the count go up every second. However, stopping the timer doesn’t do anything yet.

@T(00:28:59)
To accomplish this we will make use of a powerful feature of the Composable Architecture, and that is effect cancellation. You can mark any effect as being cancellable by providing it some kind of hashable identifier:

```swift
return .run { send in
  …
}
.cancellable(id: <#Hashable#>)
```

@T(00:29:13)
And then at a later time in the reducer you can cancel the effect via its identifier.

@T(00:29:16)
Now any hashable value will work for the identifier, even just a string:

```swift
.cancellable(id: "timer")
```

@T(00:29:21)
But that is prone to typos and mistakes.

@T(00:29:24)
Another thing you can do is define a dedicated, but private, enum type for holding your various cancellation identifiers:

```swift
private enum CancelID { case timer }
```

@T(00:29:37)
…and use that:

```swift
.cancellable(id: CancelID.timer)
```

@T(00:29:46)
So, that marks the timer effect as being cancellable, but how do you actually cancel it?

@T(00:29:51)
Well, there is a special kind of effect you can return to cancel any effect by its ID:

```swift
if state.isTimerOn {
  …
} else {
  return .cancel(id: CancelID.timer)
}
```

@T(00:30:03)
That’s all it takes, and now we see we can start and stop the timer.

## Testing

@T(00:30:11)
We have now built up a somewhat complex little feature. It’s not the most impressive thing, but it does have some of the basic shapes of problems that we encounter in our everyday work. It has a side effect that makes a network request. It has a long living effect that needs to be cancelled at a later time. And it manages a decent amount of state with some nuanced logic.

@T(00:30:27)
So, we could stop here and say “that’s the basics of the Composable Architecture, time to start rebuilding Apple’s Scrumdinger application!”

@T(00:30:34, Brandon)
However, that would be a huge mistake. We still haven’t discussed what we consider to be the #1 most powerful feature of the Composable Architecture, and that is its testing capabilities. Unit testing code isn’t super popular in the iOS community, and we think that’s a bummer. Testing is a great barometer to measure the quality of your code. If you can construct your objects and exercise their full logic in complete isolation without needing to rely on external systems or without having to jump through a bunch of hoops to get everything set up, then your code is most likely well decoupled.

@T(00:31:06)
One of the biggest problems with testing is where to start. Often when we code up our applications in the most direct and naive way, and even if we follow Apple’s tutorials and sample code, we are left with a codebase that is difficult to exercise in tests. However, features built in the Composable Architecture are incredibly easy to test. And even when you come across something that is difficult to test, it gives you the tools necessary to make it more testable.

@T(00:31:31)
So, let’s see how much of our feature we can test right off the bat, and then see what needs a little bit of work to make more testable.

@T(00:31:42)
I’ve got a blank test file open right now, and let’s create a new method for testing just the basic counter logic of the feature:

```swift
func testCounter() async {
}
```

@T(00:31:50)
It is marked as `async` because typically testing a Composable Architecture feature involves effects, and so all of the test helpers in the library are async.

@T(00:31:59)
Also for now tests are required to run on the main thread, and so let’s annotate the test with `@MainActor`:

```swift
@MainActor
final class CounterTests: XCTestCase {
  …
}
```

@T(00:32:05)
The first step to writing a test built in the Composable Architecture is to construct what is known as a test store:

```swift
let store = TestStore(
  initialState: <#_#>, reducer: <#() -> Reducer#>
)
```

@T(00:32:17)
It is constructed in the same way as a regular store, meaning it takes some initial state and the reducer that powers the feature, but it serves a different purpose.

@T(00:32:36)
The `TestStore` allows you to send actions to it and assert how state changes when done, but it also monitors how effects execute in the system and allows you to assert how those actions execute and feed data back into the system. It gives you a very complete view into how the system evolves over time, and it is your responsibility to assert on everything, otherwise you get a test failure.

So, let’s create a test store for the counter feature:

```swift
let store = TestStore(
  initialState: CounterFeature.State()
) {
  CounterFeature()
}
```

@T(00:33:07)
With the test store created we can emulate a sequence of actions the user does in the feature, and then assert how state changes each step of the way.

@T(00:33:19)
For example, we can emulate them tapping on the “Increment” button:

```swift
await store.send(.incrementButtonTapped)
```

@T(00:33:28)
To assert how state changes after that action is sent we can provide a trailing closure to `send`:

```swift
await store.send(.incrementButtonTapped) {
  $0
}
```

@T(00:33:34)
And in this closure `$0` represents the state of the feature *before* the action was sent. It is then our job to mutate `$0` to be in the exact state of the feature *after* the action was sent. If anything doesn’t match we will get a test failure.

@T(00:33:52)
For example, let’s not perform any mutations whatsoever and run the test as-is. We immediately get a test failure letting us know exactly what went wrong:

> Failed: A state change does not match expectation: …
>
> ```
>   CounterFeature.State(
> −   count: 0,
> +   count: 1,
>     fact: nil,
>     isLoadingFact: false,
>     isTimerOn: false
>   )
> ```
>
> (Expected: −, Actual: +)

This is a nicely formatted test failure pointing out the exact state that did not match. Our expectation was that the count was 0 (because we didn’t mutate `$0` at all), but in actuality it was 1.

@T(00:34:05)
To fix this we need to mutate `$0` to make its `count` 1:

```swift
await store.send(.incrementButtonTapped) {
  $0.count = 1
}
```

@T(00:34:14)
Now the test passes.

@T(00:34:16)
And just like that we have the very first test of our feature. The reason this test was so easy to write, and the reason why we get such great test failures when something goes wrong, is because our feature is entirely built with value types. Such types are incredibly easy to write tests against because they are just data, and thanks to their ability to be easily copied around we can provide the nice trailing closure syntax for asserting, and we can diff old and new values to produce a nice test failure message.

@T(00:34:54)
Things would not be so nice if we were using reference types. We wouldn’t be able to get a copy of the state before and after the action was sent so that we could perform an exhaustive asserting on everything that changed when the action was sent. The best we could do is assert on each field we care about:

```swift
XCTAssertEqual(store.state.count, 1)
```

@T(00:35:17)
…but if any other fields changed we would not be asserting on that. It is on us to remember to assert against all of the fields, and that is just not possible in practice. For example, what if new fields are added? Are you going to go back to every test you ever wrote to assert on those new fields? Not likely.

@T(00:35:40)
So, this is great, but also we are *barely* flexing the muscles that the library has for testing. Let’s test something more interesting, like timer. We’ll get a stub of a test into place that constructs a test store:

```swift
func testTimer() async {
  let store = TestStore(
    initialState: CounterFeature.State()
  ) {
    CounterFeature()
  }
}
```

@T(00:36:01)
Then we’ll send the `toggleTimerButtonTapped` action, and the only state change we expect to happen is for the `isTimerOn` boolean to flip to true:

```swift
await store.send(.toggleTimerButtonTapped) {
  $0.isTimerOn = true
}
```

@T(00:36:18)
Seems simple enough, but if we run this test we get a failure:

> Failed: An effect returned for this action is still running. It must complete before the end of the test. …
>
> To fix, inspect any effects the reducer returns for this action and ensure that all of them complete by the end of the test. There are a few reasons why an effect may not have completed:
>
>   * If using async/await in your effect, it may need a little bit of time to properly finish. To fix you can simply perform "await store.finish()" at the end of your test.
> 
>   * If an effect uses a clock/scheduler (via "receive(on:)", "delay", "debounce", etc.), make sure that you wait enough time for it to perform the effect. If you are using a test clock/scheduler, advance it so that the effects may complete, or consider using an immediate clock/scheduler to immediately perform the effect instead.
>
>   * If you are returning a long-living effect (timers, notifications, subjects, etc.), then make sure those effects are torn down by marking the effect ".cancellable" and returning a corresponding cancellation effect ("Effect.cancel") from another action, or, if your effect is driven by a Combine subject, send it a completion.

@T(00:36:22)
This is an amazing test failure to have. It is letting us know that the test store detected an effect still in flight when the test ended, and that is not OK. If the test store silently ignored this, then we may be hiding a bug in our feature. Maybe we thought we had cancelled this effect and so we would want to know if it was still running. Or maybe the effect feeds data back into the system, and the logic for those actions has a bug. We would want to assert on all of that.

@T(00:36:59)
So, we have to make sure all effects finish before the test is done, and the simplest way to do that would be to send the `toggleTimerButtonTapped` action again:

```swift
await store.send(.toggleTimerButtonTapped) {
  $0.isTimerOn = false
}
```

@T(00:37:14)
And now the test passes, but also we aren’t really testing much about the timer. How can we assert that when we wait a second we receive a `timerTicked` action?

@T(00:37:34)
Well, because we are using `Task.sleep` in the effect we have no choice but to wait for real time to pass before the effect emits an action:

```swift
try await Task.sleep(for: .milliseconds(1_100))
```

@T(00:37:52)
And because `Task.sleep` is not an exact tool, we should wait a little more than 1 second just to be safe.

@T(00:38:05)
And after that time passes we can assert that the test store received an action from an effect by using the `receive` method:

```swift
await store.receive
```

@T(00:38:16)
However, in order to use this method we need the `Action` enum to conform to `Equatable` so that we can assert on exactly what action was received:

```swift
await store.receive(.timerTicked)
```

@T(00:38:44)
If we just leave it like that and run the test we of course get a failure:

> Failed: State was not expected to change, but a change occurred: …
>
> ```
>   CounterFeature.State(
> −   count: 0,
> +   count: 1,
>     fact: nil,
>     isLoadingFact: false,
>     isTimerOn: true
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:38:50)
…and that’s because we didn’t assert on how state will change. We expect the count to go up by one, so let’s do that:

```swift
await store.receive(.timerTicked) {
  $0.count = 1
}
```

@T(00:39:06)
And now this passes. And we can do it again to make sure we get a second tick of the timer:

```swift
try await Task.sleep(for: .milliseconds(1_100))
await store.receive(.timerTicked) {
  $0.count = 2
}
```

@T(00:39:14)
The test still passes, but also the test is quite slow now:

```
Test Suite 'Selected tests' passed.
Executed 1 test, with 0 failures (0 unexpected) in 2.255 (2.257) seconds
```

@T(00:39:55)
It takes over 2 seconds to run the test. And what if the behavior we wanted to test required us to wait for 10 timer ticks. Would we really wait around for 10 seconds just so that this test could run?

@T(00:40:19)
Luckily there is a much better way of handling this, and it brings us to a very important topic in the Composable Architecture, and that’s dependencies.

@T(00:40:27)
A dependency is a piece of code that needs to talk to an external system that you do not control. For example, `Task.sleep` is a dependency because it suspends while real world time passes by. Dependencies can wreak havoc on your code base. They make it difficult to run your features in isolation, such as previews, and they make it difficult to test your code.

@T(00:40:46)
The way one takes back control over this dependency is to use the `Clock` protocol instead of `Task.sleep` directly. That way when you run the feature in a simulator or on device you can use the live, continuous clock, but in tests you can use something more suitable for testing, such as an immediate clock or a test clock.

@T(00:41:04)
One way you could use a clock in the feature is to have the reducer literally hold onto a clock:

```swift
let clock: any Clock<Duration> 
```

@T(00:41:17)
Then whoever constructs the reducer would be responsible for passing in a clock. They could choose what kind of clock they want to use.

@T(00:41:24)
However, providing dependencies explicitly like this to features can be problematic. It isn’t very ergonomic because if a leaf feature deep in your application needs a dependency, then every feature up the chain to the root will need to also hold onto the dependency just so that it can pass it down. 

@T(00:41:45)
And because of this many people provide defaults so that you don’t have to explicitly pass in the dependency:

```swift
let clock: any Clock<Duration> = ContinuousClock()
```

@T(00:41:58)
But then this isn’t very safe because it will be possible for different parts of your application to be using different dependencies since you decided to not explicitly pass them around.

@T(00:42:09)
Overall, this is just a bad way of dealing with dependencies. And luckily the Composable Architecture is tightly integrated with [our dependency management](https://github.com/pointfreeco/swift-dependencies) library that we opened sourced many months ago.

@T(00:42:20)
You simply declared your dependency using the `@Dependency` property wrapper and provide a key path that singles out which dependency you want to use:

```swift
@Dependency(\.<#⎋#>) 
```

@T(00:42:30)
And amazingly the Composable Architecture already comes with some base dependencies that are very common to use in applications, such as clocks, date generators, UUID generators, and more.

@T(00:42:40)
We can declare our dependency on a clock like so:

```swift
@Dependency(\.continuousClock) var clock
```

@T(00:42:42)
And then rather than reaching for `Task.sleep` we can perform `clock.sleep`:

```swift
try await self.clock.sleep(for: .seconds(1))
```

@T(00:43:01)
Now we have a fighting chance and testing this code without waiting for real time to pass because in tests we can pass along a different kind of clock.

@T(00:43:21)
But, before doing that, we can improve this because our libraries provide a convenience method on clocks for creating an async sequence that represents a timer:

```swift
for await _ in self.clock.timer(interval: .seconds(1)) {
  await send(.timerTicked)
}
```

@T(00:43:55)
That’s much simpler, and this method is far more accurate than `Task.sleep` as it adjusts how long it suspends based on how much drift has occurred.

@T(00:43:59)
As our feature has grown more complex, it's interesting to draw the parallels between building features in the Composable Architecture and building views in SwiftUI:

  * You define a `body` property for composing reducers or views together
  * You declare `@Dependency` or `@Environment` properties to access dependencies deep in the hierarchy

@T(00:44:40)
OK, with that change the feature works exactly as it did before in the preview and simulator, but now we can do something new in tests. First, if we run the test with no further changes we see a bunch of errors:

> Failed: testTimer(): Unimplemented: ContinuousClock.now …

> Failed: testTimer(): Unimplemented: ContinuousClock.sleep …

@T(00:45:00)
These failures are also really great to have. They let us know that we are accessing a dependency in tests without having overridden them in the test. This keeps you from accidentally accessing live dependencies in tests, which may lead you to accidentally making network requests, or tracking analytics, or as is the case with this test, slowing down the test suite.

@T(00:45:22)
So, what we need to do is override the `continuousClock` dependency on our test store, and we can do so with what is known as a `TestClock`:

```swift
let clock = TestClock()
let store = TestStore(
  initialState: CounterFeature.State()
) {
  CounterFeature()
} withDependencies: {
  $0.continuousClock = clock
}
```

@T(00:45:56)
A test clock is one in which when you tell it to sleep it suspends forever, until you explicitly advance its internal time forward.

@T(00:46:02)
So now, instead of performing `Task.sleep` in the test we can tell the clock to advance by 1 second:

```swift
await store.send(.toggleTimerButtonTapped) {
  $0.isTimerOn = true
}
await clock.advance(by: .seconds(1))
await store.receive(.timerTicked) {
  $0.count = 1
}
await clock.advance(by: .seconds(1))
await store.receive(.timerTicked) {
  $0.count = 2
}
await store.send(.toggleTimerButtonTapped) {
  $0.isTimerOn = false
}
```

@T(00:46:18)
That’s all it takes, and the test still passes, but now does so in a tiny fraction of a second:

```
Test Suite 'Selected tests' passed.
Executed 1 test, with 0 failures (0 unexpected) in 0.042 (0.044) seconds
```

@T(00:46:25)
In fact the test now runs over 60 times faster than it did previously. And if we ever did need to write a test where we let the timer tick for dozens or hundreds of times, we wouldn’t have to be afraid of literally waiting for real world time to pass. We can just tell the test clock to advance however many seconds we want, and the test should zip right on by.

@T(00:46:44, Stephen)
Let’s move on to the last bit of unit testing functionality in the feature, which is loading a fact for a number. That functionality requires making a network request to an external service that we do not control, and so it will be interesting to see how we can do this.

@T(00:46:59)
Let’s start with a new method for testing the “Get fact” behavior and we will construct a test store:

```swift
func testGetFact() async {
  let store = TestStore(
    initialState: CounterFeature.State()
  ) {
    CounterFeature()
  }
}
```

@T(00:47:14)
Then we will emulate the user tapping on the “Get fact” button:

```swift
await store.send(.getFactButtonTapped) 
```

@T(00:47:24)
And what do we expect to happen? Well, immediately there is some state that should change:

```swift
await store.send(.getFactButtonTapped) {
  $0.isLoadingFact = true
}
```

@T(00:47:34)
And then also some time later we should receive an action with the fact response causing the `isLoadingFact` boolean to flip back to false:

```swift
await store.receive(.factResponse("???")) {
  $0.isLoadingFact = false
}
```

@T(00:47:54)
But what fact do we expect to receive? This data is being loaded from an external API service that we do not control, and so they could send anything back to us. There’s no way to predict.

@T(00:48:04)
In fact, let’s run this just to see what happens…

@T(00:48:08)
Well, we actually get a few test failures:

> Failed: testGetFact(): Unimplemented: ContinuousClock.now …

> Failed: testGetFact(): Unimplemented: ContinuousClock.sleep …

> Failed: An effect returned for this action is still running. It must complete before the end of the test. …

> Failed: Expected to receive an action, but received none after 0.1 seconds.

@T(00:48:11)
The first two are easy enough to fix, we just need to override our clock dependency, but instead of using a test clock that we need to specifically advance we can use what is called an "immediate" clock that automatically advances time whenever it's told to sleep:

```swift
let store = TestStore(
  initialState: CounterFeature.State()
) {
  CounterFeature()
} withDependencies: {
  $0.continuousClock = ImmediateClock()
}
```

@T(00:48:33)
And if we re-run things, we get a different test failure:

> Failed: Received unexpected action: …
>
> ```
>   CounterFeature.Action.factResponse(
>     """
> −   ???
> +   0 is the atomic number of the theoretical element tetraneutron.
>     """
>   )
> ```
>
> (Expected: −, Received: +)

@T(00:48:41)
This lets us know we said we were receiving one action but we actually received a different one. And this is failing because the number fact API returned an actual fact, and so we do need to account for that in the assertion. I guess we can just hard code it:

```swift
await store.receive(
  .factResponse(
    """
    0 is the atomic number of the \
    theoretical element tetraneutron.
    """
  )
) {
  $0.isLoadingFact = false
  $0.fact = """
    0 is the atomic number of the \
    theoretical element tetraneutron.
    """
}
```

@T(00:48:54)
Hm, but this failed again:

> Failed: Received unexpected action: …
>
> ```
>   CounterFeature.Action.factResponse(
>     """
>     0 is the \
> −   atomic number of the theoretical element tetraneutron
> +   coldest possible temperature old the Kelvin scale
>     """
>   )"
> ```
>
> (Expected: −, Received: +)

@T(00:48:59)
Now it’s failing because we said we received a fact about the atomic number, but this time we got a completely different fact back from the API. Something about the Kelvin temperature scale.

@T(00:49:04)
This is the problem with use dependencies that talk to the outside world that we cannot control. We simply cannot write a test for this feature because there is no way to predict what the numbers API is going to send back to us.

@T(00:49:14)
And really we don’t care about testing the numbers API works as expected. That’s an external service that we do not control. For the purpose of this test it would be fine to assume that the numbers API works perfectly and sends us back some specific data so that we can then see how that data feeds into the system and affects our feature’s state.

@T(00:49:31)
Well, we can do this, and we just have to take back control over this dependency rather than letting it control us. We will do this by putting an interface in front of the work to fetch a fact for a number. This will allow us to make a network request when running in a preview or simulator, but we can choose to do something else for tests.

@T(00:49:46)
I will construct this interface as a simple struct that holds onto a closure property for the endpoint to fetch a fact:

```swift
struct NumberFactClient {
  var fetch: @Sendable (Int) async throws -> String
}
```

@T(00:50:12)
Now you may find it a little weird that we are using a struct here. Perhaps the most common way to put an interface in front of a dependency would be a protocol, but that is not the only way. There are a lot of pros and cons to consider for using either a struct or a protocol for dependencies, and we have a lot of [episodes about that](/collections/protocol-witnesses) on Point-Free that we highly encourage you to watch, but for now we are just going to go with this.

@T(00:50:31)
Now that we have the client defined I would love if there was some easy way to provide a `NumberFactClient` to the `CounterFeature` reducer. Maybe we could even use the `@Dependency` property wrapper like we did for the clock:

```swift
@Dependency(\.continuousClock) var clock
@Dependency(\.numberFact) var numberFact
```

@T(00:50:48)
In order for this kind of syntax to work we need to register the `NumberFactClient` with the dependency management system. One does this by first conforming the client to a protocol called `DependencyKey`:

```swift
extension NumberFactClient: DependencyKey {
}
```

@T(00:51:07)
And the primary requirement of this protocol is that you provide a `liveValue` with represents the version of the dependency to use in “live” situations, such as the previews, simulators and devices. This means it’s appropriate to perform a network request to the numbers API:

```swift
extension NumberFactClient: DependencyKey {
  static let liveValue = Self(
    fetch: { number in
      let (data, _) = try await URLSession.shared.data(
        from: URL(
          string: "http://www.numbersapi.com/\(number)"
        )!
      )
      return String(decoding: data, as: UTF8.self)
    }
  )
}
```

@T(00:51:54)
And the second step is to then add a computed property to the `DependencyValues` type, which will give us access to the key path in the `@Dependency` property wrapper:

```swift
extension DependencyValues {
  var numberFact: NumberFactClient {
    get { self[NumberFactClient.self] }
    set { self[NumberFactClient.self] = newValue }
  }
}
```

@T(00:52:29)
That’s all it takes to register the dependency with the library, and it’s worth mentioning that these steps aren’t much different from how one adds environment values to SwiftUI.

With that done this syntax is now compiling:

```swift
@Dependency(\.numberFact) var numberFact
```

@T(00:52:40)
And we can start using it in the reducer rather than calling out to the global, uncontrolled `URLSession` API:

```swift
return .run { [count = state.count] send in
  try await send(.factResponse(numberFact.fetch(count)))
}
```

@T(00:53:01)
We now have a fighting chance at writing that test.

@T(00:53:03)
First, let’s run the test without making any changes. We get a test failure:

> Failed: testGetFact(): @Dependency(\.numberFact) has no test implementation, but was accessed from a test context:
>
> ```
> Location:
>   Counter/ContentView.swift:41
> Dependency:
>   NumberFactClient
> ```
>
> Dependencies registered with the library are not allowed to use their default, live implementations when run from tests.

@T(00:53:19)
…letting us know that we are using a live dependency in a testing context. This is a great test failure to have because it prevents us from accidentally making a network request in a test when we don’t mean to.

@T(00:53:25)
So, what we want to do is override the `numberFact` dependency on this test store so that we can do something besides reaching out to the network:

```swift
let store = TestStore(
  initialState: CounterFeature.State()
) {
  CounterFeature()
} withDependencies: {
  $0.numberFact = <#???#>
}
```

@T(00:53:44)
But what do we do?

@T(00:53:45)
Well, thanks to our decision to model this dependency as a struct instead of a protocol we can simply override the `fetch` endpoint to provide a closure that synchronously and immediately returns some data:

```swift
let store = TestStore(
  initialState: CounterFeature.State()
) {
  CounterFeature()
} withDependencies: {
  $0.numberFact.fetch = { "\($0) is a great number!" }
}
```

@T(00:54:15)
This is us saying that we don’t want to interact with the numbers API at all. We just want to pretend that that service is working perfectly fine, and so we will emulate it by immediately returning a string.

@T(00:54:25)
And with that we can assert against the action we expect to receive and how state changes:

```swift
await store.send(.getFactButtonTapped) {
  $0.isLoadingFact = true
}
await store.receive(
  .factResponse("0 is a great number!")
) {
  $0.isLoadingFact = false
  $0.fact = "0 is a great number!"
}
```

@T(00:54:44)
This test passes, and runs in a tiny fraction of a second:

```
Test Suite 'Selected tests' passed.
Executed 1 test, with 0 failures (0 unexpected) in 0.023 (0.025) seconds
```

@T(00:54:47)
And it will pass 100% of the time, no matter how many times we run it. There’s no need to make a real life network request just to get test coverage on how our feature behaves when it tries loading a fact for a number.

@T(00:54:58)
We can write tests for unhappy paths in the feature, such as what happens when the `fetch` endpoint throws an error instead of returning a string:

```swift
func testGetFact_Failure() async {
  let store = TestStore(
    initialState: CounterFeature.State()
  ) {
    CounterFeature()
  } withDependencies: {
    $0.numberFact.fetch = { _ in
      struct SomeError: Error {}
      throw SomeError()
    }
  }
}
```

@T(00:55:12)
If you will remember we are currently not handling any errors in the reducer, and so we expect when we send the `getFactButtonTapped` action that no effect action will be received:

```swift
await store.send(.getFactButtonTapped) {
  $0.isLoadingFact = true
}
```

@T(00:55:32)
This mostly passes, but there is one failure:

> Failed: testGetFact_Failure(): An "Effect.run" returned from "Counter/ContentView.swift:58" threw an unhandled error. …
>
> ```
> CounterTests.SomeError()
> ```
>
> All non-cancellation errors must be explicitly handled via the "catch" parameter on "Effect.run", or via a "do" block.

@T(00:55:39)
This is specifically calling out the fact that we are not handling errors in our effect. And this is a good test failure to have, because it is also showing that if the numbers API ever does fail then we are not cleaning up the `isFactLoading` state. It will remain true, and so the progress indicator will be stuck as visible even though nothing is loading anymore.

@T(00:55:57)
So, there is no way to get this test to pass unless we start actually doing some error handling, but we won’t worry about that for now, and so I’ll force this to pass by telling XCTest that we expect a failure here:

```swift
XCTExpectFailure()
```

@T(00:56:11)
Now the test passes.

## Next time: tour of Scrumdinger

@T(00:56:16)
OK, so that concludes our “soft” landing into the Composable Architecture, though we did end up exploring quite a few advanced topics already. We implemented a few side effects, including a network request and a timer, and we already came face-to-face with the gnarly beast known as “dependencies.” They can wreak havoc on your code, and they made it very difficult for us to unit test our application, and so we saw what it takes to control our dependencies rather than letting them control us.

@T(00:56:38, Brandon)
And so we are now going to move on to explore Apple’s Scrumdinger application, but we also want all of our viewers to know that the Composable Architecture repo comes with lots of [demos and case studies](https://github.com/pointfreeco/swift-composable-architecture#examples) that explore other kinds of problems one faces day-to-day. We highly encourage our viewers to check out those examples to get even more comfortable with the foundations of the library.

@T(00:56:58)
We are going to start by giving a tour of the Scrumdinger application so that everyone knows what is we will be building.

@T(00:57:06)
So, let’s get started…next time!
