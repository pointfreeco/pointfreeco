## Introduction

> Correction: This episode was recorded with Xcode 11 beta 3, and a lot has changed in recent betas. While we note these changes inline below, we also went over them in detail [on our blog](/blog/posts/30-swiftui-and-state-management-corrections).

@T(00:00:05)
Today we are going to begin discussing some application architecture ideas, which somehow in the one and a half years since Point-Free was launched we haven't really discussed head-on. We've covered lots of broad ideas on how to make your applications more understandable and testable, such as pushing side effects to the boundaries, using pure functions as much as possible, and putting an emphasis on functions and composition above all other abstractions.

@T(00:00:37)
So, with the foundations of functional programming firmly rooted in everyone's mind, we can now begin discussing how to glue all of those ideas into a cohesive story on architecting large, complex applications. But, before we do that we need to explore the problem space a bit, and see what kind of challenges we encounter when we try to create even a moderately complex application. There isn't going to be a lot of functional programming in these next episodes because we need to properly set the stage so that we can see what functional programming has to say about architecture.

@T(00:01:03)
So, in these next episodes we are going to start building an application that exemplifies many of the complications that pop up in application development. It will have some state that needs to be manipulated and persisted, it will involve loading data from an API request and showing an alert, and it will have multiple screens that all need to make mutations to the global app state. Having an opinionated and consistent way to do these tasks is essential to creating a scalable architecture that can be maintained for a long time, whether you are a solo developer or on a large team.

@T(00:01:32)
We've decided to do this application in SwiftUI using Swift 5.1 and the Xcode 11 beta, but all of the problems we are discussing equally apply to UIKit applications too. We've chosen SwiftUI because Apple is taking a bit of a stronger stance on how one should architect their app than they have historically done with UIKit. This gives us the perfect opportunity to understand why architecture is important and how we can leverage the tools that Apple gives us to adopt an architecture that suits our needs.

@T(00:02:17)
It's also worth noting that we are not doing a comprehensive exploration of how SwiftUI works, we are only going to describe as much as we need to get the application going. We will explain in detail the parts of SwiftUI we use, but some things will be deferred for deeper dives in future episodes.

## A tour of the application

@T(00:02:47)
So, let's get started:

@T(00:02:53)
It's a counting app that allows you to check if a number is prime (that is, a number that is only divisible by 1 and itself), and if it is you can save or remove it from your list of favorite primes. You can also ask it to compute the "nth" prime, and this is actually doing an API request to Wolfram Alpha, a scientific computing API. We can also go back and see our entire list of favorite primes, and remove any if we want. We haven't done any styling in this application because we want to entirely focus on the complexities of how data moves through this application.

@T(00:04:23)
This of course isn't a super real-world example of an application, it's more of a toy, but it gets at the heart of a lot problems that we need to solve in any architecture for an application:

@T(00:04:32)
- There is lots of state that changes the display of the UI. For example, pressing a button causes a modal to come up, and the contents of that modal is dependent on what happened on the previous screen, and we've got this button that triggers a network request where we want to disable the button while the request is in-flight.

