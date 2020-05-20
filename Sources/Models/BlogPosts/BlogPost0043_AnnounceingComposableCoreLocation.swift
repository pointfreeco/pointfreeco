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

However, this also means that many libraries and SDKs you interact with on a daily basis need to be retrofitted to be a little more friendly to the Composable Architecture style. That's why we'd like to ease the pain of using some of Apple's most popular frameworks by providing wrapper libraries that expose their functionality in a way that plays nicely with our library.

## `ComposableCoreLocation`

The first such wrapper we are providing is `ComposableCoreLocation`, a wrapper around `CLLocationManager` that makes it easy to use from a reducer, and easy to write tests on how your logic interacts with `CLLocationManager`'s functionality. To use it, one begins by add an action to your domain that represents all of the actions the manager can emit via the `CLLocationManagerDelegate` methods:

```swift
import ComposableCoreLocation

enum AppAction {
  case locationManager(LocationManagerClient.Action)

  // Your domain's other actions:
  ...
}
```

The `LocationManagerClient.Action` enum holds a case for each delegate method of `CLLocationManagerDelegate`, such as `didUpdateLocations`, `didEnterRegion`, `didUpdateHeading` and more.

Next we add `LocationManagerClient`, which is the wrapper type around `CLLocationManager` that the library provides, to the application's environment of dependencies:

```swift
struct AppEnvironment {
  var locationManager: LocationManagerClient

  // Your domain's other dependencies:
  ...
}
```

Next, we create a location manager from our application's reducer by returning an effect from an action to kick things off. One good choice for such an action is the `onAppear` of your view. Also you must provide a unique identifier to associate with the location manager you create since it is possible to have multiple managers running at once if that's what you need.

```swift
let appReducer = AppReducer<AppState, AppAction, AppEnvironment> {
  state, action, environment in

  // A unique identifier for our location manager, just in case we want to use
  // more than one in your application.
  struct LocationManagerId: Hashable {}

  switch action {
  case .onAppear:
    // Return an effect to create the location manager.
    return environment.locationManager.create(id: LocationManagerId())
      .map(AppAction.locationManager)

  // Tap into which ever `CLLocationManagerDelegate` methods you are interested
  // in, for example when the authorization status changes to authorized:
  case .locationManager(.didChangeAuthorization(.authorizedAlways)),
       .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):

  // Or when authorization is denied:
  case .locationManager(.didChangeAuthorization(.denied)),
       .locationManager(.didChangeAuthorization(.restricted)):

  // Or when we get a new location for the user:
  case let .locationManager(.didUpdateLocations(locations)):
    // Do something with user's current location.
    ...

  // And ignore all the rest of the location manager delegate actions.
  case .locationManager:
    return .none

  // Handle the rest of your application's logic:
  ...
  }
}
```

Accessing any functionality on the location manager is done by return effects from the reducer. For example, if you want to request the user's current location when they tap a button, then you can do the following:

```swift
case .currentLocationButtonTapped:
  return environment.locationManager.requestLocation(id: LocationManagerId())
    .fireAndForget()
```

And finally, when creating the `Store` to power your application you will supply the "live" implementation of the `LocationManagerClient`, which is to say a client instance that actually holds onto a `CLLocationManager` on the inside and interacts with it directly:

```swift
let store = Store(
  initialState: AppState(),
  reducer: appReducer,
  environment: AppEnvironment(
    locationManager: .live,
    ...
  )
)
```

That is enough



## Try it out today

Lorem
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil, // TODO
  id: 43, // TODO
  publishedAt: .init(timeIntervalSince1970: 1589950800),
  title: "CoreLocation support in the Composable Architecture"
)
