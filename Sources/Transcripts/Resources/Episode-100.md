## Introduction

@T(00:00:05)
Welcome to the 100th episode of Point-Free! 🚀

@T(00:00:11)
It's hard to believe this is our 100th episode. We've been doing this series for 2 years and 3 months, and we've gone places in the past 99 episodes that we never could have predicted we would have ended up. And today is no exception. This week we are excited to announce that we are finally open sourcing [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) that we have been building for the past 9 months.

@T(00:00:37)
For those that haven't been [following along](/collections/composable-architecture), here's a little bit of history of what we have accomplished:

@T(00:00:47)
[We started this series](/collections/composable-architecture/swiftui-and-state-management) of episodes by first taking a look at what SwiftUI gives us out of the box, and it was pretty amazing. The ability to build views declaratively and model state in a lightweight way so that changes to state are instantly reflected in your UI is incredible. However, we identified a few problems that SwiftUI does not try to solve, and wondered what we could do to solve those problems in a cohesive, holistic package.

@T(00:01:15)
And so we introduced the idea of the Composable Architecture. An opinionated library that tells us exactly how we should build our applications so that we can get a lot of extra benefits that a vanilla SwiftUI application does not have.

@T(00:01:29)
We started by showing how the Composable Architecture is, well, [composable](/collections/composable-architecture/reducers-and-stores). It comes with a few basic operators that allows us to build many small features with the architecture, and then pull them back and combine them to form one big feature. This was instrumental in our work to break down a large, complex feature into many smaller, simpler features.

@T(00:01:49)
Next we showed that we could embrace the compositional operators we developed in order to fully [modularize](/collections/composable-architecture/modularity) our app. This meant that each feature could live in its own Swift module with as few dependencies between them as possible. This allowed us to build each feature in isolation, without needing to build the full application, and we could even run each feature as a little miniature application on its own. This came in handy in later episodes where we did broad refactorings of the architecture and our app and we never had to fix everything all at once. We could go feature by feature, fixing a little at a time and making sure that the refactor we were doing was the right choice.

@T(00:02:41)
Then we introduced [side effects](/collections/composable-architecture/side-effects) to the architecture. Side effects are by far the most complicated part of an application since they talk to the wild, vast, unknowable outside world, and the Composable Architecture has a very strong opinion on how side effects should be handled in your application. Many architectures out there aren't prescriptive with how side effects should be handled, but the Composable Architecture says that side effects should only be occur when wrapped up in a specific type called `Effect`, and you should never do a side effect outside of that little sandbox.

@T(00:03:14)
Next we showed [how to test](/collections/composable-architecture/testing) the composable architecture. We came up with an assertion helper that allows you to run a sequence of user actions, like the user tapping on a button or typing into a text field, and the helper forces you to assert on exactly how the state changes at each step of the way, and assert exactly how side effects are executed and what values were fed back into the system. We even got some extra exhaustivity checking with effects because the assertion helper forced us to to declare every effect output that was fed back into the system. This gave us broad coverage on both how the state of the application evolves over time and how effects interleave throughout the system.

@T(00:04:03)
As if that wasn't enough, we also showed that the Composable Architecture has a strong opinion on how [dependencies](/episodes/ep91-dependency-injection-made-composable) are managed. It tells us precisely how to model the application's dependencies and how to slice them up into smaller subsets so that you can hand just the bare essentials off to each feature.

@T(00:04:18)
And then most recently we showed how to make the Composable Architecture more [adaptable](/collections/composable-architecture/adaptation), so that we could build the core business logic in a fully agnostic manner, while then allowing views to adapt that logic to the domain that makes the most sense for them. This allowed us to have a single source of business logic powering an iOS app and a macOS app despite platform differences.

