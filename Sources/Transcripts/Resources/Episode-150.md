## Introduction

@T(00:00:05)
So this is pretty cool. Using some pretty advanced techniques from SwiftUI we have been able to build tools for the Composable Architecture that allow us to embrace better data modeling for our applications. We can now use enums for our state and emulate the idea of destructuring a store by using a `SwitchStore` view with a bunch of `CaseLet` views inside. We can even provide some basic support for exhaustivity checking so that if the state gets into a case that is not handled by a `CaseLet` view we will breakpoint to let the developer know there’s additional state to handle. And on top of all that we’ve even made the view efficient by making sure it recomputes its body if and only if the case of the enum changes.

@T(00:00:44)
We can even push some of these ideas a bit further. With a little bit of extra work you can also support default-like statements for `SwitchStore`. This can be handy if you have a lot of cases in your enum and you want to handle only a few while allowing all the others to fall through to a default view. We have some exercises for this episode that will help you explore these ideas.

@T(00:01:04)
In the past 4 episodes we have really dug deep into the concept of “deriving behavior”, which means how do we take a big blob of “behavior” for our application and break it down into smaller pieces. This is important for building small, understandable units for your application that can be plugged together to form the full application, as well as for modularizing your application which comes with a ton of benefits.

@T(00:01:30)
We started this exploration by first showing what this concept looks like in vanilla SwiftUI by using `ObservableObject`s. Apple doesn’t give us direct tools to be used for this problem, but we are able to use some tools from Combine in order to break down large view models into smaller domains. We got it to work, but it wasn’t exactly pretty. We had to do extra work to get the parent domain to update when a child domain changed, and we had to do some trickery to synchronize changes between sibling child domains without introducing memory leaks or infinite loops.

@T(00:02:02)
Then we turned our attention to the Composable Architecture. We showed that out of the box the library gives us a tool for breaking down large pieces of application logic into smaller pieces, which is the `.pullback` operator on reducers. And the library gives us a tool for breaking down large runtimes, which is the thing that actually powers our views, into smaller pieces by using the `.scope` operator on stores. These two tools allowed us to build features in isolation without any understanding of how they will be plugged into the larger application, and then it was trivial to integrate child feature into parent features.

@T(00:02:32)
Once we got a feeling for how pulling back and scoping work in the Composable Architecture we started flexing those muscles more. We started exploring tools that allow us to embed our domains into a variety of data structures, such as collections, optionals and enums. This includes using reducer operators such as the `.forEach` operator that allows you to run a reducer on every element of a collection, the `.optional` operator that enhances a reducer to work on optional state, and even a new version of `.pullback` that pulls back along state case paths for when your state is an enum. Corresponding to each of those reducer operators were new SwiftUI views for transforming the store, such as the `ForEachStore`, `IfLetStore` and even `SwitchStore`.

@T(00:02:59)
That was all pretty amazing, but now it’s time to ask: what’s the point? This is our opportunity to try to bring things down to earth and maybe even dig in a little deeper. This time we want to end this series of episodes like we started: we want to show what one must do in vanilla SwiftUI to handle things like collections of domains and optional domains so that we can better understand how it compares to the Composable Architecture and see why it is important to have tools that are tailored for these use cases.

@T(00:03:29)
So, let’s try building our demo app with the collection of counters and fact banner in vanilla SwiftUI...next time!

## Vanilla counter

@T(00:03:40)
Here we are back in our demo application that shows how to build a list of counters that each operate independently, and if you ask for a fact you get this little banner at the bottom, and even within the banner you can ask for more facts.

@T(00:03:56)
Let’s do the opposite of what we did at the beginning of the series: rather than take a vanilla SwiftUI app and translate it to the Composable Architecture we will take this more complicated Composable Architecture application and translate it to vanilla SwiftUI. We’ll do this conversion piece-by-piece so that we can see how the patterns of collections of behavior and optional behavior translate over to observable objects and view models. We’ll start with the leaf nodes and work our way back to the root view.

@T(00:04:25)
We can create a new file for our vanilla SwiftUI version of the app.

@T(00:04:30)
And we’ll copy over just the counter feature that is currently built in the Composable Architecture in order to convert it. Remember that the counter is a completely isolated feature and could even be extracted out into its own module so that it is provably isolated from the rest of the application. We would hope we can do the same in vanilla SwiftUI.

@T(00:04:55)
The Composable Architecture counter feature begins with a domain modeling exercise to figure out the features state, actions and environment and then implements a reducer to glue all of that together to form the feature’s logic. In vanilla SwiftUI all of that comes in a single package, which is the observable object. So let’s start there:

```swift
class CounterViewModel: ObservableObject {
  …
}
```

@T(00:05:27)
Each of the properties in the `CounterState` struct should become a `@Published` field in the view model:

```swift
class CounterViewModel: ObservableObject {
  @Published var alert: Alert?
  @Published var count = 0

  struct Alert: Equatable, Identifiable {
    var message: String
    var title: String

    var id: String {
      self.title + self.message
    }
  }
}
```

@T(00:05:39)
Then each case in the `CounterAction` becomes a method endpoint that can be invoked from the view:

```swift
class CounterViewModel: ObservableObject {
  …

  func decrementButtonTapped() {
  }

  func dismissAlert() {
  }

  func incrementButtonTapped() {
  }

  func factButtonTapped() {
  }

  func factResponse(result: Result<String, FactClient.Error>) {
  }
}
```

@T(00:06:00)
Inside each of these endpoints we will execute the business logic that happens in the reducer. The first three are straightforward mutations that basically translate directly, except we use `self` instead of `state`:

```swift
func decrementButtonTapped() {
  // state.count -= 1
  self.count -= 1
}

func dismissAlert() {
  // state.alert = nil
  self.alert = nil
}

func incrementButtonTapped() {
  // state.count += 1
  self.count += 1
}
```

@T(00:06:22)
The `factButtonTapped` method involves a side effect, which means we need to introduce dependencies to our view model so that this code has a chance at being testable. We can copy over the dependencies from the `CounterEnvironment`:

```swift
class CounterViewModel: ObservableObject {
  …

  let fact: FactClient
  let mainQueue: AnySchedulerOf<DispatchQueue>

  …
}
```

> Error: Cannot find type 'AnySchedulerOf' in scope

