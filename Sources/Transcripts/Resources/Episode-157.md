## Introduction

@T(00:00:05)
OK, so we’re now about halfway to implementing our search feature. We’ve got a map on the screen that we can pan and zoom around, and we’re getting real time search suggestions as we type, all powered by MapKit’s local search completer API.

@T(00:00:21)
The final feature we want to implement is to allow the user to tap a suggestion in the list and place a marker on the map corresponding to that location. Even better, sometimes the suggestions provided by the search completer don’t correspond to a single location, but rather a whole collection of collections. For example, if we search for “Apple Store” then the top suggestion has the subtitle “Search Nearby”, which should place a marker on every Apple Store nearby.

But, where are we going to get these search results from? As we saw a moment ago, the `MKLocalSearchCompletion` object has only a title and subtitle, so we don’t get an address or geographic coordinates for the location. Well, there is another API in MapKit that allows you to make a search request for points-of-interest, which means we have yet another dependency we need to control and add to our environment.

@T(00:01:18)
Let’s start by explore this API a little bit in a playground like we did for the search completer.

## Using and controlling MKLocalSearch

@T(00:01:25)
MapKit comes with a class called `MKLocalSearch` that can be used to search for particular locations. A request can be made in a variety of ways, including just asking for all points of interests in a region:

```swift
MKLocalSearch(
  request: MKLocalPointsOfInterestRequest(
    coordinateRegion: <#MKCoordinateRegion#>
  )
)
```

@T(00:01:50)
Or constructing something known as a `MKLocalSearch.Request`, which allows you to search for locations using a natural language query:

```swift
MKLocalSearch(
  request: <#MKLocalSearch.Request#>
)
```

@T(00:02:03)
Interestingly, there is even an initializer of `MKLocalSearch.Request` that takes a `MKLocalSearchCompletion` as an argument, which allows us to perform a full location search using the skeletal suggestion handed to us from the completer:

```swift
MKLocalSearch.Request.init(completion: <#MKLocalSearchCompletion#>)
```

@T(00:02:28)
In order to get access to a completion, we'll need to do so from the `MKLocalSearchCompleter`'s delegate callback.

```swift
func completerDidUpdateResult(_ completer: MKLocalSearchComleter) {
  print("succeeded")
  dump(completer.results)

  let search = MKLocalSearch(
    request: .init(completion: completer.results[0])
  )
}
```

@T(00:02:47)
And to kick off this request we will construct a `MKLocalSearch` with it and invoke the `.start` method:

```swift
MKLocalSearch(request: request)
  .start { <#MKLocalSearch.Response?#>, <#Error?#> in
    <#code#>
  }
```

@T(00:03:07)
There’s even an overload of `.start` that is powered off of Swift’s new `async`/`await` machinery. Basically any API that currently works with completion handler callbacks can be refactored to work with `async`/`await`, and it looks like this is one API that Apple has updated. Instead of the above closure-based handling of the response we can simply `try` to `await` the response:

```swift
let response = try await search.start()
```

> Error: 'async' call in a function that does not support concurrency

@T(00:03:40)
Although it seems that Swift playgrounds are not provided an async context at the root of the document, and so we have to provide it by spinning off a task:

```swift
Task {
  let response = try await search.start()
}
```

@T(00:04:05)
This response contains a few interesting things, including a bunch of map items, which are the things we want to render on our map:

```swift
print(response.mapItems)
```
```
[
  <MKMapItem: 0x6000027c05a0> {
    isCurrentLocation = 0;
    name = "Apple Grand Central";
    phoneNumber = "+1 (212) 284-1800";
    placemark = "Apple Grand Central, 45 Grand Central Terminal, New York, NY 10017, United States @ <+40.75265500,-73.97682800> +/- 0.00m, region CLCircularRegion (identifier:'<+40.75265500,-73.97682800> radius 141.52', center:<+40.75265500,-73.97682800>, radius:141.52m)";
    timeZone = "America/New_York (EDT) offset -14400 (Daylight)";
    url = "http://www.apple.com/retail/grandcentral";
  },
  …
]
```

@T(00:04:23)
These map items contain a lot of information, but most important is where they are located:

```swift
response.mapItems[0].placemark.coordinate
```

This is enough information to drop a marker on the map representing each item in the `mapItems` array.

@T(00:05:06)
The response also holds onto a `boundingRegion` field, which describes the rectangle coordinate region that encompasses all the results held in the response:

```swift
response.boundingRegion
```

@T(00:05:12)
This is enough information to re-position the map on the screen so that all of the markers appear on the screen at once.

@T(00:05:21)
So it seems like we’ve got everything we need to implement the feature we have in mind. Let’s start integration this API into our application by designing a dependency that can be used in the environment. We’ll start with a basic struct wrapper like we did for the search completer client:

```swift
struct LocalSearchClient {
}
```

@T(00:05:42)
And we’ll expose an endpoint for searching. We want to run this search against one of the completions a user taps, so we can capture that in the following signature:

```swift
struct LocalSearchClient {
  var search: (MKLocalSearchCompletion) -> Effect<
    MKLocalSearch.Response, Error
  >
}
```

