## Introduction

@T(00:00:05)
This is all looking pretty amazing. If we are willing to do the upfront work of building a parser-printer for our router, we can easily plug it into a Vapor application to power the website. Doing so allows us to remove a lot of logic from our handlers that doesn’t need to be there, such as extracting, coercing and validating data in the path or query params. And with no additional work we instantly get the ability to link to any page in our entire website.

@T(00:00:30)
But if you think all of this sounds interesting, you haven’t see anything yet.

@T(00:00:36)
Not only do we get all these benefits in the server side code, but we also get benefits in our client side iOS code that needs to talk to the server. We can instantly derive an API client that can speak to our server without doing much work at all. And the iOS client and server side client will always be in sync. If we add a new endpoint to the server it will instantly be available to us in the client with no additional work whatsoever.

@T(00:01:04)
Sound too good to be true? Let’s build a small iOS application that makes requests to our server side application.

## Setting up the iOS Client

@T(00:01:18)
We’ll start by creating a brand new Xcode project for an iOS application, which we will call Client and we will put it in a sibling directory to the server.

@T(00:01:37)
And then we can open this new Client Xcode project and drag the entire Server directory into it. This gives us one single Xcode project that can access all of the targets and libraries from both projects. With a little more work you can even consolidate all of this into a single SPM package for which your server and client targets consist of just a single file that act as the entry point into those respective applications. We won’t do that now, but we have covered these ideas in our [modularization episodes](/episodes/ep171-modularization-part-1), so we highly recommend you check those out if you are interested in that.

@T(00:02:52)
Now what we’d like to do is create an API client that could be used in our iOS application for making requests to our server, downloading data, and decoding it into models so that we can make use of that data in the application. There are a few popular ways of doing this in the iOS community, but at the end of the day they are all variations on a central theme, which is providing class, structs, methods and function helpers for constructing URL requests, firing off those URL requests (typically with URLSession), and then decoding the data it gets back.

@T(00:03:33)
The first half of this process is usually the lion's share of the work the API client needs to accomplish. We somehow need to model the data for describing an API endpoint, such as IDs, filter options, post data and more, and then we need some way to turn that data into a URL request.

@T(00:03:55)
This is precisely what our parser-printer router handles for us. We get to simultaneously describe the data needed for an API endpoint as well as how that endpoint is parsed from and printed to a URL request. So we don’t have to worry about this responsibility of the API client because our parser-printers have taken care of it.

@T(00:04:15)
The other API client responsibility is that of actually making the network request and decoding the data. That part is quite simple thanks to URLSession. As long as we can generate a URL request, it only takes a few steps to hand that to URLSession, let it do its thing to return some data to us, and then we decode it into a model.

@T(00:04:37)
So it sounds like we are more than halfway to having an API client by virtue of the fact that we have described our server routing as a parser-printer. But in reality we are actually 100% there, because our URL routing library actually vends a type that automates everything we just discussed for us.

@T(00:04:55)
In order to make use of it we need to access to the site router in the iOS application, which means we need to extract it to its own library so that it can be simultaneously used from the server and client. Let’s do that:

```swift
.package(
  url: "https://github.com/pointfreeco/swift-parsing", from: "0.9.1"
)
…
.target(
  name: "SiteRouter",
  dependencies: [
    .product(name: "_URLRouting", package: "swift-parsing"),
  ]
),
```

@T(00:06:01)
The main server “App” target will depend on it:

```swift
.target(
  name: "App",
  dependencies: [
    "SiteRouter",
    …
  ]
)
```

@T(00:06:07)
And we just need to add a few imports to the server code and everything should build and run just like it did before, we just need to publicize a few things in the `SiteRouter` module.

## Setting up the API Client

@T(00:06:58)
Now we are set up to use the site router in our iOS application. First we need to export `SiteRouter` from the package as a library.

```swift
products: [
  .library(name: "SiteRouter", targets: ["SiteRouter"])
]
```

@T(00:07:23)
Which allows us to make the Client target depend on the `SiteRouter`.

@T(00:07:41)
And just with that we are able to import the `SiteRouter` into our iOS application:

```swift
import SiteRouter
```

@T(00:07:47)
Which means we can easily construct requests to API endpoints on our server:

```swift
router.request(for: .users(.user(1, .books())))
```

@T(00:08:04)
So right off the bat we have accomplished the first major responsibility we outlined for API clients, that of giving us the tools to construct requests to the server.

@T(00:08:19)
As we alluded to before, it wouldn’t be much work to wrap our site router into a new type that can further make a request to the server using URLSession, but luckily for us there’s no need to. The `_URLParsing` library ships with a tool that can automatically derive an API client from our site router, and it even comes with some conveniences that make using it and testing with a really nice experience.

