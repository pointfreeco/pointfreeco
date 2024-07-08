## Introduction

@T(00:00:05)
We’re now going to change gears a bit to talk about one more new API that was introduced at WWDC this year, but this time it isn’t something that we have to do extra work in order to make it compatible with the Composable Architecture. Instead, it’s just a fun API that we want to use as an opportunity to build a fun application that shows off some complex behaviors.

@T(00:00:31)
We are going to take a look at the new `.searchable` API that makes it super easy to introduce custom search experiences to almost any screen. We are going to explore this API by building a simple application that allows us to search for points of interest on a map. This will give us the opportunity to play with some interesting frameworks that we haven’t touched in Point-Free yet, such as the search completer API for getting search suggestions and the local search API for searching a region of the map.

@T(00:00:58)
Often when building demo applications in the Composable Architecture we like to start with a domain modeling exercise first and then build out the logic and view. However this time we are going to do the opposite by starting with the view first. We are doing this because it isn’t entirely clear what all we need to hold in the domain, and by stubbing out a basic view and making use of MapKit’s APIs it will become very clear.

## Getting our views in place

@T(00:01:23)
We’ll start by creating a new blank project that has a simple view stubbed in:

```swift
import SwiftUI

struct ContentView: View {
  var body: some View {
    Text("Hello, world!")
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
```

@T(00:01:29)
As of iOS 14, SwiftUI comes with a `Map` view that can be used to show maps and annotations. We get access to it by importing `MapKit`:

```swift
import MapKit
```

@T(00:01:40)
Which gives us access to the following large initializer:

```swift
var body: some View {
  Map(
    coordinateRegion: <#Binding<MKCoordinateRegion>#>,
    interactionModes: <#MapInteractionModes#>,
    showsUserLocation: <#Bool#>,
    userTrackingMode: <#Binding<MapUserTrackingMode>?#>,
    annotationItems: <#RandomAccessCollection#>,
    annotationContent: <#(Identifiable) -> MapAnnotationProtocol#>
  )
}
```

@T(00:01:54)
Only one of these parameters is required, and that’s `coordinateRegion`, which is a binding that determines what area on Earth is being displayed in the map view:

```swift
coordinateRegion: <#Binding<MKCoordinateRegion>#>,
```

@T(00:02:09)
It’s a binding because it needs two way communication between our domain and its domain. If we want to programmatically change the region then we just have to mutate the binding, and if the map needs to change the region, like if the user pans or zooms, then it can also write to the binding.

@T(00:02:30)
For now we can stub out a constant binding that starts things out over New York City.

```swift
coordinateRegion: .constant(
  .init(
    center: .init(latitude: 40.7, longitude: -74),
    span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
  )
),
```

@T(00:02:49)
The other options allow us to configure how a map can be interacted with, whether or not we show and/or follow the user’s current location, as well as any annotations we want rendered over specific map locations. We won’t worry about these for now, though we’ll reintroduce some of them soon.

```swift
//interactionModes: <#MapInteractionModes#>,
//showsUserLocation: <#Bool#>,
//userTrackingMode: <#Binding<MapUserTrackingMode>?#>,
//annotationItems: <#RandomAccessCollection#>,
//annotationContent: <#(Identifiable) -> MapAnnotationProtocol#>
```

@T(00:03:06)
If we run the preview we see New York City, and we can pan, and zoom around. Nothing too exciting yet.

@T(00:03:14)
So, let’s enhance this with searchability. Adding search to a SwiftUI application means adding the `searchable` view modifier to the hierarchy. So we can tack one of its 12 (!) overloads onto our `Map` view.

```swift
.searchable(
  text: <#Binding<String>#>,
  placement: <#SearchFieldPlacement#>,
  prompt: <#Text#>,
  suggestions: <#() -> View#>
)
```

@T(00:03:42)
It takes a binding to a query, where the search field should display, a customizable placeholder prompt, and a closure that can return search suggestions while search is active.