@T(00:06:42)
We now need to import `CombineSchedulers` to get access to the `AnySchedulerOf` type eraser:

```swift
import CombineSchedulers
```

> Error: Class 'CounterViewModel' has no initializers

@T(00:06:53)
And since we are dealing with a class now we are forced to provide an initializer:

```swift
init(
  fact: FactClient,
  mainQueue: AnySchedulerOf<DispatchQueue>
) {
  self.fact = fact
  self.mainQueue = mainQueue
}
```

@T(00:07:07)
In the Composable Architecture, reducers communicate with the outside world by returning effects that are run by the `Store` and their output is fed back into the system via another action.

```swift
return environment.fact.fetch(state.count)
  .receive(on: environment.mainQueue.animation())
  .catchToEffect()
  .map(CounterAction.factResponse)
```

@T(00:07:30)
View models aren’t forced into this rigid framework, so we can simply perform the side effect in-line by `sink`ing on the publisher:

```swift
self.fact.fetch(self.count)
  .receive(on: self.mainQueue.animation())
  .sink(
    receiveCompletion: <#((Subscribers.Completion<FactClient.Error>) -> Void)#>,
    receiveValue: <#(String) -> Void#>
  )
```

@T(00:07:57)
We can handle failure in the completion block by showing an alert:

```swift
receiveCompletion: { [weak self] completion in
  if case .failure = completion {
    self?.alert = Alert(message: "Couldn't load fact.", title: "Error")
  }
},
```

@T(00:08:18)
Notice that we have to deal with memory management now since we are dealing with reference types. Here we have opted to capture `self` weakly, but others may prefer to use an `unowned self`, or even allow capturing `self` strongly since the `fetch` publisher shouldn’t be long living.

@T(00:08:54)
If a fact received:

```swift
receiveValue: { fact in
  <#???#>
}
```

@T(00:08:56)
What should we do here? In the Composable Architecture version of this application, the parent listens for this event so that it can show the fact banner at the bottom of the screen. So it looks like we will need a way to communicate from the counter domain up to the parent, but we will put that off for now and try figuring that out in a bit.

@T(00:09:22)
We have a warning, however:

> Warning: Result of call to 'sink(receiveCompletion:receiveValue:)' is unused

@T(00:09:24)
We have to now explicitly hold onto this cancellable. This wasn’t necessary in the Composable Architecture version of the code because the `Store` is responsible for running all effects and it manages the set of cancellables for the entire application.

@T(00:09:27)
But now we have to do that work ourselves, so let’s introduce a set of cancellables:

```swift
private var cancellables: Set<AnyCancellable> = []
```

@T(00:09:36)
And store the fetch cancellable in that set:

```swift
self.fact.fetch(self.count)
  …
  .store(in: &self.cancellables)
```

@T(00:09:40)
The view model is now compiling, and it doesn’t look like we even needed the `factResponse` method so let’s get rid of it.

@T(00:09:47)
Now that we have a compiling view model we can delete the reducer.

@T(00:09:56)
And start working on the view. We’ll rename the view to `VanillaCounterView`:

```swift
struct VanillaCounterView: View {
  …
}
```

@T(00:10:01)
Then we’ll swap out the `store` for a `viewModel`, and it will be an `@ObservedObject`:

```swift
struct VanillaCounterView: View {
 // let store: Store<CounterState, CounterAction>
  @ObservedObject var viewModel: CounterViewModel

  …
}
```

@T(00:10:09)
We no longer need the `WithViewStore` concept to observe state changes because that’s happening automatically by virtue of the fact that we are using an `@ObservedObject` with our view model, so we can get rid of that wrapping view.

@T(00:10:16)
For the parts of the view that were previously sending actions to the `viewStore` we can now just invoke methods, and accessing the state in the `viewModel` is the same as the `viewStore`:

```swift
VStack {
  HStack {
    Button("-") { self.viewModel.decrementButtonTapped() }
    Text("\(self.viewModel.count)")
    Button("+") { self.viewModel.incrementButtonTapped() }
  }

  Button("Fact") { self.viewModel.factButtonTapped() }
}
```

@T(00:10:36)
For the `.alert` we can swap out the `viewStore.binding` helper for deriving a binding straight from the view model:

```swift
.alert(item: self.$viewModel.alert) { alert in
  Alert(
    title: Text(alert.title),
    message: Text(alert.message)
  )
}
```

@T(00:11:06)
And just like that our new view model is compiling. Looks like we didn’t even need the `dismissAlert` endpoint, so we can delete that method as well.

@T(00:11:16)
To make sure that this feature works correct we can create a new Xcode preview by constructing a `VanillaCounterView` that is passed a view model, and to construct that view model we need to provide its dependencies:

```swift
struct Vanilla_Previews: PreviewProvider {
  static var previews: some View {
    VanillaCounterView(
      viewModel: .init(
        fact: .live,
        mainQueue: .main
      )
    )
  }
}
```

@T(00:11:45)
Counting up and down works just fine in the preview, but tapping the “Fact” button doesn’t do anything because the parent is supposed to handle that functionality.

## Vanilla counter row

@T(00:12:03)
We've already converted one of our Composable Architecture features to a vanilla SwiftUI view model. The biggest difference is that view models merge a bunch of concepts into one, whereas in the Composable Architecture, concepts are split into the pure logical reducer and the runtime store. View models smash logic and runtime together into a single unit. Vanilla SwiftUI is also a little bit shorter, which is nice.

@T(00:12:52)
Now that the counter domain has been converted to vanilla SwiftUI, let’s see what we can do about the counter row, which is just a small wrapper around the counter in order to show the feature inside the row of a list alongside a remove button.

@T(00:13:14)
We can follow the same steps as before. Let’s copy and paste the counter row domain over to this file and start converting it piecemeal. We will create a `CounterRowViewModel` observable object to represent the state and behavior of the feature:

```swift
class CounterRowViewModel: ObservableObject, Identifiable {
  …
}
```

@T(00:13:30)
Previously the Composable Architecture version of this domain held onto the counter domain. This means `CounterRowState` held onto a copy of `CounterState`, `CounterRowAction` held onto `CounterAction`s, and the logic of the counter row was run off of the `counterReducer`. If in the future the counter row needs to run its own logic, it would have defined a new reducer for itself, and then combined it with the `counterReducer` pulled back to counter row domain.