@T(00:08:56)
All we have to do is import our `_URLRouting` library, which remember currently is underscored because its an experimental library and its public API is still being refined, but someday soon we will be making it public:

```swift
import _URLRouting
```

@T(00:09:09)
Once we do that we get access to a type called `URLRoutingClient`, which can be constructed as a live dependency if we hand it a parser-printer of the right shape:

```swift
let apiClient = URLRoutingClient.live(router: router)
```

@T(00:09:38)
That’s all it takes and we now have something that can make API requests, decode the response into response models, and hand the results back to us. Although technically we have to make one small change, which is to specify the base URL of the router, just like we did in the server:

```swift
let apiClient = URLRoutingClient.live(
  router: router
    .baseURL("http://127.0.0.1:8080")
)
```

@T(00:10:06)
With a little more work we could make it so that this base URL is set based on the build of the application, such as DEBUG versus RELEASE, or could even make it changeable from within the application itself. But we aren’t going to worry about those kinds of things right now.

@T(00:10:27)
So we now have an API client, let’s start using it! We’re going to build a simple SwiftUI view that loads data from the API and displays it in a list. We could make the stubbed `ContentView` that Xcode provides us hold onto an array of books:

```swift
struct ContentView: View {
  @State var books: [BooksResponse.Book] = []
  …
}
```

@T(00:10:59)
And then in the view’s body we can create a list for each of the books in the array:

```swift
var body: some View {
  List {
    ForEach(books, id: \.id) { book in
      Text(book.title)
    }
  }
}
```

@T(00:11:12)
But in order for this to work we need access to `BooksResponse`, which currently is in the server code. In order for us to have a chance at encoding this response on the server to send out and then decoding the response on the client we need to share this model between both platforms. For that reason we will move our response types to the `SiteRouter` module and make them public, but we will relax their conformance to Vapor's `Content` protocol to `Codable` instead. This way we don't have to have our site router depend on all of Vapor, which would force our iOS client to depend on all of Vapor as well and something we do not want to do. Instead, our server code will be responsible for importing these response types and retroactively extending them to `Content`.

```swift
extension UserResponse: Content {}
extension BookResponse: Content {}
extension BooksResponse: Content {}
extension BooksResponse.Book: Content {}
```

@T(00:13:35)
In order to populate the array of books we need to make an API request, which our API client makes very easy. The client comes with a method called `request` that allows you to specify the route you want to hit as well as the response model you want to decode into:

```swift
.task {
  do {
    books = try await apiClient.request(
      .users(.user(1, .books())),
      as: BooksResponse.self
    ).value.books
  } catch {

  }
}
```

@T(00:15:04)
Now this compiles. However, if we run this nothing appears in the SwiftUI preview.

@T(00:15:20)
This is happening because our server isn’t running. We need to have the server running so that the playground can actually hit “127.0.0.1:8080” and load data from our server code. So let’s quickly switch to the “Server” target, hit cmd+R to run it, and then switch back to the “Client” target and re-run our preview.

@T(00:15:44)
Now it magically loads data! We are actually hitting our server from the SwiftUI playground, and we can see this not only because data is actually showing in the list, but we can also see logs appearing in the console of Xcode that Vapor spits out anytime a request is made.

@T(00:16:08)
This is pretty amazing. With zero work on our part we have magically created an API client that is capable of constructing a URL request that is proven to be understandable by our server, and then it makes the request to the server, and then decodes the response into a model we can easily use in our client side code. All the messiness of constructing URL paths, appending query parameters, setting post bodies and more is hidden away from us in the router.

@T(00:16:48)
This is a pretty huge win. In fact, remember that there was one site route endpoint that was responsible for creating a user. Under the hood it needs to make sure the HTTP method is a POST, and that it encodes some data into JSON to be added to the POST body of the request. The server cares about all of that, but the client doesn’t. The client just wants to tell the server “hey, create a user for me with this data”, and that’s exactly what the API client can accomplish:

```swift
apiClient.request(
  .users(.create(.init(bio: "Blobbed around the world", name: "Blob"))),
  as: <#Decodable.Protocol#>
)
```

@T(00:17:28)
We don't need to know any of the particulars of how we are communicating with the server: whether it's a GET or a POST, how to encode the JSON. All of that is handled for us behind the scenes.