@T(00:03:57)
Again to get things on the screen we can stub out a constant binding for now.

```swift
text: .constant("")
```

@T(00:04:04)
And we will hold off on customizing things further.

```swift
//placement: <#SearchFieldPlacement#>,
//prompt: <#Text#>,
//suggestions: <#() -> View#>
```

@T(00:04:08)
> Error: 'searchable(text:placement:prompt:)' is only available in iOS 15.0 or newer

We get an error that `.searchable` is only available in iOS 15, so let’s update the deployment target of the app.

@T(00:04:23)
If we re-run the preview everything looks the same, and that’s because the view still needs a place to put the search field.

@T(00:04:35)
In iPhone apps this will typically be in the navigation bar, so we can wrap things in a navigation view.

```swift
NavigationView {
  …
}
```

@T(00:04:44)
We now get a search bar floating at the top of the screen.

@T(00:05:10)
Let’s make one quick, small cosmetic change to this UI. There’s a lot of whitespace for where a navigation title should be. It doesn’t seem to be possible to hide the navigation title at this time and still have a search bar:

```swift
.navigationBarHidden(true)
```

@T(00:05:22)
So to make things look nice we can add a title instead:

```swift
.navigationTitle("Places")
```

@T(00:05:30)
And we can even change the title’s display mode to save a bit of screen real estate.

```swift
.navigationBarTitleDisplayMode(.inline)
```

@T(00:05:38)
The last argument of the `.searchable` method is a closure that returns a view, and that view is displayed while the search field is in focus. For example, we can put in a few text views inside the closure to see that appear as a list when we focus the field:

```swift
.searchable(
  text: .constant("")
//  placement: <#SearchFieldPlacement#>,
//  prompt: <#Text#>,
//  suggestions: <#() -> View#>
) {
  Text("Apple Store")
  Text("Cafe")
  Text("Library")
}
```

@T(00:06:16)
Finally, the map is only covering the safe area, so we see some white margins. I think it’d be nice to have more of a “full screen” feel by ignoring the bottom area.

```swift
.ignoresSafeArea(edges: .bottom)
```

@T(00:06:43)
We now have something that looks pretty nice!

## Introducing the Composable Architecture

@T(00:06:46)
We now have something that looks nice but is completely non-functional.

@T(00:07:07)
What we want is to build an app where, when the search query changes, we fire off a request to Apple for points of interest on the map. We’ll do so with the Composable Architecture, which means starting a domain modeling exercise, but this time influenced by what we’ve seen in the view layer.

@T(00:07:30)
We can start by describing all the mutable state on the screen, which we’ll model in a struct.

```swift
struct AppState {
}
```

@T(00:07:40)
Currently we have 2 constant bindings that represent the current region and query that represent our mutable app state so far. We can add those two fields to our `AppState` as well as using the values we were previously passing to be their defaults:

```swift
struct AppState {
  var query = ""
  var region = MKCoordinateRegion(
    center: .init(latitude: 40.7, longitude: -74),
    span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
  )
}
```

@T(00:08:07)
Next we have our actions, which we’ll represent in an enum with a case for every single way an app can be interacted with.

```swift
enum AppAction {
}
```

@T(00:08:14)
And the first two actions we’ll introduce are for the bindings that need to be able to mutate the underlying values.

```swift
enum AppAction {
  case queryChanged(String)
  case regionChanged(MKCoordinateRegion)
}
```

@T(00:08:32)
Finally we need an environment to hold all of our dependencies. We’ll start with an empty struct, but will be filling it out with dedicated clients for interacting with MapKit soon.

```swift
struct AppEnvironment {
}
```

@T(00:08:44)
We can get a reducer going for our app’s logic so far, but to get access to the `Reducer` type we must finally import the Composable Architecture.

```swift
import ComposableArchitecture
```

@T(00:08:58)
> Error: No such module 'ComposableArchitecture'
> Search package collections?

