## Introduction

@T(00:00:05)
We have now shown how to use [our parser-printer library](https://github.com/pointfreeco/swift-parsing) to build something that at first blush doesn’t exactly look related to parsing or printing at all. The router we just built is capable for picking apart a URL request to figure out what it represents and then map that to a first class domain that describes every route of a server application.

@T(00:00:22)
Then with very little work, and almost as if by magic, we were able to adapt the router so that it could be used to transform that first class domain of routes back into a URL, which was great for being able to link into various parts of the website. We didn’t have to manually construct URLs by interpolating values into strings, which is error prone and requires extra maintenance to keep everything in sync.

@T(00:00:43)
And the only reason we can use the words “parser”, “printer” and “router” in the same sentence is because our parsing library is completely generic over the type of things it can parse and print.

@T(00:00:55)
So this is looking cool, but to really show the power let’s actually build a small server side application that makes use of this router. We will first show how [Vapor](https://vapor.codes), a popular server side framework, handles routing, and then show what our router brings to the table. Not only will we achieve something that is statically type safe and can be used to generate links within the site, but we will even be able to derive an API client from it for free so that we can make requests to the server from an iOS application. 😯

## Routing in Vapor

@T(00:01:33)
So, let’s start a brand new Vapor project, which we can do by `cd`ing into a new directory, then using a tool that Vapor ships for starting a fresh Vapor project from a template, and then opening the `Package.swift` file:

```bash
$ vapor new Server -n
$ cd Server
$ open Package.swift
```

@T(00:02:16)
The vapor CLI has created a Swift package for us with a number of files already in place. We are not going to go into detail on how a Vapor project is structured because that’s not really important right now. We’ll just learn the bare minimum to get things done as we go.

@T(00:02:41)
Already we can just hit cmd+R in Xcode to build and run the project, and once it is finished we will have a server running on our computers that we can visit:

```txt
http://127.0.0.1:8080

It works!
```

@T(00:03:05)
There is one other route that comes with the default template:

```txt
http://127.0.0.1:8080/hello

Hello, world!
```

@T(00:03:10)
But any other URL will cause a 404 error since the route is not recognized:

```txt
http://127.0.0.1:8080/goodbye

{
  "error": true,
  "reason": "Not Found"
}
```

@T(00:03:18)
The code for recognizing these URLs and implementing the logic for sending content to the browser is contained in the `routes.swift` file:

```swift
import Vapor

func routes(_ app: Application) throws {
  app.get { req in
    return "It works!"
  }

  app.get("hello") { req -> String in
    return "Hello, world!"
  }
}
```

@T(00:03:45)
We’ve already discussed a bit of this syntax previously in order to demonstrate how web frameworks deal with routing. You call a method on the `app` variable in order to describe a URL pattern that should be matched, and then from the closure you return a response to send back to the client.

@T(00:04:08)
Here we are sending a simple string, but you can also send back some `Encodable` data that is automatically turned into JSON:

```swift
app.get { req in
  return ["message": "It works!"]
}
```

@T(00:04:21)
And now we get JSON in the browser:

```txt
http://127.0.0.1:8080

{
  "message": "It works!"
}
```

@T(00:04:31)
Let’s see what it takes to recreate some of our site routes in Vapor.

@T(00:04:37)
For example, we could support an endpoint for fetching the details of a particular user:

```swift
struct UserResponse: Content {
  let id: Int
  let name: String
}

app.get("users", ":userId") { req -> UserResponse in
  guard let userId = req.parameters.get("userId", as: Int.self)
  else {
    struct BadRequest: Error {}
    throw BadRequest()
  }
  return UserResponse(id: userId, name: "Blob \(userId)")
}
```

@T(00:05:24)
The `.get` method allows us to pluck a query parameter from the URL, and optionally try to convert it to a non-string type using the `LosslessStringConvertible` protocol. Of course we would want to do some real work in this closure, like making a database request or a network request. But for now we will just stub things in.

@T(00:07:49)
And we can give it a spin:

```txt
http://127.0.0.1:8080/users/42

{
  "id": 42,
  "name": "Blob 42"
}
```

```txt
http://127.0.0.1:8080/users/hello

{
  "error": true,
  "reason": "BadRequest()"
}
```

@T(00:08:09)
We can also implement a route for fetching the data for a book associated with a particular user. We can start by modeling the response we want to send back. We can do this by modeling a struct that is `Encodable` so that it can be turned back into JSON to be sent to the browser:

```swift
struct BookResponse: Codable {
  let id: UUID
  let userId: Int
  let title: String
}
```

@T(00:08:33)
And then we can return an instance of this struct from the `.get` method because Vapor allows returning any `Encodable` value from this closure:

```swift
app.get("users", ":userId", "books", ":bookId") { req -> BookResponse in
  guard
    let userId = req.parameters.get("userId", as: Int.self),
    let bookId = req.parameters.get("bookId", as: UUID.self)
  else {
    struct BadRequest: Error {}
    throw BadRequest()
  }
  return BookResponse(
    id: bookId,
    userId: userId,
    title: "Blobbed around the world \(bookId)"
  )
}
```

@T(00:09:44)
And again this closure should be doing some real, substantial work, but we will just stub in the work for now.

@T(00:09:51)
Also it’s worth mentioning that Vapor is doing some work behind the scenes here to make this work. As we mentioned a moment ago the `.get` method only works if the type you pass to it is `LosslessStringConvertible`. However, `UUID` does not conform to that protocol, though it probably should, and so Vapor has decided to implement the conformance itself. In general it is precarious to conform types you do not own to protocols you don’t own, because anyone can do that, and so if there are multiple conformances whose will win?

@T(00:10:24)
But, caveats aside, this does work how we expect:

```txt
http://127.0.0.1:8080/users/1/books/deadbeef-dead-beed-dead-beefdeadbeef

{
  "id": "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF",
  "userId": 1,
  "title": "Blobbed around the world DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"
}
```

@T(00:10:58)
It's worth mentioning, though, that it isn't ideal to specify parameters in two places: first in the route declaration, and then again where the parameter is cast to a data type, like `Int` or `UUID`. It becomes far too easy for one of these string-y values to become out of sync or wrong due to a copy paste bug.

@T(00:11:19)
Let’s try something a little more complicated. Let’s implement the endpoint that searches a user’s books. We’ll copy over the `SearchOptions` type that we used before:

```swift
struct SearchOptions {
  var sort: Sort = .title
  var direction: Direction = .asc
  var count = 10

  enum Direction {
    case asc, desc
  }
  enum Sort {
    case title, category
  }
}
```

@T(00:11:42)
And we’ll create a new response type to represent the response we want to send back from this endpoint:

```swift
struct BooksResponse: Content {
  let books: [Book]
  struct Book: Codable {
    let id: UUID
    let title: String
  }
}
```

@T(00:12:04)
Then we can create the endpoint and try extracting the user id from the path parameters:

```swift
app.get("users", ":userId", "books", "search") { req -> BooksResponse in
  guard let userId = req.parameters.get("userId", as: Int.self)
  else {
    struct BadRequest: Error {}
    throw BadRequest()
  }

}
```

@T(00:12:29)
Next we want to try to construct a `SearchOptions` value from the query parameters passed to the URL. The way we do this in Vapor is using the `decode` method on `req.query`:

```swift
let options = try req.query.decode(SearchOptions.self)
```

@T(00:12:47)
But in order for this to work we need to make our `SearchOptions` type decodable:

```swift
struct SearchOptions {
  var sort: Sort = .name
  var direction: Direction = .asc
  var count = 10

  enum Direction: String, CaseIterable {
    case asc, desc
  }
  enum Sort: String, CaseIterable {
    case name, category
  }
}
```

@T(00:12:57)
Now things compile, and we could do a little bit of work to send back a collection of a few books:

```swift
return BooksResponse(
  books: (1...options.count).map { n in
    let bookId = UUID()
    return .init(
      id: bookId,
      title: "Blobbed around the world \(n)"
    )
  }
)
```

@T(00:13:30)
And just to make sure the query parameters are really being decoded properly we could add a little bit of logic to sort this collection by the title either ascending or descending:

```swift
return BooksResponse(
  books: (1...options.count).map { n in
    let bookId = UUID()
    return .init(
      id: bookId,
      title: "Blobbed around the world \(n)"
    )
  }
    .sorted {
      options.direction == .asc
      ? $0.title < $1.title
      : $0.title > $1.title
    }
)
```

@T(00:14:01)
If we try to visit the search page we will see an error:

```txt
http://127.0.0.1:8080/users/1/books/search

{
  "error": true,
  "reason": "Value of type 'String' required for key 'sort'."
}
```

@T(00:14:08)
It seems that we are required to provide a sort parameter. And I guess that makes sense because we didn’t specify defaults anyway. So let’s do that real quick:

```txt
http://127.0.0.1:8080/users/1/books/search?sort=title&direction=asc&count=10

{
  "books": [
    {
      "id": "F411A0F3-2F5B-4D72-B79E-167FE1C37CF5",
      "title": "Blobbed around the world 1"
    },
    …
    {
      "id": "A6B9FBF6-BA6A-4B70-AE11-50D59685E744",
      "title": "Blobbed around the world 9"
    }
  ]
}
```

@T(00:14:48)
It works, and indeed we can see that we can flip the direction and the title is sorted as descending.

@T(00:15:01)
It’s a bit of a bummer to have to require all of these query parameters. Often query parameters are just additional information passed along to the URL that help customize the results sent back, and in such cases they should be optional. We should still be allowed to use this URL even if none of the query params are passed along.

@T(00:15:23)
It’s quite easy to allow the query parameters to be omitted from the URL: we just have to make all the fields of `SearchOptions` optional:

```swift
struct SearchOptions: Decodable {
  var sort: Sort? = .title
  var direction: Direction? = .asc
  var count: Int? = 10

  …
}
```

@T(00:15:32)
However, that doesn’t help with providing defaults for these fields. It will be up to use to coalesce these values to their defaults when using them, such as providing a count and sorting:

```swift
books(1...(options.count ?? 10)).map { n in
  …
}
  .sorted {
    (options.direction ?? .asc) == .asc
    ? $0.title < $1.title
    : $0.title > $1.title
  }
```

@T(00:16:04)
But this is really messy, and is going to cause our routing logic to leak into many parts of our application.

@T(00:16:18)
In order to supply defaults for these fields we need to write a custom `Decodable` conformance, so that we can first try decoding the regular way, and when it fails we can coalesce to a default. However, doing that is very cumbersome and error prone.

@T(00:16:52)
Another option would be to use property wrappers for annotating fields that we want to have defaults when it’s unable to decode from JSON:

```swift
struct SearchOptions: Decodable {
  @Default(.title) var sort: Sort
  @Default(.asc) var direction: Direction
  @Default(10) var count: Int

  …
}
```

@T(00:17:08)
But sadly this exact syntax is not really possible in Swift today, and you actually have to work around it in some awkward ways.

@T(00:17:22)
All of this is to say that something that was quite simple in our router has become a bit more complicated and nuanced in Vapor. For now we will go back to the non-optional fields and just require that all query parameters be passed.

@T(00:17:29)
But even beyond the complexities of providing defaults to query params, there’s another thing that is not entirely ideal about this code. In the handler closures for each route we have quite a bit of logic that doesn’t have anything to do with actually constructing the response to send to the browser. We are trying to extract parameters from the path and query, we are trying to massage those parameters into first class types, and then finally we start doing the work to construct the response.

@T(00:18:06)
That’s already pretty bad, but it gets worse. What if we wanted to include links in our JSON payloads that point to other parts of our API? For example, in the `UserResponse` we may want to provide a URL that points to the endpoint that can load a users books:

```swift
struct UserResponse: Content {
  …
  let booksURL: URL
}
```

@T(00:18:34)
And the `BooksResponse` may want to expose a URL for loading more information for a particular book:

```swift
struct BooksResponse: Content {
  …
  struct Book: Content {
    …
    let bookURL: URL
  }
}
```

@T(00:18:56)
As soon as we do this we get a bunch of compiler errors, and the only way to fix them is to do some string interpolation to create these URLs from scratch.

@T(00:19:00)
For example, when constructing a `UserResponse` we now need to provide a `booksURL`, which can be done by interpolating the user’s id into a string:

```swift
return UserResponse(
  id: userId,
  name: "Blob \(userId)",
  booksURL: URL(
    string: "http://127.0.0.1:8080/users/\(userId)/books/search"
  )!
)
```

@T(00:19:33)
It’s a little weird that we are hard coding the 127.0.0.1 into this URL, so we will probably want to extract that out at some point. But worse is that this isn’t even correct because due to how the router works we must provide all of the query parameters in order for this route to be recognized:

```swift
booksURL: URL(
  string: "http://127.0.0.1:8080/users/\(userId)/books/search?sort=title&direction=asc&count=10"
)!
```

@T(00:20:13)
And similarly, when constructing a `BooksResponse` we need to interpolate data into a string in order to construct a URL:

```swift
return .init(
  id: bookId,
  title: "Blobbed around the world \(n)",
  bookURL: URL(string: "http://127.0.0.1:8080/users/\(userId)/books/\(bookId)")!
)
```

@T(00:20:38)
Now of course there is nothing keeping us in check when constructing these URLs. We don’t know if they actually point to the place we think it should. There could be a typo, or the route could have changed without us knowing, or we could have even generated a completely invalid URL. On a big enough site and after having interpolated hundreds of URLs there are bound to be some mistakes somewhere.

@T(00:21:10)
So that’s the basics of creating a Vapor application, and we even recreated most of the routes we explored in the previous episode. There were some downsides to using the default vapor router, such as difficulty in converting string types extracted from a URL into your own Swift data types, and there was duplication in the router and the extraction code which led me to accidentally introduce a bug when I copied and pasted, and finally we have no way of generating valid URLs to various parts of our website. We just have to interpolate strings manually.

## Better routing with vapor-routing

@T(00:21:44)
Luckily there is a better way. Not only can we use our routing library to process incoming requests in order to figure out which parts of our application’s logic we want to execute, but we can also automatically generate URLs to any part of the application. Even better, we can use a small, companion library that helps integrate Vapor and our swift-parsing library at a deeper level.

@T(00:22:07)
So, let’s quickly bring in that library and then refactor this small Vapor application to use our libraries.

@T(00:22:14)
Let’s start by adding the library as a dependency to our Vapor application:

```swift
dependencies: [
   // 💧 A server-side Swift web framework.
  .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
  .package(url: "https://github.com/pointfreeco/vapor-routing", from: "0.1.0")
],
```

@T(00:22:34)
And we’ll make our site target depend on it:

```swift
.target(
  name: "App",
  dependencies: [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "VaporRouting", package: "vapor-routing"),
  ],
  …
)
```

@T(00:22:47)
Next we’ll copy-and-paste the site router from our other project over into a new file in the Vapor project.

@T(00:23:03)
Everything should still build because including our vapor-routing library also brings in our parsing library.

@T(00:23:07)
Next we can hop over to the `configure.swift` file and we can comment out the line that tries to register routes with the Vapor application:

```swift
// register routes
//try routes(app)
```

@T(00:23:14)
Instead of using Vapor’s routing tools we will use our own. We can get access to those tools by importing the `VaporRouting` module:

```swift
import VaporRouting
```

@T(00:23:21)
Once that is done we get access to a `mount` method on `Application` that allows us to take over routing with a parser and a handler function that transforms the parser’s output to some kind of response:

```swift
app.mount(
  <#Parser#>,
  use: <#(Request, Parser.Output) async throws -> AsyncResponseEncodable#>
)
```

@T(00:23:36)
We can plug the `router` value we previously constructed in for the first argument:

```swift
app.mount(
  router,
  use: <#(Request, Parser.Output) async throws -> AsyncResponseEncodable#>)
```

@T(00:23:40)
The second argument is just a function that transforms the `SiteRoute` enum value into a response:

```swift
app.mount(router, use: siteHandler)
```

@T(00:23:48)
We will actually add this handler to the `routes.swift` file because that is where we were previously doing this work:

```swift
func siteHandler(
  request: Request,
  route: SiteRoute
) async throws -> AsyncResponseEncodable {
  "\(route)"
}
```

Right now we have just stubbed the response to describe the route recognized.

@T(00:24:28)
And with this we can already run the site and recognize routes:

```txt
http://127.0.0.1:8080/

home
```

```txt
http://127.0.0.1:8080/users/42

users(
  App.UsersRoute.user(
    42,
    App.UserRoute.fetch
  )
)
```

```txt
http://127.0.0.1:8080/users/42/books/search

users(
  App.UsersRoute.user(
    42,
    App.UserRoute.books(
      App.BooksRoute.search(
        App.SearchOptions(
          sort: App.SearchOptions.Sort.title,
          direction: App.SearchOptions.Direction.asc,
          count: 10
        )
      )
    )
  )
)
```

And we can see the routes that are being recognized, and it even recognized the default search route search options. We didn't need to pass along query parameters like we did for the vanilla Vapor endpoint.

@T(00:25:05)
If we put in a route that is not one of the ones we handle we will see an error that is only shown during development:

```txt
http://127.0.0.1:8080/users/42/hello

Routing error: multiple failures occurred

error: unexpected input
 --> input:1:11
1 | /users/42/hello
  |           ^ expected "books"
  |           ^ expected end of input

error: unexpected input
 --> input:1:2-6
1 | /users/42/hello
  |  ^^^^^ expected "about-us"
  |  ^^^^^ expected "contact-us"
  |  ^^^^^ expected end of input

error: unexpected input
 --> input:1:1
1 | GET
  | ^ expected "POST"
```

@T(00:25:18)
So, the router is working as we expect, we just need to start filling in some of the application logic in the `siteHandler` function.

@T(00:25:36)
We can do this by switching on the route so that we can decide how each case should be handled:

```swift
func siteHandler(
  request: Request,
  route: SiteRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .aboutUs:
    <#code#>
  case .contactUs:
    <#code#>
  case .home:
    <#code#>
  case .users(_):
    <#code#>
  }
}
```

@T(00:25:45)
The about, contact and home routes are something we didn’t consider in the vanilla Vapor route, so for now let’s just put in a stub of a response by returning an empty dictionary:

```swift
case .aboutUs:
  return [String: String]()
case .contactUs:
  return [String: String]()
case .home:
  return [String: String]()
```

@T(00:25:57)
For the users routes we could expand them in line right in the switch:

```swift
case .users(.create(<#CreateUser#>)):
case .users(.user(<#Int#>, <#UserRoute#>)):
```

And then handle the logic in each of these cases.

@T(00:26:04)
However, just as we nested our routes and routers in order to make them simpler and easier to understand, we can do the same for our handlers:

```swift
func siteHandler(
  request: Request, route: SiteRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .aboutUs:
    return [String: String]()
  case .contactUs:
    return [String: String]()
  case .home:
    return [String: String]()
  case let .users(route):
    return try await usersHandler(route: route)
  }
}

func usersHandler(
  route: UsersRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .create(_):
    <#code#>
  case .user(_, _):
    <#code#>
  }
}
```

@T(00:26:38)
And now we have a smaller switch to implement application logic in. We actually never explored the `.create` endpoint in the vanilla Vapor app, although it can be done, so for now let’s just stub its response:

```swift
case .create(_):
  return [String: String]()
```

@T(00:26:50)
And then for the `.user` case we will again defer to a `userHandler` function for handling user routes:

```swift
func usersHandler(
  route: UsersRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .create(_):
    return [String: String]()
  case let .user(userId, route):
    return try await userHandler(userId: userId, route: route)
  }
}

func userHandler(
  userId: Int,
  route: UserRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .books(_):
    <#code#>
  case .fetch:
    <#code#>
  }
}
```

@T(00:27:23)
The `.fetch` case is finally a place we can implement some server-side logic.

@T(00:27:28)
In the vanilla Vapor code we were trying to extract out a user id from the path parameters, and if that failed, either due to the parameter not being present or due to it not being capable of being casted to an integer, we threw an error. Only after all of that was done could we implement the endpoint’s logic:

```swift
app.get("users", ":userId") { req -> UserResponse in
  guard let userId = req.parameters.get("userId", as: Int.self)
  else {
    struct BadRequest: Error {}
    throw BadRequest()
  }
  return UserResponse(
    id: userId,
    name: "Blob \(userId)",
    booksURL: URL(
      string: "http://127.0.0.1:8080/users/\(userId)/books/search?sort=title&direction=asc&count=10"
    )!
  )
}
```

@T(00:27:48)
But now our router has taken care of all that messy data extracting and parsing logic, so we immediately have an integer at our disposal.

@T(00:27:58)
So, we can just copy-and-paste the actual endpoint logic from the vanilla Vapor code over to our handler and nothing has to change:

```swift
case .fetch:
  return UserResponse(
    id: userId,
    name: "Blob \(userId)",
    booksURL: URL(
      string: "http://127.0.0.1:8080/users/\(userId)/books/search?sort=title&direction=asc&count=10"
    )!
  )
```

@T(00:28:05)
Further, we no longer need to generate this monstrosity of a URL from memory. The site router can take care of this for us:

```swift
booksURL: router.url(for: .users(.user(userId, .books())))
```

@T(00:28:36)
That’s pretty amazing.

@T(00:28:38)
Let’s take this for a spin real quick by temporarily putting a `fatalError` in the `.books` case:

```swift
case .books(_):
  fatalError()
```

@T(00:28:48)
Now when we run the server we get nearly what we got previously in the vanilla Vapor application:

```txt
http://127.0.0.1:8080/users/1

{
  "id": 1,
  "name": "Blob 1",
  "booksURL": "/users/1/books/search"
}
```

@T(00:28:58)
There are two main differences.

@T(00:29:02)
For one, this URL isn’t showing any of the query params that we were showing previously. The parser-printers we used to make the site router do extra work to try not to print query parameters if it’s not necessarily. In particular, if you provide defaults for your query parameters and you don’t change those defaults, then there’s no point in printing them. So that’s nice.

@T(00:29:20)
Another difference is that the host is not being printed into the URL, such as `http://127.0.0.1:8080`. This is going to be problematic because iOS clients that are reading this JSON shouldn’t have to prepend their own hosts to these URLs in order to call these endpoints.

@T(00:29:38)
Now the router comes with a way of overriding its base URL:

```swift
booksURL: router
  .baseURL("http://127.0.0.1:8080")
  .url(for: .users(.user(userId, .books())))
```

@T(00:29:56)
But it’s going to be very annoying to have to sprinkle this code everywhere in the application.

@T(00:30:01)
But we also don’t want to directly bake the base URL into the site router:

```swift
let router = OneOf {
  …
}
  .baseURL("http://127.0.0.1:8080")
```

@T(00:30:18)
We would love for the base URL to be specified a single time once the application is booted up for the first time. This would make it possible for it to be based on the environment the Vapor app is running in, so that local development uses 127.0.0.1, a staging server could use a different URL, and production can use the real domain of your website.

@T(00:30:35)
Vapor allows you to attach global variables to your application so that they are accessible throughout, and we can do that in the `configure` bootstrap function where we mounted the router.

@T(00:30:43)
Vapor has support for this concept by allowing you to attach global variables to the single `Application` instance associated with your website:

```swift
public func configure(_ app: Application) throws {
  …
}
```

@T(00:30:45)
You do this in a similar way as what is done with SwiftUI and environment values.

@T(00:30:51)
You create a type to conform to the `StorageKey` protocol and describe the type of global you want to create:

```swift
enum SiteRouterKey: StorageKey {
  typealias Value = AnyParserPrinter<URLRequestData, SiteRoute>
}
```

@T(00:31:28)
Here we are forced to use `AnyParserPrinter` because the type of `router` is a monstrosity that we can’t possibly repeat here.

@T(00:31:38)
Then you extend `Application` to provide a property for your global that secretly under the hood just reaches out to some storage held by the application:

```swift
extension Application {
  var router: SiteRouterKey.Value {
    get {
      self.storage[SiteRouterKey.self]!
    }
    set {
      self.storage[SiteRouterKey.self] = newValue
    }
  }
}
```

@T(00:31:47)
With that in place we can update our configuration code to first set up the router stored in the application, and then mount it with the site handler:

```swift
app.router = router
  .baseURL("http://127.0.0.1:8080")
  .eraseToAnyParserPrinter()

app.mount(app.router, use: siteHandler)
```

@T(00:32:09)
Now we can access the router from any place we access to the application. The most common way to access the application is through the request. We already have access to the request in the `siteHandler`, but currently we just ignore it:

```swift
func siteHandler(
  request: Request,
  route: SiteRoute
) async throws -> AsyncResponseEncodable {
  …
}
```

@T(00:32:23)
Sounds like we need to start threading that value through to all of our handlers.

@T(00:32:42)
Now that we have access to the application’s router we can use it instead of calling out to the global `router`.

```swift
booksURL: req.application.router.url(
  for: .users(.user(userId, .books()))
)
```

@T(00:32:57)
And now the full path is printed:

```json
{
  "id": 42,
  "name": "Blob 42",
  "booksURL": "http://127.0.0.1:8080/users/42/books/search"
}
```

@T(00:33:08)
So this is looking quite nice. We get to write simpler and safer code with the compiler having our back, and it’s printing the minimal representation of the URL and getting rid of any superfluous details that don’t need to be there.

@T(00:33:20)
Let’s finish things off by implementing a `booksHandler` to handle the `.books` case and get rid of the `fatalError`:

```swift
func userHandler(
  request: Request, userId: Int, route: UserRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case let .books(route):
    return try await booksHandler(
      request: request, userId: userId, route: route
    )

  case .fetch:
    return UserResponse(
      id: userId,
      name: "Blob \(userId)",
      booksURL: router.url(for: .users(.user(userId, .books())))
    )
  }
}

func booksHandler(
  request: Request, userId: Int, route: BooksRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .book(_, _):
    <#code#>
  case .search(_):
    <#code#>
  }
}
```

@T(00:33:49)
And now we can implement these final two endpoints. We can basically copy and paste the endpoint implementations from the vanilla Vapor handlers except we will ignore any work being performed to extract information from the route and coalesce it into types. Let's start with search:

```swift
case let .search(options):
  return BooksResponse(
    books: (1...options.count).map { n
      let bookId = UUID()
      return .init(
        id: bookId,
        title: "Blobbed around the world \(n)",
        bookURL: URL(
          string: "http://127.0.0.1:8080/users/\(userId)/books/\(bookId)"
        )!
      )
    }
      .sorted {
        options.direction == .asc
        ? $0.title < $1.title
        : $0.title > $1.title
      }
  )
```

@T(00:34:11)
Except now we can drop the string interpolation and instead build the URL in a static, type safe way with the compiler holding our hand the entire time:

```swift
bookURL: request.application.router
  .url(for: .users(.user(userId, .books(.book(bookId)))))
```

@T(00:34:48)
And finally, we can implement the fetch endpoint, and even though it's just a single route for now, let's push it into a dedicated book handler:

```swift
func booksHandler(
  request: Request,
  userId: Int,
  route: BooksRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case let .book(bookId, route):
    return try await bookHandler(
      request: request,
      userId: userId,
      bookId: bookId,
      route: route
    )
  …
}

func bookHandler(
  request: Request,
  userId: Int,
  bookId: UUID,
  route: BookRoute
) {
  switch route {
  case .fetch:
    return BookResponse(
      id: bookId,
      userId: userId,
      title: "Blobbed around the world \(bookId)"
    )
  }
}
```

@T(00:36:04)
This is all looking pretty amazing. If we are willing to do the upfront work of building a parser-printer for our router, we can easily plug it into a Vapor application to power the website. Doing so allows us to remove a lot of logic from our handlers that doesn’t need to be there, such as extracting, coercing and validating data in the path or query params. And with no additional work we instantly get the ability to link to any page in our entire website.

## Next time: iOS API Client

@T(00:36:28)
But if you think all of this sounds interesting, you haven’t see anything yet.

@T(00:36:34)
Not only do we get all these benefits in the server side code, but we also get benefits in our client side iOS code that needs to talk to the server. We can instantly derive an API client that can speak to our server without doing much work at all. And the iOS client and server side client will always be in sync. If we add a new endpoint to the server it will instantly be available to us in the client with no additional work whatsoever.

@T(00:37:03)
Sound too good to be true? Let’s build a small iOS application that makes requests to our server side application…next time!
