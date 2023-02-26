import Foundation

extension Episode {
  public static let ep100_ATourOfTheComposableArchitecture_pt1 = Episode(
    blurb: """
      It's our 100th episode 🎉! To celebrate, we are finally releasing the Composable Architecture as an open source library, which means you can start using it in your applications today! Let's take a tour of the library, see how it's changed from what we built in earlier episodes, and build a brand new app with it.
      """,
    codeSampleDirectory: "0100-swift-composable-architecture-tour-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 402_161_784,
      downloadUrls: .s3(
        hd1080: "0100-1080p-9f9760f74ed241c5bed4d2c7a98aa659",
        hd720: "0100-720p-7a16243734704834a71b3eb4ed6e8a5c",
        sd540: "0100-540p-5892dbe7aac34472bd5a836d140be4f2"
      ),
      vimeoId: 414_016_119
    ),
    id: 100,
    length: 32 * 60 + 56,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_588_568_400),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 100,
    subtitle: "Part 1",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 402_161_784,
      downloadUrls: .s3(
        hd1080: "0100-trailer-1080p-8fc9079664e4421984ff5cb70a45bc53",
        hd720: "0100-trailer-720p-862114bb4a56443cab85ff3eb1e038f7",
        sd540: "0100-trailer-540p-2eae6f8c217f4b2f876b0b02e8ee4dcb"
      ),
      vimeoId: 414_015_638
    ),
    transcriptBlocks: _privateTranscriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = []

private let _privateTranscriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Welcome to the 100th episode of Point-Free! 🚀
      """#,
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      It's hard to believe this is our 100th episode. We've been doing this series for 2 years and 3 months, and we've gone places in the past 99 episodes that we never could have predicted we would have ended up. And today is no exception. This week we are excited to announce that we are finally open sourcing [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) that we have been building for the past 9 months.
      """#,
    timestamp: (0 * 60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      For those that haven't been [following along](/collections/composable-architecture), here's a little bit of history of what we have accomplished:
      """#,
    timestamp: (0 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      [We started this series](/collections/composable-architecture/swiftui-and-state-management) of episodes by first taking a look at what SwiftUI gives us out of the box, and it was pretty amazing. The ability to build views declaratively and model state in a lightweight way so that changes to state are instantly reflected in your UI is incredible. However, we identified a few problems that SwiftUI does not try to solve, and wondered what we could do to solve those problems in a cohesive, holistic package.
      """#,
    timestamp: (0 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so we introduced the idea of the Composable Architecture. An opinionated library that tells us exactly how we should build our applications so that we can get a lot of extra benefits that a vanilla SwiftUI application does not have.
      """#,
    timestamp: (1 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We started by showing how the Composable Architecture is, well, [composable](/collections/composable-architecture/reducers-and-stores). It comes with a few basic operators that allows us to build many small features with the architecture, and then pull them back and combine them to form one big feature. This was instrumental in our work to break down a large, complex feature into many smaller, simpler features.
      """#,
    timestamp: (1 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we showed that we could embrace the compositional operators we developed in order to fully [modularize](/collections/composable-architecture/modularity) our app. This meant that each feature could live in its own Swift module with as few dependencies between them as possible. This allowed us to build each feature in isolation, without needing to build the full application, and we could even run each feature as a little miniature application on its own. This came in handy in later episodes where we did broad refactorings of the architecture and our app and we never had to fix everything all at once. We could go feature by feature, fixing a little at a time and making sure that the refactor we were doing was the right choice.
      """#,
    timestamp: (1 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Then we introduced [side effects](/collections/composable-architecture/side-effects) to the architecture. Side effects are by far the most complicated part of an application since they talk to the wild, vast, unknowable outside world, and the Composable Architecture has a very strong opinion on how side effects should be handled in your application. Many architectures out there aren't prescriptive with how side effects should be handled, but the Composable Architecture says that side effects should only be occur when wrapped up in a specific type called `Effect`, and you should never do a side effect outside of that little sandbox.
      """#,
    timestamp: (2 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we showed [how to test](/collections/composable-architecture/testing) the composable architecture. We came up with an assertion helper that allows you to run a sequence of user actions, like the user tapping on a button or typing into a text field, and the helper forces you to assert on exactly how the state changes at each step of the way, and assert exactly how side effects are executed and what values were fed back into the system. We even got some extra exhaustivity checking with effects because the assertion helper forced us to to declare every effect output that was fed back into the system. This gave us broad coverage on both how the state of the application evolves over time and how effects interleave throughout the system.
      """#,
    timestamp: (3 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      As if that wasn't enough, we also showed that the Composable Architecture has a strong opinion on how [dependencies](/episodes/ep91-dependency-injection-made-composable) are managed. It tells us precisely how to model the application's dependencies and how to slice them up into smaller subsets so that you can hand just the bare essentials off to each feature.
      """#,
    timestamp: (4 * 60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then most recently we showed how to make the Composable Architecture more [adaptable](/collections/composable-architecture/adaptation), so that we could build the core business logic in a fully agnostic manner, while then allowing views to adapt that logic to the domain that makes the most sense for them. This allowed us to have a single source of business logic powering an iOS app and a macOS app despite platform differences.
      """#,
    timestamp: (4 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      All of that work has culminated into open sourcing [the library](https://github.com/pointfreeco/swift-composable-architecture) that you can start using in your SwiftUI or UIKit application today. In this episode we want to give a little tour of the library, because there have been some improvements and additions that we did not cover in episodes. To demonstrate the library we are going to build a little todo app from scratch, and add a few bells and whistles to make things a little more interesting.
      """#,
    timestamp: (4 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Getting started"#,
    timestamp: (5 * 60 + 22),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's take a quick look at how the library is structured.
      """#,
    timestamp: (5 * 60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - In the Sources directory we have the core library's code. It has all the types that we've covered over the past many months, such as `Reducer`, `Store`, and `Effect`, as well as some new things not yet seen in Point-Free episodes. There are schedulers, which we will see later in this series, and in some of these subdirectories there are all types of fun helpers built on top of the core architecture, such as navigation and binding helpers, as well as effect cancellation and effect debouncing. There's lots of fun stuff to explore in here.
      """#,
    timestamp: (5 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - In the Examples directory we have a bunch of applications that help demonstrate many use cases and problems solved in the Composable Architecture. Everything from bindings and effects, to navigation and full-blown applications. Even more interesting than the applications is the test suites. Every application is fully tested, including edge cases, side effects, and subtle bits of logic.
      """#,
    timestamp: (5 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      In particular, we have a todos app. We can run the app to see a list of todos.

      - The todo list can be filtered by whether a todo has been completed or not
      - New todos can be added at the tap of a button
      - Todos can be checked complete, which will sort them to the bottom of the list
      - Completed todos can be cleared all at once
      - And we can edit the list to re-sort and delete todos
      """#,
    timestamp: (6 * 60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is the basic app we're going to walk through building today. We'll only be building a sub-set of its features, but we'll get a decent number of them done that will demonstrate what it means to build a decently complex feature using the Composable Architecture.
      """#,
    timestamp: (6 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's get started in a fresh Xcode project:
      """#,
    timestamp: (6 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Then we can add the library to this project by using Xcode's SPM integration:

      > [https://github.com/pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)
      """#,
    timestamp: (7 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The package comes with two libraries. The core library is `ComposableArchitecture`, which is what we want to use in our main Todos application. There is also a library `ComposableArchitectureTestSupport` that comes with some handy utilities for testing features built in the Composable Architecture. So let's make sure to add each library to the "Todos" and "TodosTests" targets.
      """#,
    timestamp: (7 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Since this episode was recorded, the `ComposableArchitectureTestSupport` module has merged into `ComposableArchitecture` and is no longer needed. You can now link your app target to `ComposableArchitecture` and will have access to test helpers in your test target.
      """#,
    timestamp: nil,
    type: .box(.correction)
  ),
  Episode.TranscriptBlock(
    content: #"Setting up basic infrastructure"#,
    timestamp: (8 * 60 + 5),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now that the library is in place, let's start to get our hands dirty and actually build the application. There are a few ways we can get started with the Composable Architecture. Each is completely valid, and we could do many episodes covering each one, but roughly we could either:
      """#,
    timestamp: (8 * 60 + 5),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - Begin by doing an abstract domain modeling exercise so that you can understand precisely what state and actions your features need, and from that you can build the reducer and view that realizes that domain.
      """#,
    timestamp: (8 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - We can also start from the view, maybe looking at a mockup that your designer produced for you, and from that start sketching out a SwiftUI view, and then figuring out the domain of state and actions.
      """#,
    timestamp: (8 * 60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - Or we can do what we are going to do in this episode, and take a little bit from column A and a little bit from column B.
      """#,
    timestamp: (8 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're going to start with a little domain modeling. That is, we'll define the state our feature needs to do its job, we'll define the actions that can take place in our feature, and we'll define the environment of dependencies that our feature needs to perform effectful work. We can get some stubs in place for now:
      """#,
    timestamp: (8 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct AppState {
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The state is typically a struct because it holds a bunch of independent pieces of data, though it does not always need to be a struct.
      """#,
    timestamp: (9 * 60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The actions are typically an enum because it represents one of many different types of actions that a user can perform in the UI, such as tapping a button or entering text into a text field.
      """#,
    timestamp: (9 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct AppEnvironment {
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally, the environment is pretty much always a struct, because it holds all of the dependencies our feature needs to do its job, such as API clients, analytics clients, date initializers, schedulers, and more.
      """#,
    timestamp: (9 * 60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we would define a reducer for our application, which is the thing that glues together the state, action and environment into a cohesive package. It's the thing responsible for the business logic that runs the application. Creating one for our domain involves providing a closure that is handed the current state, an incoming action, and the environment:
      """#,
    timestamp: (9 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      In this closure is where we will put all of the logic for our application. We do this by switching over the action:
      """#,
    timestamp: (10 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then in here we would consider each case in the `AppAction` enum, and for each case we would run the business logic related to that action. When we say business logic we mean something very specific. Business logic precisely corresponds to just two things:
      """#,
    timestamp: (10 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - We will make any mutations to the state necessary for the action. The `state` value passed in here is an `inout` argument. So when an action comes in, say the user tapping the todo checkbox, we can just go into the state and mutate a todo's `isComplete` field to be `true`.
      """#,
    timestamp: (10 * 60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - After you have performed all of the mutations you want to state, you can return an effect. An effect is a special type that allows you to communicate with the outside world, like executing an API request, writing data to disk, or tracking analytics, and it allows you to feed data from the outside world back into this reducer.
      """#,
    timestamp: (11 * 60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      These are the only two things you are allowed to do in a reducer. All the pure logic happens in the state mutations, and all the non-pure logic happens in the effects.
      """#,
    timestamp: (11 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Currently we don't have any actions so there's nothing to do in this reducer just yet.
      """#,
    timestamp: (11 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      While the domain and reducer model our business logic in the nice, pure, functional world, they aren't enough to power our app. We need a runtime object that is responsible for powering our views by accumulating state changes over time. The object that does this in the Composable Architecture is known as the `Store`, and each view powered by the Composable Architecture will need to hold onto one of these.
      """#,
    timestamp: (11 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, let's go ahead and add one to our `ContentView`:
      """#,
    timestamp: (12 * 60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView: View {
        let store: Store<AppState, AppAction>

        var body: some View {
          Text("Hello, World!")
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      There are two places where a `ContentView` is created: in the SwiftUI preview and in the scene delegate, and both have to be fixed to provide a store. To create a store we need the initial state of the application, the reducer that powers the business logic, and the environment that the store is running in:
      """#,
    timestamp: (12 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
          ContentView(
            store: Store(
              initialState: <#_#>,
              reducer: <#Reducer<_, _, Environment>#>,
              environment: <#Environment#>
            )
          )
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      For the initial state we can just use `AppState()`, for the reducer we can use the stubbed `appReducer` we defined earlier, and for the environment we can use `AppEnvironment()`:
      """#,
    timestamp: (13 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
          ContentView(
            store: Store(
              initialState: AppState(),
              reducer: appReducer,
              environment: AppEnvironment()
            )
          )
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then in the scene delegate we can do something similar:
      """#,
    timestamp: (13 * 60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let contentView = ContentView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment()
        )
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Let's get a little bit of the UI in place. We know we want a title for this screen, as well as a list, so we can start by wrapping a `List` component in a `NavigationView` and setting its title:
      """#,
    timestamp: (13 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView: View {
        let store: Store<AppState, AppAction>

        var body: some View {
          NavigationView {
            List {
              Text("Hello")
            }
            .navigationBarTitle("Todos")
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now with that infrastructure in place we can start doing some domain modeling. Firstly, our application is a todo app, and so of course we're going to have a list of todos in our app state. Let's model a simple todo item as struct that has a description and a boolean flag that determines if it has been completed or not:
      """#,
    timestamp: (14 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct Todo {
        var description = ""
        var isComplete = false
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And our app state should hold an array of these models:
      """#,
    timestamp: (14 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct AppState {
        var todos: [Todo] = []
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And just from this we should be able to get something on the screen that is rendered from this state. We would like to use a `ForEach` view to render a row for each todo we have in our app state:
      """#,
    timestamp: (15 * 60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      List {
        ForEach(self.store.state.todos) { todo in
          Text("Hello")
        }
        Text("Hello")
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, the store does not directly give you access to the state. If you recall from some of our most recent episodes, we require you to go through a secondary object to get access to state, called the `ViewStore`. We did this for 2 primary reasons:
      """#,
    timestamp: (15 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - First, and most importantly, the `ViewStore` gave us the opportunity to chisel away the state that the view doesn't access need access to in order to render its UI. Typically a view will hold onto a lot of state, because it needs everything to not only render its own UI, but also all the state it is going to pass down to child views so that they can render themselves. But, this means that any little change to the state is going to cause all of these views re-compute themselves, and that can lead to performance problems. The `ViewStore` gave us the perfect opportunity to mold a feature's state into something domain specific that only it cares about, and that allowed us to skip out on a lot of over computation.
      """#,
    timestamp: (15 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - Second, and just as important, the `ViewStore` allowed us to adapt our features to multiple platforms. We could implement the core logic of our feature a single time in the reducer, and then we could form projections of the general business domain into specific domains that make more sense for a platform. For example, on iOS we could show a modal when the user taps on a button, but on macOS we want to show a popover.
      """#,
    timestamp: (16 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The way we use view stores in the library is going to look a little different from how it was covered in the episodes. Thanks to a collaboration with Point-Free viewer [Chris Liscio](https://twitter.com/liscio) we were able to make the ergonomics of the view store a lot nicer, and even improve its functionality.
      """#,
    timestamp: (16 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Previously to use a view store you would add a field to your view to hold the view store and make it an `@ObservedObject`. Instead, now you just create a new special view that gives you access to a view store:
      """#,
    timestamp: (17 * 60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView: View {
        let store: Store<AppState, AppAction>

        var body: some View {
          NavigationView {
            WithViewStore(self.store) { viewStore in
              …
            }
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now, inside here we will have access to all the state in the store and we can send it actions, but in order for the view store to know how to deduplicate emissions of state, we should make our state structs `Equatable`.
      """#,
    timestamp: (18 * 60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct Todo: Equatable {
        var description = ""
        var isComplete = false
      }

      struct AppState: Equatable {
        var todos: [Todo]
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we can render our list of todos:
      """#,
    timestamp: (18 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      var body: some View {
        NavigationView {
          WithViewStore(self.store) { viewStore in
            List {
              ForEach(viewStore.state.todos) { todo in
                Text("Hello")
              }
              Text("Hello")
            }
            .navigationBarTitle("Todos")
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Even better, the `ViewStore` makes use of dynamic member lookup, which allows us to access the properties on the `state` field as if they lived directly on the view store:
      """#,
    timestamp: (18 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.todos) { todo in
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We're getting closer, but unfortunately this doesn't work just yet because `ForEach` doesn't work on just any type of collection. There are a few initializers we can choose from, each with their own requirements.
      """#,
    timestamp: (18 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      For example, one initializer of `ForEach` has us specify an `id` key path that is supposed to pluck out a piece of `Hashable` data from the `Todo` so that it can use that info to identify each element of the collection:
      """#,
    timestamp: (19 * 60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.todos, id: <#KeyPath<_.Element, _>#>) {
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Right now our `Todo` doesn't have any uniquely identifying information in it. It's just a string description and boolean flag, and it's totally possible for two different todos to have identical values for those fields.
      """#,
    timestamp: (19 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, what we can do is introduce an `id` to our `Todo` model that can be used to distinguish otherwise equal todos:
      """#,
    timestamp: (19 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct Todo: Equatable {
        var description = ""
        let id: UUID
        var isComplete = false
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then our `ForEach` can pluck out that id to help with identifying elements:
      """#,
    timestamp: (19 * 60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.todos, id: \.id) { todo in
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      But even better, there is a protocol in Swift called `Identifiable` that expresses types that carry a uniquely identifying piece of data, such as this `UUID` on `Todo`. We can make `Todo` conform to it immediately because it already satisfies its one requirement: have any `id` field that is `Hashable`:
      """#,
    timestamp: (19 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct Todo: Equatable, Identifiable {
        let id: UUID
        var isComplete = false
        var description = ""
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then we get to shorten our creating of the `ForEach` a bit because it has a special initializer that works when you are dealing with collections of identifiable data:
      """#,
    timestamp: (20 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.todos) { todo in
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now that we have access to this todo, we can render its description:
      """#,
    timestamp: (20 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.state.todos) { todo in
        Text(todo.description)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now the `ForEach` is compiling, and if our SwiftUI preview had some todos in its store then they should render here on the right. To do that we can alter the initial state of the store to provide some mock todo items:
      """#,
    timestamp: (20 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
          ContentView(
            store: Store(
              initialState: AppState(
                todos: [
                  Todo(
                    description: "Milk",
                    id: UUID(),
                    isComplete: false
                  ),
                  Todo(
                    description: "Eggs",
                    id: UUID(),
                    isComplete: false
                  ),
                  Todo(
                    description: "Hand Soap",
                    id: UUID(),
                    isComplete: false
                  ),
                ]
              ),
              reducer: appReducer,
              environment: AppEnvironment()
            )
          )
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we've got some todos rendering from the state in our store.
      """#,
    timestamp: (20 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Implementing todo functionality"#,
    timestamp: (20 * 60 + 56),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Right now each todo row is a simple `Text` view, but really it should have a checkbox and a text field. That can be accomplished by using an `HStack` to put those views next to each other, and we can even use the new SF symbols for the checkbox icon:
      """#,
    timestamp: (21 * 60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      HStack {
        Image(systemName: "checkmark.square")
        Text(todo.description)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can now see the checkboxes in the interface, but the state of the todo should drive whether or not the checkbox is checked:
      """#,
    timestamp: (21 * 60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      HStack {
        Image(systemName: todo.isComplete ? "checkmark.square" : "square")
        Text(todo.description)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      For the checkbox to be functional we should wrap it in a button.
      """#,
    timestamp: (22 * 60 + 8),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      HStack {
        Button(action: {}) {
          Image(systemName: todo.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())

        Text(todo.description)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We gave the button a "plain button style" because otherwise the default behavior of tapping a button in a SwiftUI list highlights the entire row.
      """#,
    timestamp: (22 * 60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next, we should render the description of the todo in a text field so that it can be edited. Text fields take a placeholder and a binding that manages the state of the text. For now we can use a "constant" binding that holds onto the todo's description.
      """#,
    timestamp: (22 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      HStack {
        Button(action: {}) {
          Image(systemName: todo.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())

        TextField(
          "Untitled todo",
          text: .constant(todo.description)
        )
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can even make sure that the completed styling is working correctly by editing one of our initial todos to be completed:
      """#,
    timestamp: (23 * 60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Todo(
        description: "Hand Soap",
        id: UUID(),
        isComplete: true
      ),
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And we see that the row is now properly checked off, though it's a little difficult to see, so maybe we can also grey out the entire row once the todo is completed:
      """#,
    timestamp: (23 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .foregroundColor(todo.isComplete ? .gray : nil)
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now things are rendering much better.
      """#,
    timestamp: (23 * 60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now that we have the basic skeleton of the app in place, we can start to fill in some of the actions that can happen in this UI. For example, in each of these rows the user can tap the checkbox button and they can edit the text field. If we modeled these actions naively we might be tempted to do this:
      """#,
    timestamp: (23 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
        case todoCheckboxTapped
        case todoTextFieldChanged(String)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However this isn't right because we also need to know at what index each of these actions happened. Changing the description in row 1 versus row 2 is very different, and we need to be able to handle that in the action. So really we should have something like:
      """#,
    timestamp: (24 * 60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
        case todoCheckboxTapped(index: Int)
        case todoTextFieldChanged(index: Int, text: String)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now that we've got some actions in place we can finally implement a bit of business logic in our reducer. We can start by expanding the cases we are missing in the `switch`:
      """#,
    timestamp: (24 * 60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
        switch action {
        case .todoCheckboxTapped(index: let index):

        case .todoTextFieldChanged(index: let index, text: let text):

        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And remember for each of these cases we have 2 things to accomplish: we need to make any necessary state mutations, and we need to return any effects that we want to execute.
      """#,
    timestamp: (24 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      When the todo checkbox is tapped we just want to toggle the `isComplete` boolean for that particular todo. We can do this by indexing into the `todos` array and using the `toggle` mutating method on booleans:
      """#,
    timestamp: (24 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      state.todos[index].isComplete.toggle()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We don't need to execute any effects so we can return the special `.none` effect that does nothing:
      """#,
    timestamp: (25 * 60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      case let .todoCheckboxTapped(index: index):
        state.todos[index].isComplete.toggle()
        return .none
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      One thing to note here is that when we developed the Composable Architecture [in episodes](/collections/composable-architecture/side-effects) we returned an array of effects from the reducer. This was so that we could execute multiple effects from a single action. However, the Combine framework comes with operators that can combine multiple effects into a single one, in particular the merge and concatenate operators. So it's not really necessary to return an array, and that's why now reducers can return a single effect.
      """#,
    timestamp: (25 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next, when the text field is changed for a particular todo we want to do something similar, except we want to change the `description`  field of the todo:
      """#,
    timestamp: (25 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      case .todoTextFieldChanged(index: let index, text: let text):
        state.todos[index].description = text
        return .none
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And that rounds out the bit of business logic that we can actually handle right now. We want to again point out that reducers are the glue that bind together state, actions, and effects. They only have two responsibilities: perform mutations to the current state and return effects that will later be executed in the outside world.
      """#,
    timestamp: (26 * 60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      In order for this business logic to actually be executed we need to send actions to the store. We do this by tapping into the action closures and bindings that SwiftUI exposes to us for their components. For example, the checkbox button we created has an action closure, and we'd like to send the `.todoCheckboxTapped` action to the store:
      """#,
    timestamp: (26 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Button(action: { viewStore.send(.todoCheckboxTapped(index: ???)) }) {
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      However, the action requires an index of the row being interacted with, which we don't have access to. One way to get access to that index is to call `.enumerated()` on our todos:
      """#,
    timestamp: (26 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(viewStore.todos.enumerated()) { index, todo in
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is technically not the most correct way to do this. It would be more correct, and more verbose, to zip the `todos` array with its indices collection. In this case we are safe because we are dealing with a simple 0-based index array, but if we were doing this in production we should probably `zip`-based approach.
      """#,
    timestamp: (27 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      There is another problem, which is that the collection returned by `enumerated()` is not a `RandomAccessCollection`, which `ForEach` requires, and its elements are not `Identifiable`. So we have to further wrap this in an `Array` and we have to specify what we want identify by:
      """#,
    timestamp: (27 * 60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And finally we have access to the index, and so can send indexed actions quite easily, like for the button:
      """#,
    timestamp: (28 * 60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Button(action: { viewStore.send(.todoCheckboxTapped(index: index)) }) {
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The next action we want to send is the `.todoTextFieldChanged` action whenever the text changes in the text field. This is done differently from buttons. Text fields require a binding through which we can set the value in the text field and get notified of updates to the text field.
      """#,
    timestamp: (28 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The `ViewStore` object comes with a helper method that is specifically for deriving bindings for situations like this. We can create a binding by describing what state in the store should be used for the binding, and specifying what action should be sent when the binding changes:
      """#,
    timestamp: (28 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      TextField(
        "Untitled Todo",
        text: viewStore.binding(
          get: { $0.todos[index].description },
          send: { .todoTextFieldChanged(index: index, text: $0) }
        )
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is looking a little gnarly, but we are going to have a really nice way to clean it up soon.
      """#,
    timestamp: (29 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We now have enough infrastructure in place to get a somewhat functional app going. If we run our SwiftUI preview we can now check and uncheck the todos, and we can edit the text field. However, how do we know that editing the text field is really changing our state like we expect? For the checkbox we can clearly see that state must be updated because that's the only way the checkbox gets a check image and how the color turns grey.
      """#,
    timestamp: (29 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Debugging"#,
    timestamp: (30 * 60 + 8),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Well, this gives us an opportunity to demonstrate a wonderful debugging feature of the Composable Architecture. Every reducer comes with a method called `debug` which logs every action that is sent to the store, as well as the resulting state change. We can add this method in a few spots. If we wanted to print all actions for the entire application we could add it to the reducer in the scene delegate:
      """#,
    timestamp: (30 * 60 + 8),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let contentView = ContentView(
        store: Store(
          initialState: AppState(
            todos: [
              Todo(id: UUID()),
              Todo(id: UUID()),
            ]
          ),
          reducer: appReducer.debug(),
          environment: ()
        )
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Or if we wanted to localize it to just a specific reducer we could attach it at the end:
      """#,
    timestamp: (30 * 60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
        …
      }
      .debug()
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Both approaches are valid and each has their uses. For now we'll just leave the `.debug` directly on the reducer.
      """#,
    timestamp: (30 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Now, when we run the app every single action will print a super informative message showing exactly what parts of the state were changed:
      """#,
    timestamp: (30 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      received action:
        AppAction.todoCheckboxTapped(
          index: 0
        )
        AppState(
          todos: [
            Todo(
      −       isComplete: false,
      +       isComplete: true,
              description: "Milk",
              id: 5834811A-83B4-4E5E-BCD3-8A38F6BDCA90
            ),
            Todo(
              isComplete: false,
              description: "Eggs",
              id: AB3C7921-8262-4412-AA93-9DC5575C1107
            ),
            Todo(
              isComplete: true,
              description: "Hand Soap",
              id: 06E94D88-D726-42EF-BA8B-7B4478179D19
            ),
          ]
        )
      """#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
      From this we can very clearly see that when the `todoCheckboxTapped` action was received by the store it caused the second todo item to flip its `isComplete` from `false` to `true`, and nothing else changed.
      """#,
    timestamp: (31 * 60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Further, as we type into the text field we will see that the `description` field of the todo does indeed update:
      """#,
    timestamp: (31 * 60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      received action:
        AppAction.todoTextFieldChanged(
          index: 2,
          text: "Buy Hand Soap",
        )
        AppState(
          todos: [
            Todo(
              isComplete: true,
              description: "Milk",
              id: 5834811A-83B4-4E5E-BCD3-8A38F6BDCA90
            ),
            Todo(
              isComplete: false,
              description: "Eggs",
              id: AB3C7921-8262-4412-AA93-9DC5575C1107
            ),
            Todo(
              isComplete: true,
      −       description: "BuyHand Soap",
      +       description: "Buy Hand Soap",
              id: 06E94D88-D726-42EF-BA8B-7B4478179D19
            ),
          ]
        )
      """#,
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so it seems that our reducer logic is executing correctly. The `.debug`  helper is great for making sure that actions are being sent correctly and state is mutating how you expect. An even better way to verify this would be to write tests, and we'll do that soon.
      """#,
    timestamp: (31 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Next time: collections of domain"#,
    timestamp: (32 * 60 + 32),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Before moving onto more application functionality, let's do something to clean up our reducer and view. Right now we're doing a lot of index juggling. Let's see what the Composable Architecture gives us to simplify that...next time!
      """#,
    timestamp: (32 * 60 + 32),
    type: .paragraph
  ),
]
