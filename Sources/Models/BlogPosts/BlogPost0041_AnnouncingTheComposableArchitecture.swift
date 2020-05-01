import Foundation

public let post0041_AnnouncingTheComosableArchitecture = BlogPost(
  author: .pointfree, // todo
  blurb: """
Today we are releasing the Composable Architecture as an open-source library. A way to build applications in a consistent and understandable way, with composition, testing and ergonomics in mind.
""",
  contentBlocks: [
    .init(
      content: #"""
We [first](/episodes/ep65-swiftui-and-state-management-part-1) began discussing application architecture nearly 9 months ago, and in that time we have built up a [comprehensive story](/collections/composable-architecture) of how one can build applications in a consistent and understand way. We focused on a few key topics:

* [**State management**](todo): How can we build the majority of our application using simple value types, and how can disparate parts of the application communicate with each other by sharing state.
* [**Composition**](todo): How can we break a large, complex feature down into smaller pieces that glue together to form the whole?
* [**Modularity**](todo): After having broken down a large problem into small ones, how can we put each of the pieces in their own modules, with as few dependencies as possible between them, so that we can run features in isolation without having to build the entire application?
* [**Side effects**](todo): How can we let our features communicate with the outside world, and vice-versa, in an understandable and composable way?
* [**Testing**](todo): How can we accomplish the above without sacrificing testability? We want to test our features so that it doesn't take a lot of work to set up a test, and so that we can test very deep properties of our system, including how effects are executed and how their outputs are fed back into the feature.
* [**Adaptability**](todo): How can implement the core business logic of our features a single time, while still allowing that logic to be used on multiple platforms, such as iOS, macOS, watchOS and tvOS?

And today we are excited to announce that we are finally [open-sourcing](https://github.com/pointfreeco/swift-composable-architecture) the Composable Architecture, a library for building applications in a consistent and understandable way, with composition, testing and ergonomics in mind. It can be used in SwiftUI, UIKit applications, and more, and on any Apple platform (iOS, macOS, tvOS, and watchOS).


## Basic Usage

To build a feature using the Composable Architecture you define some types and values that model your domain:

* **State**: A type that describes the data your feature needs to perform its logic and render its UI.
* **Action**: A type that represents all of the actions that can happen in your feature, such as user actions, notifications, event sources and more.
* **Environment**: A type that holds any dependencies the feature needs, such as API clients, analytics clients, etc.
* **Reducer**: A function that describes how to evolve the current state of the app to the next state given an action. The reducer is also responsible for returning any effects that should be run, such as API requests.
* **Store**: The runtime that actually drives your feature. You send all user actions to the store so that the store can run the reducer and effects, and you can observe state changes in the store so that you can update UI.

The benefits of doing this is that you will instantly unlock testability of your feature, and you will be able to break large, complex features into smaller domains that can be glued together.

As a basic example, consider a UI that shows a number along with "+" and "−" buttons that increment and decrement the number. To make things interesting, suppose there is also a button that when tapped makes an API request to fetch a random fact about that number and then displays the fact in an alert.

The state of this feature would consist of an integer for the current count, as well as an optional string that represents the title of the alert we want to show (optional because `nil` represents not showing an alert):

```swift
struct AppState {
  var count = 0
  var numberFactAlert: String?
}
```

Next we have the actions in the feature. There are the obvious actions, such as tapping the decrement button, increment button, or fact button. But there are also some slightly non-obvious ones, such as the action of the user dismissing the alert, and the action that occurs when we receive a response from the fact API request:

```swift
enum AppAction {
  case dismissFactAlert
  case decrementButtonTapped
  case incrementButtonTapped
  case numberFactButtonTapped
  case numberFactResponse(Result<String, ApiError>)
}
```

Next we model the environment of dependencies this feature needs to do its job. In particular, to fetch a fact we need to construct an `Effect` value that encapsulates the network request. So that dependency is a function from `Int` to `Effect<String, ApiError>`, where `String` represents the response from the request. Further, the effect will typically do its work on a background thread (as is common with `URLSession`), and so we need a way to receive the effect's values on the main queue. We do this via a main queue scheduler, which is a dependency that is important to control so that we can write tests:

```swift
struct AppEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var numberFact: (Int) -> Effect<String, ApiError>
}
```

Next, we implement a reducer that implements the logic for this domain. It describes how to change the current state to the next state, and describes what effects need to be executed. Some actions don't need to execute effects, and they can return `.none` to represent that:

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .dismissFactAlert:
    state.numberFactAlert = nil
    return .none

  case .decrementButtonTapped:
    state.count -= 1
    return .none

  case .incrementButtonTapped:
    state.count += 1
    return .none

  case .numberFactButtonTapped:
    return environment.numberFact(state.count)
      .receive(on: environment.mainQueue)
      .map(AppAction.numberFactResponse)
      .catchToEffect()

  case let .numberFactResponse(.success(fact)):
    state.numberFactAlert = fact
    return .none

  case let .numberFactResponse(.failure):
    state.numberFactAlert = nil
    return .none
  }
}
```

And then finally we define the view that displays the feature. It holds onto a `Store<AppState, AppAction>` so that it can observe all changes to the state and re-render, and we can send all user actions to the store so that state changes. We must also introduce a struct wrapper around the fact alert to make it `Identifiable`, which the `.alert` view modifier requires:

```swift
struct FactAlert: Identifiable {
  var title: String
  var id: String { self.title }
}

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        HStack {
          Button("−") { viewStore.send(.decrementButtonTapped) }
          Text("\(viewStore.count)")
          Button("+") { viewStore.send(.incrementButtonTapped) }
        }

        Button("Number fact") { viewStore.send(.numberFactButtonTapped) }
      }
      .alert(
        item: viewStore.binding(
          get: { $0.numberFactAlert.map(FactAlert.init(title:)) },
          send: .dismissFactAlert
        ),
        content: { Alert(title: Text($0.title)) }
      )
    }
  }
}
```

It's important to note that we were able to implement this entire feature without having a real life effect at hand. This is important because it means features can be built in isolation without building their dependencies, which can help compile times.

It is also straightforward to have a UIKit controller driven off of this store. You subscribe to the store in `viewDidLoad` in order to update the UI and show alerts. The code is a bit longer than the SwiftUI version, so we have collapsed it here:

<details>
  <summary>Click to expand!</summary>

  ```swift
  class AppViewController: UIViewController {
    let viewStore: ViewStore<AppState, AppAction>
    var cancellables: Set<AnyCancellable> = []

    init(store: Store<AppState, AppAction>) {
      self.viewStore = ViewStore(store)
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      let countLabel = UILabel()
      let incrementButton = UIButton()
      let decrementButton = UIButton()
      let factButton = UIButton()

      // Omitted: Add subviews and set up constraints...

      self.viewStore.publisher.count
        .sink { [weak countLabel] count in countLabel?.text = "\(count)" }
        .store(in: &self.cancellables)

      self.viewStore.publisher.numberFactAlert
        .sink { [weak self] numberFactAlert in
          let alertController = UIAlertController(
            title: numberFactAlert, message: nil, preferredStyle: .alert
          )
          alertController.addAction(
            UIAlertAction(
              title: "Ok",
              style: .default,
              handler: { _ in self?.viewStore.send(.dismissFactAlert) }
            )
          )
          self?.present(alertController, animated: true, completion: nil)
        })
        .store(in: &self.cancellables)
    }

    @objc private func incrementButtonTapped() {
      self.viewStore.send(.incrementButtonTapped)
    }
    @objc private func decrementButtonTapped() {
      self.viewStore.send(.decrementButtonTapped)
    }
    @objc private func factButtonTapped() {
      self.viewStore.send(.numberFactButtonTapped)
    }
  }
  ```

</details>

Once we are ready to display this view, for example in the scene delegate, we can construct a store. This is the moment where we need to supply the dependencies, and for now we can just use an effect that immediately returns a mocked string:

```swift
let appView = AppView(
  store: Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment(
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      numberFact: { number in Effect(value: "\(number) is a good number Brent") }
    )
  )
)
```

And that is enough to get something on the screen to play around with. It's definitely a few more steps than if you were to do this in a vanilla SwiftUI way, but there are a few benefits. It gives us a consistent manner to apply state mutations, instead of scattering logic in some observable objects and in various action closures of UI components. It also gives us a concise way of expressing side effects. And we can immediately test this logic, including the effects, without doing much additional work.

To test, you first create a `TestStore` with the same information that you would to create a regular `Store`, except this time we can supply test-friendly dependencies. In particular, we use a test scheduler instead of the live `DispatchQueue.main` scheduler because that allows us to control when work is executed, and we don't have to artificially wait for queues to catch up.

```swift
let scheduler = DispatchQueue.testScheduler