@T(00:17:47)
So, this is pretty amazing. We have been able to take the router that we built for our server application, which is capable of both parsing incoming requests to figure out what application logic we want to execute as well as generating outgoing URLs for embedding in responses, and from that object we derived an API client that can be used in our iOS application for communicating to the server. And we did so with no additional work.

@T(00:18:10)
It’s worth mentioning that this technique can be used even if you are not building a server-side application in Swift. If you just need to make requests to your company’s server API, rather than building an API client in the more traditional style, you can instead build a parser-printer for the API’s specification, and from that get an API client out of it for free. This will give you a bunch of tools for constructing complex requests and make everything nice and type safe.

## A complex API-driven feature

@T(00:18:36)
This is definitely looking incredible, but let’s make our little client app a little more complicated so that we can see how powerful these parser-printer routers are. What if we wanted to add a segmented control at the top of the UI that chooses between sorting directions, either ascending or descending.

@T(00:19:00)
We can add some state to our view:

```swift
struct ContentView: View {
  @State var direction: SearchOptions.Direction = .asc
  …
}
```

@T(00:19:13)
And we can bundle our list into a `VStack` so that we can put a picker view above it:

```swift
VStack {
  Picker(selection: $direction) {
    Text("Ascending").tag(SearchOptions.Direction.asc)
    Text("Descending").tag(SearchOptions.Direction.desc)
  } label: {
    Text("Direction")
  }
  .pickerStyle(.segmented)

  List {
    ForEach(books, id: \.id) { book in
      Text(book.title)
    }
  }
}
```

@T(00:19:36)
And then we can tack on a `.onChange` modifier to the end of our view so that whenever the direction changes we re-request the books from the server:

```swift
.onChange(of: direction) { _ in
  Task {
    do {
      let response = try await apiClient.request(
        .users(.user(1, .books(.search(.init(direction: direction))))),
        as: BooksResponse.self
      )
      books = response.books
    } catch {
    }
  }
}
```

@T(00:20:18)
Now the `.task` and `.onChange` modifier contain very similar code, and so you’d probably want to extract out this common code to a view model, which is exactly what we will do in a moment.

@T(00:20:29)
But, with these few changes we can now change the sort direction directly in the SwiftUI preview. If we run the preview we will see that changing the selection of the segmented control causes the results to sort differently, and we can even see from the logs that indeed the server is being hit each time we change the selection.

## Testable/previewable API clients

@T(00:20:51)
So, this all seems pretty amazing, but it gets even better. By constructing our API client in this way we immediately get the ability to override certain endpoints to return mock data synchronously. This is great for testing since we don’t want to make requests to our live server when testing. Our API client type comes with some really fantastic tools for accomplishing this, and it dovetails with many ideas we have discussed on Point-Free in the past.

@T(00:21:15)
To explore this we are going to refactor our view really quickly to use a proper view model, because that’s the only way we have a chance at testing this feature. We can basically copy-and-paste a bunch of stuff from the view in order to make a basic view model, and we’ll go ahead and preemptively require the view model to take an explicit `URLRoutingClient` as a dependency so that we can control it from the outside:

```swift
class ViewModel: ObservableObject {
  @Published var books: [BooksResponse.Book] = []
  @Published var direction: SearchOptions.Direction = .asc
  let apiClient: URLRoutingClient<SiteRoute>

  init(apiClient: URLRoutingClient<SiteRoute>) {
    self.apiClient = apiClient
  }

  @MainActor
  func fetch() async {
    do {
      let response = try await apiClient.request(
        .users(.user(1, .books(.search(.init(direction: direction))))),
        as: BooksResponse.self
      )
      books = response.books
    } catch {

    }
  }
}
```

@T(00:22:42)
Then our view can use this view model instead of having a bunch of local state, which is not easy to test:

```swift
struct ContentView: View {
  @ObservedObject var viewModel: ViewModel

  …
}
```

@T(00:22:54)
And then our view’s body can reach into the view model to get access to data instead of accessing it directly on the `ContentView`:

```swift
  var body: some View {
    VStack {
      Picker(
        selection: $viewModel.direction
      ) {
        Text("Ascending").tag(SearchOptions.Direction.asc)
        Text("Descending").tag(SearchOptions.Direction.desc)
      } label: {
        Text("Direction")
      }
      .pickerStyle(.segmented)

      List {
        ForEach(viewModel.books, id: \.id) { book in
          Text(book.title)
        }
      }
    }
    .task {
      await viewModel.fetch()
    }
    .onChange(of: viewModel.direction) { _ in
      Task {
        await viewModel.fetch()
      }
    }
  }
```