@T(00:06:22)
And you'll notice that this endpoint is quite a bit simpler than the endpoints provided by `LocalSearchCompleter`. This really does model a basic network request, where we provide it the data it needs to fire off a request, and it then returns a response or error.

@T(00:06:43)
So what does a live implementation look like?

```swift
extension LocalSearchClient {
  static let live = Self(
    search: { completion in

    }
  }
}
```

@T(00:07:05)
We can start by instantiating a request for a completion and calling `start` on it.

```swift
search: { completion in
  MKLocalSearch(request: .init(completion: completion))
    .start()

}
```

@T(00:07:17)
We can’t simply call `await` on it, because we’re not in an `async` context, and what we want to do is return an `Effect`.

@T(00:07:36)
To construct an `Effect` we could use the `future` initializer, which takes a callback, and then move the request inside, where we can invoke the response handler version of `start` instead:

```swift
search: { completion in
  Effect.future { callback in
    MKLocalSearch(request: .init(completion: completion))
      .start { response, error in

      }

  }
}
```

@T(00:08:09)
And in here we can fall back to the old API that speaks completion handlers.

```swift
Effect.future { callback in
  MKLocalSearch(request: .init(completion: completion))
    .start { response, error in
      if let response = response {
        callback(.success(response))
      } else if let error = error {
        callback(.failure(error))
      } else {
        fatalError()
      }
  }
}
```

@T(00:08:38)
It’s a bummer how much more verbose this version is than the `async` version. Even worse, it introduces invalid states that don’t make sense. Because we are working with two optionals, we have 2 states that technically compile but I'm not sure how to handle:

- Both `response` and `error` can be `nil`, which represents that fatal-erroring path.
- Both `response` and `error` can be non-`nil`, and in this case we're quietly ignoring the error.

@T(00:09:02)
In order to leverage the new API we could introduce an `async` context:

```swift
Effect.future { callback in
  Task {
    let response = try await MKLocalSearch(
      request: .init(completion: completion)
    )
    .start()
  }
}
```

@T(00:09:28)
This is API can fail, so we should introduce a `do` block to capture any errors:

```swift
Task {
  do {
    let response = try await MKLocalSearch(
      request: .init(completion: completion)
    )
    .start()
  } catch {

  }
}
```

@T(00:09:36)
And this is exactly what we want to feed to our callback:

```swift
callback(.success(response))
```

@T(00:09:42)
And in the case of failure, we can hand the error off in the `catch` block.

```swift
do {
  let response = try await localSearch.start()
  callback(.success(response))
} catch {
  callback(.failure(error))
}
```

@T(00:09:50)
OK, this is compiling now!

@T(00:09:52)
We’re wrapping this async work in a very ad hoc way right now. It seems like it would be very useful to wrap any async work in an effect. Well no such helper exists in the Composable Architecture right now, but let’s not wait on library support. We should be able to cook up this helper ourselves. To understand what the signature should be we can look at the `Task` initializer that is defined in the `_Concurrency` module:

```swift
public init(
  priority: TaskPriority? = nil,
  operation: @escaping @Sendable () async -> Success
)
```

@T(00:10:39)
And there is another initializer that takes a throwing closure, which creates a task that can fail:

```swift
public init(
  priority: TaskPriority? = nil,
  operation: @escaping @Sendable () async throws -> Success
)
```

@T(00:11:01)
So we should be able to mimic this signature to initialize an `Effect`. We'll create a new static constructor called `task` to wrap this work.

```swift
extension Effect {
  static func task(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Output
  ) -> Self
  where Failure == Error {
  }
}
```

@T(00:11:28)
We’ve constrained `Failure` to be `Error` because we’re wrapping an async failure that throws.

@T(00:11:43)
And in here we can do the same work we were doing before, except we'll pass along the task priority, and we'll call the `operation` instead of the concrete MapKit work we were doing before:

```swift
extension Effect {
  static func task(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Output
  ) -> Self
  where Failure == Error {
    .future { callback in
      Task(priority: priority) {
        do {
          callback(.success(try await operation()))
        } catch {
          callback(.failure(error))
        }
      }
    }
  }
}
```

@T(00:12:22)
This allows us to greatly simplify our dependency:

```swift
extension LocalSearchClient {
  static let live = Self { completion in
    .task {
      try await MKLocalSearch(
        request: .init(completion: completion)
      )
      .start()
    }
  }
}
```

@T(00:12:40)
We now understand how the local search APIs work, we've written a wrapper around the dependency in order to make it mockable and testable, and we've even introduced a general `Effect` helper for executing work using Swift's new `async`/`await` APIs, all without having to modify the Composable Architecture library.

## Integrating local search

@T(00:13:18)
Now that we have the search client defined and created a live implementation, let's integrate it into the application so that when we tap one of those search completions, we can fire off that local search request and display results on the map.

@T(00:13:43)
First, let’s add our new dependency to the environment of our application:

```swift
struct AppEnvironment {
  var localSearch: LocalSearchClient
  …
}
```

@T(00:13:54)
To kick off a search we need to pass a completion along to the search client when we tap a particular row by sending an action to the view store when a row is tapped:

```swift
enum AppAction {
  …
  case tappedCompletion(MKLocalSearchCompletion)
}
…
ForEach(viewStore.completions, id: \.id) { completion in
  Button(action: { viewStore.send(.tappedCompletion(completion)) }) {
    VStack(alignment: .leading) {
      Text(completion.title)
      Text(completion.subtitle)
        .font(.caption)
    }
  }
}
```

@T(00:14:43)
Our reducer needs to handle this case.

```swift
case let .tappedCompletion(completion):
  return environment.localSearch.search(completion)
```

> Error: Cannot convert return expression of type 'Effect&lt;MKLocalSearch.Response, Error>' to return type 'Effect&lt;AppAction, Never>'

@T(00:15:10)
And to feed the result of this effect back into the system we need another action.

```swift
case searchResponse(Result<MKLocalSearch.Response, Error>)
```

@T(00:15:38)
So that we can catch the effect.

```swift
case let .tappedCompletion(completion):
  return environment.localSearch.search(completion)
    .catchToEffect()
    .map(AppAction.searchResponse)
```

@T(00:16:03)
And then handle the response in our reducer.

```swift
case let .searchResponse(.success(response)):
  <#code#>
case let .searchResponse(.failure(error)):
  <#code#>
```

@T(00:16:22)
In the case of success, there are a few items we want to pluck off the response. For instance, we want to replace our state's region with the bounding region of the search results:

```swift
case let .searchResponse(.success(response)):
  state.region = .init(rawValue: response.boundingRegion)
```

@T(00:16:44)
We also have the map items available to us.

```swift
response.mapItems
```

@T(00:16:53)
We just need to introduce some state to our application in order to hold onto them and render them in our view.

```swift
struct AppState: Equatable {
  …
  var mapItems: [MKMapItem] = []
  …
}
```

@T(00:17:07)
When we get a successful response, we can assign the map items and update the region.

```swift
case let .searchResponse(.success(response)):
  state.mapItems = response.mapItems
  state.region = .init(rawValue: response.boundingRegion)
  return .none
```

@T(00:17:19)
And we can stub out some error handling:

```swift
case .searchResponse(.failure):
  // TODO: error handling
  return .none
```

@T(00:17:30)
To render these map items, we can hook into a couple `Map` view fields we’ve been ignoring:

```swift
annotationItems: <#Items#>,
annotationContent: <#(Items.Element) -> Annotation#>
```

@T(00:17:44)
These two fields are responsible for rendering annotation views over a map. This includes a collection of data with an element per annotation to render, and a view builder that can render an annotation, given one of those elements.

@T(00:18:01)
For items we can pass along the view store’s map items:

```swift
annotationItems: viewStore.mapItems,
```

> Error: Initializer 'init(coordinateRegion:interactionModes:showsUserLocation:userTrackingMode:annotationItems:annotationContent:)' requires that 'MKMapItem' conform to 'Identifiable'

@T(00:18:12)
SwiftUI needs these annotation items to be identifiable, and `MKMapItem` is not. Ideally this means introducing our own type that can hold the map item data we care about and that we can determine an `Identifiable` conformance for. But to get things building we can simply add a conformance to `MKMapItem`.

```swift
extension MKMapItem: Identifiable {}
```

@T(00:18:38)
Because `MKMapItem` is an object, it gets a free conformance based on object identity, which probably isn’t what we want here. There is no guarantee that MapKit is going to return the exact same object for the same place across searches. So all the more reason to introduce a type we own. But for now, at least we can get something on the screen.

@T(00:19:00)
And for annotation content we can render an annotation. There are several annotation views at our disposal, including a pin, a marker, or a completely customizable `MapAnnotation` view. Let’s simply render a marker by passing along the map item coordinate:

```swift
annotationContent: { mapItem in
  MapMarker(coordinate: mapItem.placemark.coordinate)
}
```

@T(00:19:29)
Everything is now building except for our previews and app entrypoint, which need to be supplied a local search client.

```swift
environment: .init(
  localSearch: .live,
  localSearchCompleter: .live
)
```

@T(00:19:48)
If we run this in the preview we can type in a query, tap a row, and the map will zoom into a region and display a pin. However, by running this in the preview we are hiding a bug that unfortunately can only be seen by running in the simulator.

@T(00:20:17)
If we do the same in the simulator we will see we have a purple warning:

> Runtime Warning: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.

@T(00:20:30)
This is because MapKit’s local search is delivering its response on a background queue. We need to redispatch this work on the main queue so that it can be rendered on the UI thread.

@T(00:20:48)
We can do this by tacking a `.receive(on:)` operation on the effect to get its output back on the main queue:

```swift
return environment.localSearch.search(completion)
  .receive(on: DispatchQueue.main)
  .catchToEffect()
  .map(AppAction.searchResponse)
```