let store = TestStore(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    mainQueue: scheduler.eraseToAnyScheduler(),
    numberFact: { number in Effect(value: "\(number) is a good number Brent") }
  )
)
```

Once the test store is created we can use it to make an assertion of an entire user flow of steps. Each step of the way we need to prove that state changed how we expect. Further, if a step causes an effect to be executed, which feeds data back into the store, we must assert that those actions were received properly.

This test has the user increment and decrement the count, then they ask for a number fact, and the response of that effect triggers an alert to be shown, and then dismissing the alert causes the alert to go away.

```swift
store.assert(
  // Test that tapping on the increment/decrement buttons changes the count
  .send(.incrementButtonTapped) {
    $0.count = 1
  },
  .send(.decrementButtonTapped) {
    $0.count = 0
  },

  // Test that tapping the fact button causes us to receive a response
  // from the effect. Note that we have to advance the scheduler
  // because we used `.receive(on:)` in the reducer.
  .send(.numberFactButtonTapped),
  .do { scheduler.advance() },
  .receive(.numberFactResponse("0 is a good number Brent")) {
    $0.numberFactAlert = "0 is a good number Brent"
  },

  // And finally dismiss the alert
  .send(.dismissFactAlert) {
    $0.numberFactAlert = nil
  }
)
```

That is the basics of building and testing a feature in the Composable Architecture. There are _a lot_ more things to be explored, such as composition, modularity, and more complex effects. The [Examples](./Examples) directory has a bunch of projects to explore to see more advanced usages.

"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: "TODO",
  id: 41,
  publishedAt: .init(timeIntervalSince1970: 1588568400),
  title: "Composable Architecture, the library"
)