@T(00:13:39)
In order to emulate this idea in vanilla SwiftUI we will hold onto a `CounterViewModel` from inside the `CounterRowViewModel`:

```swift
class CounterRowViewModel: ObservableObject {
  let counter: CounterViewModel
}
```

@T(00:13:40)
Now we are instantly faced with some things that we have to think about here. First off, we are nesting a view model inside a view model, which means its a reference type inside a reference type, and that can be tricky. Semantics of reference types can already be tricky since every mutation leaks to the outside world, but nesting them becomes even more subtle.

@T(00:14:01)
Second, we currently bind the `counter` variable with a `let`, but we are used to using `@Published var` fields in view models:

```swift
class CounterRowViewModel: ObservableObject, Identifiable {
  @Published var counter: CounterViewModel
}
```

@T(00:14:11)
However, this doesn’t work as you might expect. Any mutation that happens inside the `CounterViewModel` will not be observed by the `@Published` property wrapper. Only if you wholesale replace the entirety of `counter` with a fresh value will it be triggered.

@T(00:14:26)
So, we’re not sure if it’s more appropriate to use `let` or `@Published var`, but we’ll just keep it like this for now.

@T(00:14:36)
The `CounterRowState` had another field on it for uniquely identifying it amongst many a collection, and this value should not change so it is appropriate to just hold it as a `let`:

```swift
let id: UUID
```

@T(00:14:48)
Since the view model is a class we need to provide an initializer, whereas structs get an internal one automatically synthesized, so we’ll define one from scratch:

```swift
init(counter: CounterViewModel, id: UUID) {
  self.counter = counter
  self.id = id
}
```

@T(00:15:01)
Next we need to convert the `CounterRowAction`s into view model methods. All of the `CounterAction`s live on the `CounterViewModel` now, so anytime we want to invoke one of those we can just reach through the `counter` field to do so.

@T(00:15:17)
The one endpoint we do need to move over to the view model is `removeButtonTapped`:

```swift
func removeButtonTapped() {

}
```

@T(00:15:27)
But again, this logic does not live directly in this domain but rather is handled by the parent. We will need some way to have this child domain to communicate with the parent, which we will handle soon.

@T(00:15:45)
Next, in the view we just need to replace any references to `viewStore` with `viewModel`:

```swift
struct VanillaCounterRowView: View {
  @ObservedObject var viewModel: CounterRowViewModel

  var body: some View {
    HStack {
      VanillaCounterView(
        viewModel: self.viewModel.counter
      )
      .buttonStyle(PlainButtonStyle())
      Spacer()
      Button("Remove") {
        withAnimation {
          self.viewModel.removeButtonTapped()
        }
      }
    }
    .buttonStyle(PlainButtonStyle())
  }
}
```

@T(00:16:53)
While we reflexively added `@ObservedObject` to the view’s `viewModel`, there’s no state actually being observed, and in the original Composable Architecture version we captured this with the `stateless` transformation of the store. We can do something similar here by binding as a `let` instead:

```swift
let viewModel: CounterRowViewModel
```

## Vanilla fact prompt

@T(00:17:17)
We've now converted another layer of domain over from the Composable Architecture to vanilla SwiftUI, and there's just one more layer to get to the full application domain.

@T(00:17:28)
Before moving onto the root view of the application, which is the list of counters, let’s convert another leaf feature: the fact prompt. We can copy over the Composable Architecture code to this file so that we can start converting it.

@T(00:18:06)
First we’ll promote the simple `FactPromptState` struct to a view model class:

```swift
class FactPromptViewModel: ObservableObject {
  …
}
```

@T(00:18:17)
We will promote the mutable fields in `FactPromptState` to `@Published var` fields, but notably the `count` field was immutable and so it will stay a `let` binding:

```swift
let count: Int
@Published var fact: String
@Published var isLoading = false
```

@T(00:18:32)
We need a public initializer since we’re now a class:

```swift
public init(
  count: Int,
  fact: String
) {
  self.count = count
  self.fact = fact
}
```

@T(00:18:44)
And we can convert the actions to method endpoints on the view model:

```swift
func dismissButtonTapped() {
}

func getAnotherFactButtonTapped() {
}

func factResponse(Result<String, FactClient.Error>) {
}
```

@T(00:19:02)
The `dismissButtonTapped` method is another one of those user actions that actually needs to be handled by the parent, which we still haven’t taken the time to figure out yet, so we will wait on implementing that method.

@T(00:19:13)
The `getAnotherFactButtonTapped` method needs to execute some side effects, so just as we did with the `CounterViewModel`, we need to copy over the dependencies from `FactPromptEnvironment`:

```swift
let fact: FactClient
let mainQueue: AnySchedulerOf<DispatchQueue>
```

@T(00:19:29)
And we’ll need to update the initializer to take both the state for the feature and its dependencies:

```swift
init(
  count: Int,
  fact: String,
  fact: FactClient,
  mainQueue: AnySchedulerOf<DispatchQueue>
) {
  self.count = count
  self.fact = fact
  self.fact = fact
  self.mainQueue = mainQueue
}
```

> Error: Invalid redeclaration of 'fact'

@T(00:19:39)
Looks like we’ve got a conflict of names here, so we need to rename something. Let’s rename the dependency:

```swift
let factClient: FactClient
…
factClient: FactClient,
…
self.factClient = factClient
```

@T(00:19:51)
We can now implement the `getAnotherFactButtonTapped` endpoint, where we first mutate ourselves to go into the loading state, and then fire off the fact client request:

```swift
func getAnotherFactButtonTapped() {
  self.isLoading = true
  self.factClient.fetch(self.count)
    .receive(on: self.mainQueue.animation())
    .sink(
      receiveCompletion: <#(Subscribers.Completion<FactClient.Error>) -> Void#>,
      receiveValue: <#(String) -> Void#>
    )
}
```

@T(00:20:14)
In the sink we can flip `isLoading` off in the completion block, and when we receive a fact we can reassign it on ourselves.

```swift
.sink(
  receiveCompletion: { [weak self] _ in
    self?.isLoading = false
  },
  receiveValue: { [weak self] fact in
    self?.fact = fact
  }
)
```

@T(00:20:29)
Notice that we again had to deal with memory concerns since we are in a reference type.

@T(00:21:00)
We also have an unused warning for the cancellable the `sink` returns, and so we need to again introduce a set of cancellables to hold onto the subscription:

```swift
private var cancellables: Set<AnyCancellable> = []
```

@T(00:21:11)
And store it:

```swift
.store(in: &self.cancellables)
```

@T(00:21:16)
That’s all there is to the view model, and notice that we never actually needed the `factResponse` endpoint, so we can remove it.

@T(00:21:23)
Next we have the view, and we just need to update all instances of the `viewStore` to instead refer to the `viewModel`:

```swift
struct VanillaFactPrompt: View {
  @ObservedObject var viewModel: FactPromptViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: "info.circle.fill")
          Text("Fact")
        }
        .font(.title3.bold())
        if self.viewModel.isLoading {
          ProgressView()
        } else {
          Text(self.viewModel.fact)
        }
      }

      HStack(spacing: 12) {
        Button(
          action: {
            withAnimation {
              self.viewModel.getAnotherFactButtonTapped()
            }
          }
        ) {
          Text("Get another fact")
        }

        Button(
          action: {
            withAnimation {
              self.viewModel.dismissButtonTapped()
            }
          }
        ) {
          Text("Dismiss")
        }
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.1), radius: 20)
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
```

## Vanilla app

@T(00:22:18)
So we’ve now converted 3 separate features from the Composable Architecture into vanilla SwiftUI.

@T(00:22:29)
There’s only one left, and it’s the hardest one yet. It’s the app domain that is responsible for bringing together all of the functionality of the other 3 domains.

@T(00:22:43)
Let’s bring over all of the corresponding domain we built in the Composable Architecture so that we can start converting it.

@T(00:23:07)
We’ll upgrade `AppState` to be an observable object:

```swift
class AppViewModel: ObservableObject {
  …
}
```

@T(00:23:18)
We’ll upgrade the mutable properties to be `@Published var`s. The `counters` collection will no longer be an identified array of `CounterRowState`, but rather will just be a simple array holding a bunch of `CounterRowViewModel`s:

```swift
@Published var counters: [CounterRowViewModel] = []
```

@T(00:23:36)
Again we are encountered nested reference types, where now the `AppViewModel` class holds onto a bunch of `CounterRowViewModel` classes, which in turn holds onto a `CounterViewModel` class. The more we nest these reference types the more difficult it will be to reason about how the whole system works.

@T(00:23:49)
Further, using `@Published` on this array again does not work exactly as we would expect. Since `CounterRowViewModel` is a class we will not be notified of any changes within a particular element of the array, but we will be notified anytime an object is added to or removed from the array. So that’s a subtle behavior we have to keep in mind when trying to understand how changes to the model can trigger view re-renders.

@T(00:24:12)
We will also promote the optional fact prompt state to be an optional fact prompt view model, and so again we are nesting reference types:

```swift
@Published var factPrompt: FactPromptState?
```

@T(00:24:24)
Next we’ll implement each `AppAction` as a view model method. The `addButtonTapped` method handles adding a new `CounterRowViewModel` to the array of counters:

```swift
func addButtonTapped() {
  self.counters.append(
    .init(
      counter: .init(
        fact: <#FactClient#>,
        mainQueue: <#AnySchedulerOf<DispatchQueue>#>
      ),
      id: <#UUID#>
    )
  )
}
```

@T(00:25:04)
However, in order to create a `CounterRowViewModel` we need to pass along some dependencies, and so let’s introduce those to the class:

```swift
let fact: FactClient
let mainQueue: AnySchedulerOf<DispatchQueue>
let uuid: () -> UUID

init(
  fact: FactClient,
  mainQueue: AnySchedulerOf<DispatchQueue>,
  uuid: @escaping () -> UUID
) {
  self.fact = fact
  self.mainQueue = mainQueue
  self.uuid = uuid
}
```

@T(00:25:29)
And now we can finish implementing this endpoint:

```swift
func addButtonTapped() {
  self.counters.append(
    .init(
      counter: .init(fact: self.fact, mainQueue: self.mainQueue),
      id: self.uuid()
    )
  )
}
```

@T(00:25:52)
The other two actions in `AppAction` come from the other counter row and fact prompt domains. For the most part those domains do their thing in isolation, but there are a few particular instances where we want to understand what is happening inside them so that we can react.

@T(00:26:05)
Like when the counter row’s remove button is tapped:

```swift
case let .counterRow(id: id, action: .removeButtonTapped):
```

@T(00:26:15)
Or when the counter domain receives a fact response:

```swift
case let .counterRow(id: id, action: .counter(.factResponse(.success(fact)))):
```

@T(00:26:21)
And when the fact prompt’s dismiss button is tapped:

```swift
case .factPrompt(.dismissButtonTapped):
```

@T(00:26:27)
These are all of the child-to-parent communication channels we have alluded to a number of times in this episode, but still have not given a solution.

@T(00:26:35)
Before we get to that topic let’s convert the `AppView` to use this new view model so that we can have all the major pieces in place before we dive into more complicated things:

```swift
struct VanillaAppView: View {
  @ObservedObject var viewModel: AppViewModel

  var body: some View {
    ZStack(alignment: .bottom) {
      List {
        ForEach(self.viewModel.counters) { counterRow in
          VanillaCounterRowView(viewModel: counterRow)
        }
      }
      .navigationTitle("Counters")
      .navigationBarItems(
        trailing: Button("Add") {
          withAnimation {
            self.viewModel.addButtonTapped()
          }
        }
      )

      if let factPrompt = self.viewModel.factPrompt {
        VanillaFactPrompt(viewModel: factPrompt)
          .transition(.opacity)
          .zIndex(1)
      }
    }
  }
}
```

@T(00:28:23)
A few interesting things here is that we are able to lean on things like `ForEach` and `if let` rather than appealing to tools like `ForEachStore` and `IfLetStore`. It of course comes with some extra cost since it was only possible to use these tools due to the fact that we nested our view models, and we haven’t yet really seen the consequences of dealing with nested reference types.

@T(00:28:43)
But potential complications aside, we do now have a lot of the pieces of the application in place where we could actually get something showing in an Xcode preview:

```swift
struct VanillaContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      VanillaAppView(
        viewModel: AppViewModel(
          fact: .live,
          mainQueue: .main,
          uuid: UUID.init
        )
      )
    }

    …
  }
}
```

