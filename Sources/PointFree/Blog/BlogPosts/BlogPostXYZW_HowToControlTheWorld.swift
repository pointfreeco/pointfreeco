import Foundation

let postXYZW_howToControlTheWorld = BlogPost(
  author: .stephen,
  blurb: """
APIs that interact with the outside world can be unpredictable and difficult to test. Traditional solutions to this problem can be so verbose and cumbersome that we look to code generation or look away entirely. This post goes a bit more in depth with a technique we’ve covered on Point-Free and Stephen talked about at NSSpain.
""",
  contentBlocks: [

    .init(
      content: """
<iframe src="https://player.vimeo.com/video/291588126"
        width="100%"
        height="360"
        frameborder="0"
        webkitallowfullscreen
        mozallowfullscreen
        allowfullscreen></iframe>

---

> APIs that interact with the outside world can be unpredictable and fail. We typically weave calls to these APIs throughout our applications, coupling our code to them tightly, and making it difficult to test and simulate certain flows.

> APIs that interact with the outside world can be unpredictable and difficult to test. Traditional solutions to this problem can be so verbose and cumbersome that we look to code generation or look away entirely. This post goes a bit more in depth with a technique we’ve covered on Point-Free and Stephen talked about at NSSpain.

---

Application state almost always accumulates from many calls to APIs that read from or write out to the outside world. This includes:

  * Fetching the current date or a random number
  * Reading from or writing to disk
  * Reading from or writing to the network, like making an API request or submitting an analytics event
  * Fetching device settings, like language or locale
  * Fetching device state, like orientation and location information

These kinds of calls can account for so much of our application code that we often don't distinguish or disentangle them from code that _doesn't_ interface with the outside world. When unpredictable, unreliable code is coupled to predictable, reliable code, the whole thing becomes unpredictable and unreliable: when code that renders data to screen gets that data from the outside world, that code becomes dependent on the outside world to run at all.

There are many articles out there that cover traditional techniques of controlling these outside world dependencies in Swift and other languages, but we find these solutions to be overly verbose to little benefit, so we'd like to introduce a technique that we've used and refined over many years and many production applications that can be introduced into _any_ code base.

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

Many applications rely on the current date and time, so we find that this is a good first property to add to our `World` struct. In Swift, we fetch the current date and time using a `Date` initializer.
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
It's a function that takes zero arguments and returns a `Date`. This is the shape we'll use to control the date on our `World`.
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
With a minimal struct defined to control a single dependency of our application, we merely need to instantiate it. Traditionally, one may do so in the app delegate or main function, but we're going to define it globally at the module level, instead, right after where our `World` was defined.
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
Now this may all look a little foreign and scary and not very "Swifty," but the benefits will hopefully be clear.

Now how do we fetch the current date?
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
We like the way `Current.date()` reads: it's succinct and loud at the same time. (You could, alternatively, define a `static var` on `World` instead and reference the `World.current.date()`, though we prefer the shorter, readable, if slightly unusual, syntax.)

We can make this call anywhere in our application and we _should_. Wherever we call `Date()` we should update to call `Current.date()` instead. A simple find-and-replace usually suffices.

`Current.date()` has a distinct advantage over `Date()`: because `Current` is a mutable variable, and because `date` is a mutable property, we can swap out its implementation.
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
We can use type inference to make things a bit shorter.
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
By overriding `Current`'s `date` property with a closure that returns a specific date, `Current.date()` will now return this specific date wherever it's called.
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
By throwing this override into our app delegate, our entire app will behave as if it's running at that specific instant.
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
And this holds true in tests, too: we can now freeze time and make previously untestable things testable.

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
This format string depends on not only the device time, but on the calendar, locale, and time zone. Formatters hide these dependencies and look to the outside world by default.
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
In order to control these dependencies, we can add them to our `World`.
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
We can describe our dependencies by assigning the default values, and wherever our code depends on the current calendar, locale, or time zone---explicitly _or_ implicitly, as with our formatters---we should providing the instances that live on `Current`.
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
And this completely controls the formatter so that it produces consistently-formatted strings.

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
And now we can swap out implementations. In a few lines of code, we can see the world from the perspective of a person from Spain observing the Buddhist calendar while on holiday in Oahu.
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
And remember, we can simulate this perspective throughout our entire application with little ceremony. These changes normally require changing simulator settings and simulator restarts.

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
Here we have an API client with at least one property and one method. We could control each one individually on `Current`, but it makes more sense to group them in their own structure that mimics the way `World` controls things. Let’s define another struct:
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
It typically takes a single line to take control of each operation you care about. In this case, we can capture the assignment of our API client's token in a closure that does that assignment, while we can capture the method by referencing the uncalled member.

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
Here we’ve forced the "current user" endpoint to always return a specific user, making our app think we're in a logged-in state.

This is the first time we’re controlling code with callback, so it looks a bit different. The `fetchCurrentUser` method takes a trailing closure that gets called asynchronously with the result of a network request. This trailing closure is the `callback` specified in this override, and we can immediately and synchronouslty call that closure with a result of our choice, no need to worry about it being async.
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
Here's another example where we can easily simulate a specific failure when we hit that endpoint.

Keep in mind that, with both of these overrides, `fetchCurrentUser` no longer hits the network. We can run our application code without an internet connection and still simulate network code.

## FAQ

I'd like to address some audience concerns, because I admit, this is _not_ how we're told we should be controlling this kind of code.

### Isn't `Current` a singleton? Aren't singletons evil?

Many of us have shunned away singletons as a moral imperative, only putting up with those that come from Apple and third-party libraries, and even then we typically do as much as we can to avoid using them as singletons.

Meanwhile, we've kinda done a full-reversal here, where we've created _and embraced_ some kind of mega-singleton!

So are singletons evil? We'd like to propose that they're only evil when they're out of our control.

Most of the time, when we reference a singleton directly in code, we've tightly coupled that code to the outside world. A call to `FileManager.default` probably couples code to the file system.

`Current` doesn't have any of these problems because every property of our singleton can be overridden and controlled.

When we sprinkle singleton use throughout our code bases, they become hard to see all at once

### What about global mutation? That's evil, surely!

Another part of this approach that can make folks uneasy: our singleton is a global mutable variable.

Some of you may even have been wondering: "why are functional programmers condoning global mutation? What’s going on here?"

It's true that mutation is one of the biggest sources of complexity in our applications. It can lead to bugs that are incredibly hard to track down and logic that's much more difficult to reason about, but I don't think that applies here.

We've defined `Current` to be mutable for the purpose of making it as easy as possible to swap out dependencies for development and testing. Doing the same without mutation requires jumping through a _lot_ of hoops.

As such, typically, the world isn't be mutated in production and you can even enforce that with a compiler directive.
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
As long as `Current` is build from a tree of value types, it will not allow you to mutate it in release builds.

### Why structs with properties over protocols? Aren't protocols the "Swifty" way of controlling dependencies?

Don't get us wrong, protocols are wonderful, especially for things like `Sequence` and `Collection`, but when we only have two concrete implementations, it seems to be a bit heavy-handed for the task.

Why? They require a _ton_ of boilerplate! Let's see what it looks like to control our API example using a protocol.

We start by defining an `APIClientProtocol` that describes the interface of `APIClient` that we care about controlling.
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
Then we need to extend the real-world client with this protocol.
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
Then we need to define a mock version, which ends up being pretty verbose: we need to add an extra property to inject the behavior of simulating a logged-in state or failure.
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
Finally, wherever we use this API client, we need to explicitly erase the underlying type with our protocol.
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
Let's compare all of this work to our struct-based approach. Over half the boilerplate goes away!
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

// vs.

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
This boilerplate multiplies with every additional API endpoint we want to control.

We _do_ see, though, that our `World` is still totally compatible with protocols. Our boilerplate-full example from before was still something that could live on the `World` struct, which means we don't have to rewrite existing protocol-based code if we don't want to.

Now, one downside is that closures lose argument labels.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
APIClient.current.fetchUsers(byId: Int) { result in
  // …
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
We can usually simply move the label into the property name.
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
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
Operations with multiple arguments can make things quite a bit more awkward. For example:
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
What do we name this property? Do we include all the argument labels?
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
)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
It's not too bad, but it's certainly awkward. If the types are self-documenting, it's perfectly reasonable to truncate the variable name.
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
But if we're dealing with an `Int` and a bunch of `String`s, we could end up with subtle bugs where we pass email to the name argument and name to the email argument. We can either live with the awkward `updateUserWithIdSetNameEmailStatus`, or extend `API` with a little bit of boilerplate to smooth things over.
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
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
It's up to you! You can add this boilerplate on the rare case you need it, but it's still less boilerplate than the protocol alternative.

### What about dependency injection? Isn't it a better to pass dependencies explicitly?

The more traditional approach to controlling the world is "dependency injection," which is just a fancy way of saying: "passing globals as arguments."

We think dependency injection should be avoided for the same reasons protocols should be avoided: it requires a _lot_ of boilerplate.

Here's a view controller that takes dependencies when it's initialized (something called "constructor injection"):
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
We have boilerplate around new properties for each dependency. We have boilerplate around assigning each property at initialization. And whenever a view controller needs a new dependency, this boilerplate grows.

What if our view controller only needs dependencies to pass to another object, like another view controller?
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
 This isn't uncommon code to find in a real-world app, but it's a _lot_ of boilerplate and enough work and friction that it may prevent you from controlling dependencies at all.

And to top it off, constructor injection doesn't work with storyboards, so you're stuck with another potential runtime gotcha if you use storyboards and forget to set up your dependencies.
""",
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
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
Let's compare with `Current`:
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

Some may argue that in getting rid of the boilerplate we somehow have lost some documentation and have made the contract with dependencies less explicit. We don't think this is the case. We now have a single keyword of sorts, `Current` with a capital C, wherever _actual_ dependencies are being used. In fact, nothing prevented the older, boilerplate-ridden code from going stale. If we stopped using the current date in this `greet` function, the older code could still pass that dependency along but not use it. Here, we're able to clean up as we go! Describing dependencies in properties and in the initializer also don't make explicit _why_ the dependencies are needed. You still have to dig into the actual code to figure out what's going on. There's just a lot more code to wade through.

### What about _x_?

Are there any other concerns you have that we haven't addressed? [Email us](mailto:support@pointfree.co?subject=Current/World%20Question)!

## Conclusion

While untraditional, we hope that it's obvious how this solution of controlling dependencies is superior to the traditional solutions in use today. It also gives us an opportunity to reevaluate deep-seated beliefs we have. We should continuously question and our assumptions. In this case, we think:

  * Singletons can be good (as long as we have a means to control them) and global mutation can be good (when it's limited to development and testing). Blanket statements against singletons and global mutation are fun to make but we were able to find real value in them.

  * Protocols aren't necessarily a good choice to control dependencies. Protocol-oriented programming is all too easy to reach for when a simple value type requires less work.

  * Dependency injection is maybe an overcomplicated solution for controlling dependencies. Dependency injection has a long, complicated history, and maybe we have a better answer to it now.

`World` and `Current` are a simple means of controlling dependencies with minimal boilerplate and just goes to shows that we should always looks to make complicated, over-engineered things simpler. We highly recommend giving it a shot in your code base today!

We'll be covering this approach in further depth in the future, by showing how we can write tests using `Current` and how we can control some even more complicated APIs.
""",
      timestamp: nil,
      type: .paragraph
    ),

    ],
  coverImage: "", // TODO
  id: 20,
  publishedAt: .init(timeIntervalSince1970: 1_539_014_400),
  title: "How to Control the World"
)
