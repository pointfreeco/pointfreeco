import Foundation

public let ep65 = Episode(
  blurb: """
Let's begin exploring application architecture by understanding what are the common problems we encounter when trying to build large, complex applications. We will build an app in SwiftUI to see how Apple's new framework approaches solving these problems.
""",
  codeSampleDirectory: "0065-swiftui-and-state-management-pt1", // TODO
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 935_800_000,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/full/0065-swiftui-and-state-management-pt1-c3a3fb39-full.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/full/0065-swiftui-and-state-management-pt1.m3u8"
  ),
  id: 65,
  // todo: cloudfront
  image: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0065-swiftui-and-state-management-pt1/itunes-poster.jpg",
  length: 26 * 60 + 45,
  permission: .free,
  previousEpisodeInCollection: nil,
  publishedAt: .init(timeIntervalSince1970: 1563170400),
  references: [
    .swiftUiTutorials,
    .insideSwiftUIAboutState
  ],
  sequence: 65,
  title: "SwiftUI and State Management: Part 1",
  trailerVideo: .init(
    bytesLength: 81_600_000,
    downloadUrl: "https://pointfreeco-episodes-processed.s3.amazonaws.com/0065-swiftui-and-state-management-pt1/trailer/0065-trailer-trailer.mp4",
    streamingSource: "https://pointfreeco-episodes-processed.s3.amazonaws.com/0065-swiftui-and-state-management-pt1/trailer/0065-trailer.m3u8"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  .init(problem: """
Let's make the state even _more_ persistent by saving the state whenever a change is made and loading the state when the app launches. This can be done in a few steps:

* Make `AppState` conform to `Codable`. Because of the `PassthroughSubject` `willChange` property, you unfortunately must manually specify the other `CodingKeys` or manually implement encoding and decoding.
* Tap into each `willSet` on the model and save the JSON representation of the state to `UserDefaults`.
* When the root `ContentView` is created for the playground live view load the `AppState` from `UserDefaults`.

Once you have accomplished this your data will persist across multiple runs of the playground! However, there are quite a few problems with it. Implementing `Codable` is annoying due to the `PassthroughSubject`, we are saving the state to `UserDefaults` on every state change, which is probably too inefficient, and we have to repeat that work for each `willSet` entry point. We will explore better ways of dealing with this soon 😄.
"""),
  .init(problem: """
Search for an algorithm online that checks if an integer is prime, and port it to Swift.
"""),
  .init(problem: """
Make the counter `Text` view green when the current count value is prime, and red otherwise.
"""),
  .init(problem: """
To present modals in SwiftUI one uses the `presentation` method on views that takes a single argument of an optional `Modal` value. If this value is present then the modal will be presented, and if it's `nil` the modal will be dismissed (or if no modal is showing, nothing will happen).

Add an additional `@State` value to our `CounterView` and use it to show and hide the modal when the "Is this prime?" button is tapped.
"""),
  .init(problem: """
Add a `var favoritePrimes: [Int]` field to our `AppState`, and make sure to ping `didChange` when this value is mutated.

Use this new `favoritePrimes` state to render a "Add to favorite primes" / "Remove from favorite primes" button in the modal. Also hook up the action on this button to remove or add the current counter value to the list of favorite primes.
"""),
  .init(problem: """
Right now it's cumbersome to add new state to our `AppState` class. We have to always remember to ping `willChange` whenever any of our fields is mutated and even more work is needed if we wanted to bundle up a bunch of fields into its own state class.

These problems can be fixed by creating a generic class `Store<A>` that wraps access to a single value type `A`. Implement this class and replace all instances of `AppState` in our application with `Store<AppState>`.
""")
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: (0*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Today we are going to begin discussing some application architecture ideas, which somehow in the one and a half years since Point-Free was launched we haven't really discussed head-on. We've covered lots of broad ideas on how to make your applications more understandable and testable, such as pushing side effects to the boundaries, using pure functions as much as possible, and putting an emphasis on functions and composition above all other abstractions.
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, with the foundations of functional programming firmly rooted in everyone's mind, we can now begin discussing how to glue all of those ideas into a cohesive story on architecting large, complex applications. But, before we do that we need to explore the problem space a bit, and see what kind of challenges we encounter when we try to create even a moderately complex application. There isn't going to be a lot of functional programming in these next episodes because we need to properly set the stage so that we can see what functional programming has to say about architecture.
""",
    timestamp: (0*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So, in these next episodes we are going to start building an application that exemplifies many of the complications that pop up in application development. It will have some state that needs to be manipulated and persisted, it will involve loading data from an API request and showing an alert, and it will have multiple screens that all need to make mutations to the global app state. Having an opinionated and consistent way to do these tasks is essential to creating a scalable architecture that can be maintained for a long time, whether you are a solo developer or on a large team.
""",
    timestamp: (1*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We've decided to do this application in SwiftUI using Swift 5.1 and the Xcode 11 beta, but all of the problems we are discussing equally apply to UIKit applications too. We've chosen SwiftUI because Apple is taking a bit of a stronger stance on how one should architect their app than they have historically done with UIKit. This gives us the perfect opportunity to understand why architecture is important and how we can leverage the tools that Apple gives us to adopt an architecture that suits our needs.
""",
    timestamp: (1*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's also worth noting that we are not doing a comprehensive exploration of how SwiftUI works, we are only going to describe as much as we need to get the application going. We will explain in detail the parts of SwiftUI we use, but some things will be deferred for deeper dives in future episodes.
""",
    timestamp: (2*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "A tour of the application",
    timestamp: (2*60 + 47),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
So, let's get started:
""",
    timestamp: (2*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's a counting app that allows you to check if a number is prime (that is, a number that is only divisible by 1 and itself), and if it is you can save or remove it from your list of favorite primes. You can also ask it to compute the "nth" prime, and this is actually doing an API request to Wolfram Alpha, a scientific computing API. We can also go back and see our entire list of favorite primes, and remove any if we want. We haven't done any styling in this application because we want to entirely focus on the complexities of how data moves through this application.
""",
    timestamp: (2*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This of course isn't a super real-world example of an application, it's more of a toy, but it gets at the heart of a lot problems that we need to solve in any architecture for an application:
""",
    timestamp: (4*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- There is lots of state that changes the display of the UI. For example, pressing a button causes a modal to come up, and the contents of that modal is dependent on what happened on the previous screen, and we've got this button that triggers a network request where we want to disable the button while the request is in-flight.
""",
    timestamp: (4*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- There is state that must be persisted across multiple screens (in this case it's the list of favorite primes, because we need it in the modal that says whether to add or remove the prime, and we need it in the list view of all the primes that are our favorites).
""",
    timestamp: (4*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- There are lots of little sub-components that need to be pieced together to make the app as a whole. We'd love if each of these screens could be developed in isolation without them knowing anything about the larger application, possibly even put them in their own Swift package.
""",
    timestamp: (5*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- There are side effects happening, in particular the API request that happens when we want to compute the "nth" prime. We'd like to have an opinionated way of introducing such effects into our views so that we aren't just sprinkling network calls everywhere. Doing that makes it hard to understand how the data is flowing through our application, and makes the view harder to test.
""",
    timestamp: (5*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The navigation screen",
    timestamp: (6*60 + 04),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's get our feet wet with SwiftUI by doing something simple. We are going to create this root view. It just has a title view and two buttons stacked on top of each other vertically. No matter what, when starting to make a view in SwiftUI you always begin with making a struct that conforms to the `View` protocol, and I like to get the basic conformance in place by using an `EmptyView`:
""",
    timestamp: (6*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
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
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now already we are running into some fancy new Swift 5.1 things:

- There's this `some` keyword in the type of the `body` property. Fortunately we don't need to have a deep understanding of how this works in order to make progress on this screen. We will discuss the `some` concept more in depth in a future episode, but for now just know that inside the body of this property we just need to return some value that conforms to the `View` protocol.
""",
    timestamp: (7*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- We are able to omit the `return` from the body of the computed property since it is only a one line block
""",
    timestamp: (7*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In order to get this view rendering in a playground, we need to wrap it in a `UIHostingController`, which is a bridge between the SwiftUI world and the UIKit world.
""",
    timestamp: (7*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Next we want to start filling in the body of this view. Since we want to navigate from this view to other sub-screens, our root will be a `NavigationView`:
""",
    timestamp: (8*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct ContentView: View {
  var body: some View {
    NavigationView {
    }
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This will allow us to create buttons that push on new screens. Speaking of which, we can create a few of those using the `NavigationLink` elements:
""",
    timestamp: (8*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
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
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Only the first navigation link is showing because we haven't instructed SwiftUI on how it should flow these two elements: should they be side-by-side or stacked on top of one another? If we wrap them in a `List`, we can get them both rendering nicely.
""",
    timestamp: (9*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
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
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And one final touch, we can easily add a title for this view by setting `navigationBarTitle` on the root level view inside the `NavigationView`:
""",
    timestamp: (9*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
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
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's worth pointing out that we are using `EmptyView`s for the destination because we do not yet have content for those views. This is a handy trick for filling out UI slowly. If there is something that requires a view but you don't yet have anything at hand, you can just stick in an `EmptyView`. This is analogous to something we have done many times on this series for implementation functions, except we've used `fatalError`, which is a `Never` returning function.
""",
    timestamp: (10*60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And just like that we have our first screen! Tapping on the buttons just leads to blank screens, but we were able to get something on the screen so quickly.
""",
    timestamp: (10*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The counter screen",
    timestamp: (11*60 + 21),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Next we are going to start building out the counter screen. We can start by building out some scaffolding and swapping it in for our live view:
""",
    timestamp: (11*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct CounterView: View {
  var body: some View {
    EmptyView()
  }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
//  rootView: ContentView()
  rootView: CounterView()
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we need to build out the contents of our counter view using `HStack`s and `VStack`s in order to horizontally and vertically stack our views.
""",
    timestamp: (11*60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
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
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Creating a `Button` requires specifying an action closure which is executed whenever the button is tapped. We're going to want to do some work in there soon, but for now we will provide a no-op closure
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We're purposefully not covering styling in this episode, but in order to make things a bit easier to read, let's increase the font of this view to be title size.
""",
    timestamp: (14*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.font(.title)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So all of the core UI is now in place, but we need to update our root content view so that tapping a button makes us drill down into this screen:
""",
    timestamp: (14*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
NavigationLink(destination: CounterView()) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we can drill down into this screen.
""",
    timestamp: (14*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And in order to get the title in place, we need to add a navigation title to the counter view.
""",
    timestamp: (14*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
.navigationTitle("Counter demo")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Nothing on this screen is hooked up. When tapping on any of the buttons nothing happens.
""",
    timestamp: (14*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
SwiftUI gives us a few options for introducing state into a view in such a way that whenever the state changes the view is re-rendered with the update state. Let's start with the simplest option, which begins by introducing a `var` property to our view that is marked with the `@State` attribute:
""",
    timestamp: (15*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@State var count: Int = 0
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is a new Swift feature called a "property wrapper". It's a mechanism that allows you to wrap a type in another type that provides some functionality, while still exposing the underlying wrapped value to us directly. This `@State` attribute wraps around an integer with a new object that does 2 things for us:
""",
    timestamp: (15*60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It gives us a `count` variable that we can use in our view to update its presentation based on that value.
""",
    timestamp: (15*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
self.count // Int
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The simplest piece is just to put the value of the count inside the `TextView` we have:
""",
    timestamp: (16*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Text("\\(self.count)")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Very easy. A little more complicated would be to update the label of the button that is responsible for computing the "nth" prime. We want to turn the `count` value into an order (e.g. 1st, 2nd, 3rd, etc.), and we can do that with a number formatter:
""",
    timestamp: (16*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now we can use this helper function in the button's label.
""",
    timestamp: (16*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: {}) {
  Text("What's the \\(ordinal(self.count)) prime?")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So far, `@State` doesn't seem to be doing much. We're just accessing the integer count directly. Behind the scenes, though, the `@State` attribute also wraps `count` in a binding:
""",
    timestamp: (16*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
self.$count // Binding<Int>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is a type that SwiftUI uses to know when the value has been updated so that it can re-compute its view with the updated information. This is really powerful, because in the view we get to mutate this variable in simple, very familiar way, but under the hood SwiftUI is doing a bunch of work to make sure that change propagates to the proper place.
""",
    timestamp: (17*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So for example, in our +/- buttons we can do a very simple mutation of the `count` variable:
""",
    timestamp: (17*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.count -= 1 }) {
  Text("-")
}
Button(action: { self.count += 1 }) {
  Text("+")
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And just like that we already have a semi-functioning application. Tapping those buttons now causes the counter value to go up and down, and even changes the label of the button.
""",
    timestamp: (17*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Persisting the counter screen",
    timestamp: (17*60 + 53),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now that was very easy to get up and running, almost too easy. And in fact there is a pretty serious problem. Using the `@State` attribute we are specifying that the view has some local state it cares about, but there is no easy way to allow that state to propagate to other screens. We can see this by simply changing the counter, going back to the main screen, and then going back into the counter. It reset to 0 instead of maintaining its previous value.
""",
    timestamp: (17*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The reason for this is that `@State` is specifically for local, non-persisted state that only this view would care about and want to control. The prototypical example is the highlighted state of a button, which is entirely controlled by the user's touch, and therefore does not need to travel any further than the button itself.
""",
    timestamp: (18*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For the times that you do want state to persist, there is another concept that SwiftUI provides called an `@ObjectBinding`. This works in much the same way that `@State` does, except it gives you the responsibility of describing how mutations to your state can take place, and how those changes are notified to the SwiftUI system. Having access to this responsibility is exactly what allows you to represent your state as a more global object, rather than local to the view, so that changes to the state can reverberate throughout your entire app.
""",
    timestamp: (19*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
To begin, we'll change our `@State` to an `@ObjectBinding`:
""",
    timestamp: (19*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@ObjectBinding var count: Int = 0
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
There are two things wrong with this:
""",
    timestamp: (19*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- First, we should not be defaulting this value to 0 because it's no longer true that every time this screen opens it will start with the counter at 0. We want it to reference a persisted, global value, and so we should get rid of the default value and just specify the type: `var count: Int`.
""",
    timestamp: (19*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
- Second, the type of the value of an `@ObjectBinding` must conform to the `BindableObject` protocol. It's precisely implementing this protocol that allows us to control how mutations happen to our persistent state and how to notify the rest of the system.
""",
    timestamp: (20*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This second point means we need to wrap our count value in a new type that can conform to this protocol. We may be tempted to use a `struct` for this because we know value types are great:
""",
    timestamp: (20*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct AppState: BindableObject {
  var count: Int
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But we immediately hit a problem:

> 🛑 Non-class type 'AppState' cannot conform to class protocol 'BindableObject'
""",
    timestamp: (20*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is because the `BindableObject` protocol inherits from `AnyObject`, which means it must be a class. And this kinda makes sense because we are wanting a singular, persistent source for our app state, and so it does not make sense to make copies of our state and operate on those. We want all operations to be happening on the single, true data.
""",
    timestamp: (20*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So let's change to a class:
""",
    timestamp: (21*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
class AppState: BindableObject {
  var count: Int
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we have a couple compiler errors telling us that `count` isn't initialized and that we haven't fulfilled all the requirements of the protocol.

We can default the `count` to `0`.
""",
    timestamp: (21*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
class AppState: BindableObject {
  var count = 0
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then to conform to the protocol we must provide a `didChange` property. The autocomplete is a little confusing, but what's really going on here is we need to provide a `didChange` publisher:
""",
    timestamp: (21*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var didChange: AppState.PublisherType
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This episode was recorded with Xcode 11 beta 3, and a change has been made to the `BindableObject` protocol in beta 4 and later versions of Xcode. The protocol now requires a `willChange` publisher, and you are supposed to ping this publisher _before_ you make any mutations to your model.
""",
    timestamp: nil,
    type: .correction
  ),
  Episode.TranscriptBlock(
    content: """
Now publishers are a concept from the Combine framework that is shipping alongside SwiftUI, and we'll have a bunch to say about it in future episodes, but for now we can think of it as a mechanism that allows us to notify interested subscribers when something changes. For our purposes we can use what is known as a `PassthroughSubject`, which has two generics: one for the values it can emit and one for the errors it can complete with. Again to simplify we will use `Void` and `Never` to represent a subject that emits nothing of interest when something changes and can never fail:
""",
    timestamp: (21*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var didChange = PassthroughSubject<Void, Never>()
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This mechanism works a lot like notification center does, but a lot more localized. Anyone who is interested in listening to the changes of this object can easily subscribe, and we can notify of a change by simply hitting the `send` method on this value.
""",
    timestamp: (22*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And that right there is enough to satisfy the compiler, but it isn't doing anything yet. We need to ping this publisher every time our model changes, and fortunately Swift makes this pretty straightforward: we just need to attach a `didSet` handler to our property:
""",
    timestamp: (23*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var count = 0 {
  didSet {
    self.didChange.send()
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
With Xcode 11 beta 4 and later, you should tap into the `willSet` observer instead of `didSet` so that you can notify the publisher of changes _before_ you make mutations to your state.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And that is all we need to do to get persistent state in place for our application. To hook it up to our view we will update our state variable:
""",
    timestamp: (24*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
@ObjectBinding var state: AppState
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This will break a few things in our view because we no longer have a `count` field, and instead we must access it through our `state` field:
""",
    timestamp: (24*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Button(action: { self.state.count -= 1 }) {
…
Text("\\(self.state.count)")
…
Button(action: { self.state.count += 1 }) {
…
Text("What's the \\(ordinal(self.state.count)) prime?")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And finally the only thing left to fix is to explicitly pass the app state to the counter view when we drill down:
""",
    timestamp: (24*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
NavigationLink(destination: CounterView(state: <#AppState#>)) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But in order to do that our `ContentView` needs access to the app state too, so I guess we should add it:
""",
    timestamp: (24*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct ContentView: View {
  @ObjectBinding var state: AppState
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So then we can pass it along:
""",
    timestamp: (25*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
NavigationLink(destination: CounterView(state: self.state)) {
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then finally we gotta provide the app state to the `ContentView` when it is first instantiated for the playground live view:
""",
    timestamp: (25*60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
PlayergroundPage.current.live = UIHostingController(
  rootView: ContentView(state: AppState())
)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Ok, so we had to do a bit of plumbing to properly get our global app state inside each of our views, but the benefit of doing this work is that now the count value will persist across all screens. We can drill down into the counter, change it, go back to the main screen, and drill down again and everything is restored to how it was previously. So we have achieved persistence with very little work using the power of `@ObjectBinding` in SwiftUI.
""",
    timestamp: (25*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Next time: prime checking",
    timestamp: (26*60 + 21),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now that we know how to express state in a view, make the view react to changes in that state, and even how to persist the state across the entire application, let's build out another screen in our app. Let's do the prime number checker modal. This appears when you tap the "Is this prime?" button, and it shows you a label that let's you know if the current counter is prime or not, and it gives you a button for saving or removing the number from your list of favorites.
""",
    timestamp: (26*60 + 21),
    type: .paragraph
  ),
]
