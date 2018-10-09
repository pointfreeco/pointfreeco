import Foundation

let post0021_howToControlTheWorld = BlogPost(
  author: .stephen,
  blurb: """
APIs that interact with the outside world are unpredictable and make it difficult to test and simulate code paths in our apps. Existing solutions to this problem are verbose and complicated, so let's explore a simpler solution by embracing singletons and global mutation, and rejecting protocol-oriented programming and dependency injection.
""",
  contentBlocks: [

    .init(
      content: """
---

> APIs that interact with the outside world are unpredictable and make it difficult to test and simulate code paths in our apps. Existing solutions to this problem are verbose and complicated, so let's explore a simpler solution by embracing singletons and global mutation, and rejecting protocol-oriented programming and dependency injection.

> We've covered this topic on Point-Free [two](/episodes/ep16-dependency-injection-made-easy) [times](/episodes/ep18-dependency-injection-made-comfortable) in the past and Stephen recently [talked about it](https://vimeo.com/291588126) at [NSSpain](https://2018.nsspain.com):

<iframe src="https://player.vimeo.com/video/291588126"
        width="100%"
        height="360"
        frameborder="0"
        webkitallowfullscreen
        mozallowfullscreen
        allowfullscreen></iframe>

---

Application state almost always accumulates from many calls to APIs that read from or write out to the outside world. This includes:

  * Fetching the current date or a random number
  * Reading from or writing to disk
  * Reading from or writing to the network, like making an API request or submitting an analytics event
  * Fetching device settings, like language or locale
  * Fetching device state, like orientation or location information

These kinds of calls can account for so much of our application code that we often don't distinguish or disentangle them from code that _doesn't_ interface with the outside world. When unpredictable, unreliable code is coupled to predictable, reliable code, it all becomes unpredictable and unreliable. When code that renders data to the screen fetches that data from the outside world, that code becomes dependent on the outside world to run at all.

There are many articles out there that cover traditional techniques of controlling these outside world dependencies in Swift (and in other languages), but we find these solutions to be overly verbose to no benefit, so we'd like to introduce a technique that we've used and refined over many years and many production applications that can be introduced into _any_ code base.

## Defining the World

An important part of controlling dependencies is to be able to describe them. The way that we'll describe them is using a simple struct.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
The properties of this struct will describe the dependencies that our application cares about.

Many applications rely on the current date and time, so we find that this is a good first property to add to our `World` struct. In Swift, we fetch the current date and time using a specific `Date` initializer.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
import Foundation
Date() // 2018-10-08 17:42:42 UTC
Date() // 2018-10-08 17:42:45 UTC
Date() // 2018-10-08 17:42:48 UTC
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Every time this initializer is called we get a different value, which means that any code that calls this initializer may behave differently depending on when it's called. What's the shape of this initializer?
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Date.init as () -> Date
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
It's a function that takes zero arguments and returns a `Date`. This is the shape of the property we'll use to control the date on our `World`.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var date: () -> Date
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
The default implementation of this property will wrap a call to the `Date` initializer.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var date: () -> Date = { Date() }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Swift's type inference allows us to describe things even more succinctly.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var date = { Date() }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
With a minimal struct defined to control a single dependency of our application, we merely need to instantiate it. Traditionally, one may be encouraged do so in the app delegate or main function, but we're going to define it globally at the module level.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var date = { Date() }
}

var Current = World()
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Now this all may look a little foreign and scary, and not very "Swifty," but the benefits will hopefully become clear.

How do we fetch the current date?
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.date() // 2018-10-08 17:45:24 UTC
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
We like the way `Current.date()` reads: it's succinct and loud at the same time. While you could, alternatively, define a `static var` on `World` and reference `World.current.date()`, we prefer the slightly unusual syntax precisely _because_ it's unusual: it sticks out! It's also a bit shorter and reads a bit more nicely.

Now we can make this call anywhere in our application and we _should_. Wherever we call `Date()` we should update to call `Current.date()` instead. A simple find-and-replace usually suffices.

Calls to `Current.date()` have a distinct advantage over calls to `Date()`: because `Current` is a mutable variable, and because `date` is a mutable property, we can swap out its implementation at will.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
// Send our application back in time.
Current.date = { Date.distantPast }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
We can even use type inference to make things a bit shorter.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.date = { .distantPast }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
By overriding `Current`'s `date` property with a closure that returns a specific date, `Current.date()` will now return this specific date wherever and whenever it's called.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.date() // 0001-01-01 00:00:00 UTC
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
We've fixed `date` to return the same date every time, which means any of our application code should behave in a consistent manner.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.date() // 0001-01-01 00:00:00 UTC
Current.date() // 0001-01-01 00:00:00 UTC
Current.date() // 0001-01-01 00:00:00 UTC
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
If we throw this override into our app delegate, our entire app will behave as if it's running at that specific instant.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions:
  [UIApplicationLaunchOptionsKey: Any]?
) -> Bool {

  Current.date = { Date(timeIntervalSinceReferenceDate: 0) }

  return true
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
This holds true in tests, too: we can now freeze time and make previously untestable things testable.

# Adding to the World

Just because code calls `Current.date()` doesn't mean it's completely controlled. For example:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
let formatter = DateFormatter()

formatter.dateStyle = .short
formatter.timeStyle = .short

formatter.string(from: Current.date())
// "10/8/18, 1:30 PM"
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
This formatted string depends on not only the device time, but on the calendar, locale, and time zone. Formatters hide these dependencies! They look to the outside world by default.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
formatter.calendar // Calendar
formatter.locale // Locale
formatter.timeZone // TimeZone
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
In order to control these dependencies, we simply add them to our `World` struct.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var calendar = Calendar.autoupdatingCurrent
  var date = { Date() }
  var locale = Locale.autoupdatingCurrent
  var timeZone = TimeZone.autoupdatingCurrent
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
We can describe them by assigning default values, and wherever our code depends on the current calendar, locale, or time zone---explicitly _or_ implicitly, as with our formatters---we should providing the instances that live on `Current`.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
formatter.calendar = Current.calendar
formatter.locale = Current.locale
formatter.timeZone = Current.timeZone
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
This code completely controls the formatter so that it produces consistently-formatted strings.

We can even extend `World` to make it responsible for producing obedient formatters, reducing the amount of work at each call site that depends on a formatter.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
extension World {
  func dateFormatter(
    dateStyle: DateFormatter.DateStyle = .none,
    timeStyle: DateFormatter.TimeStyle = .none
    )
    -> DateFormatter {

      let formatter = DateFormatter()

      formatter.dateStyle = dateStyle
      formatter.timeStyle = timeStyle

      formatter.calendar = self.calendar
      formatter.locale = self.locale
      formatter.timeZone = self.timeZone

      return formatter
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
And now, in a few lines of code, we can see the world from the perspective of a person from Spain observing the Buddhist calendar while on holiday in Oahu.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.dateFormatter(dateStyle: .long, timeStyle: .long)
  .string(from: Current.date())
// "October 8, 2018 at 1:35 PM"

Current.calendar = Calendar(identifier: .buddhist)
Current.locale = Locale(identifier: "es_ES")
Current.timeZone = TimeZone(identifier: "Pacific/Honolulu")!

Current.dateFormatter(dateStyle: .long, timeStyle: .long)
  .string(from: Current.date())
// "8 de octubre de 2561 BE, 13:35"
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
And remember, we can simulate this perspective throughout our entire application with little ceremony: just a few extra lines in our app delegate. Seeing this perspective normally requires changing simulator settings and simulator restarts.

# More Complex Dependencies

Controlling the date and device settings is relatively straightforward, but how do we control a more complex dependency, like an API client? For example:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
APIClient.shared.token = token
APIClient.shared.fetchCurrentUser { result in
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Here we have an API client with at least one property and one method. We could control each one individually on `Current`, but it makes more sense to group them in their own structure that mimics the way the `World` struct controls things. Let’s define another struct that is responsible for this subset of dependencies:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct API {
  var setToken = { APIClient.shared.token = $0 }
  var fetchCurrentUser = APIClient.shared.fetchCurrentUser
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
It typically takes a single line to take control each operation you care about. In this case, we can capture the assignment of our API client's token in a closure that does that assignment, while we can capture the method that fetches the current user by referencing the method without calling it.

This grouping becomes another property on `World`.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var api = API()
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
As long as our application code exclusively uses `Current.api` and not `APIClient.shared`, we can swap out implementations and simulate various states.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
// Simulate being logged-in as a specific user
Current.api.fetchCurrentUser = { callback in
  callback(.success(User(name: "Blob")))
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Here we’ve forced the "current user" endpoint to always return a specific user, making our app think that we're in a logged-in state.

This is the first time we’re controlling code with a callback, so it looks a bit different. The `fetchCurrentUser` method takes a trailing closure that gets called asynchronously with the result of a network request. This trailing closure is the `callback` specified in our override, and we can immediately and synchronouslty call that closure with a result of our choice, no need to worry about it being async.

Here's another example where we can easily simulate a specific failure when we hit an endpoint:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
// Simulate specific errors
Current.api.fetchCurrentUser = { callback in
  callback(.failure(APIError.userSuspended))
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
And now our application will consistently behave as if the current user has been suspended.

Keep in mind that, with both of these overrides, `fetchCurrentUser` no longer hits the network. We can run our application code without an internet connection and still simulate network code.

## But Wait---or, Frequently Asked Questions (FAQ)

We'd like to address some common concerns. This is certainly _not_ how we're told we should be controlling dependencies, but we believe that it stands up against any scrutiny.

### Isn't `Current` a singleton? Aren't singletons evil?

Many of us have shunned away singletons as a moral imperative, only putting up with those that come from Apple and third-party libraries, and even then we typically do as much as we can to avoid using them as singletons, but we've done a full-reversal here: we've created _and embraced_ a mega-singleton!

Are singletons evil? We'd like to propose that they're only evil when they're out of our control. Most of the time, when we reference a singleton directly in code, we've tightly coupled that code to the outside world. A call to a singleton like `FileManager.default` most likely couples that code to the file system and it can be quite cumbersome to temporarily decouple it.

`Current` doesn't have any of the problems traditional singletons have because every property of `Current` can be overridden and controlled, typically in a single, additional line of code. `Current` also unifies all of our calls to other singletons in a single, controllable package. We typically sprinkle singleton use throughout our code, making them hard to see all at once.

### What about global mutation? That's evil, surely!

Another part of our approach that can make folks uneasy is that our singleton is a global mutable variable. Some of you may even have been wondering: "Why are functional programmers condoning global mutation? What’s going on here?"

It's true that mutation is one of the biggest sources of complexity in code. It can lead to bugs that are incredibly hard to track down and logic that's much more difficult to reason about, but we don't think that concern applies here.

We've defined `Current` to be mutable for the purpose of making it as easy as possible to swap out dependencies for development and testing. Doing the same without mutation requires jumping through a _lot_ of hoops.

As such, typically, the world isn't mutated in release builds and you can even enforce that with a compiler directive.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
#if DEBUG
var Current = World()
#else
let Current = World()
#endif
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
As long as `Current` is built from a tree of value types, the compiler will not allow you to mutate it in release builds.

### Why structs with properties and not protocols? Aren't protocols the "Swifty" way of controlling dependencies?

Don't get us wrong, protocols are wonderful, especially when they have many conformances, as with `Sequence` and `Collection`, but when we only have two concrete implementations, it seems to be a bit heavy-handed for the task. Why? Protocols require a _ton_ of boilerplate!

Let's see what it looks like to control our API example using a protocol. We'll start by defining an `APIClientProtocol` that describes the interface of `APIClient` that we care about controlling.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
protocol APIClientProtocol {
  var token: String? { get set }
  func fetchCurrentUser(_ completionHandler: (Result<User, Error>) -> Void)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Next, we need to extend the real-world client with this protocol.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
extension APIClient: APIClientProtocol {}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
After that, we need to define a mock version, which ends up being pretty verbose: we need to add an extra property to inject the behavior of simulating a logged-in state or failure.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
class MockAPIClient: APIClientProtocol {
  var token: String?

  var currentUserResult: Result<User, Error>?
  func fetchCurrentUser(_ completionHandler: (Result<User, Error>) -> Void) {
    completionHandler(self.fetchCurrentUserResult!)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Finally, wherever we use this API client, we need to explicitly erase the underlying type with our protocol. For example, if we used the `World` as a more traditional container:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct World {
  var api: APIClientProtocol = APIClient.shared
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
If we look at it all at once, it's a lot of work:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
protocol APIClientProtocol {
  var token: String? { get set }
  func fetchCurrentUser(_ completionHandler: (Result<User, Error>) -> Void) -> Void
}

extension APIClient: APIClientProtocol {}

class MockAPIClient: APIClientProtocol {
  var token: String?

  var currentUserResult: Result<User, Error>?
  func fetchCurrentUser(_ completionHandler: (Result<User, Error>) -> Void) {
    completionHandler(self.fetchCurrentUserResult!)
  }
}

struct World {
  var api: APIClientProtocol = APIClient.shared
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Let's compare all of this work to our struct-based approach:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct API {
  var setToken = { APIClient.shared.token = $0 }
  var fetchCurrentUser = APIClient.shared.fetchCurrentUser
}

struct World {
  var api = API()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Only 7 lines of code instead of 15! Over half the boilerplate goes away, and this boilerplate multiplies with every additional API endpoint we want to control.

It's interesting to note here, though, that our `World` struct is still totally compatible with protocols. The protocol-based, boilerplate-filled example is still something that can live on the `World` struct. This means we don't have to rewrite existing protocol-based code if we don't want to.

The main downside in using struct properties over protocol functions is that closures can't have argument labels. For example, given an `APIClient` method with an argument label:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
APIClient.current.fetchUser(byId: Int) { result in
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Our approach would have to move the label name into the property name.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct API {
  var fetchUserById = APIClient.current.fetchUser(byId:)
  // …
}

Current.fetchUserById(1)
// vs.
APIClient.current.fetchUser(byId: 1)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Operations with multiple arguments can make things quite a bit more awkward. For example, an `updateUser` function with multiple named arguments:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
APIClient.current.updateUser(
  withId: 1,
  setName: "Blob",
  email: "blob@pointfree.co",
  status: "active"
) { result in
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
What would we name this property if we were to control it? Do we include all the argument labels?
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
struct API {
  var updateUserWithIdSetNameEmailStatus = APIClient.current.updateUser
  // …
}

Current.api.updateUserWithIdSetNameEmailStatus(
  1, "Blob", "blob@pointfree.co", "active"
) {
  // …
}
// vs.
APIClient.current.updateUser(
  withId: 1, setName: "Blob", email: "blob@pointfree.co", status: "active"
) {
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
While the difference isn't too bad, it's certainly awkward.

When the argument types are self-documenting, it's perfectly reasonable to truncate the variable name.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
Current.api.updateUser
// (User.Id, User.Name, User.Email, User.Status, (Result<User, Error>) -> Void)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
But if we're dealing with an `Int` and a bunch of `String`s, we could end up with subtle bugs where we pass an email to the name argument or a name to the email argument. It seems most prudent to either live with the awkward and verbose `updateUserWithIdSetNameEmailStatus` property, or extend `API` with a little bit of boilerplate to smooth things over at the call site.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
extension API {
  func updateUser(
    withId id: Int,
    setName name: String,
    email: String,
    status: String
    completionHandler: @escaping (Result<User, Error>) -> Void
    ) {

    self.updateUserWithIdSetNameEmailStatusCompletionHandler(
      id, name, email, status, completionHandler
    )
  }
}

Current.api.updateUser(
  withId: 1, setName: "Blob", email: "blob@pointfree.co", status: "active"
) {
  // …
}
// vs.
APIClient.current.updateUser(
  withId: 1, setName: "Blob", email: "blob@pointfree.co", status: "active"
) {
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
It's up to you! You can always add this boilerplate on the rare case that you need it and it's _still_ less boilerplate than the protocol alternative.

### What about dependency injection? Isn't it better to pass dependencies explicitly?

The more traditional approach to controlling the world is with "dependency injection," which is a fancy way of saying: "passing globals as arguments."

We think dependency injection should be avoided for the same reasons protocols should be avoided: it requires a _lot_ of boilerplate.

Here's a view controller that takes dependencies at initialization (something called "constructor injection"):
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
class MyViewController: UIViewController {
  let api: APIClientProtocol
  let date: () -> Date
  let label = UILabel()

  init(_ api: APIClientProtocol, _ date: () -> Date) {
    self.api = api
    self.date = date
  }

  func greet() {
    self.api.fetchCurrentUser { result in
      if let user = result.success {
        self.label.text = "Hi, \\(user.name)! It’s \\(self.date())."
      }
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
There's a bunch of boilerplate here. We have boilerplate that declares properties for each dependency. We have boilerplate that declares initializer arguments for each dependency. We have boilerplate that assigns these initializer arguments to properties for each dependency. And whenever a view controller needs an additional dependency, each instance of boilerplate grows.

Sometimes a view controller only needs dependencies to pass them to another object, like another view controller. What does this look like?
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
class MyViewController: UIViewController {
  let api: APIClientProtocol
  let date: () -> Date

  init(_ api: APIClientProtocol, _ date: () -> Date) {
    self.api = api
    self.date = date
  }

  func presentChild() {
    let childViewController = ChildViewController(
      api: self.api, date: self.date
    )
  }
}

class ChildViewController: UIViewController {
  let api: APIClientProtocol
  let date: () -> Date
  let label = UILabel()

  init(_ api: APIClientProtocol, _ date: () -> Date) {
    self.api = api
    self.date = date
  }

  func greet() {
    self.api.fetchCurrentUser { result in
      if let user = result.success {
        self.label.text = "Hi, \\(user.name)! It’s \\(self.date())."
      }
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
More boilerplate! It's an extra layer that we need to thread new dependencies through.

Boilerplate like this doesn't go unnoticed. People have come up with all sorts of ways to organize this boilerplate, like creating protocols per dependency in order to expose just the dependencies needed.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
protocol APIClientProvider {
  var api: APIClientProtocol { get }
}

protocol DateProvider {
  func date() -> Date
}

extension World: APIClientProvider, DateProvider {}

class MyViewController: UIViewController {
  typealias Dependencies = APIClientProvider & DateProvider

  let label = UILabel()
  let dependencies: Dependencies

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func greet() {
    self.dependencies.api.fetchCurrentUser { result in
      if let user = result.success {
        self.label.text = "Hi, \\(user.name)! It’s \\(self.dependencies.date())."
      }
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
This kind of code isn't uncommon to find in a real-world app, and it's even _more_ boilerplate than our first example! This is enough additional work and friction that it may prevent folks from controlling dependencies at all.

To top it off, constructor injection doesn't work with storyboards, so you're stuck with another potential runtime gotcha if you use storyboards and forget to set up your dependencies.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
protocol APIClientProvider {
  var api: APIClientProtocol { get }
}

protocol DateProvider {
  func date() -> Date
}

extension World: APIClientProvider, DateProvider {}

class MyViewController: UIViewController {
  typealias Dependencies = APIClientProvider & DateProvider

  var dependencies: Dependencies!

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "child" {
      let childViewController = segue.destinationViewController as! ChildViewController

      // Without this line we have a crash in wait!
      childViewController.dependencies = self.dependencies
    }
  }
}

class ChildViewController: UIViewController {
  typealias Dependencies = APIClientProvider & DateProvider

  var dependencies: Dependencies!
  @IBOutlet var label: UILabel!

  func greet() {
    self.dependencies.api.fetchCurrentUser { result in
      if let user = result.success {
        self.label.text = "Hi, \\(user.name)! It’s \\(self.dependencies.date())."
      }
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
What would this last, most complicated example look like with `Current`:
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
class MyViewController: UIViewController {}

class ChildViewController: UIViewController {
  @IBOutlet var label: UILabel!

  func greet() {
    Current.api.fetchCurrentUser { result in
      if let user = result.success {
        self.label.text = "Hi, \\(user.name)! It’s \\(Current.date())."
      }
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
The boilerplate completely disappears. Parent view controllers don't need to worry about passing dependencies along. Storyboard glue code disappears. We're down to the bare essentials.

Some may feel that constructor injection makes an object's contract with dependencies explicit, and that using `Current`, instead, somehow makes dependencies _less_ explicit. We don't think this is the case. We now have a single keyword of sorts, `Current` with a capital C, that occurs wherever _actual_ dependencies are being used. The extra boilerplate of properties, initializer arguments, and initializer assignment do nothing to guarantee that these dependencies are used: the child view controller could stop using a dependency and we could continue to pass a dependency along. We've found stale dependencies like this in many code bases that we've worked on that use constructor injection.

In the end, in order to truly know how an object uses dependencies, you need to read the code and find the uses. This is true for both approaches, but one approach has a lot less code that you need to read.

### What about _x_?

Are there any other concerns you have that we haven't addressed? [Email us](mailto:support@pointfree.co?subject=Current/World%20Question)!

## Conclusion

While unconventional, we hope that it's obvious that this solution of controlling dependencies is superior to the traditional solutions in use today. It also gives us an opportunity to reevaluate deep-seated beliefs we may have. We should continuously question our assumptions. In this case, we found that:

  * Singletons can be good (as long as we have a means to control them) and global mutation can be good (when it's limited to development and testing). Blanket statements against singletons and global mutation are fun to make, but we were able to find real value in using them.

  * Protocols aren't necessarily a good choice to control dependencies. Protocol-oriented programming is all too easy to reach for when a simple value type requires less work.

  * Dependency injection might be an overcomplicated solution for controlling dependencies. Dependency injection has a long, complicated history, but we may have a better solution now.

`World` and `Current` are a simple means of controlling dependencies with minimal boilerplate and studying them reinforces that we should always looks to make complicated, over-engineered code simpler. We highly recommend giving it a shot in your code base today!

We'll be diving deeper into this approach in the future. We'll show what it looks like to write tests by swapping `Current` implementations, and we'll demonstrate what it looks like to control even more complicated APIs.
""",
      timestamp: nil,
      type: .paragraph
    ),

    ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0021-how-to-control-the-world/poster.jpg",
  id: 21,
  publishedAt: .init(timeIntervalSince1970: 1_539_093_600),
  title: "How to Control the World"
)