@T(00:23:24)
Now our view is compiling, but anywhere we try to construct a view is failing because we need to supply a view model. This is our chance to supply dependencies so that we can control the environment we are working in. For now we’ll just use the live API client in the preview:

```swift
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      viewModel: .init(
        apiClient: .live(
          router: router.baseURL("http://127.0.0.1:8080")
        )
      )
    )
  }
}
```

@T(00:23:45)
And in the app entry point:

```swift
import SiteRouter

@main
struct ClientApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        viewModel: .init(
          apiClient: .live(router: router.baseURL("http://127.0.0.1:8080"))
        )
      )
    }
  }
}
```

@T(00:24:23)
In order to write a test for this feature we need to construct a view model and then invoke endpoints on the view model to assert on what happens after:

```swift
class ClientTests: XCTestCase {
  func testBasics() async throws {
    let viewModel = ViewModel(apiClient: ???)

    await viewModel.fetch()
  }
}
```

@T(00:24:40)
However, to do this we need to supply an API client. We definitely do not want to supply a live API client because that would leave us exposed to the vagaries of the outside world, such as the quality of our internet connection, the stability of the server, and the unpredictable data the server could send back.

@T(00:24:58)
So what we like to do is skip the live logic of the API client entirely, and just synchronously return the data we want to test with. Technically we can build a whole new API client from scratch by just supplying a function that can transform `SiteRoute` values into data and response:

```swift
let viewModel = ViewModel(
  apiClient: .init(
    request: <#(SiteRoute) async throws -> (Data, URLResponse)#>
  )
)
```

@T(00:25:17)
But implementing such a function takes a lot of work. We’d have to destructure the `SiteRoute` to match on the exact route we care about and then construct some `Data` and `URLResponse` from scratch, and then I guess return some kind of default data and response in all other cases.

@T(00:25:30)
So, this is why our library comes with tools for starting the API client off in a state where none of the site routes are implemented, and then we can override just the specific endpoints we think will be invoked.

@T(00:25:41)
Even better, if an API endpoint is invoked that we did not override we will get a test failure, which allows us to exhaustively prove what parts of our API the view model actually needs to do its job. And in the future if we start using new API endpoints we will be instantly notified of which tests need to be updated to account for the new behavior.

@T(00:16:03)
So, we can start our view model off with a fully failing API client, which means no matter which route you try to hit you will get a test failure:

```swift
class ClientTests: XCTestCase {
  func testBasics() async throws {
    let viewModel = ViewModel(apiClient: .failing)

    await viewModel.fetch()
  }
}
```

> Failed: Failed to respond to route: SiteRoute.users(.user(1, .books(.search(SearchOptions(sort: .name, direction: .asc, count: 10)))))
>
> Use 'URLRoutingClient&lt;SiteRoute>.override' to supply a default response for this route.

@T(00:26:17)
And of course this immediately fails because the `.fetch` method tries to hit an API endpoint. The test failure is very helpful in showing us exactly what API endpoint was hit, and so all we have to do is override this specific endpoint so that it returns some real data.

@T(00:26:38)
There is a method that allows us to do this:

```swift
let viewModel = ViewModel(
  apiClient: .failing
    .override
)
```

@T(00:26:47)
There are a few options for describing how we want to override the API client, and each is interesting and as their own uses, but the one we are most interested in is the one that allows us to specify the exact endpoint we want to stub in for some synchronous mock data.

@T(00:26:57)
In order to get access to that `override` we need to make `SiteRoute` equatable so that `override` can understand which route it is we are overriding.

@T(00:27:22)
And now we get access to an `override` method that allows us to specify the exact route we want to override, as well as the response we want to synchronously and immediately return:

```swift
let viewModel = ViewModel(
  apiClient: .failing
    .override(
      <#SiteRoute#>,
      with: <#() throws -> Result<(Data, URLResponse), URLError>#>
    )
)
```

@T(00:27:36)
The route we want to override is the exact enum value we expect to be invoked in the view model. Currently it’s just a hardcoded value, but in a real application there may be logic that determines which endpoint is invoked, and this style of testing gives us the ability to test that logic.

```swift
let viewModel = ViewModel(
  apiClient: .failing
    .override(
      .users(.user(42, .books(.search(.init(direction: .asc))))),
      with: <#() throws -> Result<(Data, URLResponse), URLError>#>
    )
)
```

@T(00:28:00)
Next we need to construct the data and response we want the API client to send back when this exact API endpoint is invoked. This gives us full freedom to describe exactly how the API client responds, but in terms of its data but also in terms of its status code, headers and more.

@T(00:18:18)
The library comes with a helper to make constructing this result a bit nicer:

```swift
let viewModel = ViewModel(
  apiClient: .failing
    .override(
      .users(.user(1, .books())),
      with: {
        try .ok(
          BooksResponse(
            books: [
              .init(
                id: UUID(
                  uuidString: "deadbeef-dead-beef-dead-beefdeadbeef"
                )!,
                title: "Blobbed around the world",
                bookURL: "/books/deadbeef-dead-beef-dead-beefdeadbeef"
              )
            ]
          )
        )
      }
    )
)
```

@T(00:28:54)
So now we have forced the failing API client to not fail on this one, specific route, in which case a concrete `BooksResponse` will be returned.

@T(00:29:03)
In fact, now that we have this, our test suite is passing because the `fetch` method will invoke this specific endpoint under the hood, and all is fine. That means we can now finally make assertions on how the view model’s state changes after the `fetch` endpoint is invoked:

```swift
XCTAssertEqual(
  viewModel.books,
  [
    .init(
      id: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!,
      title: "Blobbed around the world",
      bookURL: "/books/deadbeef-dead-beef-dead-beefdeadbeef"
    )
  ]
)
```

@T(00:29:38)
But to do that we need to make `Book` equatable:

```swift
public struct Book: Codable, Equatable {
}
```

@T(00:29:45)
And now this test passes!

@T(00:29:51)
So this is pretty incredible. Not only could we generate an API client from our router for free, with no extra work on our part, but it’s even infinitely testable right out of the box. We can tap into the API client to override just a specific endpoint, and force it to return the data that we want. And then we get to test how that data flows into the rest of the system, which we can do by making assertions on the view model’s state.

@T(00:30:14)
But there are more applications of this override concept than just for tests. Currently in our preview we are using a live API client, which is cool for when we want to demo how the screen integrates with a live, running web server, but often we do not want to do that. Many times running a full server is a bit too heavy handed for something like a preview, and so we just want to supply some simple data to the preview to show, and we can use a different overload of `override` to accomplish this.

@T(00:30:43)
We can start our preview off in a failing state:

```swift
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      viewModel: .init(
        apiClient: .failing
      )
    )
  }
}
```

Which will cause the preview to show no data, because the API client we supplied just immediately fails for each endpoint.

@T(00:30:52)
So, we can chain onto this failing client the `.override` method, but this time we can supply a predicate that determines which routes we want to override rather than supplying just one single route that we want to override:

```swift
viewModel: .init(
  apiClient: .failing
    .override(
      <#(SiteRoute) -> Bool#>,
      with: <#() throws -> Result<(Data, URLResponse), URLError>#>
    )
)
```

@T(00:31:13)
So, we could use pattern matching to say that we only want to support the search endpoint:

```swift
viewModel: .init(
  apiClient: .failing
    .override {
      guard case .users(.user(_, .books(.search))) = $0
      else { return false }
      return true
    } with: {

    }
)
```

@T(00:31:43)
And then when that predicate is true we will override that endpoint with a mock `BooksResponse`:

```swift
viewModel: .init(
  apiClient: .failing
    .override {
      guard case .users(.user(_, .books(.search))) = $0
      else { return false }
      return true
    } with: {
      try .ok(
        BooksResponse(
          books: (1...100).map { n in
            .init(
              id: .init(),
              title: "Book \(n)",
              bookURL: URL(string: "/books/\(n)")!
            )
          }
        )
      )
    }
)
```

@T(00:32:12)
And now our preview is running again, but it’s no longer hitting a server. We are just providing the data immediately to the preview.

@T(00:32:26)
So, not only have we installed a router into a Vapor application that is statically checked and type safe, and in doing so not only have we made it possible to immediately link to other parts of the application in a static and type safe way, but once all of that was done we get an API client out of it for free. This allowed us to make API requests from an iOS application to our server without doing any additional work.

@T(00:32:50)
And if that wasn’t amazing enough, we were able to accomplish all of this in an infinitely testable and flexible manner. We can easily construct all new API clients that stub out just a small portion of the routes in order to use the client in tests and previews.

## Conclusion

@T(00:33:06)
Well, that concludes this tour of our swift-parsing library. We think it’s pretty incredible that in just 4 episodes we have touched upon small parsing problems such as what one encounters in Advent of Code challenges, as well as comparing regular expressions to incremental parsing, and then somehow ended on type safe routing and derived API clients.

@T(00:33:38)
We think this just goes to show how incredibly powerful a generic, composable parsing library can be. Believe it or not there is still more parsing topics we want to cover in the future, but we want to cover some different topics, so we’ll leave it here for now.

@T(00:33:53)
Until next time!
