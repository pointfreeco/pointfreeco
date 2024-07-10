## Introduction

@T(00:00:05)
So this is pretty amazing. We have built a parser that mimics what Apple’s sample code does with regexes, but we were able to slightly tweak the parser so that it was also a printer, and then, with a few more tweaks we made it so that it works on a lower level string representation, UTF-8, which is even more performant.

@T(00:00:22)
It’s also interesting to compare these two approaches for extracting data out of a string. Regular expressions are really good at describing ways of finding subtle and nuanced patterns in a string. However, once you capture those substrings you still have a mini-parsing problem on your hands because you typically want to turn those substrings into something more well structured, like numbers, dates, or custom struct and enum data types, and that work must be done in code that is entirely separate from the regex pattern you construct.

@T(00:00:51)
On the other hand, parsers are really good at describing how to incrementally consume bits from the beginning of a string and turn those bits into data types. This is great for breaking down the process of parsing into many tiny steps that concentrate on just one task, and great for extracting out high level, first class data types along the way. Further, as we have now seen a few times, parsers also have a chance at becoming printers, which has no equivalent in the world of regular expressions. However, parsers are not as good as finding nuanced patterns in strings as regular expressions are, and so if that is necessary for your domain it may be difficult to use parsers.

@T(00:01:30)
All of this is to say that parsing and regular expressions form an overlapping Venn diagram where either tool can be used to solve certain problems, and then other problems are best solved with one tool or the other. There is no universal solution here.

@T(00:01:45)
There is one other problem area where parser-printers really shine that unfortunately regular expressions can’t really help out with, and that’s when needing to process inputs that aren’t strings. All of the problems we have considered so far in this tour, including the Advent of Code example and the bank statement parser, have operated on simple string inputs, and of course the idea of regular expressions only makes sense for strings.

@T(00:02:07)
However, there are times we want to extract information from things that are not simple strings. An example of this we have touched upon a number of times in Point-Free is URL routing. This is the process of taking a nebulous, incoming URL request, which includes a path, query params, request body data, headers and more, and turning it into something more well-structured so that we know where in our app our website the user wants to go.

@T(00:02:33)
There are many open source libraries out there that aim to solve this problem, but there’s another side to URL routing that isn’t talked about much. And that’s how do you do the reverse where you want to turn your well-structured data back into a URL request. This is very important when building websites where you need to be able to create valid URLs to pages on your site.

## The problem

@T(00:02:53)
Let’s quickly recap the problem space of URL routing for our viewers since some watching this episode may not have been following our past episodes, and then let’s show what our parser library has to say about routing.

