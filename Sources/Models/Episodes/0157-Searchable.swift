import Foundation

extension Episode {
  public static let ep157_searchable = Episode(
    blurb: """
      We finish our search-based application by adding and controlling another MapKit API, integrating it into our application so we can annotate a map with search results, and then we'll go the extra mile and write tests for the entire thing!
      """,
    codeSampleDirectory: "0157-searchable-pt2",
    exercises: _exercises,
    id: 157,
    length: 57 * 60 + 40,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_629_090_000),
    references: [
      Episode.Reference(
        author: "Harry Lane",
        blurb: #"""
          A WWDC session exploring the `.searchable` view modifier.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10176/",
        publishedAt: referenceDateFormatter.date(from: "2021-06-09"),
        title: "Craft search experiences in SwiftUI"
      ),
      .init(
        author: "Sarun Wongpatcharapakorn",
        blurb: """
          A comprehensive article explaining the full `.searchable` API, including some things we did not cover in this episode, such as the `.dismissSearch` environment value and search completions.

          > SwiftUI finally got native search support in iOS 15. We can add search functionality to any navigation view with the new searchable modifier. Let's explore its capability and limitation.
          """,
        link: "https://sarunw.com/posts/searchable-in-swiftui/",
        publishedAt: referenceDateFormatter.date(from: "2021-07-07"),
        title: "Searchable modifier in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for the `.searchable` view modifier.
          """#,
        link:
          "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`searchable(_:text:placement:suggestions:)`"
      ),
    ],
    sequence: 157,
    subtitle: "Part 2",
    title: "Searchable SwiftUI",
    trailerVideo: .init(
      bytesLength: 31_768_150,
      downloadUrls: .s3(
        hd1080: "0157-trailer-1080p-a289eb51065b46f6b78bc6037c5effc3",
        hd720: "0157-trailer-720p-dd0fe41cde30487aa863b732ca668b07",
        sd540: "0157-trailer-540p-85ded24a704549c6bc1f4813d1fd8742"
      ),
      vimeoId: 585_305_341
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      In the episode we were able to get by without having to wrap Apple's `MKMapItem` type, but let's now go the extra mile and do so by introducing our own `MapItem` type. How does controlling this type affect our application and test code?
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Add an endpoint to `LocalSearchClient` that can perform a local search with a query string instead of a completion. The [`MKLocalSearch.Request`](https://developer.apple.com/documentation/mapkit/mklocalsearch/request) type has a `naturalLanguageQuery` mutable field that does just this.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      WWDC introduced another search-related API that we didn't have time to explore, and that's the [`onSubmit(of:_:)`](https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)/) view modifier, which evaluates an action closure when it detects a particular "submit trigger" is executed, which includes a "search" trigger:

      ```swift
      .onSubmit(of: .search) { ... }
      ```

      Use this API to introduce the ability for a user to fire off a search by submitting the current query string to the local search endpoint from the previous exercise.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Let's clean up the `LocalSearchClient` dependency. There are a few things we can fix and make nicer:

      * `MKLocalSearch.Request` has a `region` field that we've been ignoring, but we should pass the app's region to the dependency as input so that it can apply the region to the search request.

      * We have 2 separate endpoints for local search, but it might be nicer to unify this into a single interface to better match Apple's APIs.
      """#,
    solution: nil
  ),
]

extension Episode.Video {
  public static let ep157_searchable = Self(
    bytesLength: 488_685_581,
    downloadUrls: .s3(
      hd1080: "0157-1080p-b623f91dffa24fc1b5edcbc36b35b507",
      hd720: "0157-720p-8cb81a8b39074cbc8b50ff84cf6f5379",
      sd540: "0157-540p-f08c1316a1ee4c7888d4f24c1df3c690"
    ),
    vimeoId: 585_305_356
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep157_searchable: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Ok, so we’re now about halfway to implementing our search feature. We’ve got a map on the screen that we can pan and zoom around, and we’re getting real time search suggestions as we type, all powered by MapKit’s local search completer API.
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The final feature we want to implement is to allow the user to tap a suggestion in the list and place a marker on the map corresponding to that location. Even better, sometimes the suggestions provided by the search completer don’t correspond to a single location, but rather a whole collection of collections. For example, if we search for “Apple Store” then the top suggestion has the subtitle “Search Nearby”, which should place a marker on every Apple Store nearby.
        """#,
      timestamp: 21,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But, where are we going to get these search results from? As we saw a moment ago, the `MKLocalSearchCompletion` object has only a title and subtitle, so we don’t get an address or geographic coordinates for the location. Well, there is another API in MapKit that allows you to make a search request for points-of-interest, which means we have yet another dependency we need to control and add to our environment.
        """#,
      timestamp: nil,  // 53,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by explore this API a little bit in a playground like we did for the search completer.
        """#,
      timestamp: (1 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Using and controlling MKLocalSearch"#,
      timestamp: (1 * 60 + 25),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        MapKit comes with a class called `MKLocalSearch` that can be used to search for particular locations. A request can be made in a variety of ways, including just asking for all points of interests in a region:
        """#,
      timestamp: (1 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        MKLocalSearch(
          request: MKLocalPointsOfInterestRequest(coordinateRegion: <#T##MKCoordinateRegion#>)
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Or constructing something known as a `MKLocalSearch.Request`, which allows you to search for locations using a natural language query:
        """#,
      timestamp: (1 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        MKLocalSearch(
          request: <#T##MKLocalSearch.Request#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Interestingly, there is even an initializer of `MKLocalSearch.Request` that takes a `MKLocalSearchCompletion` as an argument, which allows us to perform a full location search using the skeletal suggestion handed to us from the completer:
        """#,
      timestamp: (2 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        MKLocalSearch.Request.init(completion: <#T##MKLocalSearchCompletion#>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In order to get access to a completion, we'll need to do so from the `MKLocalSearchCompleter`'s delegate callback.
        """#,
      timestamp: (2 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        func completerDidUpdateResult(_ completer: MKLocalSearchComleter) {
          print("succeeded")
          dump(completer.results)

          let search = MKLocalSearch(request: .init(completion: completer.results[0]))
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And to kick off this request we will construct a `MKLocalSearch` with it and invoke the `.start` method:
        """#,
      timestamp: (2 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        MKLocalSearch(request: request)
          .start { <#MKLocalSearch.Response?#>, <#Error?#> in
            <#code#>
          }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s even an overload of `.start` that is powered off of Swift’s new `async`/`await` machinery. Basically any API that currently works with completion handler callbacks can be refactored to work with `async`/`await`, and it looks like this is one API that Apple has updated. Instead of the above closure-based handling of the response we can simply `try` to `await` the response:
        """#,
      timestamp: (3 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let response = try await search.start()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 'async' call in a function that does not support concurrency

        Although it seems that Swift playgrounds are not provided an async context at the root of the document, and so we have to provide it by spinning off a task:
        """#,
      timestamp: (3 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Task {
          let response = try await search.start()
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This response contains a few interesting things, including a bunch of map items, which are the things we want to render on our map:
        """#,
      timestamp: (4 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        print(response.mapItems)
        // [<MKMapItem: 0x6000027c05a0> {
        //     isCurrentLocation = 0;
        //     name = "Apple Grand Central";
        //     phoneNumber = "+1 (212) 284-1800";
        //     placemark = "Apple Grand Central, 45 Grand Central Terminal, New York, NY 10017, United States @ <+40.75265500,-73.97682800> +/- 0.00m, region CLCircularRegion (identifier:'<+40.75265500,-73.97682800> radius 141.52', center:<+40.75265500,-73.97682800>, radius:141.52m)";
        //     timeZone = "America/New_York (EDT) offset -14400 (Daylight)";
        //     url = "http://www.apple.com/retail/grandcentral";
        // },
        // ...
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        These map items contain a lot of information, but most important is where they are located:
        """#,
      timestamp: (4 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        response.mapItems[0].placemark.coordinate
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is enough information to drop a marker on the map representing each item in the `mapItems` array.
        """#,
      timestamp: nil,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The response also holds onto a `boundingRegion` field, which describes the rectangle coordinate region that encompasses all the results held in the response:
        """#,
      timestamp: (5 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        response.boundingRegion
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is enough information to re-position the map on the screen so that all of the markers appear on the screen at once.
        """#,
      timestamp: (5 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So it seems like we’ve got everything we need to implement the feature we have in mind. Let’s start integration this API into our application by designing a dependency that can be used in the environment. We’ll start with a basic struct wrapper like we did for the search completer client:
        """#,
      timestamp: (5 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchClient {
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we’ll expose an endpoint for searching. We want to run this search against one of the completions a user taps, so we can capture that in the following signature:
        """#,
      timestamp: (5 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchClient {
          var search: (MKLocalSearchCompletion) -> Effect<MKLocalSearch.Response, Error>
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And you'll notice that this endpoint is quite a bit simpler than the endpoints provided by `LocalSearchCompleter`. This really does model a basic network request, where we provide it the data it needs to fire off a request, and it then returns a response or error.
        """#,
      timestamp: (6 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So what does a live implementation look like?
        """#,
      timestamp: (6 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient {
          static let live = Self(
            search: { completion in

            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can start by instantiating a request for a completion and calling `start` on it.
        """#,
      timestamp: (7 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        search: { completion in
          MKLocalSearch(request: .init(completion: completion))
            .start()

        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can’t simply call `await` on it, because we’re not in an `async` context, and what we want to do is return an `Effect`.
        """#,
      timestamp: (7 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct an `Effect` we could use the `future` initializer, which takes a callback, and then move the request inside, where we can invoke the response handler version of `start` instead:
        """#,
      timestamp: (7 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        search: { completion in
          Effect.future { callback in
            MKLocalSearch(request: .init(completion: completion))
              .start { response, error in

              }

          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And in here we can fall back to the old API that speaks completion handlers.
        """#,
      timestamp: (8 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s a bummer how much more verbose this version is than the `async` version. Even worse, it introduces invalid states that don’t make sense. Because we are working with two optionals, we have 2 states that technically compile but I'm not sure how to handle:

        - Both `response` and `error` can be `nil`, which represents that fatal-erroring path.
        - Both `response` and `error` can be non-`nil`, and in this case we're quietly ignoring the error.
        """#,
      timestamp: (8 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        In order to leverage the new API we could introduce an `async` context:
        """#,
      timestamp: (9 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Effect.future { callback in
          Task {
            let response = try await MKLocalSearch(request: .init(completion: completion))
              .start()

          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is API can fail, so we should introduce a `do` block to capture any errors:
        """#,
      timestamp: (9 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Task {
          do {
            let response = try await MKLocalSearch(request: .init(completion: completion))
              .start()
          } catch {

          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And this is exactly what we want to feed to our callback:
        """#,
      timestamp: (9 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        callback(.success(response))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And in the case of failure, we can hand the error off in the `catch` block.
        """#,
      timestamp: (9 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        do {
          let response = try await localSearch.start()
          callback(.success(response))
        } catch {
          callback(.failure(error))
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        OK, this is compiling now!
        """#,
      timestamp: (9 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’re wrapping this async work in a very ad hoc way right now. It seems like it would be very useful to wrap any async work in an effect. Well no such helper exists in the Composable Architecture right now, but let’s not wait on library support. We should be able to cook up this helper ourselves. To understand what the signature should be we can look at the `Task` initializer that is defined in the `_Concurrency` module:
        """#,
      timestamp: (9 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Success)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And there is another initializer that takes a throwing closure, which creates a task that can fail:
        """#,
      timestamp: (10 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So we should be able to mimic this signature to initialize an `Effect`. We'll create a new static constructor called `task` to wrap this work.
        """#,
      timestamp: (11 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension Effect {
          static func task(
            priority: TaskPriority? = nil,
            operation: @escaping @Sendable () async throws -> Output
          ) -> Self
          where Failure == Error {
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’ve constrained `Failure` to be `Error` because we’re wrapping an async failure that throws.
        """#,
      timestamp: (11 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And in here we can do the same work we were doing before, except we'll pass along the task priority, and we'll call the `operation` instead of the concrete MapKit work we were doing before:
        """#,
      timestamp: (11 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This allows us to greatly simplify our dependency:
        """#,
      timestamp: (12 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient {
          static let live = Self { completion in
            .task {
              try await MKLocalSearch(request: .init(completion: completion))
                .start()
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We now understand how the local search APIs work, we've written a wrapper around the dependency in order to make it mockable and testable, and we've even introduced a general `Effect` helper for executing work using Swift's new `async`/`await` APIs, all without having to modify the Composable Architecture library.
        """#,
      timestamp: (12 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Integrating local search"#,
      timestamp: (13 * 60 + 18),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have the search client defined and created a live implementation, let's integrate it into the application so that when we tap one of those search completions, we can fire off that local search request and display results on the map.
        """#,
      timestamp: (13 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        First, let’s add our new dependency to the environment of our application:
        """#,
      timestamp: (13 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppEnvironment {
          var localSearch: LocalSearchClient
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To kick off a search we need to pass a completion along to the search client when we tap a particular row by sending an action to the view store when a row is tapped:
        """#,
      timestamp: (13 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction {
          ...
          case tappedCompletion(MKLocalSearchCompletion)
        }
        ...
        ForEach(viewStore.completions, id: \.id) { completion in
          Button(action: { viewStore.send(.tappedCompletion(completion)) }) {
            VStack(alignment: .leading) {
              Text(completion.title)
              Text(completion.subtitle)
                .font(.caption)
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Our reducer needs to handle this case.
        """#,
      timestamp: (14 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .tappedCompletion(completion):
          return environment.localSearch.search(completion)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Cannot convert return expression of type 'Effect<MKLocalSearch.Response, Error>' to return type 'Effect<AppAction, Never>'

        And to feed the result of this effect back into the system we need another action.
        """#,
      timestamp: (15 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case searchResponse(Result<MKLocalSearch.Response, Error>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that we can catch the effect.
        """#,
      timestamp: (15 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .tappedCompletion(completion):
          return environment.localSearch.search(completion)
            .catchToEffect()
            .map(AppAction.searchResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then handle the response in our reducer.
        """#,
      timestamp: (16 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .searchResponse(.success(response)):

        case let .searchResponse(.failure(error)):

        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        In the case of success, there are a few items we want to pluck off the response. For instance, we want to replace our state's region with the bounding region of the search results:
        """#,
      timestamp: (16 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .searchResponse(.success(response)):
          state.region = .init(rawValue: response.boundingRegion)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We also have the map items available to us.
        """#,
      timestamp: (16 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        response.mapItems
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We just need to introduce some state to our application in order to hold onto them and render them in our view.
        """#,
      timestamp: (16 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState: Equatable {
          ...
          var mapItems: [MKMapItem] = []
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        When we get a successful response, we can assign the map items and update the region.
        """#,
      timestamp: (17 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .searchResponse(.success(response)):
          state.mapItems = response.mapItems
          state.region = .init(rawValue: response.boundingRegion)
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can stub out some error handling:
        """#,
      timestamp: (17 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .searchResponse(.failure):
          // TODO: error handling
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To render these map items, we can hook into a couple `Map` view fields we’ve been ignoring:
        """#,
      timestamp: (17 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        annotationItems: <#Items#>,
        annotationContent: <#(Items.Element) -> Annotation#>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        These two fields are responsible for rendering annotation views over a map. This includes a collection of data with an element per annotation to render, and a view builder that can render an annotation, given one of those elements.
        """#,
      timestamp: (17 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For items we can pass along the view store’s map items:
        """#,
      timestamp: (18 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        annotationItems: viewStore.mapItems,
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Initializer 'init(coordinateRegion:interactionModes:showsUserLocation:userTrackingMode:annotationItems:annotationContent:)' requires that 'MKMapItem' conform to 'Identifiable'

        SwiftUI needs these annotation items to be identifiable, and `MKMapItem` is not. Ideally this means introducing our own type that can hold the map item data we care about and that we can determine an `Identifiable` conformance for. But to get things building we can simply add a conformance to `MKMapItem`.
        """#,
      timestamp: (18 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension MKMapItem: Identifiable {}
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Because `MKMapItem` is an object, it gets a free conformance based on object identity, which probably isn’t what we want here. There is no guarantee that MapKit is going to return the exact same object for the same place across searches. So all the more reason to introduce a type we own. But for now, at least we can get something on the screen.
        """#,
      timestamp: (18 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And for annotation content we can render an annotation. There are several annotation views at our disposal, including a pin, a marker, or a completely customizable `MapAnnotation` view. Let’s simply render a marker by passing along the map item coordinate:
        """#,
      timestamp: (19 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        annotationContent: { mapItem in
          MapMarker(coordinate: mapItem.placemark.coordinate)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Everything is now building except for our previews and app entrypoint, which need to be supplied a local search client.
        """#,
      timestamp: (19 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment: .init(
          localSearch: .live,
          localSearchCompleter: .live
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we run this in the preview we can type in a query, tap a row, and the map will zoom into a region and display a pin. However, by running this in the preview we are hiding a bug that unfortunately can only be seen by running in the simulator.
        """#,
      timestamp: (19 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we do the same in the simulator we will see we have a purple warning:
        """#,
      timestamp: (20 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🟪 SwiftUI: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.

        This is because MapKit’s local search is delivering its response on a background queue. We need to redispatch this work on the main queue so that it can be rendered on the UI thread.
        """#,
      timestamp: (20 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can do this by tacking a `.receive(on:)` operation on the effect to get its output back on the main queue:
        """#,
      timestamp: (20 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        return environment.localSearch.search(completion)
          .receive(on: DispatchQueue.main)
          .catchToEffect()
          .map(AppAction.searchResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, by doing a little bit of upfront work right now we’ll make our lives much easier when it comes to testing. We are going to explicitly add a main queue dependency to our environment via the `[AnyScheduler](https://pointfreeco.github.io/combine-schedulers/AnyScheduler/)` type from our [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library:
        """#,
      timestamp: (21 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppEnvironment {
          ...
          var mainQueue: AnySchedulerOf<DispatchQueue>
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that we can use it on the search effect:
        """#,
      timestamp: (21 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .tappedCompletion(completion):
          return environment.localSearch.search(completion)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(AppAction.searchResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This will make it possible to use immediate schedulers and test schedulers when writing tests for this feature, rather than being at the mercy of the live dispatch queue, which forces us to add explicitly waits to our tests to wait for thread hops.
        """#,
      timestamp: (21 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we need to update our preview and app entry point:
        """#,
      timestamp: (22 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment: .init(
          localSearch: .live,
          localSearchCompleter: .live(),
          mainQueue: .main
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we build, we can search for some places and they immediately appear on the map, and the purple warning has gone away.
        """#,
      timestamp: (22 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we wanted to get a little fancy we could even add an animation so that the map zooms and pans to the region where the marker will be. This is quite easy thanks to the `.animation()` method [we defined](/episodes/ep136-swiftui-animation-the-basics) in our Combine Schedulers library, which we did [a number of episodes](/collections/combine/schedulers) on a few months ago:
        """#,
      timestamp: (22 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .tappedCompletion(completion):
          return environment.localSearch.search(completion)
            .receive(on: environment.mainQueue.animation())
            .catchToEffect()
            .map(AppAction.searchResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is pretty cool. With just a bit of work we have now designed two dependency wrappers around MapKit APIs, `MKLocalSearchCompleter` and `MKLocalSearch`, and have implemented a decently complicated piece of logic to allow us to search for locations and display those locations on the map.
        """#,
      timestamp: (23 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Testing the entire application"#,
      timestamp: (23 * 60 + 29),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        But let’s kick things up a notch.
        """#,
      timestamp: (23 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We could keep adding features to this, but let's turn our attention to testing. Already the logic is quite complicated, requiring us to fire off multiple effects and coordinate their responses. As we will build more and more of this places searching application we are going to add more logic to the reducer, and so ideally we should have some tests in place to make sure things are working as we expect.
        """#,
      timestamp: (23 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        As we’ve said a number of times on Point-Free, testing is one of the most important features of the Composable Architecture and it is a true super power of the library. We can test every little subtle edge case of our reducers, including how effects are executed and fed back into the system, all the while the library keeps us in check to make sure we are exhaustively asserting on everything that happens and no letting anything slip by.
        """#,
      timestamp: (23 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can start with a stub:
        """#,
      timestamp: (24 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import ComposableArchitecture
        import XCTest
        @testable import Search

        class SearchTests: XCTestCase {
          func testExample() {
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first thing we need to do to test a feature in the Composable Architecture is to create a test store, which takes the same arguments as a normal store:
        """#,
      timestamp: (24 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let store = TestStore(
          initialState: <#_#>,
          reducer: <#Reducer<_, _, _>#>,
          environment: <#_#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can configure it with some initial state, reducer, and environment.
        """#,
      timestamp: (24 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let store = TestStore(
          initialState: .init(),
          reducer: appReducer,
          environment: .init(
            localSearch: <#LocalSearchClient#>,
            localSearchCompleter: <#LocalSearchCompleter#>,
            mainQueue: <#AnySchedulerOf<DispatchQueue>#>
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We don’t want to use a “live” environment here because it hits Apple’s APIs, which we can’t control, and uses a main queue, which would require us to wait for effects to be received using `XCTestExpectation`s.
        """#,
      timestamp: (25 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Back in a series of episodes we titled “[Better Test Dependencies](/collections/dependencies/better-test-dependencies)”, we introduced the notion of “[failing dependencies](/collections/dependencies/better-test-dependencies/ep139-better-test-dependencies-failability)”: dependencies that call `XCTFail` whenever an endpoint is exercised, letting us prove that the code paths we are testing do not use certain dependencies, and forcing us to address when new dependencies are exercised in a test.
        """#,
      timestamp: (25 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        In fact, the [Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) library that [the Composable Architecture](/collections/composable-architecture) depends on comes with a “[failing](https://pointfreeco.github.io/combine-schedulers/FailingScheduler/)” scheduler, so we can supply that immediately:
        """#,
      timestamp: (25 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        mainQueue: .failing
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) comes with a “[failing](https://pointfreeco.github.io/swift-composable-architecture/Effect/#effect.failing(_:))” effect, which we can use in the endpoints for the search client and the completer. Let’s go ahead and create a static `.failing` implementation of each of our clients, just like `AnyScheduler` has:
        """#,
      timestamp: (25 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient {
          static let failing = Self(
            search: { _ in .failing("LocalSearchClient.search is unimplemented") }
          )
        }

        extension LocalSearchCompleter {
          static let failing = Self(
            completions: { .failing("LocalSearchCompleter.completions is unimplemented") },
            search: { _ in .failing("LocalSearchCompleter.search is unimplemented") }
          )
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now instantiating a store is short and sweet:
        """#,
      timestamp: (26 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let store = TestStore(
          initialState: .init(),
          reducer: appReducer,
          environment: .init(
            localSearch: .failing,
            localSearchCompleter: .failing,
            mainQueue: .failing
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have a store, we can start sending it a script of actions and describe how we expect state to evolve over time.
        """#,
      timestamp: (26 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `.onAppear` action seems like a good one to start with.
        """#,
      timestamp: (27 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.onAppear)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can run tests and already get our first failure.
        """#,
      timestamp: (27 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 LocalSearchCompleter.completions is unimplemented - A failing effect ran.

        This is a good error to have! The failing effect requires us to consider this effect and explicitly handle it.
        """#,
      timestamp: (27 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Since this is an effect that can emit multiple times we will use a passthrough subject to control it under the hood, which allows us to emit many outputs:
        """#,
      timestamp: (27 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import Combine
        import MapKit
        ...
        let completionsSubject = PassthroughSubject<Result<[MKLocalSearchCompletion], Error>, Never>()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can override the environment’s endpoint to return this subject:
        """#,
      timestamp: (28 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.environment.localSearchCompleter.completions = {
          completionsSubject.eraseToEffect()
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is the first time we have updated the environment of a test store in this fashion on Point-Free episodes. Typically we create an environment up at the top of the test and pass it to the test store all at once. However, it is also possible to make updates to the environment after creating the test store, which allows you to either change a dependency’s behavior in the middle of the test. Both styles have their pros and cons, so it’s up to you and your team to decide which you prefer.
        """#,
      timestamp: (28 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we run tests, we get a different failure:
        """#,
      timestamp: (29 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 An effect returned for this action is still running. It must complete before the end of the test.

        This is saying that the test store knows there is a long-living effect that is still running when the test completes. This is also a good error to have. It’s forcing us to be exhaustive in our tests. If an action fires off an effect, you should want to assert against actions it may feed back into the system, or you should want it to complete.
        """#,
      timestamp: (29 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        In the future we may want to cancel this effect using another hook like `onDisappear`, but for now we can get the test passing by sending a completion to the subject at the end of the test.
        """#,
      timestamp: (30 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        defer { completionsSubject.send(completion: .finished) }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now the test is passing.
        """#,
      timestamp: (31 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start interacting with the feature. We can simulate a user typing a query into the search field.
        """#,
      timestamp: (31 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.queryChanged("Apple"))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we get a couple failures:
        """#,
      timestamp: (31 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ LocalSearchCompleter.search is unimplemented - A failing effect ran.
        > ❌ State change does not match expectation: …
        >
        >       AppState(
        >         completions: [
        >         ],
        >         mapItems: [
        >         ],
        >     −   query: "",
        >     +   query: "Apple",
        >         region: CoordinateRegion(
        >           center: LocationCoordinate2D(
        >             latitude: 40.7,
        >             longitude: -74.0
        >           ),
        >           span: CoordinateSpan(
        >             latitudeDelta: 0.075,
        >             longitudeDelta: 0.075
        >           )
        >         )
        >       )
        >
        > (Expected: −, Actual: +)

        The first failure is because `queryChanged` fires off another failing effect that we need to override. The second is because the test store forces us to describe any mutations made to state, and `queryChanged` updates the `query` field. We can assert against this state change by opening a trailing closure where we mutate the state to how we expect it to look.
        """#,
      timestamp: (31 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.queryChanged("Apple")) {
          $0.query = "Apple"
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then, for the other failure, we can stub out an effect that feeds completions back into the system.
        """#,
      timestamp: (32 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.environment.localSearchCompleter.search = { _ in
          .fireAndForget {
            completionsSubject.send(.success([MKLocalSearchCompletion()]))
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        When we re-run the test we get a new failure:
        """#,
      timestamp: (33 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ The store received 1 unexpected action after this one: …
        >
        > Unhandled actions:
        >     [
        >       AppAction.completionsUpdated(
        >         Result<Array<MKLocalSearchCompletion>, Error>.success(
        >           [
        >             <MKLocalSearchCompletion 0x6000029b6760> ,
        >           ]
        >         )
        >       ),
        >     ]

        This is yet another good failure to have. Not only do we need to exhaustively describe any mutations that happen to test store state, we must also assert against any actions that are fed back into the system from effects. We can do so with the `receive` method on the test store:
        """#,
      timestamp: (34 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.completionsUpdated(.success([MKLocalSearchCompletion()])))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Instance method 'receive(_:file:line:_:)' requires that 'AppAction' conform to 'Equatable'

        But to compare this action with the one we expect to receive `AppAction` must be equatable.
        """#,
      timestamp: (34 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Unfortunately, we don’t get a synthesized conformance for free:
        """#,
      timestamp: (35 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction: Equatable {
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Type 'AppAction' does not conform to protocol 'Equatable’

        The only type that is really getting in the way right now is `Error`, which as a protocol does not conform to `Equatable`. To work around this, we can take advantage of the fact that every `Error` can be cast to `NSError`, and `NSError` does conform to `Equatable`.
        """#,
      timestamp: (35 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case completionsUpdated(Result<[MKLocalSearchCompletion], NSError>)
        ...
        case searchResponse(Result<MKLocalSearch.Response, NSError>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We just need to cast the errors in our reducer before returning the effects:
        """#,
      timestamp: (35 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .onAppear:
          return environment.localSearchCompleter.completions()
            .map { $0.mapError { $0 as NSError } }
            .map(AppAction.completionsUpdated)
            .eraseToEffect()
        ...
        case let .tappedCompletion(completion):
          return environment.localSearch.search(completion)
            .receive(on: environment.mainQueue.animation())
            .mapError { $0 as NSError }
            .catchToEffect()
            .map(AppAction.searchResponse)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Our tests are now building and when we run them we get 2 new failures:
        """#,
      timestamp: (36 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ Received unexpected action: …
        >
        >       AppAction.completionsUpdated(
        >         Result<Array<MKLocalSearchCompletion>, NSError>.success(
        >           [
        >     −       <MKLocalSearchCompletion 0x6000019405f0> ,
        >     +       <MKLocalSearchCompletion 0x6000019406e0> ,
        >           ]
        >         )
        >       )
        >
        > (Expected: −, Received: +)
        >
        > ❌ State change does not match expectation: …
        >
        >       AppState(
        >         completions: [
        >     +     <MKLocalSearchCompletion 0x6000019406e0> ,
        >         ],
        >         mapItems: [
        >         ],
        >         query: "Apple",
        >         region: CoordinateRegion(
        >           center: LocationCoordinate2D(
        >             latitude: 40.7,
        >             longitude: -74.0
        >           ),
        >           span: CoordinateSpan(
        >             latitudeDelta: 0.075,
        >             longitudeDelta: 0.075
        >           )
        >         )
        >       )
        >
        > (Expected: −, Actual: +)

        The first failure says that the action we said we received does not actually the match the action we did receive. They are both `.completionsUpdated` actions, and even both `.success`, but the objects inside the success case does not match:
        """#,
      timestamp: (26 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        >     −       <MKLocalSearchCompletion 0x6000019405f0> ,
        >     +       <MKLocalSearchCompletion 0x6000019406e0> ,

        The fact that we are seeing pointer addresses in here means we are dealing with reference type, which are notoriously tricky to define equatability on. Perhaps the MapKit framework tracks some additional identity that gets lost when we recreate the completion here in the test. Maybe we can work around it by reusing the same object:
        """#,
      timestamp: (37 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let completion = MKLocalSearchCompletion()
        store.environment.localSearchCompleter.search = { _ in
          .fireAndForget {
            completionsSubject.send(.success([completion]))
          }
        }
        ...
        store.receive(.completionsUpdated(.success([completion])))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ Received unexpected action: …
        >
        > Expected:
        >   completionsUpdated(Swift.Result<Swift.Array<__C.MKLocalSearchCompletion>, __C.NSError>.success([<MKLocalSearchCompletion 0x600001dd3390> ]))
        >
        > Received:
        >   completionsUpdated(Swift.Result<Swift.Array<__C.MKLocalSearchCompletion>, __C.NSError>.success([<MKLocalSearchCompletion 0x600001dd3390> ]))

        Unfortunately not. Despite conforming to `Equatable`, even the same object does not considered equivalent:
        """#,
      timestamp: (27 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let completion = MKLocalSearchCompletion()
        XCTAssertEqual(completion, completion)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 XCTAssertEqual failed: ("<MKLocalSearchCompletion 0x6000031f5810> ") is not equal to ("<MKLocalSearchCompletion 0x6000031f5810> ")

        Well we should always be prepared to hit limits like these when working with types we don’t own, especially reference types, and luckily we are. Let’s create a wrapper type around `MKLocalSearchCompletion` that we have complete control over so that we can get this assertion reasonably passing, just as we did for the coordinate and region types from MapKit:
        """#,
      timestamp: (38 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompletion: Equatable {

        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It will hold onto the raw value from MapKit, which is needed later to initialize a local search request.
        """#,
      timestamp: (39 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompletion: Equatable {
          let rawValue: MKLocalSearchCompletion
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This live value is not what we want to use for tests, we will make it optional.
        """#,
      timestamp: (39 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompletion: Equatable {
          let rawValue: MKLocalSearchCompletion?
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And for our tests, we’ll also include the fields we care about.
        """#,
      timestamp: (39 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompletion: Equatable {
          let rawValue: MKLocalSearchCompletion?

          var subtitle: String
          var title: String
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        But knowing that we can’t depend on the synthesized equatability of that raw value, we should define a custom conformance.
        """#,
      timestamp: (39 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompletion: Equatable {
          ...
          static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.subtitle == rhs.subtitle
              && lhs.title == rhs.title
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We will also want a few specific ways to create this type. In the live dependency we’ll need to create this type from a raw `MKLocalSearchCompletion`, but in tests we’ll want to create this type from just the title and subtitle strings:
        """#,
      timestamp: (40 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next we should update our dependencies to work with this type. First, the completer will not return completion results of the `LocalSearchCompletion` type, rather than the `MKLocalSearchCompletion` type:
        """#,
      timestamp: (40 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchCompleter {
          var completions: () -> Effect<Result<[LocalSearchCompletion], Error>, Never>
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And its live implementation will need to be updated to deal with the new type::
        """#,
      timestamp: (41 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        class Delegate: NSObject, MKLocalSearchCompleterDelegate {
          let subscriber: Effect<Result<[LocalSearchCompletion], Error>, Never>.Subscriber
          init(subscriber: Effect<Result<[LocalSearchCompletion], Error>, Never>.Subscriber) {
            self.subscriber = subscriber
          }
          func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            self.subscriber.send(
              .success(
                completer.results
                .map(LocalSearchCompletion.init(rawValue:)))
            )
          }
          func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            self.subscriber.send(.failure(error))
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then the search client:
        """#,
      timestamp: (41 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchClient {
          var search: (LocalSearchCompletion) -> Effect<Response, Error>
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And its live implementation can reach into the completion’s `rawValue` to get the real `MKLocalSearchCompletion`, but because its optional we will force unwrap it:
        """#,
      timestamp: (42 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient {
          static let live = Self { completion in
            .task {
              try await MKLocalSearch(request: .init(completion: completion.rawValue!))
                .start()
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We feel it is OK to force unwrap here because the `rawValue` should never be non-`nil` in production code, only in test code. In fact,  we could strengthen this property by making the initializer that uses the `rawValue` to be the only publicly available initializer, and then the initializer that takes a title and subtitle would be made internal so that it was only available to tests.
        """#,
      timestamp: (42 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Next, in our app domain we will hold onto an array of `LocalSearchCompletion` values, which should make equatable checks much better:
        """#,
      timestamp: (42 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct AppState: Equatable {
          var completions: [LocalSearchCompletion] = []
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Some of our app actions also update:
        """#,
      timestamp: (43 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction: Equatable {
          case completionsUpdated(Result<[LocalSearchCompletion], NSError>)
          ...
          case tappedCompletion(LocalSearchCompletion)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Nothing needs to change in the reducer.
        """#,
      timestamp: (43 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And in the view, where `ForEach` that iterates over the completions.
        """#,
      timestamp: (43 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 Referencing initializer 'init(_:content:)' on 'ForEach' requires that 'LocalSearchCompletion' conform to 'Identifiable’

        We need to update the id we wrote to work on our custom type, instead. We can even make it `Identifiable` and drop the view’s `id:` parameter.
        """#,
      timestamp: (43 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchCompletion: Identifiable {
          public var id: [String] {
            [self.title, self.subtitle]
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Which means we can even drop the `id` parameter from `ForEach`.
        """#,
      timestamp: (43 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ForEach(viewStore.completions) { completion in
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Our app is building, but our tests are not. We need to update the passthrough subject to work with our new wrapper type:
        """#,
      timestamp: (43 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let completionsSubject = PassthroughSubject<Result<[LocalSearchCompletion], Error>, Never>()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And our completion:
        """#,
      timestamp: (44 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let completion = LocalSearchCompletion(
          subtitle: "Search Nearby",
          title: "Apple Store"
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Tests are compiling, and we’re down to one failure, where we need to assert against assigning the completions.
        """#,
      timestamp: (44 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.completionsUpdated(.success([completion]))) {
          $0.completions = [completion]
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And tests pass!
        """#,
      timestamp: (45 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Finally let’s test tapping a completion.
        """#,
      timestamp: (45 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.tappedCompletion(completion))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ An effect returned for this action is still running. It must complete before the end of the test.
        > ❌ DispatchQueue - A failing scheduler scheduled an action to run immediately.
        > ❌ LocalSearchClient.search is unimplemented - A failing effect ran.

        Ok, 3 failures! And if we read through them we see they’re all related:
        """#,
      timestamp: (46 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Tapping a completion fires off a failing effect, which is scheduled on a failing queue, and so that effect is still running.
        """#,
      timestamp: (46 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can upgrade our failing scheduler to an immediate one to fix the first two failures.
        """#,
      timestamp: (46 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.environment.mainQueue = .immediate
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can override the search endpoint with some mock data.
        """#,
      timestamp: (47 * 60 + 33),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.environment.localSearch.search = { _ in Effect(value: <#Output#>) }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can try to create a local search response and set some mock data on it:
        """#,
      timestamp: (48 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let response = MKLocalSearch.Response()
        response.mapItems = [MKMapItem()]
        response.boundingRegion = .init(
          center: .init(latitude: 0, longitude: 0),
          span: .init(latitudeDelta: 1, longitudeDelta: 1)
        )
        return .init(value: response)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ Cannot assign to property: 'mapItems' is a get-only property
        > ❌ Cannot assign to property: 'boundingRegion' is a get-only property

        OK well it looks like we’re hitting another limitation of working directly with Apple’s types. We’ll want to wrap the response as well.
        """#,
      timestamp: (48 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct LocalSearchClient {
          var search: (MKLocalSearchCompletion) -> Effect<Response, Error>

          struct Response: Equatable {
            var boundingRegion = CoordinateRegion()
            var mapItems: [MKMapItem] = []
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This time we can simply wrap the raw data the reducer needs. No need to hold onto the response. The reason we needed to hold onto the `MKLocalSearchCompletion` in our wrapper type is because the live `MKLocalSearch.Request` needs access to it.
        """#,
      timestamp: (50 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s add a helper initializer that takes a raw value:
        """#,
      timestamp: (50 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient.Response {
          init(rawValue: MKLocalSearch.Response) {
            self.init(
              boundingRegion: .init(rawValue: rawValue.boundingRegion),
              mapItems: rawValue.mapItems
            )
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can update the live client.
        """#,
      timestamp: (51 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension LocalSearchClient {
          static let live = Self { completion in
            .task {
              .init(
                rawValue: try await MKLocalSearch(
                  request: .init(completion: completion.rawValue!)
                ).start()
              )
            }
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And app action:
        """#,
      timestamp: (51 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        enum AppAction: Equatable {
          ...
          case searchResponse(Result<LocalSearchClient.Response, NSError>)
          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s one compiler error in the reducer where previously we were creating a `CoordinateRegion` from an `MKCoordinateRegion`, but now we can just use the coordinate region directly:
        """#,
      timestamp: (51 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .searchResponse(.success(response)):
          state.mapItems = response.mapItems
          state.region = response.boundingRegion
          return .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The app is building again, but now we can create one of those mock values:
        """#,
      timestamp: (52 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let response = LocalSearchClient.Response(
          boundingRegion: .init(
            center: .init(latitude: 0, longitude: 0),
            span: .init(latitudeDelta: 1, longitudeDelta: 1)
          ),
          mapItems: [MKMapItem()]
        )
        store.environment.localSearch.search = { _ in .init(value: response) }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ The store received 1 unexpected action after this one: …
        >
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

        One failure, where we need to handle the response action:
        """#,
      timestamp: (53 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.searchResponse(.success(response))) {
          $0.region = response.boundingRegion
          $0.mapItems = response.mapItems
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And they pass!
        """#,
      timestamp: (54 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we have a test suite in place, let's add a new feature to see how it affects our tests. Let's make it so when you tap a completion, we repopulate the search field with the full title of the completion:
        """#,
      timestamp: (54 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case let .tappedCompletion(completion):
          state.query = completion.title
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > ❌ State change does not match expectation: …
        >
        >       AppState(
        >         ...
        >     -   query: "Apple",
        >     +   query: "Apple Store",
        >         ...
        >       )

        Our tests give us instant feedback as to how state changed based of our expectations, making it easy to update:
        """#,
      timestamp: (55 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.send(.completionTapped(completion)) {
          $0.query = "Apple Store"
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now it passes again!
        """#,
      timestamp: (55 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Before we conclude, we should mention that there's one lone type that we didn't write a wrapper for, and that's `MKMapItem`. And remember, we _did_ conform that type to `Identifiable`, which is probably not a good idea for types we don't own. Ideally this type would be wrapped, as well, but we'll leave that as an exercise for the viewer.
        """#,
      timestamp: (55 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Conclusion"#,
      timestamp: (56 * 60 + 30),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Amazingly this is testing a pretty complex flow, and for the most part its straightforward in the Composable Architecture. We simulate a script of user actions, things like typing into the search bar and tapping on a search suggestion, and we get to assert that not only does state change how we expect, but even effects execute and feed their data back into the system as we expect. Right now we're only testing the happy path, but there's also the unhappy paths, which are completely testable, and could guide error handling in our application.
        """#,
      timestamp: (56 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        That concludes this series of episodes. We just wanted to give our viewers a peek into some of the cool things announced at WWDC a few months ago, and give some insight into how we might support some of those new features in the Composable Architecture.
        """#,
      timestamp: (57 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Until next time…
        """#,
      timestamp: (57 * 60 + 35),
      type: .paragraph
    ),
  ]
}