@T(00:30:04)
We can add counters to our heart’s content, and even count up and down inside each row, but sadly the fact functionality does not work, nor can we remove a row after we add it. This functionality requires us to come up with a way to have the child domains communicate to the parent so that certain behavior can be implemented.

## Vanilla communication

@T(00:30:24)
We've gotten all of the domains in place now. We were even able to get a preview running where some of the functionality works, but any functionality that depends on communication between domains is so far completely inert.

@T(00:30:35)
Let’s start with one of the simpler forms of child-to-parent communication: letting the counter row communicate to the app domain that the remove button was tapped so that the app behavior can remove that element from the array of counters.

@T(00:30:54)
The easiest way to do is to add a callback closure to communicate to the app view that the button has been tapped in the row view. We can do this by introducing a new property to the `VanillaCounterRowView`:

```swift
struct VanillaCounterRowView: View {
  let viewModel: CounterRowViewModel
  let onRemoveTapped: () -> Void

  …
}
```

@T(00:31:13)
And the remove button’s action closure can invoke this closure instead of calling the method on the view model:

```swift
Button("Remove") {
  withAnimation {
    self.onRemoveTapped()
    // self.viewModel.removeButtonTapped()
  }
}
```

@T(00:31:22)
To take advantage of this new `onRemoveTapped` callback we can provide our own closure when constructing the `VanillaCounterRowView`:

```swift
ForEach(
  self.viewModel.counters,
  content: {
    VanillaCounterRowView(
      viewModel: $0,
      onRemoveTapped: {

      }
    )
  }
)
```

@T(00:31:37)
And it’s in this closure that we can do the removing work.

```swift
onRemoveTapped: {
  self.viewModel.removeButtonTapped(id: counterRowViewModel.id)
}
```

@T(00:31:53)
And let's implement this new method on `AppViewModel` for handling this logic:

```swift
func removeButtonTapped(id: UUID) {
  self.counters.removeAll(where: { $0.id == id })
}
```

@T(00:32:09)
Now when we run the preview we can see that the remove behavior works.

@T(00:32:18)
So, this is one way of communicating from child to parent. We can communicate via the view layer where the parent passes a callback closure, and the child uses it to let the parent know what is going on in the child. It’s very simple, but it also has some problems of its own. We’ll see some of these problems in a bit when we write some tests, but the most glaring problem is that this form of child-to-parent communication doesn’t work in all cases. There are times you need something a bit different.

@T(00:32:49)
To see this, let’s implement the behavior where the counter feature receives a response from the fact API request and we show a fact prompt banner over the main app view. We might think we can simply add an `onFact` callback closure to the counter view like we did for the row:

```swift
struct VanillaCounterView: View {
  @ObservedObject var viewModel: CounterViewModel
  let onFact: (Int, String) -> Void

  …
}
```

@T(00:33:26)
However, we don’t have access to the moment the fact response is received in the view layer. That’s all done in the view model. So this is an example where it’s not reasonable to communicate from child to parent with simple callback closures in the view. We’ve got to explore how we can get view models to directly communicate with each other.

@T(00:33:54)
One thing we could try to do is repeat the pattern we did for views, but in the view model. So, we could introduce an `onFact` callback closure to `CounterViewModel`:

```swift
class CounterViewModel: ObservableObject {
  …
  let onFact: (Int, String) -> Void
  …
}
```

@T(00:34:04)
Which means introducing it to the initializer:

```swift
init(
  onFact: @escaping (Int, String) -> Void,
  …
) {
  self.onFact = onFact
  …
}
```

@T(00:34:14)
And now in that empty `receiveValue` closure we can start invoking the `onFact` callback, but we just have to be careful of retain cycles and do a little bit of a dance to unwrap the optional `self`:

```swift
receiveValue: { [weak self] fact in
  guard let self = self else { return
  self.onFact(self.count, fact)
}
```

@T(00:34:53)
The only compiler error we have is in `AppViewModel`’s `addButtonTapped` method because when we create the counter view model we now have to provide this new callback closure:

```swift
func addButtonTapped() {
  self.counters.append(
    .init(
      counter: .init(fact: self.fact, mainQueue: self.mainQueue),
      id: self.uuid()
    )
  )
}
```

> Error: Missing argument for parameter 'onFact' in call

@T(00:35:05)
To fix the error we can open up the closure:

```swift
func addButtonTapped() {
  self.counters.append(
    .init(
      counter: .init(
        onFact: { number, fact in

        },
        fact: self.fact,
        mainQueue: self.mainQueue
      ),
      id: self.uuid()
    )
  )
}
```

@T(00:35:18)
And then in this closure is where we want to do the work to populate the fact prompt:

```swift
func addButtonTapped() {
  self.counters.append(
    .init(
      counter: .init(
        onFact: { [weak self] number, fact in
          guard let self = self else { return }
          self.factPrompt = .init(
            count: number,
            fact: fact,
            factClient: self.fact,
            mainQueue: self.mainQueue
          )
        },
        fact: self.fact,
        mainQueue: self.mainQueue
      ),
      id: self.uuid()
    )
  )
}
```

@T(00:36:20)
Wow, ok, this is intense. We have a strange nested creation of view models, where the act of creating a `CounterViewModel` causes us to open up a closure and create another view model inside. It’s particularly weird to see the `FactClient` and main queue scheduler being passed into two spots near each other, but each represents a very different context. On top of that we have to worry about retain cycles again, and this time it is definitely necessary to weakify `self` because we are setting up a long-living connection between the `CounterViewModel` and the `AppViewModel`.

@T(00:37:06)
But, at least the feature is now working. If we run the preview we can finally tap on the “Fact” button and get a fact populating the banner at the bottom of the screen. We can even ask for another fact, and the loading indicator works as expected and the new fact appears after a moment. The dismiss button does not yet work, and that brings us to our last example of child-to-parent communicate.

@T(00:37:35)
We can implement this communicate much like we did the remove functionality, by using a simple callback closure in the view layer. So, we’ll add that field to the `VanillaFactPromptView`:

```swift
struct VanillaFactPrompt: View {
  @ObservedObject var viewModel: FactPromptViewModel
  let onDismissTapped: () -> Void

  …
}
```

@T(00:37:54)
And invoke it when the “Dismiss” button is tapped:

```swift
Button(
  action: {
    withAnimation {
      self.onDismissTapped()
      // self.viewModel.dismissButtonTapped()
    }
  }
) {
  Text("Dismiss")
}
```