We haven't added this package to the project yet, but that gives us the chance to explore another new feature of Xcode 13, which is package collections. If we configure Xcode with Point-Free’s package collection on the Swift Package Index, importing things becomes just a few clicks away from the fix-it.

@T(00:10:05)
Now we can define a reducer:

```swift
let appReducer = Reducer<
  AppState,
  AppAction,
  AppEnvironment
> { state, action, environment in
}
```

@T(00:10:28)
Where we’ll switch over each action so we can update the associated binding state and return the `.none` effect, since we’re not ready to kick off any side effects yet.

```swift
switch action {
case let .queryChanged(query):
  state.query = query
  return .none

case let .regionChanged(region):
  state.region = region
  return .none
}
```

@T(00:11:01)
We’re now ready to update our view. We’ll introduce a store that will hold onto our app’s state and logic, and can process actions to mutate it over time.

```swift
struct ContentView: View {
  let store: Store<AppState, AppAction>
  …
}
```

@T(00:11:14)
And in the body of the view we need to use `WithViewStore` to observe the store’s state and send it actions.

```swift
var body: some View {
  WithViewStore(self.store) { viewStore in
    …
  }
}
```

@T(00:11:34)
The default `WithViewStore` initializer requires that state is equatable in order to de-dupe and minimize the number of times it evaluates its body.

@T(00:11:42)
We can hopefully synthesize a conformance:

```swift
struct AppState: Equatable {
  var query = ""
  var region = MKCoordinateRegion(
    center: .init(latitude: 40.7, longitude: -74),
    span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
  )
}
```

@T(00:11:50)
> Error: Type 'AppState' does not conform to protocol 'Equatable’

But unfortunately, despite being a simple struct with a few value type fields, `MKCoordinateRegion` does not conform to `Equatable`.

@T(00:11:59)
One thing we could do is simply conform `MKCoordinateRegion` to the `Equatable` protocol ourselves. After all the implementation is quite straightforward:

```swift
extension MKCoordinateRegion: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.center == rhs.center && lhs.span == rhs.span
  }
}

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

extension MKCoordinateSpan: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
  }
}
```

@T(00:12:16)
However, this kind of conformance is only appropriate for an application target. It should never be used for a library that could be reused in many places because Apple or someone else may someday define their own conformance, and there is no mechanism in Swift to decide which conformance to use. In general it’s a bad idea to conform 3rd party types to 3rd party protocols, and so we will not do this.

@T(00:12:38)
Instead we are going to put in the work to implement the correct way of doing this, even though it is a bit arduous. We will define brand new `Equatable` types that mirror `MKCoordinateRegion`, `CLLocationCoordinate2D` and `MKCoordinateSpan`, and expose ways to convert between the two types:

```swift
struct CoordinateRegion: Equatable {
  var center = LocationCoordinate2D()
  var span = CoordinateSpan()
}

extension CoordinateRegion {
  init(rawValue: MKCoordinateRegion) {
    self.init(
      center: .init(rawValue: rawValue.center),
      span: .init(rawValue: rawValue.span)
    )
  }

  var rawValue: MKCoordinateRegion {
    .init(center: self.center.rawValue, span: self.span.rawValue)
  }
}

struct LocationCoordinate2D: Equatable {
  var latitude: CLLocationDegrees = 0
  var longitude: CLLocationDegrees = 0
}

extension LocationCoordinate2D {
  init(rawValue: CLLocationCoordinate2D) {
    self.init(latitude: rawValue.latitude, longitude: rawValue.longitude)
  }

  var rawValue: CLLocationCoordinate2D {
    .init(latitude: self.latitude, longitude: self.longitude)
  }
}

struct CoordinateSpan: Equatable {
  var latitudeDelta: CLLocationDegrees = 0
  var longitudeDelta: CLLocationDegrees = 0
}

extension CoordinateSpan {
  init(rawValue: MKCoordinateSpan) {
    self.init(latitudeDelta: rawValue.latitudeDelta, longitudeDelta: rawValue.longitudeDelta)
  }

  var rawValue: MKCoordinateSpan {
    .init(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
  }
}
```