@T(00:04:58)
- There is state that must be persisted across multiple screens (in this case it's the list of favorite primes, because we need it in the modal that says whether to add or remove the prime, and we need it in the list view of all the primes that are our favorites).

@T(00:05:11)
- There are lots of little sub-components that need to be pieced together to make the app as a whole. We'd love if each of these screens could be developed in isolation without them knowing anything about the larger application, possibly even put them in their own Swift package.

@T(00:05:36)
- There are side effects happening, in particular the API request that happens when we want to compute the "nth" prime. We'd like to have an opinionated way of introducing such effects into our views so that we aren't just sprinkling network calls everywhere. Doing that makes it hard to understand how the data is flowing through our application, and makes the view harder to test.

## The navigation screen

@T(00:06:04)
Let's get our feet wet with SwiftUI by doing something simple. We are going to create this root view. It just has a title view and two buttons stacked on top of each other vertically. No matter what, when starting to make a view in SwiftUI you always begin with making a struct that conforms to the `View` protocol, and I like to get the basic conformance in place by using an `EmptyView`:

```swift
import SwiftUI

struct ContentView: View {
  var body: some View {
    EmptyView()
  }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: ContentView()
)
```

@T(00:07:04)
Now already we are running into some fancy new Swift 5.1 things:

- There's this `some` keyword in the type of the `body` property. Fortunately we don't need to have a deep understanding of how this works in order to make progress on this screen. We will discuss the `some` concept more in depth in a future episode, but for now just know that inside the body of this property we just need to return some value that conforms to the `View` protocol.

@T(00:07:29)
- We are able to omit the `return` from the body of the computed property since it is only a one line block

@T(00:07:48)
In order to get this view rendering in a playground, we need to wrap it in a `UIHostingController`, which is a bridge between the SwiftUI world and the UIKit world.

@T(00:08:16)
Next we want to start filling in the body of this view. Since we want to navigate from this view to other sub-screens, our root will be a `NavigationView`:

```swift
struct ContentView: View {
  var body: some View {
    NavigationView {
    }
  }
}
```

@T(00:08:27)
This will allow us to create buttons that push on new screens. Speaking of which, we can create a few of those using the `NavigationLink` elements:

```swift
struct ContentView: View {
  var body: some View {
    NavigationView {
      NavigationLink(destination: EmptyView()) {
        Text("Counter demo")
      }
      NavigationLink(destination: EmptyView()) {
        Text("Favorite primes")
      }
    }
  }
}
```

@T(00:09:22)
Only the first navigation link is showing because we haven't instructed SwiftUI on how it should flow these two elements: should they be side-by-side or stacked on top of one another? If we wrap them in a `List`, we can get them both rendering nicely.

```swift
struct ContentView: View {
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: EmptyView()) {
          Text("Counter demo")
        }
        NavigationLink(destination: EmptyView()) {
          Text("Favorite primes")
        }
      }
    }
  }
}
```

@T(00:09:48)
And one final touch, we can easily add a title for this view by setting `navigationBarTitle` on the root level view inside the `NavigationView`:

```swift
struct ContentView: View {
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: EmptyView()) {
          Text("Counter demo")
        }
        NavigationLink(destination: EmptyView()) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}
```

@T(00:10:09)
It's worth pointing out that we are using `EmptyView`s for the destination because we do not yet have content for those views. This is a handy trick for filling out UI slowly. If there is something that requires a view but you don't yet have anything at hand, you can just stick in an `EmptyView`. This is analogous to something we have done many times on this series for implementation functions, except we've used `fatalError`, which is a `Never` returning function.

@T(00:10:54)
And just like that we have our first screen! Tapping on the buttons just leads to blank screens, but we were able to get something on the screen so quickly.

## The counter screen

@T(00:11:21)
Next we are going to start building out the counter screen. We can start by building out some scaffolding and swapping it in for our live view:

```swift
struct CounterView: View {
  var body: some View {
    EmptyView()
  }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  // rootView: ContentView()
  rootView: CounterView()
)
```

@T(00:11:58)
Now we need to build out the contents of our counter view using `HStack`s and `VStack`s in order to horizontally and vertically stack our views.

```swift
struct CounterView: View {
  var body: some View {
    VStack {
      HStack {
        Button(action: {}) {
          Text("-")
        }
        Text("0")
        Button(action: {}) {
          Text("+")
        }
      }
      Button(action: {}) {
        Text("Is this prime?")
      }
      Button(action: {}) {
        Text("What is the 0th prime?")
      }
    }
  }
}
```

Creating a `Button` requires specifying an action closure which is executed whenever the button is tapped. We're going to want to do some work in there soon, but for now we will provide a no-op closure

@T(00:14:03)
We're purposefully not covering styling in this episode, but in order to make things a bit easier to read, let's increase the font of this view to be title size.

```swift
.font(.title)
```

@T(00:14:21)
So all of the core UI is now in place, but we need to update our root content view so that tapping a button makes us drill down into this screen:

```swift
NavigationLink(destination: CounterView()) {
```

@T(00:14:41)
Now we can drill down into this screen.

@T(00:14:47)
And in order to get the title in place, we need to add a navigation title to the counter view.

```swift
.navigationBarTitle("Counter demo")
```

@T(00:14:59)
Nothing on this screen is hooked up. When tapping on any of the buttons nothing happens.

@T(00:15:10)
SwiftUI gives us a few options for introducing state into a view in such a way that whenever the state changes the view is re-rendered with the update state. Let's start with the simplest option, which begins by introducing a `var` property to our view that is marked with the `@State` attribute:

```swift
@State var count: Int = 0
```

@T(00:15:38)
This is a new Swift feature called a "property wrapper". It's a mechanism that allows you to wrap a type in another type that provides some functionality, while still exposing the underlying wrapped value to us directly. This `@State` attribute wraps around an integer with a new object that does 2 things for us:

@T(00:15:54)
It gives us a `count` variable that we can use in our view to update its presentation based on that value.

```swift
self.count  // Int
```

@T(00:16:02)
The simplest piece is just to put the value of the count inside the `TextView` we have:

```swift
Text("\(self.count)")
```

@T(00:16:10)
Very easy. A little more complicated would be to update the label of the button that is responsible for computing the "nth" prime. We want to turn the `count` value into an order (e.g. 1st, 2nd, 3rd, etc.), and we can do that with a number formatter:

```swift
private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}
```

@T(00:16:33)
And now we can use this helper function in the button's label.

```swift
Button(action: {}) {
  Text("What's the \(ordinal(self.count)) prime?")
}
```

@T(00:16:47)
So far, `@State` doesn't seem to be doing much. We're just accessing the integer count directly. Behind the scenes, though, the `@State` attribute also wraps `count` in a binding:

```swift
self.$count  // Binding<Int>
```

@T(00:17:08)
This is a type that SwiftUI uses to know when the value has been updated so that it can re-compute its view with the updated information. This is really powerful, because in the view we get to mutate this variable in simple, very familiar way, but under the hood SwiftUI is doing a bunch of work to make sure that change propagates to the proper place.

@T(00:17:32)
So for example, in our +/- buttons we can do a very simple mutation of the `count` variable:

```swift
Button(action: { self.count -= 1 }) {
  Text("-")
}
Button(action: { self.count += 1 }) {
  Text("+")
}
```

@T(00:17:42)
And just like that we already have a semi-functioning application. Tapping those buttons now causes the counter value to go up and down, and even changes the label of the button.

## Persisting the counter screen

@T(00:17:53)
Now that was very easy to get up and running, almost too easy. And in fact there is a pretty serious problem. Using the `@State` attribute we are specifying that the view has some local state it cares about, but there is no easy way to allow that state to propagate to other screens. We can see this by simply changing the counter, going back to the main screen, and then going back into the counter. It reset to 0 instead of maintaining its previous value.

@T(00:18:20)
The reason for this is that `@State` is specifically for local, non-persisted state that only this view would care about and want to control. The prototypical example is the highlighted state of a button, which is entirely controlled by the user's touch, and therefore does not need to travel any further than the button itself.

@T(00:19:00)
For the times that you do want state to persist, there is another concept that SwiftUI provides called an `@ObjectBinding`. This works in much the same way that `@State` does, except it gives you the responsibility of describing how mutations to your state can take place, and how those changes are notified to the SwiftUI system. Having access to this responsibility is exactly what allows you to represent your state as a more global object, rather than local to the view, so that changes to the state can reverberate throughout your entire app.

@T(00:19:34)
To begin, we'll change our `@State` to an `@ObjectBinding`:

```swift
@ObjectBinding var count: Int = 0
```

@T(00:19:40)
There are two things wrong with this:

@T(00:19:43)
- First, we should not be defaulting this value to 0 because it's no longer true that every time this screen opens it will start with the counter at 0. We want it to reference a persisted, global value, and so we should get rid of the default value and just specify the type: `var count: Int`.

@T(00:20:00)
- Second, the type of the value of an `@ObjectBinding` must conform to the `BindableObject` protocol. It's precisely implementing this protocol that allows us to control how mutations happen to our persistent state and how to notify the rest of the system.

@T(00:20:26)
This second point means we need to wrap our count value in a new type that can conform to this protocol. We may be tempted to use a `struct` for this because we know value types are great:

```swift
struct AppState: BindableObject {
  var count: Int
}
```

@T(00:20:40)
But we immediately hit a problem:

> Error: Non-class type 'AppState' cannot conform to class protocol 'BindableObject'

@T(00:20:42)
This is because the `BindableObject` protocol inherits from `AnyObject`, which means it must be a class. And this kinda makes sense because we are wanting a singular, persistent source for our app state, and so it does not make sense to make copies of our state and operate on those. We want all operations to be happening on the single, true data.

@T(00:21:10)
So let's change to a class:

```swift
class AppState: BindableObject {
  var count: Int
}
```

@T(00:21:13)
Now we have a couple compiler errors telling us that `count` isn't initialized and that we haven't fulfilled all the requirements of the protocol.

We can default the `count` to `0`.

```swift
class AppState: BindableObject {
  var count = 0
}
```

@T(00:21:40)
And then to conform to the protocol we must provide a `didChange` property. The autocomplete is a little confusing, but what's really going on here is we need to provide a `didChange` publisher:

```swift
var didChange: AppState.PublisherType
```

> Correction: In Xcode 11 beta 5 and later versions, SwiftUI's `BindableObject` protocol was deprecated in favor of an `ObservableObject` protocol that was introduced to the Combine framework. This protocol utilizes an `objectWillChange` property of `ObservableObjectPublisher`, which is pinged _before_ (not after) any mutations are made to your model:
>
> ```swift
> let objectDidChange = ObservableObjectPublisher()
> ```
>
> This boilerplate is also not necessary, as the `ObservableObject` protocol will synthesize a default publisher for you automatically.

@T(00:21:54)
Now publishers are a concept from the Combine framework that is shipping alongside SwiftUI, and we'll have a bunch to say about it in future episodes, but for now we can think of it as a mechanism that allows us to notify interested subscribers when something changes. For our purposes we can use what is known as a `PassthroughSubject`, which has two generics: one for the values it can emit and one for the errors it can complete with. Again to simplify we will use `Void` and `Never` to represent a subject that emits nothing of interest when something changes and can never fail:

```swift
var didChange = PassthroughSubject<Void, Never>()
```

@T(00:22:59)
This mechanism works a lot like notification center does, but a lot more localized. Anyone who is interested in listening to the changes of this object can easily subscribe, and we can notify of a change by simply hitting the `send` method on this value.

@T(00:23:23)
And that right there is enough to satisfy the compiler, but it isn't doing anything yet. We need to ping this publisher every time our model changes, and fortunately Swift makes this pretty straightforward: we just need to attach a `didSet` handler to our property:

```swift
var count = 0 {
  didSet {
    self.didChange.send()
  }
}
```

> Correction: With Xcode 11 beta 5 and later, `willSet` should be used instead of `didSet`:
>
> ```swift
> var count = 0 {
>   willSet {
>     self.objectWillChange.send()
>   }
> }
> ```
>
> Or you can remove this boilerplate entirely by using a `@Published` property wrapper:
>
> ```swift
> @Published var count = 0
> ```

@T(00:24:03)
And that is all we need to do to get persistent state in place for our application. To hook it up to our view we will update our state variable:

```swift
@ObjectBinding var state: AppState
```

> Correction: With Xcode 11 beta 5 and later, SwiftUI's `@ObjectBinding` property wrapper was deprecated in favor of the `@ObservedObject` wrapper introduced to the Combine framework.

@T(00:24:17)
This will break a few things in our view because we no longer have a `count` field, and instead we must access it through our `state` field:

```swift
Button(action: { self.state.count -= 1 }) {
…
Text("\(self.state.count)")
…
Button(action: { self.state.count += 1 }) {
…
Text("What's the \(ordinal(self.state.count)) prime?")
```

@T(00:24:34)
And finally the only thing left to fix is to explicitly pass the app state to the counter view when we drill down:

```swift
NavigationLink(destination: CounterView(state: <#AppState#>)) {
```

@T(00:24:54)
But in order to do that our `ContentView` needs access to the app state too, so I guess we should add it:

```swift
struct ContentView: View {
  @ObjectBinding var state: AppState
```

@T(00:25:08)
So then we can pass it along:

```swift
NavigationLink(destination: CounterView(state: self.state)) {
```

@T(00:25:10)
And then finally we gotta provide the app state to the `ContentView` when it is first instantiated for the playground live view:

```swift
PlaygroundPage.current.live = UIHostingController(
  rootView: ContentView(state: AppState())
)
```

@T(00:25:52)
OK, so we had to do a bit of plumbing to properly get our global app state inside each of our views, but the benefit of doing this work is that now the count value will persist across all screens. We can drill down into the counter, change it, go back to the main screen, and drill down again and everything is restored to how it was previously. So we have achieved persistence with very little work using the power of `@ObjectBinding` in SwiftUI.

## Next time: prime checking

@T(00:26:21)
Now that we know how to express state in a view, make the view react to changes in that state, and even how to persist the state across the entire application, let's build out another screen in our app. Let's do the prime number checker modal. This appears when you tap the "Is this prime?" button, and it shows you a label that let's you know if the current counter is prime or not, and it gives you a button for saving or removing the number from your list of favorites.