@T(00:38:01)
Then when we construct the `VanillaFactPrompt` view we can pass along a closure to handle tapping the dismiss button, and we’ll forward that to a method on the view model:

```swift
VanillaFactPrompt(
  viewModel: factPrompt,
  onDismissTapped: {
    self.viewModel.dismissFactPrompt()
  }
)
```

@T(00:38:21)
And that method doesn’t currently exist on `AppViewModel`, but it’s easy enough to implement:

```swift
func dismissFactPrompt() {
  self.factPrompt = nil
}
```

## Vanilla testing

@T(00:38:47)
The app now works exactly as the Composable Architecture version, but we’ve accomplished everything using just the tools that SwiftUI and Combine give out of the box. Some things were a lot easier, such as our ability to deriving bindings right off the view model and use things like `ForEach` and `if let` instead of `ForEachStore` and `IfLetStore`. Other things were more complicated, like the fact that we now have a deeply nested hierarchy of reference types to represent the multiple domains in one cohesive package, we have to explicitly manage the lifecycle of our effects, and communication between parent and child requires more work.

@T(00:39:23)
Let’s take a moment to compare our vanilla SwiftUI code base with the Composable Architecture one in two key areas: testing and ease of adding a new feature.

@T(00:39:37)
We wrote a pretty succinct test for the Composable Architecture feature that played through a full user script of the user adding a counter, interacting with it, removing it, and more. Let’s look at that test and see what it takes to write the equivalent for our new vanilla SwiftUI feature.

@T(00:39:54)
Our test suite begins with a few simple steps: We simulate the user tapping the “Add” button, and assert that a new element was appended to the `counters` array in state, and then we simulate tapping the increment button inside the first row of the list and assert that that counter’s `count` field went to 1:

```swift
store.send(.addButtonTapped) {
  $0.counters.append(
    .init(counter: .init(), id: id)
  )
}
store.send(
  .counterRow(id: id, action: .counter(.incrementButtonTapped))
) {
  $0.counters[id: id]?.counter.count = 1
}
```

@T(00:40:15)
These assertions are really succinct, and they are packing a lot of power. First of all, we are exhaustively asserting across the entire state of the application. If one small thing changed anywhere in the state that we did not explicitly assert, whether it be in a particular counter in the list, or in the fact prompt, or at the root of the application state, we will instantly get a failure. For example, suppose we claim that when a counter row was incremented it had a `count` value of `2` instead of `1`:

```swift
store.send(
  .counterRow(id: id, action: .counter(.incrementButtonTapped))
) {
  $0.counters[id: id]?.counter.count = 1
}
```

> Failed: State change does not match expectation: …
>
> ```
>   AppState(
>     counters: [
>       CounterRowState(
>         counter: CounterState(
>           alert: nil,
> −         count: 2
> +         count: 1
>         ),
>         id: 00000000-0000-0000-0000-000000000000
>       ),
>     ],
>     factPrompt: nil
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:40:43)
We instantly get a failure that points out exactly what part of the state mismatched our expectation.

@T(00:40:50)
Let’s change the count back to get a passing.

@T(00:40:55)
It’s even further exhaustive on how effects execute and feed their data back into the system. The fact that these two assertions pass means that no effects were executed between sending these two actions, for if an effect executed and feed a new action into the system we would get a failure if we tried sending a new action without first asserting that we received an action from the effect.

@T(00:41:17)
For example, if we forget to receive the fact response:

```swift
// store.receive(
//   .counterRow(
//     id: id,
//     action: .counter(
//       .factResponse(.success("1 is a good number."))
//     )
//   )
// ) {
//   $0.factPrompt = .init(count: 1, fact: "1 is a good number.")
// }
```

> Failed: Must handle 1 received action before sending an action: …

@T(00:41:27)
We get a failure because we did not explicitly assert that we expected to receive this action.

@T(00:41:35)
Let’s see what it takes to capture just these first two assertions with the vanilla SwiftUI view model. We can start by getting some scaffolding in place for the test:

```swift
func testViewModel() {
  let id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

  let viewModel = AppViewModel(
    fact: .init(fetch: {
      .init(value: "\($0) is a good number.")
    }),
    mainQueue: .immediate,
    uuid: { id }
  )

}
```

@T(00:42:09)
We can then simulate the user tapping on the add button by simply invoking that method on the view model:

```swift
viewModel.addButtonTapped()
```

@T(00:42:19)
And already we have a pretty striking difference between view model testing and testing in the Composable Architecture. This test will pass as-is. And that’s not surprising because all we are doing is invoking a method.

@T(00:42:34)
However, the equivalent code in a Composable Architecture test:

```swift
store.send(.addButtonTapped)
```

@T(00:42:44)
Fails because we are forced to describe every state change that happened after sending that action:

> Error: State change does not match expectation: …
>
> ```
>   AppState(
>     counters: [
> +     CounterRowState(
> +       counter: CounterState(
> +         alert: nil,
> +         count: 0
> +       ),
> +       id: 00000000-0000-0000-0000-000000000000
> +     ),
>     ],
>     factPrompt: nil
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:42:58)
But let’s go ahead and add an assertion after invoking the view model method:

```swift
XCTAssertEqual(
  <#expression1: Equatable#>,
  <#expression2: Equatable#>
)
```

@T(00:43:09)
Question is, what can as assert against? The `viewModel.counters` field holds an array of view models, which are reference types, and so it’s tricky to test for equality between reference types. First of all, our `CounterRowViewModel` doesn’t conform to `Equatable` so we can’t do this:

```swift
XCTAssertEqual(
  viewModel.counters,
  [
  ]
)
```

> Error: Global function '`XCTAssertEqual(_:_:_:file:line:)`' requires that 'CounterRowViewModel' conform to 'Equatable'

@T(00:43:24)
And even if we go make the view model conform to `Equatable`:

```swift
class CounterRowViewModel: ObservableObject, Equatable, Identifiable {
```

> Error: Type 'CounterRowViewModel' does not conform to protocol 'Equatable'

@T(00:43:46)
We run into the problem that classes do not get an automatically synthesized `Equatable` conformance like structs do. There’s probably a good reason for this. Structs are just a simple bag of data, and so equality between values is very straightforward, whereas classes are an amalgamation of data and behavior, and so equality can be a much more subtle distinction.