@T(00:13:32)
This is definitely a lot more code, and it’s a bummer to maintain, but it’s boilerplate that is straightforward. Ideally, the underlying types will be equatable in the future. (Everyone file feedbacks!)

@T(00:13:46)
And now if we update `AppState` to use this new `CoordinateRegion` we get a type that can automatically synthesize its `Equatable` conformance:

```swift
struct AppState: Equatable {
  var query = ""
  var region = CoordinateRegion(
    center: .init(latitude: 40.7, longitude: -74),
    span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
  )
}
```

@T(00:13:55)
And let’s also update the `AppAction` to use `CoordinateRegion` instead of `MKCoordinateRegion`:

```swift
enum AppAction {
  …
  case regionChanged(CoordinateRegion)
}
```

@T(00:13:57)
And now `WithViewStore` is happy.

@T(00:14:01)
Now that we have constructed a `viewStore` we can derive bindings that interact with the store. For the coordinate region:

```swift
coordinateRegion: viewStore.binding(
  get: \.region.rawValue,
  send: { .regionChanged(.init(rawValue: $0)) }
)
```

@T(00:15:16)
It’s a bummer that we have to do extra work for wrapping and unwrapping the coordinate region, but it’s important to have the `Equatable` conformance so that `WithViewStore` can be efficient, and at the end of the day `MKCoordinateRegion` should really be `Equatable` already.

@T(00:15:31)
The query binding is a little simpler:

```swift
.searchable(
  text: viewStore.binding(
    get: \.query,
    send: AppAction.queryChanged
  )
)
```

@T(00:15:50)
The only errors we have left are in our preview and app entry point, because `ContentView` now takes a store. We can construct one in each place:

```swift
ContentView(
  store: Store(
    initialState: .init(),
    reducer: appReducer,
    environment: .init()
  )
)
```

## Using and controlling MKLocalSearchCompleter

@T(00:16:33)
If we re-run things, they work exactly as before, but now our view is communicating with the store, and if we were to add a `.debugActions()` modifier to our reducer, we would see that as we pan and zoom the map, and as we type a query, actions are being sent through our business logic, which means we’re finally in a position to start executing some side effects when the query changes using APIs from MapKit.

@T(00:17:43)
The effect we want to execute while the user types is a request to get search suggestions based on the query entered. So for example, if you type “Cafe” into the search field you get an option that allows you to see all cafes nearby, along with a list of actual cafes with their addresses.

@T(00:18:02)
Turns out MapKit ships with an API that does this just, and it’s called `MKLocalSearchCompleter`. This means we will be introducing this object to our domain as a dependency in the environment.

@T(00:18:16)
First, to get a feel for how the API works let’s open up a playground, import `MapKit` and instantiate a completer:

```swift
import MapKit

let completer = MKLocalSearchCompleter()
```

@T(00:18:38)
Completers are initialized without any parameters. The way you interact with them is by mutating some fields. To search for nearby Apple Stores, we could update the `queryFragment` property.

```swift
completer.queryFragment = "Apple Store"
```

@T(00:19:06)
And then, we can access search results from the `results` property.

```swift
completer.results // []
```

@T(00:19:15)
This is empty, which is to be expected, because completers do their work asynchronously, and it can take some time to fire off the request and receive a response.

@T(00:19:29)
Completers communicate back to us when results are ready by using the delegate pattern. This is a great example of an API that will someday fit in nicely with Swift’s new `async`/`await` functionality, but in the meantime we can introduce a simple delegate that just prints out its results:

```swift
class LocalSearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    print("succeeded")
    dump(completer.results)
  }

  func completer(
    _ completer: MKLocalSearchCompleter, didFailWithError error: Error
  ) {
    print("failed", error)
  }
}
```

