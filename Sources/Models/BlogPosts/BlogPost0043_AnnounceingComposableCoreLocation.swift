import Foundation

public let post0043_AnnounceingComposableCoreLocation = BlogPost(
  author: .pointfree,
  blurb: """
We are releasing a mini-library that makes working with CoreLocation easier to work with in the Composable Architecture.
""",
  contentBlocks: [
    .init(
      content: #"""
A little over 2 weeks ago we released the [Composable Architecture](/blog/posts/41-composable-architecture-the-library), a library for building applications in a consistent and understandable way, with composition, testing and ergonomics in mind. Today we are releasing the first support library to go with it: [`ComposableCoreLocation`](https://github.com/pointfreeco/swift-composable-architecture/tree/master/Sources/ComposableCoreLocation).

One of the most important principles of the Composable Architecture is that side effects are never performed directly, but instead are wrapped in the `Effect` type, returned from reducers, and then the `Store` later performs the effect. This is crucial for simplifying how data flows through an application, and for gaining testability on the full end-to-end cycle of user action to effect execution.

However, this also means that many libraries and SDKs you interact with on a daily basis need to be retrofitted to be a little more friendly to the Composable Architecture style. That's why we'd like to make it easier to use some of Apple's most popular frameworks by providing wrapper libraries that expose their functionality in a way that plays nicely with our library.

## `ComposableCoreLocation`

The first such wrapper we are providing is `ComposableCoreLocation`, a wrapper around `CLLocationManager` that makes it easy to use from a reducer, and easy to write tests on how your logic interacts with `CLLocationManager`'s functionality. To use it, one begins by adding an action to your domain that represents all of the actions the manager can emit via the `CLLocationManagerDelegate` methods:

```swift
import ComposableCoreLocation

enum AppAction {
  case locationManager(LocationManager.Action)

  // Your domain's other actions:
  ...
}
```

The `LocationManager.Action` enum holds a case for each delegate method of `CLLocationManagerDelegate`, such as `didUpdateLocations`, `didEnterRegion`, `didUpdateHeading` and more.

Next we add `LocationManager`, which is the wrapper type around `CLLocationManager` that the library provides, to the application's environment of dependencies:

```swift
struct AppEnvironment {
  var locationManager: LocationManager

  // Your domain's other dependencies:
  ...
}
```

Next, we create a location manager and request authorization from our application's reducer by returning an effect from an action to kick things off. One good choice for such an action is the `onAppear` of your view. Also you must provide a unique identifier to associate with the location manager you create since it is possible to have multiple managers running at once if that's what you need.

```swift
let appReducer = AppReducer<AppState, AppAction, AppEnvironment> {
  state, action, environment in

  // A unique identifier for our location manager, just in case we want to use
  // more than one in your application.
  struct LocationManagerId: Hashable {}

  switch action {
  case .onAppear:
    return .merge(
      environment.locationManager
        .create(id: LocationManagerId())
        .map(AppAction.locationManager),

      environment.locationManager
        .requestWhenInUseAuthorization(id: LocationManagerId())
        .fireAndForget()
      )

  ...
  }
}
```

With that initial set up we will now get all of `CLLocationManagerDelegate`'s methods delivered to our reducer via actions. To handle a particular delegate action we simply need to destructure it inside the `.locationManager` case we added to our `AppAction`. For example, once we get location authorization from the user we could request their current location:

```swift
case .locationManager(.didChangeAuthorization(.authorizedAlways)),
     .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):

  return environment.locationManager
    .requestLocation(id: LocationManagerId())
    .fireAndForget()
```

And if the user denies location access we can show an alert telling them that we need access to be able to do anything in the app:

```swift
case .locationManager(.didChangeAuthorization(.denied)),
     .locationManager(.didChangeAuthorization(.restricted)):

  state.alert
    = "Please give location access so that we can show you some cool stuff."
  return .none
```

And we'll be notified of the user's location being obtained by handling the `.didUpdateLocations` action:

```swift
case let .locationManager(.didUpdateLocations(locations)):
  // Do something cool with user's current location.
  ...
```

And once you have handled all the `CLLocationManagerDelegate` actions you care about, you can ignore the rest:

```swift
case .locationManager:
  return .none
```

Accessing any functionality on the location manager is done by returning effects from the reducer. For example, if you want to request the user's current location when they tap a button, then you can do the following:

And finally, when creating the `Store` to power your application you will supply the "live" implementation of the `LocationManager`, which is to say a client instance that actually holds onto a `CLLocationManager` on the inside and interacts with it directly:

```swift
let store = Store(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    locationManager: .live,
    // And your other dependencies...
  )
)
```

That is enough to implement a basic application that interacts with CoreLocation. But that's only the beginning 😁.

## Testing CoreLocation

The true power of building your application this way and interfacing with CoreLocation this way is the ability to test how your application interacts with CoreLocation. It starts by creating a `TestStore` whose environment contains the `.mock` version of the `LocationManager`. The `.mock` function allows you to create a fully controlled version of the client that does not interact with a `CLLocationManager` at all. Instead, you override whichever endpoints your feature needs to supply deterministic functionality.

For example, to test the flow of asking for location authorization, being denied, and showing an alert we need to override the `create` endpoint and the `requestWhenInUseAuthorization` endpoint. The `create` endpoint needs to return an effect that emits the delegate actions, which we can control via a publish subject. And the `requestWhenInUseAuthorization` endpoint is a fire-and-forget effect, but we can make assertions that it was called how we expect.

```swift
var didRequestInUseAuthorization = false
let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

let store = TestStore(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    locationManager: .mock(
      create: { _ in locationManagerSubject.eraseToEffect() },
      requestWhenInUseAuthorization: { _ in
        .fireAndForget { didRequestInUseAuthorization = true }
    })
  )
)
```

Then we can write an assertion that simulates a sequence of user steps and location manager delegate actions, and we assert on how state mutates and how effects are received. For example, we can have the user come to the screen, have the location authorization request denied, and then assert that an effect was received which caused the alert to show:

```swift
store.assert(
  .send(.onAppear),

  // Simulate the user denying location access
  .do {
    locationManagerSubject.send(.didChangeAuthorization(.denied))
  },

  // We receive the authorization change delegate action from the effect
  .receive(.locationManager(.didChangeAuthorization(.denied))) {
    $0.alert = "Please give location access so that we can show you some cool stuff."
  },

  // Store assertions require all effects to be completed, so we complete
  // the subject manually.
  .do {
    locationManagerSubject.send(completion: .finished)
  }
)
```

And this is only the tip of the iceberg. We can further test what happens when we are given authorization by the user and the request for their location returns a specific location that we control, and even what happens when the request for their location fails. It is very easy to write these tests, and allows us to test deep, subtle properties of our application.

## Demo application

[<img width="100%" alt="macOS and iOS demo applications using the CoreLocation library" src="https://user-images.githubusercontent.com/135203/82390225-0187c880-99f3-11ea-8ae7-e33f6993f89d.png">](https://user-images.githubusercontent.com/135203/82390225-0187c880-99f3-11ea-8ae7-e33f6993f89d.png)

To show a more advanced usage of `ComposableCoreLocation` we have built a new [demo application](https://github.com/pointfreeco/swift-composable-architecture/tree/master/Examples/LocationManager) in the library repo. It shows how to:

* Ask for the user's current location, showing an alert if denied and centering the map on the location if authorized.
* Search the region on the map for certain categories of points of interest, such as cafes, museums, etc.
* How to power both an iOS and macOS application from a single source of business logic.
* A full test suite showing that the application interacts with CoreLocation how we expect.

## Try it out today

We're excited to release this support library for the [Composable Architecture](https://www.github.com/pointfreeco/swift-composable-architecture), and hope it can help simplify your application's interaction with CoreLocation. We will have more support libraries like this coming soon, so keep an eye out!
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 43,
  publishedAt: .init(timeIntervalSince1970: 1589950800),
  title: "CoreLocation support in the Composable Architecture"
)