@T(00:21:09)
However, by doing a little bit of upfront work right now we’ll make our lives much easier when it comes to testing. We are going to explicitly add a main queue dependency to our environment via the `[AnyScheduler](https://pointfreeco.github.io/combine-schedulers/AnyScheduler/)` type from our [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library:

```swift
struct AppEnvironment {
  …
  var mainQueue: AnySchedulerOf<DispatchQueue>
}
```

@T(00:21:44)
So that we can use it on the search effect:

```swift
case let .tappedCompletion(completion):
  return environment.localSearch.search(completion)
    .receive(on: environment.mainQueue)
    .catchToEffect()
    .map(AppAction.searchResponse)
```

@T(00:21:52)
This will make it possible to use immediate schedulers and test schedulers when writing tests for this feature, rather than being at the mercy of the live dispatch queue, which forces us to add explicitly waits to our tests to wait for thread hops.

@T(00:22:06)
Next we need to update our preview and app entry point:

```swift
environment: .init(
  localSearch: .live,
  localSearchCompleter: .live(),
  mainQueue: .main
)
```

@T(00:22:19)
Now when we build, we can search for some places and they immediately appear on the map, and the purple warning has gone away.

@T(00:22:34)
If we wanted to get a little fancy we could even add an animation so that the map zooms and pans to the region where the marker will be. This is quite easy thanks to the `.animation()` method [we defined](/episodes/ep136-swiftui-animation-the-basics) in our Combine Schedulers library, which we did [a number of episodes](/collections/combine/schedulers) on a few months ago:

```swift
case let .tappedCompletion(completion):
  return environment.localSearch.search(completion)
    .receive(on: environment.mainQueue.animation())
    .catchToEffect()
    .map(AppAction.searchResponse)
```

@T(00:23:08)
This is pretty cool. With just a bit of work we have now designed two dependency wrappers around MapKit APIs, `MKLocalSearchCompleter` and `MKLocalSearch`, and have implemented a decently complicated piece of logic to allow us to search for locations and display those locations on the map.

## Testing the entire application

@T(00:23:29)
But let’s kick things up a notch.

@T(00:23:32)
We could keep adding features to this, but let's turn our attention to testing. Already the logic is quite complicated, requiring us to fire off multiple effects and coordinate their responses. As we will build more and more of this places searching application we are going to add more logic to the reducer, and so ideally we should have some tests in place to make sure things are working as we expect.

@T(00:23:55)
As we’ve said a number of times on Point-Free, testing is one of the most important features of the Composable Architecture and it is a true super power of the library. We can test every little subtle edge case of our reducers, including how effects are executed and fed back into the system, all the while the library keeps us in check to make sure we are exhaustively asserting on everything that happens and no letting anything slip by.

@T(00:24:23)
We can start with a stub:

```swift
import ComposableArchitecture
import XCTest
@testable import Search

class SearchTests: XCTestCase {
  func testExample() {
  }
}
```

@T(00:24:29)
The first thing we need to do to test a feature in the Composable Architecture is to create a test store, which takes the same arguments as a normal store:

```swift
let store = TestStore(
  initialState: <#_#>,
  reducer: <#Reducer<_, _, _>#>,
  environment: <#_#>
)
```

@T(00:24:46)
We can configure it with some initial state, reducer, and environment.

```swift
let store = TestStore(
  initialState: .init(),
  reducer: appReducer,
  environment: .init(
    localSearch: <#LocalSearchClient#>,
    localSearchCompleter: <#LocalSearchCompleter#>,
    mainQueue: <#AnySchedulerOf<DispatchQueue>#>
  )
)
```

@T(00:25:01)
We don’t want to use a “live” environment here because it hits Apple’s APIs, which we can’t control, and uses a main queue, which would require us to wait for effects to be received using `XCTestExpectation`s.

@T(00:25:17)
Back in a series of episodes we titled “[Better Test Dependencies](/collections/dependencies/better-test-dependencies)”, we introduced the notion of “[failing dependencies](/collections/dependencies/better-test-dependencies/ep139-better-test-dependencies-failability)”: dependencies that call `XCTFail` whenever an endpoint is exercised, letting us prove that the code paths we are testing do not use certain dependencies, and forcing us to address when new dependencies are exercised in a test.

@T(00:25:40)
In fact, the [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library that [the Composable Architecture](/collections/composable-architecture) depends on comes with a “[failing](https://pointfreeco.github.io/combine-schedulers/FailingScheduler/)” scheduler, so we can supply that immediately:

```swift
mainQueue: .failing
```

@T(00:25:54)
And [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) comes with a “[failing](https://pointfreeco.github.io/swift-composable-architecture/Effect/#effect.failing(_:))” effect, which we can use in the endpoints for the search client and the completer. Let’s go ahead and create a static `.failing` implementation of each of our clients, just like `AnyScheduler` has:

```swift
extension LocalSearchClient {
  static let failing = Self(
    search: { _ in
      .failing("LocalSearchClient.search is unimplemented")
    }
  )
}

extension LocalSearchCompleter {
  static let failing = Self(
    completions: {
      .failing("LocalSearchCompleter.completions is unimplemented")
    },
    search: { _
      in .failing("LocalSearchCompleter.search is unimplemented")
    }
  )
}
```

@T(00:26:50)
And now instantiating a store is short and sweet:

```swift
let store = TestStore(
  initialState: .init(),
  reducer: appReducer,
  environment: .init(
    localSearch: .failing,
    localSearchCompleter: .failing,
    mainQueue: .failing
  )
)
```

@T(00:26:56)
Now that we have a store, we can start sending it a script of actions and describe how we expect state to evolve over time.

@T(00:27:09)
The `.onAppear` action seems like a good one to start with.

```swift
store.send(.onAppear)
```

@T(00:27:18)
And we can run tests and already get our first failure.

> Failed: LocalSearchCompleter.completions is unimplemented - A failing effect ran.

@T(00:27:26)
This is a good error to have! The failing effect requires us to consider this effect and explicitly handle it.

@T(00:27:48)
Since this is an effect that can emit multiple times we will use a passthrough subject to control it under the hood, which allows us to emit many outputs:

```swift
import Combine
import MapKit
…
let completionsSubject = PassthroughSubject<
  Result<[MKLocalSearchCompletion], Error>,
  Never
>()
```

@T(00:28:25)
And we can override the environment’s endpoint to return this subject:

```swift
store.environment.localSearchCompleter.completions = {
  completionsSubject.eraseToEffect()
}
```

@T(00:28:52)
This is the first time we have updated the environment of a test store in this fashion on Point-Free episodes. Typically we create an environment up at the top of the test and pass it to the test store all at once. However, it is also possible to make updates to the environment after creating the test store, which allows you to either change a dependency’s behavior in the middle of the test. Both styles have their pros and cons, so it’s up to you and your team to decide which you prefer.

@T(00:29:51)
Now when we run tests, we get a different failure:

> Failed: An effect returned for this action is still running. It must complete before the end of the test.

@T(00:29:55)
This is saying that the test store knows there is a long-living effect that is still running when the test completes. This is also a good error to have. It’s forcing us to be exhaustive in our tests. If an action fires off an effect, you should want to assert against actions it may feed back into the system, or you should want it to complete.

@T(00:30:40)
In the future we may want to cancel this effect using another hook like `onDisappear`, but for now we can get the test passing by sending a completion to the subject at the end of the test.

```swift
defer { completionsSubject.send(completion: .finished) }
```

@T(00:31:00)
And now the test is passing.

@T(00:31:17)
Let’s start interacting with the feature. We can simulate a user typing a query into the search field.

```swift
store.send(.queryChanged("Apple"))
```

@T(00:31:32)
And we get a couple failures:

> Failed: LocalSearchCompleter.search is unimplemented - A failing effect ran.

> Failed: State change does not match expectation: …
>
> ```
>   AppState(
>     completions: [
>     ],
>     mapItems: [
>     ],
> −   query: "",
> +   query: "Apple",
>     region: CoordinateRegion(
>       center: LocationCoordinate2D(
>         latitude: 40.7,
>         longitude: -74.0
>       ),
>       span: CoordinateSpan(
>         latitudeDelta: 0.075,
>         longitudeDelta: 0.075
>       )
>     )
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:31:35)
The first failure is because `queryChanged` fires off another failing effect that we need to override. The second is because the test store forces us to describe any mutations made to state, and `queryChanged` updates the `query` field. We can assert against this state change by opening a trailing closure where we mutate the state to how we expect it to look.

```swift
store.send(.queryChanged("Apple")) {
  $0.query = "Apple"
}
```

@T(00:32:31)
And then, for the other failure, we can stub out an effect that feeds completions back into the system.

```swift
store.environment.localSearchCompleter.search = { _ in
  .fireAndForget {
    completionsSubject.send(.success([MKLocalSearchCompletion()]))
  }
}
```

@T(00:33:40)
When we re-run the test we get a new failure:

> Failed: The store received 1 unexpected action after this one: …
>
> ```
> Unhandled actions:
>   [
>     AppAction.completionsUpdated(
>       Result<Array<MKLocalSearchCompletion>, Error>.success(
>         [
>           <MKLocalSearchCompletion 0x6000029b6760> ,
>         ]
>       )
>     ),
>   ]
> ```

@T(00:34:02)
This is yet another good failure to have. Not only do we need to exhaustively describe any mutations that happen to test store state, we must also assert against any actions that are fed back into the system from effects. We can do so with the `receive` method on the test store:

```swift
store.receive(.completionsUpdated(.success([MKLocalSearchCompletion()])))
```

> Error: Instance method '`receive(_:file:line:_:)`' requires that 'AppAction' conform to 'Equatable'

@T(00:34:35)
But to compare this action with the one we expect to receive `AppAction` must be equatable.

@T(00:35:04)
Unfortunately, we don’t get a synthesized conformance for free:

```swift
enum AppAction: Equatable {
  …
}
```

> Error: Type 'AppAction' does not conform to protocol 'Equatable’

@T(00:35:07)
The only type that is really getting in the way right now is `Error`, which as a protocol does not conform to `Equatable`. To work around this, we can take advantage of the fact that every `Error` can be cast to `NSError`, and `NSError` does conform to `Equatable`.

```swift
case completionsUpdated(Result<[MKLocalSearchCompletion], NSError>)
…
case searchResponse(Result<MKLocalSearch.Response, NSError>)
```

@T(00:35:32)
We just need to cast the errors in our reducer before returning the effects:

```swift
case .onAppear:
  return environment.localSearchCompleter.completions()
    .map { $0.mapError { $0 as NSError } }
    .map(AppAction.completionsUpdated)
    .eraseToEffect()
…
case let .tappedCompletion(completion):
  return environment.localSearch.search(completion)
    .receive(on: environment.mainQueue.animation())
    .mapError { $0 as NSError }
    .catchToEffect()
    .map(AppAction.searchResponse)
```

@T(00:36:35)
Our tests are now building and when we run them we get 2 new failures:

> Failed: Received unexpected action: …
>
> ```
>   AppAction.completionsUpdated(
>     Result<Array<MKLocalSearchCompletion>, NSError>.success(
>       [
> −       <MKLocalSearchCompletion 0x6000019405f0> ,
> +       <MKLocalSearchCompletion 0x6000019406e0> ,
>       ]
>     )
>   )
> ```
>
> (Expected: −, Received: +)

> Failed: State change does not match expectation: …
>
> ```
>   AppState(
>     completions: [
> +     <MKLocalSearchCompletion 0x6000019406e0> ,
>     ],
>     mapItems: [
>     ],
>     query: "Apple",
>     region: CoordinateRegion(
>       center: LocationCoordinate2D(
>         latitude: 40.7,
>         longitude: -74.0
>       ),
>       span: CoordinateSpan(
>         latitudeDelta: 0.075,
>         longitudeDelta: 0.075
>       )
>     )
>   )
> ```
>
> (Expected: −, Actual: +)

@T(00:26:42)
The first failure says that the action we said we received does not actually the match the action we did receive. They are both `.completionsUpdated` actions, and even both `.success`, but the objects inside the success case does not match:

@T(00:37:03)
The fact that we are seeing pointer addresses in here means we are dealing with reference type, which are notoriously tricky to define equatability on. Perhaps the MapKit framework tracks some additional identity that gets lost when we recreate the completion here in the test. Maybe we can work around it by reusing the same object:

```swift
let completion = MKLocalSearchCompletion()
store.environment.localSearchCompleter.search = { _ in
  .fireAndForget {
    completionsSubject.send(.success([completion]))
  }
}
…
store.receive(.completionsUpdated(.success([completion])))
```

> Failed: Received unexpected action: …
>
> Expected:
>   completionsUpdated(Swift.Result&lt;Swift.Array&lt;__C.MKLocalSearchCompletion>, __C.NSError>.success([&lt;MKLocalSearchCompletion 0x600001dd3390> ]))
>
> Received:
>   completionsUpdated(Swift.Result&lt;Swift.Array&lt;__C.MKLocalSearchCompletion>, __C.NSError>.success([&lt;MKLocalSearchCompletion 0x600001dd3390> ]))

@T(00:27:45)
Unfortunately not. Despite conforming to `Equatable`, even the same object does not considered equivalent:

```swift
let completion = MKLocalSearchCompletion()
XCTAssertEqual(completion, completion)
```

> Failed: XCTAssertEqual failed: ("&lt;MKLocalSearchCompletion 0x6000031f5810>") is not equal to ("&lt;MKLocalSearchCompletion 0x6000031f5810>")

@T(00:38:13)
Well we should always be prepared to hit limits like these when working with types we don’t own, especially reference types, and luckily we are. Let’s create a wrapper type around `MKLocalSearchCompletion` that we have complete control over so that we can get this assertion reasonably passing, just as we did for the coordinate and region types from MapKit:

```swift
struct LocalSearchCompletion: Equatable {

}
```

@T(00:39:01)
It will hold onto the raw value from MapKit, which is needed later to initialize a local search request.

```swift
struct LocalSearchCompletion: Equatable {
  let rawValue: MKLocalSearchCompletion
}
```

@T(00:39:16)
This live value is not what we want to use for tests, we will make it optional.

```swift
struct LocalSearchCompletion: Equatable {
  let rawValue: MKLocalSearchCompletion?
}
```

@T(00:39:28)
And for our tests, we’ll also include the fields we care about.

```swift
struct LocalSearchCompletion: Equatable {
  let rawValue: MKLocalSearchCompletion?

  var subtitle: String
  var title: String
}
```

@T(00:39:40)
But knowing that we can’t depend on the synthesized equatability of that raw value, we should define a custom conformance.

```swift
struct LocalSearchCompletion: Equatable {
  …
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.subtitle == rhs.subtitle
      && lhs.title == rhs.title
  }
}
```

@T(00:40:08)
We will also want a few specific ways to create this type. In the live dependency we’ll need to create this type from a raw `MKLocalSearchCompletion`, but in tests we’ll want to create this type from just the title and subtitle strings:

```swift
init(rawValue: MKLocalSearchCompletion) {
  self.rawValue = rawValue
  self.subtitle = rawValue.subtitle
  self.title = rawValue.title
}

init(subtitle: String, title: String) {
  self.rawValue = nil
  self.subtitle = subtitle
  self.title = title
}
```

@T(00:40:52)
Next we should update our dependencies to work with this type. First, the completer will not return completion results of the `LocalSearchCompletion` type, rather than the `MKLocalSearchCompletion` type:

```swift
struct LocalSearchCompleter {
  var completions: () -> Effect<
    Result<[LocalSearchCompletion], Error>, Never
  >
  …
}
```

@T(00:41:18)
And its live implementation will need to be updated to deal with the new type::

```swift
class Delegate: NSObject, MKLocalSearchCompleterDelegate {
  let subscriber: Effect<
    Result<[LocalSearchCompletion], Error>, Never
  >
  .Subscriber
  
  init(
    subscriber: Effect<
      Result<[LocalSearchCompletion], Error>, Never
    >
    .Subscriber
  ) {
    self.subscriber = subscriber
  }
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    self.subscriber.send(
      .success(
        completer.results
        .map(LocalSearchCompletion.init(rawValue:)))
    )
  }
  func completer(
    _ completer: MKLocalSearchCompleter,
    didFailWithError error: Error
  ) {
    self.subscriber.send(.failure(error))
  }
}
```

@T(00:41:55)
And then the search client:

```swift
struct LocalSearchClient {
  var search: (LocalSearchCompletion) -> Effect<Response, Error>
}
```

@T(00:42:05)
And its live implementation can reach into the completion’s `rawValue` to get the real `MKLocalSearchCompletion`, but because its optional we will force unwrap it:

```swift
extension LocalSearchClient {
  static let live = Self { completion in
    .task {
      try await MKLocalSearch(
        request: .init(completion: completion.rawValue!)
      )
      .start()
    }
  }
}
```

@T(00:42:20)
We feel it is OK to force unwrap here because the `rawValue` should never be non-`nil` in production code, only in test code. In fact,  we could strengthen this property by making the initializer that uses the `rawValue` to be the only publicly available initializer, and then the initializer that takes a title and subtitle would be made internal so that it was only available to tests.

@T(00:42:50)
Next, in our app domain we will hold onto an array of `LocalSearchCompletion` values, which should make equatable checks much better:

```swift
struct AppState: Equatable {
  var completions: [LocalSearchCompletion] = []
  …
}
```

@T(00:43:07)
Some of our app actions also update:

```swift
enum AppAction: Equatable {
  case completionsUpdated(Result<[LocalSearchCompletion], NSError>)
  …
  case tappedCompletion(LocalSearchCompletion)
}
```

@T(00:43:10)
Nothing needs to change in the reducer.

@T(00:43:15)
And in the view, where `ForEach` that iterates over the completions.

> Error: Referencing initializer 'init(_:content:)' on 'ForEach' requires that 'LocalSearchCompletion' conform to 'Identifiable’

@T(00:43:17)
We need to update the id we wrote to work on our custom type, instead. We can even make it `Identifiable` and drop the view’s `id:` parameter.

```swift
extension LocalSearchCompletion: Identifiable {
  public var id: [String] {
    [self.title, self.subtitle]
  }
}
```

@T(00:43:44)
Which means we can even drop the `id` parameter from `ForEach`.

```swift
ForEach(viewStore.completions) { completion in
  …
}
```

@T(00:43:56)
Our app is building, but our tests are not. We need to update the passthrough subject to work with our new wrapper type:

```swift
let completionsSubject = PassthroughSubject<
  Result<[LocalSearchCompletion], Error>, Never
>()
```

@T(00:44:24)
And our completion:

```swift
let completion = LocalSearchCompletion(
  subtitle: "Search Nearby",
  title: "Apple Store"
)
```

@T(00:44:42)
Tests are compiling, and we’re down to one failure, where we need to assert against assigning the completions.

```swift
store.receive(.completionsUpdated(.success([completion]))) {
  $0.completions = [completion]
}
```

@T(00:45:42)
And tests pass!

@T(00:45:46)
Finally let’s test tapping a completion.

```swift
store.send(.tappedCompletion(completion))
```

> Failed: An effect returned for this action is still running. It must complete before the end of the test.

> Failed: DispatchQueue - A failing scheduler scheduled an action to run immediately.

> Failed: LocalSearchClient.search is unimplemented - A failing effect ran.

@T(00:46:06)
OK, 3 failures! And if we read through them we see they’re all related:

@T(00:46:12)
Tapping a completion fires off a failing effect, which is scheduled on a failing queue, and so that effect is still running.

@T(00:46:48)
We can upgrade our failing scheduler to an immediate one to fix the first two failures.

```swift
store.environment.mainQueue = .immediate
```

@T(00:47:33)
And we can override the search endpoint with some mock data.

```swift
store.environment.localSearch.search = { _ in Effect(value: <#Output#>) }
```

@T(00:48:08)
We can try to create a local search response and set some mock data on it:

```swift
let response = MKLocalSearch.Response()
response.mapItems = [MKMapItem()]
response.boundingRegion = .init(
  center: .init(latitude: 0, longitude: 0),
  span: .init(latitudeDelta: 1, longitudeDelta: 1)
)
return .init(value: response)
```

> Failed: Cannot assign to property: 'mapItems' is a get-only property

> Failed: Cannot assign to property: 'boundingRegion' is a get-only property

@T(00:48:59)
OK well it looks like we’re hitting another limitation of working directly with Apple’s types. We’ll want to wrap the response as well.

```swift
struct LocalSearchClient {
  var search: (MKLocalSearchCompletion) -> Effect<Response, Error>

  struct Response: Equatable {
    var boundingRegion = CoordinateRegion()
    var mapItems: [MKMapItem] = []
  }
}
```

@T(00:50:00)
This time we can simply wrap the raw data the reducer needs. No need to hold onto the response. The reason we needed to hold onto the `MKLocalSearchCompletion` in our wrapper type is because the live `MKLocalSearch.Request` needs access to it.

@T(00:50:20)
Let’s add a helper initializer that takes a raw value:

```swift
extension LocalSearchClient.Response {
  init(rawValue: MKLocalSearch.Response) {
    self.init(
      boundingRegion: .init(rawValue: rawValue.boundingRegion),
      mapItems: rawValue.mapItems
    )
  }
}
```

@T(00:51:16)
We can update the live client.

```swift
extension LocalSearchClient {
  static let live = Self { completion in
    .task {
      .init(
        rawValue: try await MKLocalSearch(
          request: .init(completion: completion.rawValue!)
        )
        .start()
      )
    }
  }
}
```

@T(00:51:35)
And app action:

```swift
enum AppAction: Equatable {
  …
  case searchResponse(Result<LocalSearchClient.Response, NSError>)
  …
}
```

@T(00:51:47)
There’s one compiler error in the reducer where previously we were creating a `CoordinateRegion` from an `MKCoordinateRegion`, but now we can just use the coordinate region directly:

```swift
case let .searchResponse(.success(response)):
  state.mapItems = response.mapItems
  state.region = response.boundingRegion
  return .none
```

@T(00:52:15)
The app is building again, but now we can create one of those mock values:

```swift
let response = LocalSearchClient.Response(
  boundingRegion: .init(
    center: .init(latitude: 0, longitude: 0),
    span: .init(latitudeDelta: 1, longitudeDelta: 1)
  ),
  mapItems: [MKMapItem()]
)
store.environment.localSearch.search = { _ in .init(value: response) }
```

> Failed: The store received 1 unexpected action after this one: …
>
> ```
> Unhandled actions: [
>   AppAction.searchResponse(
>     Result<Response, NSError>.success(
>       Response(
>         boundingRegion: CoordinateRegion(
>           center: LocationCoordinate2D(
>             latitude: 50.0,
>             longitude: 50.0
>           ),
>           span: CoordinateSpan(
>             latitudeDelta: 0.5,
>             longitudeDelta: 0.5
>           )
>         ),
>         mapItems: [
>           <MKMapItem: 0x60000112cd20> {
>               isCurrentLocation = 0;
>               name = "Unknown Location";
>               placemark = "<+50.50000000,+50.50000000> +/- 0.00m, region CLCircularRegion (identifier:'<+50.50000000,+50.50000000> radius 0.00', center:<+50.50000000,+50.50000000>, radius:0.00m)";
>           },
>         ]
>       )
>     )
>   ),
> ]
> ```

@T(00:53:01)
One failure, where we need to handle the response action:

```swift
store.receive(.searchResponse(.success(response))) {
  $0.region = response.boundingRegion
  $0.mapItems = response.mapItems
}
```

@T(00:54:28)
And they pass!

@T(00:54:38)
Now that we have a test suite in place, let's add a new feature to see how it affects our tests. Let's make it so when you tap a completion, we repopulate the search field with the full title of the completion:

```swift
case let .tappedCompletion(completion):
  state.query = completion.title
```

> Failed: State change does not match expectation: …
>
> ```
>   AppState(
>     …
> −   query: "Apple",
> +   query: "Apple Store",
>     …
>   )
> ```

@T(00:55:15)
Our tests give us instant feedback as to how state changed based of our expectations, making it easy to update:

```swift
store.send(.completionTapped(completion)) {
  $0.query = "Apple Store"
}
```

@T(00:55:52)
And now it passes again!

@T(00:55:54)
Before we conclude, we should mention that there's one lone type that we didn't write a wrapper for, and that's `MKMapItem`. And remember, we _did_ conform that type to `Identifiable`, which is probably not a good idea for types we don't own. Ideally this type would be wrapped, as well, but we'll leave that as an exercise for the viewer.

## Conclusion

@T(00:56:30)
Amazingly this is testing a pretty complex flow, and for the most part its straightforward in the Composable Architecture. We simulate a script of user actions, things like typing into the search bar and tapping on a search suggestion, and we get to assert that not only does state change how we expect, but even effects execute and feed their data back into the system as we expect. Right now we're only testing the happy path, but there's also the unhappy paths, which are completely testable, and could guide error handling in our application.

@T(00:57:12)
That concludes this series of episodes. We just wanted to give our viewers a peek into some of the cool things announced at WWDC a few months ago, and give some insight into how we might support some of those new features in the Composable Architecture.

@T(00:57:35)
Until next time…