@T(00:04:41)
All of that work has culminated into open sourcing [the library](https://github.com/pointfreeco/swift-composable-architecture) that you can start using in your SwiftUI or UIKit application today. In this episode we want to give a little tour of the library, because there have been some improvements and additions that we did not cover in episodes. To demonstrate the library we are going to build a little todo app from scratch, and add a few bells and whistles to make things a little more interesting.

## Getting started

@T(00:05:02)
Let's take a quick look at how the library is structured.

@T(00:05:32)
- In the Sources directory we have the core library's code. It has all the types that we've covered over the past many months, such as `Reducer`, `Store`, and `Effect`, as well as some new things not yet seen in Point-Free episodes. There are schedulers, which we will see later in this series, and in some of these subdirectories there are all types of fun helpers built on top of the core architecture, such as navigation and binding helpers, as well as effect cancellation and effect debouncing. There's lots of fun stuff to explore in here.

@T(00:05:53)
- In the Examples directory we have a bunch of applications that help demonstrate many use cases and problems solved in the Composable Architecture. Everything from bindings and effects, to navigation and full-blown applications. Even more interesting than the applications is the test suites. Every application is fully tested, including edge cases, side effects, and subtle bits of logic.

@T(00:06:09)
In particular, we have a todos app. We can run the app to see a list of todos.

- The todo list can be filtered by whether a todo has been completed or not
- New todos can be added at the tap of a button
- Todos can be checked complete, which will sort them to the bottom of the list
- Completed todos can be cleared all at once
- And we can edit the list to re-sort and delete todos

@T(00:06:41)
This is the basic app we're going to walk through building today. We'll only be building a sub-set of its features, but we'll get a decent number of them done that will demonstrate what it means to build a decently complex feature using the Composable Architecture.

@T(00:06:55)
Let's get started in a fresh Xcode project:

@T(00:07:10)
Then we can add the library to this project by using Xcode's SPM integration:

> [https://github.com/pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)

@T(00:07:38)
The package comes with two libraries. The core library is `ComposableArchitecture`, which is what we want to use in our main Todos application. There is also a library `ComposableArchitectureTestSupport` that comes with some handy utilities for testing features built in the Composable Architecture. So let's make sure to add each library to the "Todos" and "TodosTests" targets.

> Correction: Since this episode was recorded, the `ComposableArchitectureTestSupport` module has merged into `ComposableArchitecture` and is no longer needed. You can now link your app target to `ComposableArchitecture` and will have access to test helpers in your test target.

## Setting up basic infrastructure

@T(00:08:05)
Now that the library is in place, let's start to get our hands dirty and actually build the application. There are a few ways we can get started with the Composable Architecture. Each is completely valid, and we could do many episodes covering each one, but roughly we could either:

@T(00:08:19)
- Begin by doing an abstract domain modeling exercise so that you can understand precisely what state and actions your features need, and from that you can build the reducer and view that realizes that domain.

@T(00:08:31)
- We can also start from the view, maybe looking at a mockup that your designer produced for you, and from that start sketching out a SwiftUI view, and then figuring out the domain of state and actions.

@T(00:08:46)
- Or we can do what we are going to do in this episode, and take a little bit from column A and a little bit from column B.

@T(00:08:52)
We're going to start with a little domain modeling. That is, we'll define the state our feature needs to do its job, we'll define the actions that can take place in our feature, and we'll define the environment of dependencies that our feature needs to perform effectful work. We can get some stubs in place for now:

```swift
struct AppState {
}
```

@T(00:09:00)
The state is typically a struct because it holds a bunch of independent pieces of data, though it does not always need to be a struct.

```swift
enum AppAction {
}
```

@T(00:09:14)
The actions are typically an enum because it represents one of many different types of actions that a user can perform in the UI, such as tapping a button or entering text into a text field.

```swift
struct AppEnvironment {
}
```

@T(00:09:35)
And finally, the environment is pretty much always a struct, because it holds all of the dependencies our feature needs to do its job, such as API clients, analytics clients, date initializers, schedulers, and more.

@T(00:09:52)
Next we would define a reducer for our application, which is the thing that glues together the state, action and environment into a cohesive package. It's the thing responsible for the business logic that runs the application. Creating one for our domain involves providing a closure that is handed the current state, an incoming action, and the environment:

```swift
let appReducer = Reducer<
  AppState, AppAction, AppEnvironment
> { state, action, environment in
}
```

@T(00:10:34)
In this closure is where we will put all of the logic for our application. We do this by switching over the action:

```swift
let appReducer = Reducer<
  AppState, AppAction, AppEnvironment
> { state, action, environment in
  switch action {
  }
}
```

@T(00:10:41)
And then in here we would consider each case in the `AppAction` enum, and for each case we would run the business logic related to that action. When we say business logic we mean something very specific. Business logic precisely corresponds to just two things:

@T(00:10:54)
- We will make any mutations to the state necessary for the action. The `state` value passed in here is an `inout` argument. So when an action comes in, say the user tapping the todo checkbox, we can just go into the state and mutate a todo's `isComplete` field to be `true`.

@T(00:11:12)
- After you have performed all of the mutations you want to state, you can return an effect. An effect is a special type that allows you to communicate with the outside world, like executing an API request, writing data to disk, or tracking analytics, and it allows you to feed data from the outside world back into this reducer.

@T(00:11:30)
These are the only two things you are allowed to do in a reducer. All the pure logic happens in the state mutations, and all the non-pure logic happens in the effects.

@T(00:11:44)
Currently we don't have any actions so there's nothing to do in this reducer just yet.

@T(00:11:47)
While the domain and reducer model our business logic in the nice, pure, functional world, they aren't enough to power our app. We need a runtime object that is responsible for powering our views by accumulating state changes over time. The object that does this in the Composable Architecture is known as the `Store`, and each view powered by the Composable Architecture will need to hold onto one of these.

@T(00:12:19)
So, let's go ahead and add one to our `ContentView`:

```swift
struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    Text("Hello, World!")
  }
}
```

@T(00:12:44)
There are two places where a `ContentView` is created: in the SwiftUI preview and in the scene delegate, and both have to be fixed to provide a store. To create a store we need the initial state of the application, the reducer that powers the business logic, and the environment that the store is running in:

```swift
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
```

@T(00:13:15)
For the initial state we can just use `AppState()`, for the reducer we can use the stubbed `appReducer` we defined earlier, and for the environment we can use `AppEnvironment()`:

```swift
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
```

@T(00:13:28)
And then in the scene delegate we can do something similar:

```swift
let contentView = ContentView(
  store: Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment()
  )
)
```

@T(00:13:47)
Let's get a little bit of the UI in place. We know we want a title for this screen, as well as a list, so we can start by wrapping a `List` component in a `NavigationView` and setting its title:

```swift
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
```

@T(00:14:24)
And now with that infrastructure in place we can start doing some domain modeling. Firstly, our application is a todo app, and so of course we're going to have a list of todos in our app state. Let's model a simple todo item as struct that has a description and a boolean flag that determines if it has been completed or not:

```swift
struct Todo {
  var description = ""
  var isComplete = false
}
```

@T(00:14:52)
And our app state should hold an array of these models:

```swift
struct AppState {
  var todos: [Todo] = []
}
```

@T(00:15:00)
And just from this we should be able to get something on the screen that is rendered from this state. We would like to use a `ForEach` view to render a row for each todo we have in our app state:

```swift
List {
  ForEach(self.store.state.todos) { todo in
    Text("Hello")
  }
  Text("Hello")
}
```

@T(00:15:36)
However, the store does not directly give you access to the state. If you recall from some of our most recent episodes, we require you to go through a secondary object to get access to state, called the `ViewStore`. We did this for 2 primary reasons:

@T(00:15:51)
- First, and most importantly, the `ViewStore` gave us the opportunity to chisel away the state that the view doesn't access need access to in order to render its UI. Typically a view will hold onto a lot of state, because it needs everything to not only render its own UI, but also all the state it is going to pass down to child views so that they can render themselves. But, this means that any little change to the state is going to cause all of these views re-compute themselves, and that can lead to performance problems. The `ViewStore` gave us the perfect opportunity to mold a feature's state into something domain specific that only it cares about, and that allowed us to skip out on a lot of over computation.

@T(00:16:29)
- Second, and just as important, the `ViewStore` allowed us to adapt our features to multiple platforms. We could implement the core logic of our feature a single time in the reducer, and then we could form projections of the general business domain into specific domains that make more sense for a platform. For example, on iOS we could show a modal when the user taps on a button, but on macOS we want to show a popover.

@T(00:16:53)
The way we use view stores in the library is going to look a little different from how it was covered in the episodes. Thanks to a collaboration with Point-Free viewer [Chris Liscio](https://twitter.com/liscio) we were able to make the ergonomics of the view store a lot nicer, and even improve its functionality.

@T(00:17:12)
Previously to use a view store you would add a field to your view to hold the view store and make it an `@ObservedObject`. Instead, now you just create a new special view that gives you access to a view store:

```swift
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
```

@T(00:18:00)
Now, inside here we will have access to all the state in the store and we can send it actions, but in order for the view store to know how to deduplicate emissions of state, we should make our state structs `Equatable`.

```swift
struct Todo: Equatable {
  var description = ""
  var isComplete = false
}

struct AppState: Equatable {
  var todos: [Todo]
}
```

@T(00:18:30)
And now we can render our list of todos:

```swift
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
```

@T(00:18:38)
Even better, the `ViewStore` makes use of dynamic member lookup, which allows us to access the properties on the `state` field as if they lived directly on the view store:

```swift
ForEach(viewStore.todos) { todo in
```

@T(00:18:47)
We're getting closer, but unfortunately this doesn't work just yet because `ForEach` doesn't work on just any type of collection. There are a few initializers we can choose from, each with their own requirements.

@T(00:19:02)
For example, one initializer of `ForEach` has us specify an `id` key path that is supposed to pluck out a piece of `Hashable` data from the `Todo` so that it can use that info to identify each element of the collection:

```swift
ForEach(viewStore.todos, id: <#KeyPath<_.Element, _>#>) {
```

@T(00:19:18)
Right now our `Todo` doesn't have any uniquely identifying information in it. It's just a string description and boolean flag, and it's totally possible for two different todos to have identical values for those fields.

@T(00:19:30)
So, what we can do is introduce an `id` to our `Todo` model that can be used to distinguish otherwise equal todos:

```swift
struct Todo: Equatable {
  var description = ""
  let id: UUID
  var isComplete = false
}
```

@T(00:19:45)
And then our `ForEach` can pluck out that id to help with identifying elements:

```swift
ForEach(viewStore.todos, id: \.id) { todo in
```

@T(00:19:51)
But even better, there is a protocol in Swift called `Identifiable` that expresses types that carry a uniquely identifying piece of data, such as this `UUID` on `Todo`. We can make `Todo` conform to it immediately because it already satisfies its one requirement: have any `id` field that is `Hashable`:

```swift
struct Todo: Equatable, Identifiable {
  let id: UUID
  var isComplete = false
  var description = ""
}
```

@T(00:20:13)
And then we get to shorten our creating of the `ForEach` a bit because it has a special initializer that works when you are dealing with collections of identifiable data:

```swift
ForEach(viewStore.todos) { todo in
```

@T(00:20:26)
And now that we have access to this todo, we can render its description:

```swift
ForEach(viewStore.state.todos) { todo in
  Text(todo.description)
}
```

@T(00:20:38)
Now the `ForEach` is compiling, and if our SwiftUI preview had some todos in its store then they should render here on the right. To do that we can alter the initial state of the store to provide some mock todo items:

```swift
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
```

@T(00:20:52)
And now we've got some todos rendering from the state in our store.

## Implementing todo functionality

@T(00:21:26)
Right now each todo row is a simple `Text` view, but really it should have a checkbox and a text field. That can be accomplished by using an `HStack` to put those views next to each other, and we can even use the new SF symbols for the checkbox icon:

```swift
HStack {
  Image(systemName: "checkmark.square")
  Text(todo.description)
}
```

@T(00:21:54)
We can now see the checkboxes in the interface, but the state of the todo should drive whether or not the checkbox is checked:

```swift
HStack {
  Image(
    systemName: todo.isComplete
      ? "checkmark.square"
      : "square"
  )
  Text(todo.description)
}
```

@T(00:22:08)
For the checkbox to be functional we should wrap it in a button.

```swift
HStack {
  Button(action: {}) {
    Image(
      systemName: todo.isComplete
        ? "checkmark.square"
        : "square"
    )
  }
  .buttonStyle(PlainButtonStyle())

  Text(todo.description)
}
```

@T(00:22:15)
We gave the button a "plain button style" because otherwise the default behavior of tapping a button in a SwiftUI list highlights the entire row.

@T(00:22:29)
Next, we should render the description of the todo in a text field so that it can be edited. Text fields take a placeholder and a binding that manages the state of the text. For now we can use a "constant" binding that holds onto the todo's description.

```swift
HStack {
  Button(action: {}) {
    Image(
      systemName: todo.isComplete
        ? "checkmark.square"
        : "square"
    )
  }
  .buttonStyle(PlainButtonStyle())

  TextField(
    "Untitled todo",
    text: .constant(todo.description)
  )
}
```

@T(00:23:02)
We can even make sure that the completed styling is working correctly by editing one of our initial todos to be completed:

```swift
Todo(
  description: "Hand Soap",
  id: UUID(),
  isComplete: true
),
```

@T(00:23:10)
And we see that the row is now properly checked off, though it's a little difficult to see, so maybe we can also grey out the entire row once the todo is completed:

```swift
.foregroundColor(todo.isComplete ? .gray : nil)
```

@T(00:23:29)
And now things are rendering much better.

@T(00:23:33)
Now that we have the basic skeleton of the app in place, we can start to fill in some of the actions that can happen in this UI. For example, in each of these rows the user can tap the checkbox button and they can edit the text field. If we modeled these actions naively we might be tempted to do this:

```swift
enum AppAction {
  case todoCheckboxTapped
  case todoTextFieldChanged(String)
}
```

@T(00:24:11)
However this isn't right because we also need to know at what index each of these actions happened. Changing the description in row 1 versus row 2 is very different, and we need to be able to handle that in the action. So really we should have something like:

```swift
enum AppAction {
  case todoCheckboxTapped(index: Int)
  case todoTextFieldChanged(index: Int, text: String)
}
```

@T(00:24:37)
Now that we've got some actions in place we can finally implement a bit of business logic in our reducer. We can start by expanding the cases we are missing in the `switch`:

```swift
let appReducer = Reducer<
  AppState, AppAction, Void
> { state, action, _ in
  switch action {
  case .todoCheckboxTapped(index: let index):

  case .todoTextFieldChanged(index: let index, text: let text):

  }
}
```

@T(00:24:48)
And remember for each of these cases we have 2 things to accomplish: we need to make any necessary state mutations, and we need to return any effects that we want to execute.

@T(00:24:58)
When the todo checkbox is tapped we just want to toggle the `isComplete` boolean for that particular todo. We can do this by indexing into the `todos` array and using the `toggle` mutating method on booleans:

```swift
state.todos[index].isComplete.toggle()
```

@T(00:25:16)
We don't need to execute any effects so we can return the special `.none` effect that does nothing:

```swift
case let .todoCheckboxTapped(index: index):
  state.todos[index].isComplete.toggle()
  return .none
```

@T(00:25:22)
One thing to note here is that when we developed the Composable Architecture [in episodes](/collections/composable-architecture/side-effects) we returned an array of effects from the reducer. This was so that we could execute multiple effects from a single action. However, the Combine framework comes with operators that can combine multiple effects into a single one, in particular the merge and concatenate operators. So it's not really necessary to return an array, and that's why now reducers can return a single effect.

@T(00:25:47)
Next, when the text field is changed for a particular todo we want to do something similar, except we want to change the `description`  field of the todo:

```swift
case .todoTextFieldChanged(index: let index, text: let text):
  state.todos[index].description = text
  return .none
```

@T(00:26:09)
And that rounds out the bit of business logic that we can actually handle right now. We want to again point out that reducers are the glue that bind together state, actions, and effects. They only have two responsibilities: perform mutations to the current state and return effects that will later be executed in the outside world.

@T(00:26:27)
In order for this business logic to actually be executed we need to send actions to the store. We do this by tapping into the action closures and bindings that SwiftUI exposes to us for their components. For example, the checkbox button we created has an action closure, and we'd like to send the `.todoCheckboxTapped` action to the store:

```swift
Button(action: {
  viewStore.send(.todoCheckboxTapped(index: <#???#>))
}) {
  …
}
```

@T(00:26:52)
However, the action requires an index of the row being interacted with, which we don't have access to. One way to get access to that index is to call `.enumerated()` on our todos:

```swift
ForEach(viewStore.todos.enumerated()) { index, todo in
  …
}
```

@T(00:27:13)
This is technically not the most correct way to do this. It would be more correct, and more verbose, to zip the `todos` array with its indices collection. In this case we are safe because we are dealing with a simple 0-based index array, but if we were doing this in production we should probably `zip`-based approach.

@T(00:27:42)
There is another problem, which is that the collection returned by `enumerated()` is not a `RandomAccessCollection`, which `ForEach` requires, and its elements are not `Identifiable`. So we have to further wrap this in an `Array` and we have to specify what we want identify by:

```swift
ForEach(
  Array(viewStore.todos.enumerated()), id: \.element.id
) { index, todo in
  …
}
```

@T(00:28:09)
And finally we have access to the index, and so can send indexed actions quite easily, like for the button:

```swift
Button(action: {
  viewStore.send(.todoCheckboxTapped(index: index))
}) {
  …
}
```

@T(00:28:14)
The next action we want to send is the `.todoTextFieldChanged` action whenever the text changes in the text field. This is done differently from buttons. Text fields require a binding through which we can set the value in the text field and get notified of updates to the text field.

@T(00:28:32)
The `ViewStore` object comes with a helper method that is specifically for deriving bindings for situations like this. We can create a binding by describing what state in the store should be used for the binding, and specifying what action should be sent when the binding changes:

```swift
TextField(
  "Untitled Todo",
  text: viewStore.binding(
    get: { $0.todos[index].description },
    send: { .todoTextFieldChanged(index: index, text: $0) }
  )
)
```

@T(00:29:34)
This is looking a little gnarly, but we are going to have a really nice way to clean it up soon.

@T(00:29:38)
We now have enough infrastructure in place to get a somewhat functional app going. If we run our SwiftUI preview we can now check and uncheck the todos, and we can edit the text field. However, how do we know that editing the text field is really changing our state like we expect? For the checkbox we can clearly see that state must be updated because that's the only way the checkbox gets a check image and how the color turns grey.

## Debugging

@T(00:30:08)
Well, this gives us an opportunity to demonstrate a wonderful debugging feature of the Composable Architecture. Every reducer comes with a method called `debug` which logs every action that is sent to the store, as well as the resulting state change. We can add this method in a few spots. If we wanted to print all actions for the entire application we could add it to the reducer in the scene delegate:

```swift
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
```

@T(00:30:34)
Or if we wanted to localize it to just a specific reducer we could attach it at the end:

```swift
let appReducer = Reducer<
  AppState, AppAction, Void
> { state, action, _ in
  …
}
.debug()
```

@T(00:30:46)
Both approaches are valid and each has their uses. For now we'll just leave the `.debug` directly on the reducer.

@T(00:30:52)
Now, when we run the app every single action will print a super informative message showing exactly what parts of the state were changed:

```diff
received action:
  AppAction.todoCheckboxTapped(
    index: 0
  )
  AppState(
    todos: [
      Todo(
-       isComplete: false,
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
```

@T(00:31:07)
From this we can very clearly see that when the `todoCheckboxTapped` action was received by the store it caused the second todo item to flip its `isComplete` from `false` to `true`, and nothing else changed.

@T(00:31:36)
Further, as we type into the text field we will see that the `description` field of the todo does indeed update:

```diff
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
-       description: "BuyHand Soap",
+       description: "Buy Hand Soap",
        id: 06E94D88-D726-42EF-BA8B-7B4478179D19
      ),
    ]
  )
```

@T(00:31:56)
And so it seems that our reducer logic is executing correctly. The `.debug`  helper is great for making sure that actions are being sent correctly and state is mutating how you expect. An even better way to verify this would be to write tests, and we'll do that soon.

## Next time: collections of domain

@T(00:32:32)
Before moving onto more application functionality, let's do something to clean up our reducer and view. Right now we're doing a lot of index juggling. Let's see what the Composable Architecture gives us to simplify that...next time!