@T(00:44:06)
This means if we want to test equality between view models like we do for state in the Composable Architecture we have to manually implement equality, which is not only going to be a lot of boilerplate but also it’s not even clear how we should implement it. Take for example the `CounterViewModel`. Not only does it hold data but it also holds dependencies. Do we need to do some kind of equality checking on those? And should we take behavior into consideration when defining equality? Like, should we factor in the fact API request being in flight to distinguish two potentially different view models? These are the kinds of questions I do not want to answer, and so let’s not try to conform view models to the `Equatable` protocol.

@T(00:44:52)
Instead, we will just assert on a few fields that we are interested in. For example, after the add button is tapped we expect the counters array to have a single element, and that element’s count should be 0:

```swift
XCTAssertEqual(viewModel.counters.count, 1)
XCTAssertEqual(viewModel.counters[0].counter.count, 0)
```

@T(00:45:29)
This passes, but it’s also not as strong as it could be. If any changes were made out of these two simple checks we will completely miss it in this test, and that’s a bummer.

@T(00:45:40)
We can also quickly simulate the user tapping on the increment button in a particular row of the list, and assert on the count after that action:

```swift
viewModel.counters[0].counter.incrementButtonTapped()
XCTAssertEqual(viewModel.counters[0].counter.count, 1)
```

@T(00:46:11)
Again, more things outside the `count` field could have been mutated and we would be none the wiser.

@T(00:46:18)
The next interesting segment of assertions in the Composable Architecture test is where we simulate the user tapping the fact button in a particular row of the list, which doesn’t cause any state mutations to happen:

```swift
store.send(.counterRow(id: id, action: .counter(.factButtonTapped)))
```

@T(00:46:27)
But, it does cause an effect to be executed, which feeds a response back into the system, which in turn causes the fact prompt to appear:

```swift
store.receive(
  .counterRow(
    id: id,
    action: .counter(
      .factResponse(.success("1 is a good number."))
    )
  )
) {
  $0.factPrompt = .init(count: 1, fact: "1 is a good number.")
}
```

@T(00:46:32)
This is showing off the exhaustive effect testing that is possible in the Composable Architecture. If we had not explicitly asserted that we received an action from an effect and the resulting state mutation that happened due to that action we would have gotten a failure. This is a really incredible feature of the library.

@T(00:46:46)
On the other hand, for the vanilla SwiftUI view model we can reach into the `counters` array, grab the view model at the 0th index, and invoke its `factButtonTapped` method:

```swift
viewModel.counters[0].counter.factButtonTapped()
```

@T(00:46:57)
And again this test passes just fine. There are no checks in place to force us to deal with the fact that tapping that button causes a side effect. Luckily we can test the result of the effect because we controlled the fact client and scheduler. We expect that the `factPrompt` all the way back at the root as flipped to something non-`nil`:

```swift
XCTAssertNotNil(viewModel.factPrompt)
```

@T(00:47:28)
This test passes, and we could strengthen it a bit more by asserting on some of the state inside `factPrompt`:

```swift
XCTAssertEqual(viewModel.factPrompt?.count, 1)
XCTAssertEqual(viewModel.factPrompt?.fact, "1 is a good number.")
```

@T(00:48:05)
This is pretty cool. We are getting some good test coverage on how two completely independent features integrate with each other. The entire counter domain and fact prompt domain could be put into their own modules with no dependency between them whatsoever, all the while letting the `AppViewModel` integrate the features together. The action that took place deep in the array of view models has had reverberations all the way back at the root, and we get to test the whole thing in one package. That’s really powerful.

@T(00:48:33)
The final steps of the Composable Architecture test dismiss the fact prompt, and then simulate tapping the remove button on the counter that was previously added:

```swift
store.send(.factPrompt(.dismissButtonTapped)) {
  $0.factPrompt = nil
}

store.send(.counterRow(id: id, action: .removeButtonTapped)) {
  $0.counters = []
}
```

@T(00:48:39)
To do this in the vanilla SwiftUI view model we can invoke the `dismissFactPrompt` method and make sure that the `factPrompt` field goes back to `nil`:

```swift
viewModel.dismissFactPrompt()
XCTAssertNil(viewModel.factPrompt)
```

@T(00:48:56)
And then we can further invoke the `.removeButtonTapped` endpoint and make sure the `counters` array is emptied:

```swift
viewModel.removeButtonTapped(id: id)
XCTAssertEqual(viewModel.counters.count, 0)
```

@T(00:49:17)
So, we’ve now roughly recovered the test suite we had for the Composable Architecture, but just using a plain, vanilla SwiftUI view model. The tests aren’t as strong as they could be because we lose lots of opportunities for exhaustivity, such as asserting on how state changes and how effects are executed.

@T(00:49:38)
There’s another weakness in this test suite that’s a little more subtle. Notice that before the two assertions we just wrote we are reaching directly into the `AppViewModel` to invoke an endpoint to execute some logic:

```swift
viewModel.dismissFactPrompt()
viewModel.removeButtonTapped(id: id)
```

@T(00:49:50)
But in the Composable Architecture version we are actually sending actions in the child domains, which are the fact prompt domain and the counter row domain:

```swift
store.send(.factPrompt(.dismissButtonTapped))
store.send(.counterRow(id: id, action: .removeButtonTapped))
```

@T(00:50:04)
This may seem like an insignificant distinction, but it actually comes with a big consequence. The reason these endpoints exist on the root `AppViewModel` rather than their respective view models is because we allowed the child view to communicate to the parent when an action happened, and we did that because it was the easiest way to accomplish what we wanted. However, any communication we perform in the view layer is automatically less testable than if we were to keep things in the observable object layer.

@T(00:50:28)
For example, what if we wanted to add some additional behavior to when the user taps the remove button, like tracking an analytics event or something? Then we would want to add a new endpoint to the `CounterRowViewModel` to handle that behavior:

```swift
class CounterRowViewModel: ObservableObject, Identifiable {
  …

  func removeButtonTapped() {
    // TODO: track analytics
  }
}
```

@T(00:50:47)
And we’d want to invoke that method when the remove button is tapped:

```swift
Button("Remove") {
  withAnimation {
    self.onRemoveTapped()
    self.viewModel.removeButtonTapped()
  }
}
```