@T(00:03:07)
[swift-parsing](https://github.com/pointfreeco/swift-parsing) comes with a routing demo in the benchmarks target, which holds a whole bunch of parsers that attack various problems. In Routing.swift we have an example of how to build up a URLRequest parser, which allows you to process requests such as these:

```swift
let requests = [
  URLRequestData(),
  URLRequestData(path: "/contact-us"),
  URLRequestData(path: "/episodes"),
  URLRequestData(path: "/episodes/1"),
  URLRequestData(path: "/episodes/1/comments"),
  URLRequestData(path: "/episodes/1/comments", query: ["count": ["20"]]),
  URLRequestData(
    method: "POST",
    path: "/episodes/1/comments",
    body: .init(#"{"commenter":"Blob","message":"Hi!"}"#.utf8)
  ),
]
```

@T(00:03:54)
…into first-class Swift data types that describe all the different places those requests can be routed to in our application:

```swift
enum AppRoute: Equatable {
  case home
  case contactUs
  case episodes(EpisodesRoute)
}
enum EpisodesRoute: Equatable {
  case index
  case episode(id: Int, route: EpisodeRoute)
}
enum EpisodeRoute: Equatable {
  case show
  case comments(CommentsRoute)
}
enum CommentsRoute: Equatable {
  case post(Comment)
  case show(count: Int)
}
struct Comment: Codable, Equatable {
  let commenter: String
  let message: String
}
```

@T(00:04:12)
We’ve explored this kind of router a number of times on Point-Free, including on our [navigation](/collections/swiftui/navigation) series, our [modularity](/episodes/ep171-modularization-part-1) series, and most recently we showed how [parser builders](/episodes/ep175-parser-builders-the-point) make constructing routers like this a breeze.

@T(00:04:23)
In fact, the most [recent release](https://github.com/pointfreeco/swift-parsing/releases/0.9.1) of swift-parsing comes with an experimental routing library that provides tools for making it easy to parse URL requests. It is even being used in this `Router.swift` file. If we scan the file we will see lots of new, interesting routing-related types such as `Path`, `Query`, `Field` and more. We are going to dive deep into these types in a moment, but for now we just need to know that these types can be used to describe how one parses an incoming request into the more structured route enums we showed above.

@T(00:04:58)
But, as useful as it is to parse requests into enum values, it can be just as useful to print an enum value back into a request that would route back to the enum value. This is most important when building a website. Every single web framework, whether it’s [Ruby on Rails](https://rubyonrails.org), Node.js’s [Express](http://expressjs.com) framework or Swift’s [Vapor](https://vapor.codes), comes with a way to route requests to particular portions of the application’s logic.

@T(00:05:34)
For example, Rails applications have a “routes.rb” file that describes all the URLs the site recognizes, and specifies what part of application logic to execute when a route is recognized:

```ruby
Rails.application.routes.draw do
  get "/users/:user_id/books/:book_id" => "books#fetch"
end
```

@T(00:05:50)
This says that when a GET request comes into the server matching "/users/:user_id/books/:book_id" that it will be recognized and a `fetch` method on a `books` controller will be invoked. Further, whatever was matched in the `:user_id` and `:book_id` parameters will be bundled into a dictionary that will be accessible from the controller so that the application can perform special logic.

@T(00:06:15)
It is worth noting that the parameters extracted from the URL are not typed at all. You have to explicitly cast and defensively program against the types you expect them to be, and deal with type mismatches in your application’s logic.

@T(00:06:28)
This is similar to how express.js works, except you provide a callback closure directly in the route for when it is recognized:

```javascript
app.get('/users/:userId/books/:bookId', function (req, res) {
  …
})
```

@T(00:06:48)
Again these parameters are not type safe, just like with Ruby. Now, we shouldn’t fault Rails and express.js too much for this because both Ruby and JavaScript are dynamic languages. They don’t prioritize a type system like Swift does.

@T(00:07:04)
Vapor, the web framework written in Swift, exposes a very similar API for routing requests, except you separate the path components in variadic arguments:

```swift
app.get("users", ":userID", "books", ":bookID") { req in
  …
}
```

@T(00:07:28)
This API has been closely modeled after express.js’s API, and sadly it also adopts a lack of type safety in the arguments. The `:userID` and `:bookID` parameters are bundled up into a `[String: String]` dictionary and then it is up to you to further transform it into the types you expect and handle when there is a type mismatch.

@T(00:07:51)
This is just a small sample of how a few popular web frameworks handle URL request routing. But routing is only half the story when it comes to building a server. We not only want to route incoming requests to specific webpages, but we also want to generate URLs that can be embedded in webpages for navigating our site.

@T(00:08:09)
For example, if we render a list of all the books associated with a user we would need to manually generate a whole bunch of HTML links like this:

```html
<a href="/users/42/book/123">Blob Autobiography</a>
<a href="/users/42/book/321">Blobbed around the world</a>
…
```

@T(00:08:19)
To generate those URLs we would need to literally interpolate a string like this:

```swift
"/users/\(user.id)/book/\(book.id)"
```

@T(00:08:45)
This a little hard to read, but it may not bother you too much. However, the real trouble is that there is nothing guaranteeing that we keep the routing logic and the linking logic in sync. In fact, I actually have a typo here. The URL component should be “books” not “book”:

```swift
"/users/\(user.id)/books/\(book.id)"
```

@T(00:09:18)
This typo would have meant that we were accidentally generating incorrect links on our site, which would result in 404s. That just shouldn’t be possible.

@T(00:09:28)
And these kinds of mistakes wouldn’t be possible if parsing and printing were unified in one package so that you didn’t have to repeat yourself for each task. Just as the router should be able to parse an incoming request to extract data from it:

```swift
router.parse("/users/42/books/123")   // (42, 123)
```

@T(00:10:03)
The router should also have the ability to turn the user id and book id back into a request:

```swift
router.print((user.id, book.id))   // "/users/42/books/123"
```

@T(00:10:18)
This code would be 100% type safe. It would know that it needs two arguments, both of which are integers. You would not be allowed to pass anything else.

@T(00:10:32)
Interestingly, neither express.js nor Vapor try to solve for this problem, but Rails does and has for a very long time. They call it “named routes”, and every route you specify in a Rails application has a corresponding function that is magically generated for you:

```ruby
users_books_path 42, 321 # /users/42/books/321
```

(In Ruby, parentheses on function calls are optional.)

@T(00:11:07)
This is very cool, and honestly makes for a much better experience making a website when you know the framework is helping you correctly generate links within your site. However, it is not type safe at all. These functions are not statically known and so they cannot be autocompleted by an IDE. Instead, you must know how to write them out perfectly from memory, and there is nothing preventing you from passing nonsensical data to the function like a boolean instead of an integer. The function will happily take that data and try to do the best it can with it, or fail at runtime.

@T(00:11:41)
Our URL request parser accomplishes what these 3 web frameworks are trying to accomplish, but in a more concise and type safe manner. We get to deal with first-class Swift data types, rather than strings, and because it’s all built on parsers it is infinitely flexible and easy to add your own new parsers to the mix. And further, once we learn how to turn our router into a printer we will immediately get the ability to print 100% correct links to various parts of our site.

## Creating a router

@T(00:12:10)
Let’s put our money where our mouth is and generate a brand new router, and show how one single object can simultaneously encapsulate the idea of parsing incoming requests and printing outgoing requests.

@T(00:12:24)
We are going to make use of the package’s `_URLRouting` library, which comes with a bunch of handy parsers that we will explore in a moment. It’s worth noting that this library is underscored because it’s still experimental, and so although it is totally fine to depend on it you should expect its API to change in the future a little more than the core parsing library does.

@T(00:12:45)
Let’s start with the same route we have been looking at to explore the problem space:

```txt
users/42/books/123
```

@T(00:12:49)
If we were to build a parser of this as a simple string, it might look like this:

```swift
let router = Parse {
  "/users/"
  Digits()
  "/books/"
  Digits()
}

try router.parse("users/42/books/123")   // (42, 123)
```

@T(00:13:30)
It certainly works, but it’s also a little strange. We have to remember to put leading or trailing slashes on some of the path components otherwise it will not work properly, and this parser is only concentrated on parsing the path of a URL. But there’s a lot more to a URL request than just the path. There are query params, request methods, body data, headers and more.

@T(00:13:50)
We want to be able to parse all of those things so that we can handle more complex URLs such as:

```txt
users/42/books/search?sort=title&direction=asc
```

@T(00:14:03)
or:

```txt
POST users/42/books

{"title": "Blob Cookbook", "category": "Cooking", …}
```

@T(00:14:09)
This is why it’s not correct to express our router as a parser of strings, but rather it needs to be able to parse something more complex. Naively we may think our parsers should literally operate on a Foundation `URLRequest`:

```swift
let request = URLRequest(url: URL(string: "users/42/books?sort=title&direction=asc")!)
```

@T(00:14:23)
But this is a little too unstructured. It would be really difficult to find, extract and consume the “sort=title” fragment from the query string.

@T(00:14:31)
So, this is why our URL routing library does not work on raw URL requests, but rather a new data type called `URLRequestData` that breaks out all parts of a URL into separate fields of a struct that are optimized for parsing:

```swift
public struct URLRequestData: Equatable, _EmptyInitializable {
  public var body: Data?
  public var headers: Fields = .init([:], isNameCaseSensitive: false)
  public var host: Substring?
  public var method: String?
  public var password: String?
  public var path: ArraySlice<Substring> = []
  public var port: Int?
  public var query: Fields = .init([:], isNameCaseSensitive: true)
  public var scheme: String?
  public var user: String?
}
```

@T(00:14:54)
Now URL parsers can operate on this type in a much simpler manner.

@T(00:14:57)
So, going back to our model URL:

```txt
users/42/books/123
```

@T(00:14:49)
This represents a URL request for which only the path has been specified. We can use the `Path` parser to handle this:

```swift
let router = Path {
  "users"
  Digits()
  "books"
  Digits()
}
```

This looks quite similar to what we did previously with the `Parse` entry point, but notice that we no longer need to specify trailing slashes. Each parser listed in this path builder context operates on a single, atomic path component.

@T(00:15:27)
We can give this parser a spin by having it parse a `URLRequestData`, which can be constructed from a string representing the URL’s path for the situations where you don’t need to specify the other parts of the request:

```swift
try router.parse(.init(string: "/users/42/books/123")!)   // (42, 123)
```

@T(00:15:43)
And it easily processed the URL by extracting out the 42 and the 123.

@T(00:15:47)
More conveniently, the router comes with some helper methods for matching a path directly:

```swift
try router.match(path: "/users/42/books/123")   // (42, 123)
```

@T(00:15:59)
But amazingly, we can also print a tuple back into a valid URL path:

```swift
try router.print(((3241, 654342))   // URLRequestData
```

@T(00:16:18)
And just as there are helpers for matching paths, there are also helpers for printing to paths:

```swift
router.path(for: (3241, 654342))   // "/users/42/books/123"
```

@T(00:16:31)
This is looking really cool, but of course in a real world website you want to handle a lot more routes than just a single one. Suppose we also had a route for accessing just the info for a particular user:

```txt
/users/42
```

@T(00:16:44)
This can be represented as a path parser like so:

```swift
Path {
  "users"
  Digits()
}
```

@T(00:16:52)
But we’d like to somehow combine this path parser with the previous one so that we can first try one, and if it fails try the next one.

@T(00:17:00)
The primary tool for doing this kind of work is the `OneOf` parser which is specifically designed to allow running multiple parsers and taking the first one that succeeds.

@T(00:17:15)
However, if we naively do this by just sticking our parsers into a `OneOf` builder context we get a compiler error:

```swift
let router = OneOf {
  Path {
    "users"
    Digits()
  }

  Path {
    "users"
    Digits()
    "books"
    Digits()
  }
}
```

> Error: Static method 'buildBlock' requires the types 'Int' and '(Int, Int)' be equivalent

@T(00:17:19)
And this is because `OneOf` requires every parser inside the closure to have the same input and output type. So, we need some kind of parent type to encapsulate all of the various routes of our site, and enums are great for this:

```swift
enum SiteRoute {
  case user(id: Int)
  case book(userId: Int, bookId: Int)
}
```

@T(00:17:52)
Then we want to transform each parser to bundle up their data into one of these `SiteRoute` cases.

@T(00:17:57)
The tool to do this that works particularly well for URL routing into a case of an enum is a top-level parser known as `Route`:

```swift
Route {
  Path {
    "users"
    Digits()
    "books"
    Digits()
  }
}
```

@T(00:18:12)
And to bundle up the two integers extracted from this path parser into the `.book` case of the `SiteRoute` enum in a parser-printer friendly way we do the following:

```swift
Route(.case(SiteRoute.book)) {
  Path {
    "users"
    Digits()
    "books"
    Digits()
  }
}
```

And similarly for the `user` case:

```swift
Route(.case(SiteRoute.user)) {
  Path {
    "users"
    Digits()
  }
}
```

@T(00:18:36)
Now everything compiles, and when we try parsing we get a `SiteRoute` value:

```swift
try router.match(path: "/users/42/books/123")
// .book(userId: 42, bookId: 123)
try router.match(path: "users/42")
// .user(id: 42)
```

And also cool, constructing a path or URL to a route can be done using a fully formed `SiteRoute` rather than just a tuple:

```swift
try router.path(for: .book(userId: 42, bookId: 123))
// "/users/42/bookId/123"
```

@T(00:19:04)
Let’s add a few more routes to our router to get a feel for how this will scale in practice. Suppose we wanted an endpoint for searching all of a user’s books:

```txt
/users/42/books/search
```

@T(00:19:11)
But to make things interesting we will also allow for some query params that customize how the list of books is shown, such as a field to sort on, a direction to sort, and a result count

```txt
/users/42/books/search?sort=title&direction=asc&count=10
```

@T(00:19:17)
This will give us an opportunity to show how easy it is to coalesce such a complicated piece of data into first class, Swift data types. Let’s start by doing some domain modeling to get a new route into the `SiteRoute` enum.

@T(00:19:29)
We can add a new case to the enum to represent getting the books for a particular user with some options:

```swift
enum SiteRoute {
  case user(id: Int)
  case book(userId: Int, bookId: Int)
  case searchBooks(userId: Int, options: SearchOptions)
}
```

@T(00:19:38)
Here we decided to bundle up the options into its own type since it has quite a bit of data:

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

With the domain modeling done we can start to slowly build up a parser that can pluck out the various parts of the URL and package the data up into the `.books` case of the `SiteRoute` enum.

@T(00:19:48)
To begin, we can construct a `Route` parser with a `.case` conversion that focuses on the `.books` case:

```swift
Route(.case(SiteRoute.searchBooks(userId:options:))) {
}
```

@T(00:19:59)
Then we can parse the path we expect:

```swift
Path {
  "users"
  Digits()
  "books"
  "search"
}
```

@T(00:20:13)
And if you find the newlines to be too verbose you can even put them all on the same line, as long as you separate the parsers by semicolons:

```swift
Path { "users"; Digits(); "books"; "search" }
```

@T(00:20:23)
Next we need to parse the query items from the URL. We expect to be able to get the “sort”, “direction” and “count” fields. To do this we first start with the `Query` parser which acts as an entry point to running many parsers on the query items dictionary inside `URLRequestData`:

```swift
Query {
}
```

@T(00:20:38)
And then in here we can list all the fields we want to parse by specifying the name of the field, and the parser we want to run on the query params value:

```swift
Field(<#name: String#>, <#value: () -> _#>)
```

@T(00:20:51)
For example, the string name can just be “sort” for the sort param:

```swift
Field("sort", <#value: () -> _#>)
```

@T(00:20:56)
And then the parser specified needs to somehow transform the string “title” into a `Options.Sort` case. There is actually a really nice way to do this, and we’ve seen it before on this tour, and that’s to make the `Options.Sort` enum into `String`-representable and case-iterable:

```swift
enum Sort: String, CaseIterable {
  case title, category
}
```

@T(00:21:15)
Once that’s done you can trivially derive a parser for it:

```swift
Field("sort") { SearchOptions.Sort.parser() }
```

@T(00:21:24)
Currently this parser will fail if I can’t find a query param named “sort” or if the `Options.Sort.parser()` fails, and that will cause the entire route to fail. That may not actually be what you want for this query param. It seems that if the param was left off or malformed we could instead default you to something reasonable, like say sorting by title.

@T(00:21:42)
We can do this by using an optional argument to the `Field` initializer that allows us to specify a default in case the parser fails:

```swift
Field("sort", default: .title) { SearchOptions.Sort.parser() }
```

This reads pretty nicely.

@T(00:21:48)
We can essentially do the same for the “direction” field, as long as we make that enum string-representable and case-iterable first:

```swift
enum Direction: String, CaseIterable {
  case asc, desc
}
```

@T(00:22:02)
And now the direction query field parser can be constructed like so:

```swift
Field("direction", default: .asc) { SearchOptions.Direction.parser() }
```

@T(00:22:05)
And we can construct the count query field parser like so:

```swift
Field("count", default: 10) { Digits() }
```

@T(00:22:14)
We are close, but right now the `Query` parser will output a 3-tuple of sort, direction, and count, but we want all of that info bundled up into the `SearchOptions` struct. We can do that by wrapping the `Query` parser in a `Parse` parsers so that we can provide the memberwise conversion:

```swift
Route(.case(SiteRoute.searchBooks)) {
  Path { "users"; Int.parser(); "books"; "search" }
  Parse(.memberwise(SearchOptions.init)) {
    Query {
      Field("sort", default: .title) { Options.Sort.parser() }
      Field("direction", default: .asc) { Options.Direction.parser() }
      Field("count", default: 10) { Digits() }
    }
  }
}
```

@T(00:22:37)
And just like that everything is compiling, and we now have a type safe way of parsing an incoming books request into a route, as well as a type safe way of turning a books route back into a request.

@T(00:22:47)
For example, we could try parsing a books URL with no query parameters to see that the options have all been given defaults:

```swift
try router.match(path: "/users/42/books/search")
// searchBooks(
//   userId: 42,
//   options: Options(sort: .title, direction: .asc, count: 10)
// )
```

@T(00:23:06)
Or we could supply one query param, like say the count, to make sure that the options are set correctly:

```swift
try router.match(path: "/users/42/books?count=100")
// searchBooks(
//   userId: 42,
//   options: Options(sort: .title, direction: .asc, count: 100)
// )
```

And they are.

@T(00:23:13)
So that’s already amazing, but things start looking really amazing when we want to construct a URL to a books endpoint that needs to set various query params. For example, to fetch books for a user that is sorted by category, descending, with a count of 100:

```swift
router.path(
  for: .searchBooks(
    userId: 23423,
   options: .init(sort: .category, direction: .desc, count: 100)
  )
)
// "/users/23423/books?count=100&direction=desc&sort=category"
```

@T(00:23:39)
And amazingly a full URL was created, with query parameters and all. We didn’t have to do any string interpolation, or worry about URL encoding values, or any of the complexities inherent in building complex URLs. We just described some parsers using high level tools, and almost as if by magic the parsers are also printers.

@T(00:24:01)
We get to think about routing at a very high level and let the parsers handle all the low level details. We don’t even need to worry about using URL unfriendly characters that typically can mess up a URL if you are not careful. For example, suppose we added an ampersand to the raw representation of the `category` case:

```swift
enum Sort: String, CaseIterable {
  case title, category = "c&tegory"
}
```

@T(00:24:22)
This is of course a silly thing to do, but even with that change when we print the route we will see that the ampersand is automatically escaped:

```swift
router.path(
  to: .searchBooks(
    userId: 23423,
    options: .init(sort: .category, direction: .desc, count: 100)
  )
)
// "/users/23423/books?count=100&direction=desc&sort=c%26tegory"
```

@T(00:24:31)
If the router had accidentally printed with an unescaped ampersand:

```txt
/users/23423/books?count=100&direction=desc&sort=c&tegory
```

@T(00:24:39)
Then this would have been a bug in the router since if we tried to turn around and parse the “sort” key we would not get “category”, we would just get “c”.

@T(00:24:49)
So it’s pretty amazing how easy it is to parse a complex URL like the the books endpoint.

@T(00:25:02)
Let’s add just one more endpoint so that we can push things a little further. Let’s add a POST endpoint for creating a user that needs to take a JSON payload in the request body:

```txt
POST /users

{"name": "Blob", bio: "Blobbed around the world."}
```

@T(00:25:21)
Let’s first do some domain modeling by adding a new case to the `SiteRoute` to represent the create user endpoint:

```swift
enum SiteRoute {
  case createUser(…)
  …
}
```

@T(00:25:34)
Now we could just list out the fields we want to capture in the enum case:

```swift
case createUser(name: String, bio: String)
```

@T(00:25:42)
But there are few reasons we don’t want to do that. First of all, right now we just have 2 fields but in the future there could be a lot more and this will be unwieldy. But more importantly, we would like to use Swift’s codable feature for automatically turning JSON into data types and turning data types back into JSON, and that works best by having all the fields bundled into a struct.

@T(00:26:09)
So let’s do that:

```swift
enum SiteRoute {
  case createUser(CreateUser)
  …
}
struct CreateUser: Codable {
  let bio: String
  let name: String
}
```

@T(00:26:21)
And now we can start building the route. We can start with the `Route` parser and describe which case of the `SiteRoute` we want to parse into:

```swift
Route(.case(SiteRoute.createUser)) {
}
```

@T(00:26:35)
And then we can use the `Method` parser in order to indicate that we only want to recognized POSTs to this endpoint:

```swift
Route(.case(SiteRoute.createUser)) {
  Method.post
}
```

@T(00:26:51)
It’s worth noting that so far we haven’t needed to specify `Method.get` in any of our other routes, and that is because if the method is not specified in a route we assume you mean it to be a GET.

@T(00:27:04)
Further we should only POST to the “/users” URL, which we can describe with a `Path` parser:

```swift
Route(.case(SiteRoute.createUser)) {
  Method.post
  Path { "users" }
}
```

@T(00:27:11)
And finally we need to somehow parse the body data of the incoming request in order to turn that data into one of those `CreateUser` structs that describes all the information needed to create a user.

@T(00:27:20)
To do this we can use another parser the URL routing library comes with called `Body`:

```swift
Body(<#Conversion#>)
```

@T(00:27:27)
The `Body` parser allows you to supply a conversion for transforming the raw data of the request into something more well-structured, like our `CreateUser` struct.

@T(00:27:35)
Then, we want to convert that into a `CreateUser` struct using a JSON decoder, which we can do with yet another tool the library ships with:

```swift
Body(.json(CreateUser.self))
```

@T(00:27:53)
And amazingly, everything is compiling.

@T(00:27:56)
We may be tempted to give this a spin by running the parser on a simple URL path:

```swift
do {
  try router.match(path: "/users")
} catch {
  print(error)
}
```

```txt
error: unexpected input
 --> input:1:1
1 | GET
  | ^ expected "POST"
```

@T(00:28:20)
But this of course is not going to work because we need to construct a POST request with a JSON data body in order to successfully parse. We can create one of these by hand pretty easily:

```swift
var request = URLRequest(url: URL(string: "/users")!)
request.httpMethod = "POST"
request.httpBody = try JSONEncoder().encode(
  CreateUser(bio: "Blobbed around the world", name: "Blob")
)
try router.match(request: request)
// createUser(
//   CreateUser(bio: "Blobbed around the world", name: "Blob")
// )
```

@T(00:29:08)
And just like that we can parse this quite complex URL request into the `.createUser` case of the `SiteRoute` enum.

@T(00:29:29)
But even cooler, we can also print this route back into a URL request, where it'll automatically set the HTTP method to POST and encode its more structured data into a JSON blob for the request body.

```swift
try router.request(
  for: .createUser(.init(bio: "Blobbed around the world", name: "Blob")
)
// /users
```

@T(00:30:21)
In fact, this single line is doing all the work that we previously did in a more ad hoc fashion to show how parsing worked:

```swift
var request = URLRequest(url: URL(string: "/users")!)
request.httpMethod = "POST"
request.httpBody = try JSONEncoder().encode(
  CreateUser(bio: "Blobbed around the world", name: "Blob")
)
try router.match(request: request)

try router.request(
  for: .createUser(.init(bio: "Blobbed around the world", name: "Blob")
) == request
// true
```

@T(00:30:55)
And so this is pretty amazing that with one single object we are getting the ability to parse and print URLs in a type safe way. But it feels even more amazing when you refactor your router and have the compiler holding your hand every step of the way.

@T(00:31:08)
For example, suppose we didn’t want our URLs to say “users” and “books” and instead use the singular form:

```txt
user/42/book/123
```

@T(00:31:13)
There is only one place to make this change so that both our incoming request parser and outgoing request printer are both immediately updated.

@T(00:31:52)
If our router was not a unified parser-printer we would have to first make the change in the URL recognizer, like say in vapor.

```swift
app.get("user", ":userID", "book", ":bookID") { req in
  …
}
```

@T(00:32:06)
And then we would have to also update everywhere we were manually generating URLs by interpolating strings:

```txt
<a href="user/\(user.id)/book/\(book.id)>\(book.title)</a>
```

@T(00:32:16)
For a large site this could be nearly impossible to do with 100% confidence that you found all places that need to be updated.

@T(00:32:24)
But our unified parser-printer router is immediately in working order, capable of parsing the new URL format:

```swift
try router.match(path: "/user/42")
// user(id: 42)
```

And capable of printing to the new format:

```swift
try router.request(for: .user(id: 3241))
// /user/3241
```

@T(00:32:38)
And if we refactored the routes to change the types, like say the book’s id should be a UUID instead of an integer:

```swift
enum SiteRoute {
  …
  case book(userId: Int, bookId: UUID)
  …
}
```

@T(00:32:47)
Then we instantly get compiler errors letting us know all the places we need to update.

@T(00:32:52)
First we need to update the book route to use a `UUID` parser instead of an integer parser:

```swift
Route(.case(SiteRoute.book)) {
  Path {
    "user"
    Digits()
    "book"
    UUID.parser()
  }
}
```

@T(00:33:03)
And then when printing the book route we need to make sure to provide a UUID rather than an integer:

```swift
try router.request(for: .book(userId: 3241, bookId: UUID())))
// /user/3241/book/998020F4-6F13-47FF-AAB1-404FE204BCC3
```

@T(00:33:12)
We can also update our sample code to parse a book route by providing a UUID in the path rather than an integer:

```swift
try router.match(
  path: "/user/42/book/deadbeef-dead-beef-dead-beefdeadbeef"
)
// book(userId: 42, bookId: DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF)
```

@T(00:33:34)
By leveraging parsers instead of string interpolation we are help prevent bugs that can be very surprising or subtle. For example, it’s quite lucky that interpolating UUID’s into a string does what we want:

```swift
"\(UUID())"   // "E153A706-2531-486B-990C-60F45696740D"
```

@T(00:33:53)
But had we wrapped the UUID in another type in order to embrace type safe identifiers, something we have talked about a bunch of Point-Free and even open sourced a library for accomplishing it called swift-tagged, then we would find that naively interpolating this value into a string does not do what we want:

```swift
struct BookId {
  let id = UUID()
}
"\(BookId())"   // "BookId(id: CCBFDAE0-ABC5-431B-8301-ADC9292F7676)"
```

@T(00:34:11)
Parsers can help us from making these kinds of mistakes.

@T(00:34:14)
It’s incredible to see how easy it is to refactor routes and how the compiler has your back every step of the way. Using this kind of routing system can make it impossible to make common mistakes when dealing with URLs for websites.

## Nested routes

@T(00:34:28)
There is one thing that stands out in our current router, and it became very apparent when we performed that refactor to return “users” and “user” and “books” to “book”. There is a lot of repeated code in the construction of the router. There are 4 different places we parse off the “user” string from the path components, and for every  additional user-related route we introduce, we will have to do the same. This is not going to scale well, especially for a large site, and fortunately there is a way to break up routes into smaller enums.

@T(00:35:05)
Let’s try refactoring our single, large route enum into a bunch of smaller route enums.

@T(00:35:13)
We’ll start by making `SiteRoute` hold a single case for all users-related routes:

```swift
enum SiteRoute {
  case users(UsersRoute)
}
enum UsersRoute {
}
```

@T(00:35:28)
This gives us a single place to put users routes, and anything that isn’t users related can go adjacent to the `.users` case. For example we may have routes for the home page of the site, as well as the “about us” and “contact us” pages:

```swift
enum SiteRoute {
  case aboutUs
  case contactUs
  case home
  case users(UsersRoute)
}

let router = OneOf {
  Route(.case(SiteRoute.aboutUs)) {
    Path { "about-us" }
  }
  Route(.case(SiteRoute.contactUs)) {
    Path { "contact-us" }
  }
  Route(.case(SiteRoute.home))
  …
}
```

@T(00:35:46)
This allows the `SiteRoute` enum to grow without affecting the `UsersRoute` enum.

@T(00:36:33)
Then, in the `UsersRoute` enum we can put whatever routes we want associated with user pages and actions. For example, the `.create` route:

```swift
enum UsersRoute {
  case create(CreateUser)
}
```

@T(00:36:46)
Notice that we can now just call it `.create` instead of `.createUser` because it’s already clear that we are talking about users from the name of the enum. There’s no need to further qualify it.

@T(00:36:53)
The `.create` endpoint is the only route we need that works on the level of “users”, but if we drill in deeper we will have more routes that work on the level of a particular user. To represent this we can have a case that holds the integer id of the user we are focused on, as well as a route enum that holds onto the routes that are important for that particular user:

```swift
enum UsersRoute {
  case create(CreateUser)
  case user(Int, UserRoute)
}
enum UserRoute {
}
```

@T(00:37:18)
We’ve even decided to omit the enum case labels because it’s a lot more clear what this integer corresponds to. This will help make some of our code even more succinct, but if you prefer the labels you can always bring them back.

@T(00:37:35)
This means we can add more and more routes to the `UsersRoute` enum that deals with endpoints related to the entire collection of users, say an endpoint for search users, all without cluttering the `UserRoute` enum which only holds endpoints for for a particular user.

@T(00:37:50)
So now we can ask what endpoints are important for a particular user. We’ve got one endpoint for fetching the user that corresponds to a particular id:

```swift
enum UserRoute {
  case fetch
}
```

@T(00:38:00)
Notice that this can be just called `fetch` with no mention of user because it’s already determined by the surrounding context of the `UserRoute` enum. Also we don’t need to put an ID in the associated values of the case because that is determined in the parent enum:

```swift
case user(Int, UserRoute)
```

@T(00:38:16)
This means every route we add to the `UserRoute` enum will automatically come with an integer ID. We don’t need to repeat it for each case.

@T(00:38:23)
We can even default the `UserRoute` to be fetch in the parent case so that it’s even easier for us to construct these routes:

```swift
case user(Int, UserRoute = .fetch)
```

@T(00:38:31)
In addition to a fetch endpoint for grabbing a particular user we also have routes that are associated to a user’s books, which we will model with yet another enum:

```swift
enum UserRoute {
  case books(BooksRoute)
  case fetch
}
enum BooksRoute {
}
```

@T(00:38:45)
And then this enum can hold all the routes that are specific to things that deal with a user’s books, all without making any changes to the `UserRoute` enum. For example, we could search all of their books with some filtering and sorting applied:

```swift
enum BooksRoute {
  case search(SearchOptions)
}
```

@T(00:38:59)
You can also fetch the details of a particular book determined by its UUID:

```swift
enum BooksRoute {
  case fetch(UUID)
  case search(SearchOptions)
}
```

@T(00:39:03)
However, in the future there may be even more routes that are specific to a particular book for a particular user. For example, you may be able to delete a book, edit a book, or maybe even favorite a book. So, for that reason we prefer to put these routes in their own enum even though currently we only have a single route that we care about:

```swift
enum BooksRoute {
  case book(UUID, BookRoute)
  case search(SearchOptions)
}
enum BookRoute {
  case fetch
}
```

@T(00:39:34)
And just like before we can provide some defaults that make it even easier to construct these routes for a few specific situations:

```swift
enum UserRoute {
  case books(BooksRoute = .search())
  case fetch
}
enum BooksRoute {
  case book(UUID, BookRoute = .fetch)
  case search(SearchOptions = .init())
}
```

@T(00:39:52)
We have now completely refactored our routes to be a deeply nested enum rather than one big flat enum with many cases. And the really cool thing is that constructing a route is like having a conversation with the compiler. You get to choose from a small number of routes in a step-by-step process until you construct a full route.

@T(00:40:08)
For example, we can first decide that we want to construct a route relating to users somehow:

```swift
SiteRoute.users(<#UsersRoute#>)
```

@T(00:40:17)
And then from here we can decide that we want a route that relates to a specific user:

```swift
SiteRoute.users(.user(<#Int#>, <#UserRoute#>))
```

@T(00:40:23)
And then from here we can fill in a user id and decide that we further want a route that deals with the books of this user:

```swift
SiteRoute.users(.user(1, .books(<#BooksRoute#>)))
```

@T(00:40:31)
And then from here we can decide we want a route that deals with a particular book of this user:

```swift
SiteRoute.users(.user(1, .books(.book(<#UUID#>, <#BookRoute#>))))
```

@T(00:40:36)
And finally we can specify the book’s id and the route for the book, which right now the only choice is to fetch the book:

```swift
SiteRoute.users(.user(id: 1, route: .books(.book(UUID()))))
```

@T(00:40:45)
So that’s pretty cool.

@T(00:40:46)
But now we need to get our parser to understand this deeply nested enum. And that just means our router also needs to become deeply nested.

@T(00:40:53)
We can introduce additional routes to out flat `router` for the nested `.users` case. This is a little more complicated because there are a bunch of routes in the `UsersRoute` enum that need to be handled. However, we can defer all of that logic to a `usersRouter` that can be constructed in a similar manner:

```swift
let router = OneOf {
  …

  Route(.case(SiteRoute.users)) {
    usersRouter
  }
}

let usersRouter = OneOf {
}
```

@T(00:41:28)
And then inside this `OneOf` builder context we can handle each of the cases in the `UsersRoute` enum. The create endpoint is the simplest because it doesn’t require any deeper routing:

```swift
let usersRouter = OneOf {
  Route(.case(UsersRoute.create)) {
    Method.post
    Path { "users" }
    Body(.json(CreateUser.self))
  }
}
```

@T(00:41:49)
The `.user` case of the `UsersRoute` is a little more complicated because there are a bunch of routes in the `UserRoute` enum that need to be handled. However, we can defer all of that logic to a `userRouter` that can be constructed in a similar manner:

```swift
let usersRouter = OneOf {
  …

  Route(.case(UsersRoute.user)) {
    Path { "users"; Digits() }
    userRouter
  }
}

let userRouter = OneOf {
}
```

@T(00:41:18)
But before moving on there is already something we can do to clean up a little bit of repetitive work. Notice that in both routes handled by the `usersRouter` we are parsing the “users” path component. In fact, every route that we put in here will have to do the same. If later we have a delete endpoint, and a search endpoint, and more, each one of those routes will need to make sure to parse “users” from the first path component.

@T(00:42:41)
We can remove all mention of the “users” path component from the `usersRoute` and instead move that work to be done a single time to the `siteRouter`:

```swift
let usersRouter = OneOf {
  Route(.case(UsersRoute.create)) {
    Method.post
    Body(.data.json(CreateUser.self))
  }

  Route(.case(UsersRoute.user)) {
    Path { Digits() }
    userRouter
  }
}

let router = OneOf {
  Route(.case(SiteRoute.aboutUs)) {
    Path { "about-us" }
  }
  Route(.case(SiteRoute.contactUs)) {
    Path { "contact-us" }
  }
  Route(.case(SiteRoute.home))

  Route(.case(SiteRoute.users)) {
    Path { "users" }
    usersRouter
  }
}
```

@T(00:42:56)
Now our `usersRouter` can just concentrate on the “users” domain of routing, and the site router can figure out how to plug it into the greater routing system by first parsing off the “users” path component.

@T(00:43:07)
Moving on to the `userRouter`, in here we can handle each case of the `UserRoute` enum. The easiest to deal with is the `.fetch` case since there is nothing more to parse:

```swift
let userRouter = OneOf {
  Route(.case(UserRoute.fetch))
}
```

@T(00:43:18)
Then for the `.books` route we can again defer to a `booksRouter` that we will define, but we can also upfront parse the “books” path component since every route in the `booksRouter` will want that work implicitly done for them:

```swift
let userRouter = OneOf {
  Route(.case(UserRoute.books)) {
    Path { "books" }
    booksRouter
  }

  …
}

let booksRouter = OneOf {
}
```

@T(00:43:37)
And then inside the `booksRouter` we need to handle each case of the `BooksRoute` enum. This includes the `.search` case which allows one to search a user’s books via a couple of query param options:

```swift
let booksRouter = OneOf {
  Route(.case(BooksRoute.search)) {
    Path { "search" }
    Parse(.memberwise(Options.init(sort:direction:count:))) {
      Query {
        Field("sort", default: .title) { Options.Sort.parser() }
        Field("direction", default: .asc) { Options.Direction.parser() }
        Field("count", default: 10) { Digits() }
      }
    }
  }
}
```

@T(00:44:05)
And then we will handle the `.book` case by again deferring to a `bookRouter`:

```swift
let booksRouter = OneOf {
  Route(.case(BooksRoute.book)) {
    Path { UUID.parser() }
    bookRouter
  }
  …
}

let bookRouter = OneOf {
  Route(.case(BookRoute.fetch))
}
```

@T(00:44:34)
We have a few compiler errors but it’s just because when we print a route we need to use the new nested types instead of the old flat style:

```swift
do {
  siteRouter.path(for: .users(.user(3241, .books(.book(UUID())))))
  siteRouter.path(for: .users(.user(3241)))
  siteRouter.path(
    for: .users(
      .user(23423,
      .books(.search(.init(sort: .category, direction: .desc, count: 100)))
    )
  )
} catch {
  print(error)
}
```

@T(00:45:29)
And just like that everything is compiling and running just as before. It’s a little more verbose than previously, but it’s also a lot more descriptive and in a sense easier to use. Rather than seeing a gigantic list of routes to choose from we can be presented with a small list, and then once we choose a route we have another small set of choices, and on and on until we get to a leaf node of the route tree.

@T(00:46:01)
Now that our routes and router are broken up into a lot of small pieces that plug together some really fun stuff happens. First of all, earlier when we demonstrated how the router’s parser and printer stay fully in sync by renaming the “users” path components to “user” and the “books” path components to “book”, we had to make that change in multiple routes.

@T(00:46:19)
Now there is only one single place to make those changes since we perform that parsing in the parent router:

```swift
Route(.case(SiteRoute.users)) {
   // Path { "users" }
  Path { "user" }
  usersRouter
}

…

Route(.case(UserRoute.books)) {
   // Path { "books" }
  Path { "book" }
  booksRouter
}
```

@T(00:46:28)
So that’s already a pretty big win.

@T(00:46:34)
There’s another benefit to breaking up a large router into many smaller, nested routes, and that’s you get a performance boost for free. When routes are listed in one long, flat enum like this:

```swift
enum Routes {
  case route1(...)
  case route2(...)
  case route3(...)
  case route4(...)
  case route5(...)
  …
}
```

@T(00:46:45)
The router has no choice but to linearly go down the list one at a time and try each one.

@T(00:46:50)
But now with routes heavily nested we get opportunities to completely short-circuit entire groups of routes that we know can never succeed. For example, if the URL we are parsing does not begin with the “users” path component then we know we don’t have to try any of the routes nested in the `.users` case. That can be a huge win.

## Next time: Vapor routing

@T(00:47:12)
We have now shown how to use [our parser-printer library](https://github.com/pointfreeco/swift-parsing) to build something that at first blush doesn’t exactly look related to parsing or printing at all. The router we just built is capable for picking apart a URL request to figure out what it represents and then map that to a first class domain that describes every route of a server application.

@T(00:47:28)
Then with very little work, and almost as if by magic, we were able to adapt the router so that it could be used to transform that first class domain of routes back into a URL, which was great for being able to link into various parts of the website. We didn’t have to manually construct URLs by interpolating values into strings, which is error prone and requires extra maintenance to keep everything in sync.

@T(00:47:49)
And the only reason we can use the words “parser”, “printer” and “router” in the same sentence is because our parsing library is completely generic over the type of things it can parse and print.

@T(00:48:01)
So this is looking cool, but to really show the power let’s actually build a small server side application that makes use of this router. We will first show how Vapor, a popular server side framework, handles routing, and then show what our router brings to the table. Not only will we achieve something that is statically type safe and can be used to generate links within the site, but we will even be able to derive an API client from it for free so that we can make requests to the server from an iOS application. 😯

@T(00:48:35)
So, let’s dig in…next time!