@T(00:20:19)
We just have to create one and assign it:

```swift
let delegate = LocalSearchCompleterDelegate()
completer.delegate = delegate
```

@T(00:20:37)
And when we run the playground, we get a bunch of things printed to the console:

```txt
succeeded
▿ 12 elements
  - <MKLocalSearchCompletion 0x…> Apple Store (Search Nearby) #0
    - super: NSObject
  - …
```

@T(00:20:52)
Each of these `MKLocalSearchCompletion` values are something we could show to the user in the suggestions list. And they should live update as they type into the search field.

@T(00:21:04)
So it seems like we know enough about this dependency to introduce it to our environment.

@T(00:21:11)
In order to control this dependency in tests, previews, and more, we will introduce a lightweight wrapper type that can hold the live implementation under the hood. We’ve done this a number of times before on Point-Free, and did the deepest dive in our series on “[designing dependencies](/collections/dependencies/designing-dependencies),” where we showed how to control a number of increasingly complex dependencies, from simple API requests to a complex location manager that used delegates.

@T(00:21:40)
Here we also have a dependency that uses delegates, which are among the more complicated dependencies to control. We’ll start by hopping back over to the application target and creating a struct wrapper that will hold a field for each endpoint that we want to access in the completer:

```swift
struct LocalSearchCompleter {}
```

@T(00:22:14)
We might distill the work down to sending a new search query into the completer and then returning the results in an effect:

```swift
struct LocalSearchCompleter {
  var search: (String) -> Effect<[MKLocalSearchCompletion], Error>
}
```

@T(00:22:46)
This is not an uncommon way of capturing this kind of work. We could then lean on Combine’s APIs in our reducer to debounce this work and manage cancellation.

@T(00:23:04)
The `MKLocalSearchCompleter` API, however, has already been designed to take care of all of the affordances of debouncing, cancellation, and more. All you have to do is keep updating the `queryFragment` field and the framework just notifies you when it receives some results. So it’s not necessary for us to do any of that work. Instead, we should introduce endpoints more analogous to the endpoints on the search completer.

@T(00:23:28)
So far in the playground we hit an endpoint to update the `queryFragment`. This is an in-place mutation of a string that returns no data, so we can model it with a function that takes a `String` and returns an effect that never outputs nor fails.

```swift
var search: (String) -> Effect<Never, Never>
```

@T(00:24:02)
And then we need an endpoint that returns a long-living effect for all of the delegate methods. In our case we have a very simple delegate with 2 endpoints: 1 that returns updated completion results, and 1 that handles failure.

@T(00:24:20)
Now, at first we may think we should model this as an effect that can deliver an array of `MKLocalSearchCompletion`s or an error:

```swift
var completions: () -> Effect<[MKLocalSearchCompletion], Error>
```

@T(00:24:38)
However, this represents a long-living effect that can fail, but once it does fail it ends the effect forever. That isn’t how the delegate system works. With the delegate the `MKLocalSearchCompleter` can ping the success and failure endpoints as many times as it wants. For example, maybe due to intermittent network problems the completer emits an error, but then a moment later things start working normally and delivers a success. The effect as written here cannot accomplish that.

@T(00:25:12)
So, we need to change the type of effect so that it can deliver as many completions or errors as it wants, which we can do by using a result type as the output:

```swift
var completions: () -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>
```

@T(00:25:36)
This is the interface that we will deal with in order to work with search completers.

@T(00:25:43)
Now we can start defining an implementation of this interface. We’ll start with the live client, which uses an actual, real life `MKLocalSearchCompleter` under the hood in order to implement these endpoints. We like to house these implementations as statics inside the client type:

```swift
extension LocalSearchCompleter {
  static let live = Self(
    completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
    search: <#(String) -> Effect<Never, Never>#>
  )
}
```

