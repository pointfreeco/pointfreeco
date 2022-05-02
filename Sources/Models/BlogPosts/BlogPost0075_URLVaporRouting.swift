import Foundation

public let post0075_URLVaporRouting = BlogPost(
  author: .pointfree,
  blurb: """
Introducing new routing libraries that make client-side and server-side routing easy with more type safety and less fuss.
""",
  contentBlocks: [
    .init(
      content: #"""
We are excited to announce two brand new open source projects that bring composable, type safe, and bidirectional routing to both iOS client applications and server-side Swift applications:

* The [URL Routing][swift-url-routing] library gives you tools for transforming URL requests into first class data types, and the reverse to turn data back into URL requests. [Learn more](#urlrouting) ⬇
* The [Vapor Routing][vapor-routing] library gives you tools for handling routing in a Vapor web application in a type safe way and for statically linking to any part of you website. [Learn more](#vaporrouting) ⬇

Both libraries are built on the back of our powerful [Parsing][swift-parsing] library, and shows just how useful generalized parsing can be.

<div id="urlrouting"></div>

## URLRouting

The [URL Routing][swift-url-routing] library gives you access to tools that can parse a nebulous URL request into a first class data type, with composability, type safety and ergonomics in mind. This can be useful for client-side iOS applications that need to support deep-linking, as well as server-side applications.

To use the library you first begin with a domain modeling exercise. You model a route enum that represents each URL you want to recognize in your application, and each case of the enum holds the data you want to extract from the URL.

For example, if we had screens in our Books application that represent showing all books, showing a particular book, and searching books, we can model this as an enum:

```swift
enum AppRoute {
  case books
  case book(id: Int)
  case searchBooks(query: String, count: Int = 10)
}
```

Notice that we only encode the data we want to extract from the URL in these cases. There are no details of where this data lives in the URL, such as whether it comes from path parameters, query parameters or POST body data.

Those details are determined by the router, which can be constructed with the tools shipped in [URL Routing][swift-url-routing] library. Its purpose is to transform an incoming URL into the `AppRoute` type. For example:

```swift
import URLRouting

let appRouter = OneOf {
  // GET /books
  Route(.case(AppRoute.books))) {
    Path { "books" }
  }

  // GET /books/:id
  Route(.case(AppRoute.books(id:))) {
    Path { "books"; Digits() }
  }

  // GET /books/search?query=:query&count=:count
  Route(.case(AppRoute.searchBooks(query:count:))) {
    Path { "books"; "search" }
    Query {
      Field("query")
      Field("count", default: 10) { Digits() }
    }
  }
}
```

This router describes at a high-level how to pick apart the path components, query parameters, and more from a URL in order to transform it into an `AppRoute`.

Once this router is defined you can use it to implement deep-linking logic in your application. You can implement a single function that accepts a `URL`, use the router's `match` method to transform it into an `AppRoute`, and then switch on the route to handle each deep link destination:

```swift
func handleDeepLink(url: URL) throws {
  switch try appRouter.match(url: url) {
  case .books:
    // navigate to books screen

  case let .book(id: id):
    // navigate to book with id

  case let .searchBooks(query: query, count: count):
    // navigate to search screen with query and count
  }
}
```

This kind of routing is incredibly useful in client side iOS applications, but it can also be used in server-side applications. Even better, it can automatically transform `AppRoute` values back into URLs, which is handy for linking to various parts of your website:

```swift
appRoute.path(for: .searchBooks(query: "Blob Bio"))
// "/books/search?query=Blob%20Bio"
```

```swift
Node.ul(
  books.map { book in
    .li(
      .a(
        .href(appRoute.path(for: .book(id: book.id))),
        book.title
      )
    )
  }
)
```
```html
<ul>
  <li><a href="/books/1">Blob Autobiography</a></li>
  <li><a href="/books/2">Blobbed around the world</a></li>
  <li><a href="/books/3">Blob's guide to success</a></li>
</ul>
```

This can be incredibly powerful for generating provably correct URLs within your site, and not having to worry about routes changing or typos being accidentally introduced. In fact, we use the URL routing to power routing on this very site, which you can see by peeking at the [code][pointfreeco-url-routing-example] since it is all [open source][pointfreeco-github].

<div id="vaporrouting"></div>

## VaporRouting

As we can see, URL Routing provides some useful tools for server-side applications, which is why we are also open sourcing [Vapor Routing][vapor-routing], which provides [Vapor][vapor] bindings to the URL Routing library.

Routing in Vapor has a simple API that is similar to popular web frameworks in other languages, such as Ruby's [Sinatra][sinatra] or Node's [Express][express]. It works well for simple routes, but complexity grows over time due to lack of type safety and inability to _generate_ correct URLs to pages on your site.

To see this, consider an endpoint to fetch a book that is associated with a particular user:

```swift
// GET /users/:userId/books/:bookId
app.get("users", ":userId", "books", ":bookId") { req -> Response in
  guard
    let userId = req.parameters.get("userId", Int.self),
    let bookId = req.parameters.get("bookId", Int.self)
  else {
    struct BadRequest: Error {}
    throw BadRequest()
  }

  // Logic for fetching user and book and constructing response...
  let user = try await database.fetchUser(user.id)
  let book = try await database.fetchBook(book.id)
  return BookResponse(...)
}
```

When a URL request is made to the server whose method and path matches the above pattern, the closure will be executed for handling that endpoint's logic.

Notice that we must sprinkle in validation code and error handling into the endpoint's logic in order to coerce the stringy parameter types into first class data types. This obscures the real logic of the endpoint, and any changes to the route's pattern must be kept in sync with the validation logic, such as if we wanted to rename the `:userId` or `:bookId` parameters.

In addition to these drawbacks, we often need to be able to generate valid URLs to various server endpoints. For example, suppose we wanted to [generate an HTML page][swift-html-vapor] with a list of all the books for a user, including a link to each book. We have no choice but to manually interpolate a string to form the URL, or build our own ad hoc library of helper functions that do this string interpolation under the hood:

```swift
Node.ul(
  user.books.map { book in
    .li(
      .a(.href("/users/\(user.id)/book/\(book.id)"), book.title)
    )
  }
)
```
```html
<ul>
  <li><a href="/users/42/book/321">Blob autobiography</a></li>
  <li><a href="/users/42/book/123">Life of Blob</a></li>
  <li><a href="/users/42/book/456">Blobbed around the world</a></li>
</ul>
```

It is our responsibility to make sure that this interpolated string matches exactly what was specified in the Vapor route. This can be tedious and error prone.

In fact, there is a typo in the above code. The URL constructed goes to "/book/:bookId", but really it should be "/book*s*/:bookId":

```diff
- .a(.href("/users/\(user.id)/book/\(book.id)"), book.title)
+ .a(.href("/users/\(user.id)/books/\(book.id)"), book.title)
```

[VaporRouting][vapor-routing] aims to solve these problems, and more, when dealing with routing in a Vapor application.

To use the library, one starts by constructing an enum that describes all the routes your website supports. For example, the book endpoint described above can be represented as:

```swift
enum SiteRoute {
  case userBook(userId: Int, bookId: Int)
  // more cases for each route
}
```

Then you construct a router, which is an object that is capable of parsing URL requests into `SiteRoute` values and _printing_ `SiteRoute` values back into URL requests. Such routers can be built from various types the library vends, such as `Path` to match particular path components, `Query` to match particular query items, `Body` to decode request body data, and more:

```swift
import VaporRouting

let siteRouter = OneOf {
  // Maps the URL "/users/:userId/books/:bookId" to the
  // SiteRouter.userBook enum case.
  Route(.case(SiteRouter.userBook)) {
    Path { "users"; Digits(); "books"; Digits() }
  }

  // More uses of Route for each case in SiteRoute
}
```

> Note: Routers are built on top of the [Parsing][swift-parsing] library, which provides a general solution for parsing more nebulous data into first-class data types, like URL requests into your app's routes.

Once that little bit of upfront work is done, using the router doesn't look too dissimilar from using Vapor's native routing tools. First you mount the router to the application to take care of all routing responsibilities, and you do so by providing a closure that transforms `SiteRoute` to a response:

```swift
// configure.swift
public func configure(_ app: Application) throws {
  ...

  app.mount(siteRouter, use: siteHandler)
}

func siteHandler(
  request: Request,
  route: SiteRoute
) async throws -> AsyncResponseEncodable {
  switch route {
  case .userBook(userId: userId, bookId: bookId):
    let user = try await database.fetchUser(user.id)
    let book = try await database.fetchBook(book.id)
    return BookResponse(...)

  // more cases...
  }
}
```

Notice that handling the `.userBook` case is entirely focused on just the logic for the endpoint, not parsing and validating the parameters in the URL.

With that done you can now easily generate URLs to any part of your website using a type safe, concise API. For example, generating the list of book links now looks like this:

```swift
Node.ul(
  user.books.map { book in
    .li(
      .a(
        .href(siteRouter.path(for: .userBook(userId: user.id, bookId: book.id)),
        book.title
      )
    )
  }
)
```

Note there is no string interpolation or guessing what shape the path should be in. All of that is handled by the router. We only have to provide the data for the user and book ids, and the router takes care of the rest. If we make a change to the `siteRouter`, such as recognizer the singular form "/user/:userId/book/:bookId", then all paths will automatically be updated. We will not need to search the code base to replace "users" with "user" and "books" with "book".

## Get started today!

That's a short summary of the powers these libraries contain, but there is a lot more to discover. If you currently maintain deep-linking in your iOS application or a server-side Swift application, try our libraries today for improved compile-time safety and composability! Version 0.1.0 of [URLRouting][swift-url-routing-0-1-0] and [VaporRouting][vapor-routing-0-1-0] have just been released.

[swift-parsing]: http://github.com/pointfreeco/swift-parsing
[swift-url-routing]: http://github.com/pointfreeco/swift-url-routing
[vapor-routing]: http://github.com/pointfreeco/vapor-routing
[vapor-routing-0-1-0]: https://github.com/pointfreeco/vapor-routing/releases/tag/0.1.0
[swift-url-routing-0-1-0]: https://github.com/pointfreeco/swift-url-routing/releases/tag/0.1.0
[vapor]: http://vapor.codes
[express]: http://expressjs.com
[sinatra]: http://sinatrarb.com
[pointfreeco-url-routing-example]: https://github.com/pointfreeco/pointfreeco/blob/f96c00ee2ef188d4cdb9a867086de848b96e0dc5/Sources/PointFreeRouter/Routes.swift#L9
[pointfreeco-github]: http://github.com/pointfreeco/pointfreeco
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil, // TODO
  id: 75,
  publishedAt:  Date(timeIntervalSince1970: 1651467600),
  title: "Open Sourcing URLRouting and VaporRouting"
)