@T(00:50:53)
I guess we have to invoke both functions: one to let the parent know we tapped the remove button and the other to let the domain for the row to execute its own behavior. That’s pretty weird.

@T(00:51:04)
Even weirder, we would have to invoke both methods in tests if we wanted to test both the removing logic as well as the analytics behavior:

```swift
viewModel.counters[0].removeButtonTapped()
// TODO: assert analytics were tracked
viewModel.removeButtonTapped(id: id)
XCTAssertEqual(viewModel.counters.count, 0)
```

@T(00:51:32)
That looks really bizarre. The whole reason this looks so strange is because we are communicating between child and parent in the view layer instead of the view model layer. It’s possible to refactor the view models so that they communicate directly, and then we could greatly improve the strength of this test.

@T(00:51:45)
OK, so that’s testing. We were able to test the same things that we tested in the Composable Architecture, but with weaker guarantees and less exhaustivity.

## Vanilla feature iteration

@T(00:52:05)
Let’s compare the vanilla SwiftUI and Composable Architecture styles from another angle: how easy it is to add a new feature. Let’s quickly add a row to the the list that simply shows the sum of all the counters being displayed. In the Composable Architecture this is as simple as adding a computed property to compute the sum:

```swift
struct AppState: Equatable {
  …

  var sum: Int {
    self.counters.reduce(0) { $0 + $1.counter.count }
  }
}
```

@T(00:52:52)
And then a `Text` view at the top of the `List` that displays the counters:

```swift
List {
  Text("Sum: \(viewStore.sum)")

  …
}
```

@T(00:53:10)
That’s all there is to it. As we add counters and increment them this sum will instantly update.

@T(00:53:30)
For the vanilla SwiftUI view model we can also add a computed property, but this time to the `AppViewModel`:

```swift
class AppViewModel: ObservableObject {
  …

  var sum: Int {
    self.counters.reduce(0) { $0 + $1.counter.count }
  }
}
```

@T(00:53:53)
And we can add a `Text` view to the top of the `List` that displays the counters:

```swift
Text("Sum: \(viewModel.sum)")
```

@T(00:54:08)
That was quick for vanilla SwiftUI too, but sadly it doesn’t work. If we add some counters and start incrementing them the sum text never updates. This is due to that subtlety we mentioned before where `@Published` fields do not pick up changes in classes, and hence we are not actually observing the changes to the `CounterViewModel`'s count.

@T(00:54:46)
If we add or remove a counter from the list we will then see the sum update because those operations do trigger the `@Published` property, thus causing the view to re-render.

@T(00:54:49)
In order to support this feature we need to listen for changes inside the `CounterViewModel` from the `AppViewModel`, and then manually trigger `objectWillChange`. To do this we need to insert some additional logic in the `addButtonTapped` method. We can extract out a little local counter view model so that we can observe it:

```swift
func addButtonTapped() {
  let counterViewModel = CounterViewModel(
    onFact: { [weak self] number, fact in
      guard let self = self else { return }
      self.factPrompt = .init(
        count: number,
        fact: fact,
        factClient: self.fact,
        mainQueue: self.mainQueue
      )
    },
    fact: self.fact,
    mainQueue: self.mainQueue
  )

  self.counters.append(
    .init(
      counter: counterViewModel,
      id: self.uuid()
    )
  )
}
```

@T(00:55:07)
And then we can `sink` on the counter view model’s `$count` publisher to be notified of when it changes, and use that as an opportunity to ping the app view model’s `objectWillChange`:

```swift
counterViewModel.$count
  .sink { _ in self.objectWillChange.send() }
```

@T(00:55:37)
This returns a cancellable we need to keep track of, which means we have to introduce a set of cancellables to the `AppViewModel` class:

```swift
private var cancellables: Set<AnyCancellable> = []
```

@T(00:55:52)
So that we can store it:

```swift
counterViewModel.$count
  .sink { _ in self.objectWillChange.send() }
  .store(in: &self.cancellables)
```

@T(00:55:58)
Now when we run the preview we see the behavior we expect. As we increment and decrement in any row we see the sum row update.

@T(00:56:16)
In the Composable Architecture, adding this new feature was quite simple because we were dealing with value types that can be automatically observed by the system via the Store. In vanilla SwiftUI we had to do a little more work since we are dealing with view models as reference types and we need to manually coordinate updates between them.

@T(00:56:37)
What's cool, though, is that both versions of the application were defined in about the same number of lines of code, where the Composable Architecture is only a couple dozen lines longer, but comes with a bunch of tools for composability and testability.

## Conclusion

@T(00:57:42)
That concludes this series of episodes. We’ve gone on a long journey to explore the concept of “deriving behavior”, which is what we do when we want to build features in isolation as small domains and plug them together to form the larger application domain. We started in vanilla SwiftUI to explore the tools that Apple gives us out of the box. It’s possible, but it can be tricky.

@T(00:58:06)
Then we explored the tools that the Composable Architecture gives us, and there was a lot there. At its core it provides `pullback` for transforming a feature’s logic and `scope` for transforming a feature’s runtime. These two tools together gives you the ability to break down lots of domains into smaller and smaller domains.

@T(00:58:26)
But some domains are complicated enough where `pullback` and `scope` don’t cut it. When domains are embedded in data structures, such as collections, optionals, or enums, we need more tools. Some of those tools were already available to users of the library, such as the `forEach` and `optional` higher-order reducers and the `ForEachStore` and `IfLetStore` views that help transform stores. Other tools, such as `pullback` along state case paths and the `SwitchStore` were developed live right in these episodes and then later open sourced.

@T(00:58:59)
And then finally we came full circle and decided to try to rebuild an application we made entirely in the Composable Architecture using only the tools Apple gives us in SwiftUI. We found that it is totally possible, and we were even able to achieve isolation, modularity and some test coverage. However, some complexity slipped into the application due to the fact that we are now primarily dealing with reference types rather than value types, and we weren’t able to recover the nice testing abilities of the Composable Architecture.

@T(00:59:29)
So, the main point to this exploration is to convince you that it is a worthwhile endeavor to think about how to break down domains into smaller units, and how to approach this problem in both vanilla SwiftUI and the Composable Architecture. Amazingly the code for each implementation is nearly identical, weighing in at a little over 300 lines of code each, so you'll be doing just fine with either approach.

@T(01:00:04)
Until next time!