@T(00:26:12)
In order to implement these two endpoints we need to construct an `MKLocalSearchCompleter` somewhere. We could define one in the global module scope, but it would be better to scope it locally so that only the internals of this live client has access to it. To do this we can make the `live` static field a computed field, which then gives us the opportunity to construct a locally scoped `MKLocalSearchCompleter`:

```swift
extension LocalSearchCompleter {
  static var live: Self {
    let completer = MKLocalSearchCompleter()

    return Self(
      completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
      search: <#(String) -> Effect<Never, Never>#>
    )
  }
}
```

@T(00:26:57)
The `search` endpoint is the simplest one to implement because it’s just a matter of mutating the `completer`'s `queryFragment` field. However, we don’t want to just do it immediately. We want to only perform that mutation when the effect is executed, which we can do by return a `.fireAndForget`, which is one that can run but never emits output or failures:

```swift
return Self(
  completions: <#() -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>#>,
  search: { query in
    .fireAndForget {
      completer.queryFragment = query
    }
  }
)
```

@T(00:27:35)
The `completions` endpoint is a little more difficult to implement because it needs to construct a long-living effect that can emit lots of data, and it does so by using a delegate. Let’s get the basics into place first. To return a long-living effect we can use the `.run` static function on `Effect`, which takes a closure that is handed a `subscriber` which can be used to send as many outputs to the subscriber as we need. We also need to return a cancellable from this `.run` method, which will be useful in a moment for cleaning up resources when the effect is cancelled:

```swift
completions: {
  .run { subscriber in
    return AnyCancellable {

    }
  }
},
```

@T(00:28:40)
In order to receive completer results we need to construct a delegate. We can even define it directly in the scope of the `.run` closure, which means its only accessible inside this hyperlocal scope:

```swift
class Delegate: NSObject, MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
  }
}
```

@T(00:29:18)
Now what we want do is send the `subscriber` data in each of these delegate methods. We can just hold onto the subscriber inside the `Delegate` itself:

```swift
let subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber

init(subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber) {
  self.subscriber = subscriber
}
```

@T(00:29:46)
And then its easy to implement the delegate methods:

```swift
func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
  self.subscriber.send(.success(completer.results))
}

func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
  self.subscriber.send(.failure(error))
}
```

@T(00:30:37)
We can now set the delegate for the completer:

```swift
let delegate = Delegate(subscriber: subscriber)
completer.delegate = delegate
```

@T(00:30:57)
However, the `delegate` property on `MKLocalSearchCompleter` is defined as `weak`, which means that unless something else is holding onto the delegate it will be deallocated.

@T(00:31:12)
This is where the cancellable comes into play. We can capture the delegate in that closure to make sure it lives for as long as the publisher lives:

```swift
let delegate = Delegate(subscriber: subscriber)
completer.delegate = delegate
return AnyCancellable {
  _ = delegate
}
```

@T(00:31:27)
And that completes the live implementation of the search completer. It may seem complex, but remember that the dependency itself is quite complex since it uses delegates.

## Displaying search results

@T(00:31:49)
Let’s now make use of this new dependency to get some actual search completions when the query changes. We’ll start by adding the client to the `AppEnvironment`:

```swift
struct AppEnvironment {
  var localSearchCompleter: LocalSearchCompleter
}
```

@T(00:32:11)
And let’s go ahead and update all the places we create the environment to use the live one for now:

```swift
ContentView(
  store: .init(
    initialState: .init(),
    reducer: appReducer,
    environment: .init(
      localSearchCompleter: .live
    )
  )
)
```

@T(00:32:30)
With the dependency now in our environment we can make use of it in the reducer. For example, when the query we can fire off a `.search` effect from the completer:

```swift
case let .queryChanged(query):
  state.query = query
  return environment.localSearchCompleter.search(query)
```

@T(00:32:49)
But remember that `.search` is an `Effect<Never, Never>`, and so it does not feed and data back into the system. So, in order to get this to compile we have to coalesce the `<Never, Never>` effect into a `<AppAction, Never>` effect, which can be done with the `.fireAndForget()` operator:

```swift
return environment.localSearchCompleter.search(query)
  .fireAndForget()
```

@T(00:33:04)
This automatically casts the output and failure to what the reducer needs to return.

@T(00:33:12)
The only purpose of the `.search` endpoint is to communicate to the underlying `MKLocalSearchCompleter` that the query fragment changed, which then will cause results to be propagated to the delegate. In order to get the results from the delegate we must execute the long-living `.completions` effect to get a stead stream of suggestions as the query changes.

@T(00:33:31)
A good place to kick off long-living effects like this are by hooking into an `.onAppear` action that is invoked a single time when the view appears. So, let’s add the action to `AppAction`:

```swift
enum AppAction: Equatable {
  case onAppear
  …
}
```

@T(00:33:45)
And then we can handle this action in the reducer by starting up the long-living effect of completions:

```swift
case .onAppear:
  return environment.localSearchCompleter.completions()
```

@T(00:33:59)
This effect does feed data back into the system, unlike the `.search` endpoint, which means we need an action for receiving the data. The action will hold onto the exact data emitted by the effect, which is a result of either a successful array of completion results or an error:

```swift
case completionsUpdated(Result<[MKLocalSearchCompletion], Error>)
```

@T(00:34:20)
Then, when the `completions` effect emits data we can pipe that into this `AppAction` in order to send it back into the system:

```swift
return environment.localSearchCompleter.completions()
  .map(AppAction.completionsUpdated)
```

@T(00:34:34)
Since we now have a new action we have to handle it in the reducer. We can stub out the implementation by breaking up the success and failure cases and returning no effects:

```swift
case let .completionsUpdated(.success(completions)):
  return .none

case .completionsUpdated(.failure):
  return .none
```

@T(00:35:00)
To properly handle these cases we need to start holding completions in state so that we can keep track of the ones returned to us from the effect, which would then allow us to populate the suggestions list in the view. So, we’ll add a field to `AppState`:

```swift
struct AppState: Equatable {
  var completions: [MKLocalSearchCompletion] = []
  …
}
```

@T(00:35:23)
Interestingly, `MKLocalSearchCompletion` is `Equatable`, but this is just because it’s actually an `NSObject` which is always `Equatable`.

@T(00:35:33)
And now we can hold onto completions when they are delivered to us by the effect:

```swift
case let .completionsUpdated(.success(completions)):
  state.completions = completions
  return .none

case .completionsUpdated(.failure):
  // TODO: error handling
  return .none
```

@T(00:35:49)
Let’s also make sure to send the `.onAppear` action in the view:

```swift
.onAppear { viewStore.send(.onAppear) }
```

@T(00:36:06)
Things are now compiling, but we’re not doing anything with the completions we hold in state yet.

@T(00:36:09)
We want to show these completions in the suggestions part of the search, which you will remember is handled by providing a trailing closure to the `.searchable` API:

```swift
.searchable(
  text: viewStore.binding(
    get: \.query,
    send: AppAction.queryChanged
  )
) {
  …
}
```

@T(00:36:27)
We can `ForEach` over our completions in this closure in order to render the suggestions for the user to choose from:

```swift
.searchable(
  text: viewStore.binding(
    get: \.query,
    send: AppAction.queryChanged
  )
) {
  if viewStore.query.isEmpty {
    Text("Apple Store")
    Text("Cafes")
    Text("Library")
  } else {
    ForEach(viewStore.completions) { completion in
      Text(completion.title)
    }
  }
}
```

@T(00:36:44)
> Error: Referencing initializer 'init(_:content:)' on 'ForEach' requires that 'MKLocalSearchCompletion' conform to 'Identifiable'

It looks like `MKLocalSearchCompletion` is not `Identifiable`, and so it cannot be passed to `ForEach` directly. One thing we could do is pass a key path to an identifier, like maybe its title:

```swift
ForEach(viewStore.completions, id: \.title) { completion in
  …
}
```

@T(00:37:10)
Instead we can use the `id` argument of `ForEach` to compute an identifier to be used. `MKLocalSearchCompletion` only has a `title` and `subtitle` field, neither of which uniquely identify a completion, but put together it should be unique. So let’s add a computed property:

```swift
extension MKLocalSearchCompletion {
  var id: [String] { [self.title, self.subtitle] }
}
```

@T(00:37:54)
And now this compiles:

```swift
ForEach(viewStore.completions, id: \.id) { completion in
  Text(completion.title)
}
```

@T(00:37:59)
Even better, if we run the Xcode preview we can see lives search suggestions appearing as we type in the field. It’s even super responsive, nearly changing instantly with each key stroke.

@T(00:38:24)
Let’s improve the experience a little bit, because if I type something like “Apple Store” into the query I get what look like a bunch of duplicate entries. The `subtitle` of a completion provides more context, which would be nice to display.

```swift
ForEach(viewStore.completions, id: \.id) { completion in
  VStack(alignment: .leading) {
    Text(completion.title)
    Text(completion.subtitle)
      .font(.caption)
  }
}
```

@T(00:38:51)
And now things look really nice.

@T(00:38:59)
Finally, let's also improve the default suggestions experience. I'm going to paste in a whole bunch of code just to show how rich of an experience is possible to define here. We can even get something that looks a lot like Apple's official Maps experience with just a little bit of work:

```swift
if viewStore.query.isEmpty {
  HStack {
    Text("Recent Searches")
    Spacer()
    Button(action: {}) {
      Text("See all")
    }
  }
  .font(.callout)

  HStack {
    Image(systemName: "magnifyingglass")
    Text("Apple • New York")
    Spacer()
  }
  HStack {
    Image(systemName: "magnifyingglass")
    Text("Apple • New York")
    Spacer()
  }
  HStack {
    Image(systemName: "magnifyingglass")
    Text("Apple • New York")
    Spacer()
  }

  HStack {
    Text("Find nearby")
    Spacer()
    Button(action: {}) {
      Text("See all")
    }
  }
  .padding(.top)
  .font(.callout)

  ScrollView(.horizontal) {
    HStack {
      ForEach(1...2, id: \.self) { _ in
        VStack {
          ForEach(1...2, id: \.self) { _ in
            HStack {
              Image(systemName: "bag.circle.fill")
                .foregroundStyle(Color.white, Color.red)
                .font(.title)
              Text("Shopping")
            }
            .padding([.top, .bottom, .trailing],  4)
          }
        }
      }
    }
  }

  HStack {
    Text("Editors’ picks")
    Spacer()
    Button(action: {}) {
      Text("See all")
    }
  }
  .padding(.top)
  .font(.callout)
}
```

## Next time: annotating the map view

@T(00:39:49)
OK, so we’re now about halfway to implementing our search feature. We’ve got a map on the screen that we can pan and zoom around, and we’re getting real time search suggestions as we type, all powered by MapKit’s local search completer API.

@T(00:40:03)
The final feature we want to implement is to allow the user to tap a suggestion in the list and place a marker on the map corresponding to that location. Even better, sometimes the suggestions provided by the search completer don’t correspond to a single location, but rather a whole collection of collections. For example, if we search for “Apple Store” then the top suggestion has the subtitle “Search Nearby”, which should place a marker on every Apple store nearby.

@T(00:40:37)
But, where are we going to get these search results from? As we saw a moment ago, the `MKLocalSearchCompletion` object has only a title and subtitle, so we don’t get an address or geographic coordinates for the location. Well, there is another API in MapKit that allows you to make a search request for points-of-interest, which means we have yet another dependency we need to control and add to our environment.

@T(00:41:02)
Let’s start by explore this API a little bit in a playground like we did for the search completer…next time!
