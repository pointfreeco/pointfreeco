## Introduction

@T(00:00:05)
So that gives a slight glimpse into how we share code between client and server. Some of the easiest things to share are data types and models, such as the puzzle and move types, as well as pure functions that do simple transformations of data, such as the verification function.

@T(00:00:31)
And all of that is already pretty powerful, but there is an even cooler chunk of code being shared.

@T(00:00:41)
The entire server routing system and the entire client-side API service are completely unified. What we mean is the code that parses incoming requests on the server is the exact same code that powers an API client in the iOS app for making network requests to the server. The moment we add a new route to the server we instantly get the ability to make requests to that route. There’s no need to read the server code or bother a colleague to figure out how a request can be constructed. It’s also impossible to construct an incorrect request. We have compile time guarantees that we didn’t accidentally misspell something in the URL request, or use camel case for a URL path that should have been kebab case, or used a GET request when it should have been a POST request, amongst a whole slew of other problems one can have when trying to build API clients.

@T(00:01:30)
We want to give a tour of how this code works because it’s honestly amazing to see, and is going to be a big topic we dive into soon on Point-Free.

## A router and API client in one

@T(00:01:46)
Let’s start by switching our active target to `ServerRouter`. This module contains all the code necessary to both parse an incoming request on the server-side and to generate an outgoing request for the iOS app. It also has a playground in the module, which thanks to recent improvements in SPM it’s now possible to run playgrounds in packages. So let’s open `Router.playground`.

@T(00:02:18)
There’s already a little bit of code in here for importing the libraries necessary to play around with the router and it constructs a router by supplying some dependencies necessary for the router to implement its logic:

```swift
import Foundation
import ServerRouter
import SharedModels

let router = ServerRouter.router(
  date: Date.init,
  decoder: JSONDecoder(),
  encoder: JSONEncoder(),
  secrets: ["deadbeef"],
  sha256: { $0 }
)
```

@T(00:02:27)
Some these dependencies aren’t too surprising, like the JSON decoder encoder. There are certain parts of the router that needs to deserialize and serialize the body of a POST request, and so we inject these objects so that we can be consistent in how we do that work. The other 3 are not so obvious, but they are necessary for signing certain API requests so that they cannot be tampered with.

@T(00:02:48)
This single value is capable of simultaneously routing incoming server side requests and constructing outgoing client side requests. Let’s demonstrate this by giving it a spin.

@T(00:02:59)
Routing an incoming request means a raw `URLRequest` comes in and we want to parse and transform it into a first party type that we can then used to perform the actual server logic. This is basically the same principle that many of our viewers have probably employed in order to support deep linking in their applications.

@T(00:03:16)
The first class data that we want to transform into is known as `ServerRoute`, and we can hop to `ServerRoute.swift` to check it out:

```swift
public enum ServerRoute: Equatable {
  case api(Api)
  case appSiteAssociation
  case appStore
  case authenticate(AuthenticateRequest)
  case demo(Demo)
  case download
  case home
  case pressKit
  case privacyPolicy
  case sharedGame(SharedGame)

  …
}
```

@T(00:03:22)
It’s basically a big ole enum of every single part of the site or API one can interact with. Some of these cases lead to further nested enums, such as `Api`, `Demo` and `SharedGame`.

@T(00:03:38)
Let’s try creating a request that will map to one of these cases via the router. We can start simple. The homepage is probably just a request to the root of the isowords website, so let's use the `match` method to parse out such a request. There are multiple overloads of the `match` method, including one that takes a full `URLRequest`, which includes the URL, request method, headers, and body, and some helpers that simply take a `URL` or even url `String`. Let's keep things simple:

```swift
router
  .match(string: "https://www.isowords.xyz/")
// .home
```

@T(00:04:23)
And indeed the root URL matches the home route.

@T(00:04:26)
The press kit is also probably something simple, maybe just `/press-kit`:

```swift
router
  .match(string: "https://www.isowords.xyz/press-kit")
// .pressKit
```

@T(00:04:32)
And indeed it is.

@T(00:04:37)
Let’s now try something a little more complicated. Let’s construct the API request that fetches today’s daily challenge results so far, which is what is loaded on the home screen to populate the module at the top that says “X people have already played.”

@T(00:04:52)
I think I remember what most of this route looks like so I’m going to give it a shot. I know that all the API requests are nested inside the `/api` path component name space, so I’ll start there:

```swift
router
  .match(string: "https://www.isowords.xyz/api/")
// nil
```

@T(00:05:03)
Now currently this returns `nil` because there is no case of the route that represents the root of the `/api` path. But I further know that daily challenge routes are in the `/daily-challenges` path component:

```swift
router
  .match(string: "https://www.isowords.xyz/api/daily-challenges")
// nil
```

@T(00:05:17)
This still returns `nil` because we haven’t yet constructed a request that exactly represents one of our routes. To get the results for just today’s daily challenge we need to further tack on the path component `/today`:

```swift
router
  .match(string: "https://www.isowords.xyz/api/daily-challenges/today")
// nil
```

@T(00:05:28)
OK this is still `nil`, but it’s only because there are some required query parameters that also need to be supplied. Most importantly every API request must have an access token attached, which is assigned to every player upon authentication in the game. We can provide this in the query params:

```swift
router
  .match(string: "https://www.isowords.xyz/api/daily-challenges/today?accessToken=deadbeef-dead-beef-dead-beefdeadbeef")
// nil
```

@T(00:05:53)
And finally we also need to provide a language parameter so that we know for which language we are fetching daily challenge results. Currently isowords is only available in English but we hope to soon be available in other languages, and that will mean we will need to segment scores and leaderboards by language. We can provide this in the query params just like the access token:

```swift
router
  .match(string: "https://www.isowords.xyz/api/daily-challenges/today?accessToken=deadbeef-dead-beef-dead-beefdeadbeef&language=en")
// .api(
//   Api(
//     accessToken: DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF,
//     isDebug: false,
//     route: .dailyChallenge(.today(language: .en))
//   )
// )
```

@T(00:06:18)
And we finally get a non-`nil` value, which means our router has successfully recognized the request, and it’s this deeply nested enum value that points to an `.api` route, and inside there it points to a `.dailyChallenge` route, and inside there it points to the `.today` route with the language `.en`.

@T(00:06:38)
So this is what powers routing on our server. Whenever a request comes in we use the `.match` method on the router to figure out what route the request represents, and then we switch on the massive enum to figure out what part of the server logic to execute, not too unlike how we implement reducers in the Composable Architecture.

@T(00:06:56)
But that’s only half the responsibilities of the router. The other half is to generate requests that can be used to make requests to the API. This is extremely important because as you can see from what we just did, some of our routes are quite complicated and there’s a lot to get right. Rather than munge together a raw `URLRequest` from scratch it would be far better to construct one of those `ServerRoute` enum values, which is statically type checked by the compiler, and let the router worry about turning it into a request.

@T(00:07:25)
And luckily that’s exactly what our router does. The `.request(for:)` method on the router takes a `ServerRoute` value and returns a request:

```swift
router
  .request(for: <#ServerRoute#>)
```

@T(00:07:38)
We can even just do `.` in here and let autocomplete show us everything that’s possible to request. Doing that we see all the choices we saw in the `ServerRoute` file a moment ago:

```swift
api
appSiteAssociation
appStore
authenticate
demo
download
home
pressKit
privacyPolicy
sharedGame
```

@T(00:07:44)
Let’s choose the `.api` route:

```swift
router
  .request(for: .api(<#ServerRoute.Api#>))
```

@T(00:07:47)
Now we have to choose a particular `.api` route, which we can explore again by just typing `.` and letting autocomplete show us the options:

```swift
.init(
  accessToken: <#AccessToken#>,
  isDebug: <#Bool#>,
  route: <#ServerRoute.Api.Route#>
)
```

@T(00:07:55)
Looks like we only have one choice, and that’s because to construct an `.api` request we have to fill in some required fields before we are allowed to choose from all of the API’s routes. Let’s just stick some data in for these fields:

```swift
router
  .request(
    for: .api(
      .init(
        accessToken: .init(rawValue: UUID()),
        isDebug: false,
        route: <#ServerRoute.Api.Route#>
      )
    )
  )
```

@T(00:08:16)
Now when we autocomplete on this `.api` route we get some choices:

```swift
changelog
config
currentPlayer
dailyChallenge
games
leaderboard
push
sharedGame
verifyReceipt
```

@T(00:08:18)
Let’s go into the `.dailyChallenge` route since that’s what we experimented with a moment ago:

```swift
router
  .request(
    for: .api(
      .init(
        accessToken: .init(rawValue: UUID()),
        isDebug: false,
        route: .dailyChallenge(<#ServerRoute.Api.Route.DailyChallenge#>)
      )
    )
  )
```

@T(00:08:22)
And let’s see what our choices are to fill this in:

```swift
results
start
today
```

@T(00:08:24)
The `.today` route seems like a good candidate for loading today’s results:

```swift
router
  .request(
    for: .api(
      .init(
        accessToken: .init(rawValue: UUID()),
        isDebug: false,
        route: .dailyChallenge(.today(language: <#Language#>))
      )
    )
  )
```

@T(00:08:29)
And now we’re just left with filling in the language, which we can do with English:

```swift
router
  .request(
    for: .api(
      .init(
        accessToken: .init(rawValue: UUID()),
        isDebug: false,
        route: .dailyChallenge(.today(language: .en))
      )
    )
  )
```

@T(00:08:32)
We have now filled in all the holes for this route, and the playground is now compiling. It is amazing that we did not even have compiling code until all the holes were filled. That is giving us static, compile time guarantees that our route has been constructed correctly.

@T(00:08:46)
And even better, the router has returned a fully constructed `URLRequest` that can be used to fire off a network request to load data from the server:

```swift
// api/daily-challenges/today?accessToken=3EE1B177-CCCD-4E75-838B-B5F6AF5068F5&language=en
```

@T(00:09:03)
Let’s try a more complicated route. What if we wanted to construct the API request that submits a score to the leaderboard. Turns out this one single route supports a lot of different use cases. We can start by constructing the `.games` route and then the `.submit` route:

```swift
router.request(
  for: .api(
    .init(
      accessToken: .init(rawValue: UUID()),
      isDebug: false,
      route: .games(
        .submit(<#ServerRoute.Api.Route.Games.SubmitRequest#>)
      )
    )
  )
)
```

@T(00:09:27)
To construct a `SubmitRequest` we have to supply a `gameContext` and an array of `moves`, which are the actual moves used to play the game:

```swift
.init(
  gameContext: <#ServerRoute.Api.Route.Games.SubmitRequest.GameContext#>,
  moves: <#Moves#>
)
```

@T(00:09:36)
To construct a `GameContext` we have to choose one of the types of games that we support:

```swift
dailyChallenge
shared
solo
turnBased
```

@T(00:09:42)
Each of these types of games provides a different set of data in order to submit to the leaderboards. Let’s go with `.solo` for the purpose of this demonstration:

```swift
gameContext: .solo(
  <#ServerRoute.Api.Route.Games.SubmitRequest.GameContext.Solo#>
),
```

@T(00:09:50)
To construct one of these `Solo` values we have to specify all of the important parts of a solo game, including `gameMode` (which is `.timed` or `.unlimited`), `language` (which is just English for now), and the `puzzle` is the full description of the isowords cube that was played:

```swift
.init(
  gameMode: <#GameMode#>,
  language: <#Language#>,
  puzzle: <#ArchivablePuzzle#>
)
```

@T(00:09:57)
Let’s just fill in some data for these arguments. For the puzzle we can use a `.mock` that we have prepared in the `SharedModels` module:

```swift
gameContext: .solo(
  .init(
    gameMode: .timed,
    language: .en,
    puzzle: .mock
  )
)
```

@T(00:10:09)
And finally we have to provide an array of `moves`. We also have mocks for the `Move` type, so let’s use em:

```swift
moves: [
  .highScoringMove,
  .removeCube
]
```

@T(00:10:23)
So all in all this is a pretty intense way of constructing an API request:

```swift
router.request(
  for: .api(
    .init(
      accessToken: .init(rawValue: UUID()),
      isDebug: false,
      route: .games(
        .submit(
          .init(
            gameContext: .solo(
              .init(
                gameMode: .timed,
                language: .en,
                puzzle: .mock
              )
            ),
            moves: [
              .highScoringMove,
              .removeCube
            ]
          )
        )
      )
    )
  )
)
```

@T(00:10:39)
However, everything is fully static and type checked by the server. We do not have to guess at at which of these parameters belong in the query string, or which are apart of the request body, or perhaps maybe some of these even go in the headers. All of that is hidden from us and not important at all. The router takes care of it for us. All we have to do is provide all of these arguments and everything will just work in the background.

@T(00:10:58)
This is pretty amazing. We are able to keep the server and client in sync automatically, and we simultaneously make it a breeze to route requests on the server and construct requests on the API client. It can honestly be pretty mind blowing to simply add a new route or add extra data to an existing route and instantly see all the spots in both the server and client that need to be updated, and then everything just works.

@T(00:11:21)
This is in stark contrast with how we usually do API clients in our iOS applications. If we’re lucky someone from the backend team will have a spec or some kind of documentation so that we know what endpoints are available to hit, and if we’re not lucky we may have to just message a colleague for details or search through the server code ourselves.

@T(00:11:39)
To see all the places in the client we are making use of this machinery we just have to do a project search for `environment.apiClient`. We’ll see dozens of spots where we are making API requests.

@T(00:11:53)
For example, in the `DailyChallengeView.swift` file we make an API request to load today’s results:

```swift
case .onAppear:
  return .merge(
    environment.apiClient.apiRequest(
      route: .dailyChallenge(.today(language: .en)),
      as: [FetchTodaysDailyChallengeResponse].self
    )
    .receive(on: environment.mainRunLoop.animation())
    .catchToEffect()
    .map(DailyChallengeAction.fetchTodaysDailyChallengeResponse),

    …
  )
```

@T(00:12:04)
This is the same route we were looking at earlier. We can also take a look at the app delegate, where we're registering for push notifications:

```swift
environment.apiClient.apiRequest(
  route: .push(
    .register(
      .init(
        authorizationStatus: .init(
          rawValue: settings.authorizationStatus.rawValue
        ),
        build: environment.build.number(),
        token: token
      )
    )
  )
)
```

@T(00:12:13)
Every time we make one of these API requests, all we need to do is construct a statically typed value, in this most recent case a `ServerRoute.push(.register)` with a bunch of data inside. The router is what takes care of things behind the scenes. We don't need to know whether the data we supply are header values, JSON body, or query parameters. All that gets taken care of for us automatically.

@T(00:12:36)
Underneath the hood the live API client is using one of those router values we see right here in order to generate a `URLRequest` and fire it off with a `URLSession`. We can even see this if we jump to the file that has the live `ApiClient`. There’s a little private helper method that calls the `.request(for:)` method on the router:

```swift
guard
  let request = router.request(for: route, base: baseUrl)?
    .setHeaders()
```

@T(00:13:01)
So that’s how the router works, but I’m sure you are really curious how we implemented it. Well, we’re not ready to go deep into why and how it’s implemented the way it is, but we can give a small peek.

@T(00:13:11)
If we hop over to `Router.swift` we will see some really wild stuff. We will see a big list of values that all look like gibberish. Take for instance this one:

```swift
.case(ServerRoute.Api.Route.changelog(build:))
  <¢> get %> "changelog"
  %> queryParam("build", .tagged(.int))
  <% end
```

@T(00:13:25)
Believe it or not, this is describing a parser. Now it certainly doesn’t look like any parser we covered in any of our 21 episodes on parsing, but that’s because we have been thinking about and iterating on parsing for a very, very long time. In the early days, before we launched Point-Free, we experimented with a parsing library that looks like this. The symbols are the binary operator version of operators that we now know and love by other names, in particular they are `.map`, `.skip` and `.take`.

@T(00:13:37)
For example, in today’s parsing vernacular we would formulate this parser as something like this:

```swift
Get()
  .skip(Path("changelog"))
  .take(QueryParam("build", .tagged(.int))
  .skip(End())
  .map(ServerRoute.Api.Route.changelog)
```

@T(00:14:13)
This makes it very clear how we are picking apart and processing an incoming `URLRequest`. We first parse that it’s a `GET` request, then we parse off `"changelog"` from the path components and discard the results, thanks to the `.skip` operator. Then we parse off a `build` parameter from the query, and further process it as a tagged integer using our `Tagged` library. And then we `.map` on that build number to bundle it into the `.changlog` case of our API route.

@T(00:14:16)
But, as we mentioned earlier, this expression is not just a simple parser. It is an invertible parser. This means it can also turn routes into `URLRequest`s, which is necessary for the API client in the iOS app. That means we have to do a little bit of extra work to make a syntax like this work for our router, but it’s totally possible and it’s pretty amazing to see. But we’ll have to save that for another Point-Free episode.

@T(00:14:39)
So, we want to iterate how cool this is. The very code that powers routing on our server is also powering the API client in the iOS app. Literally this little `router` value we see right here is used both on the server and in the iOS app. It’s really awesome and removes a whole slew of problems and bugs that we just never have to think about:

@T(00:15:00)
- We don’t have to manually construct URLs for the server, which runs the risk of typos. For example, the server may use kebab case for the URL path components and you may accidentally use camel case:
    /api/leaderboard-scores
    /api/leaderboardScores
    We don’t have to worry about that at all with our router because we never actually construct paths when using the router. All of that is handled automatically in the parser-printer layer that powers the router.

@T(00:15:25)
- We don’t have to remember which parameters are passed in the query params versus the headers versus the request body. All of that is hidden from us. We just construct the route enum value by providing all the arguments necessary, and the router takes care of populating query params, headers and body automatically.

@T(00:15:45)
- Also, the moment a new route is added to that big enum we showed a moment ago it is instantly available to both the client and the server. You don’t have to look through sever code or ask your backend colleague to give you the details about the new endpoint. You just need to need to construct the enum value and then you are good to go.

## Integration testing super powers: the client

@T(00:16:01)
So this is all pretty interesting stuff. Not only do we get to write our server in Swift, which we of course rather write than other popular server languages such as Ruby, Python, Go or JavaScript, but we also get to share a lot of code between client and server.

@T(00:16:19)
But sharing code between the two platforms is only the beginning. There are also huge benefits to be had in testing. We write units tests for our client code by mocking out the API client dependency to return whatever data we want so that we can exercise every part of our feature. And at the same time we write units tests for our server by mocking out its dependencies to exercise every part of its logic. What if we could combine these somehow?

@T(00:16:51)
After all, the server and client are both written in Swift. What if we could provide a “mock” API client to our iOS code that secretly under the hood executes actual server code. This would allow us to write a single test that simultaneously exercises both the iOS logic and the server logic. We don’t even need to jump through any hoops to get a local server running so that we can hit it. We can just literally run server code inside our iOS app!

@T(00:17:21)
Let’s see how this is possible.

@T(00:17:25)
We’re going to add an integration test for the game over screen. This screen is already well covered by other simpler tests. For example, if we hop over to `GameOverFeatureTests.swift` we will see 7 tests covering all types of scenarios, such as what happens when you finish a regular solo game versus a daily challenge, as well as requesting an App Store review when you close the game over screen, and also some test coverage on showing the upgrade interstitial if you haven’t yet purchased the full game. We have some screenshot tests too.

@T(00:18:14)
However, all of these tests work by taking the failing API client and then overriding some of its endpoints to get us the data we need. For example, to test submitting a solo game’s scores we have:

```swift
environment.apiClient.override(
  route: .games(
    .submit(
      .init(
        gameContext: .solo(
          .init(gameMode: .timed, language: .en, puzzle: .mock)
        ),
        moves: [.mock]
      )
    )
  ),
  withResponse: .ok([
    "solo": [
      "ranks": [
        "lastDay": LeaderboardScoreResult.Rank(outOf: 100, rank: 1),
        "lastWeek": .init(outOf: 1000, rank: 10),
        "allTime": .init(outOf: 10000, rank: 100),
      ]
    ]
  ])
)
```

@T(00:19:05)
This is great for writing tests really quickly and testing every little edge case of the code base, but also it’s not as strong as it could be.

@T(00:19:14)
What if when the `.games(.submit)` route was requested we actually ran the real server code, which is responsible for decoding the request, routing it to the function that handles this particular piece of logic, which then verifies the puzzle data submitted, makes a database request to save that data, and then returns your ranks. If we could capture all of that in a single test then I think we could have a lot more confidence that changes to the frontend or backend will not accidentally break the app.

@T(00:19:47)
So let’s give it a shot! We’ll start by adding a new test target specifically for this integration test. We prefer to do a new target than add this test to the existing `GameOverFeatureTests` target because integration tests need to build server code, and that means building some heavy duty stuff such as our experimental web libraries and Swift NIO. We wouldn’t want to incur that build cost when we just write a simple, non-integration unit test for our feature, and so adding a new target makes it possible to keep those tests lightweight while still allowing us to a richer test experience for the integration.

@T(00:20:24)
We will add this test target to `Package.swift` under the `client` section, since we will run client code in these integration tests:

```swift
.testTarget(
  name: "GameOverFeatureIntegrationTests",
  dependencies: [
    "GameOverFeature",
    "IntegrationTestHelpers",
    "SiteMiddleware",
  ]
),
```

@T(00:20:50)
This test target depends on the core `GameOverFeature`, which is the iOS code, `IntegrationTestHelpers` which holds the code that will allow us to automatically derive and API client from the server code, and then `SiteMiddleware`, which is the server code that runs the site.

@T(00:21:12)
With the `Package.swift` updated we need to create the `GameOverFeatureIntegrationTests` directory inside the `Tests` directory, and create a new test file with a stub of a test:

```swift
import XCTest

class GameOverFeatureIntegrationTests: XCTestCase {
  func testSubmitSoloScore() {
  }
}
```

@T(00:21:38)
Now if we try to run this test we will find we can't, because Xcode has not created a scheme for this test target. We could manually add the test to one of our preexisting schemes, but that will slow down our existing tests quite a bit because we're bringing in more dependencies for this style of test. Instead we can create a brand new dedicated scheme for this test target.

@T(00:22:54)
So now that things are building and tests can run, where do we even start with writing such an integration test?

@T(00:23:04)
Well, amazingly we can actually let the failing test dependencies guide us like it did in our past episodes on [better test dependencies](/collections/dependencies/better-test-dependencies). In those episodes we demonstrated how to write a test from scratch by just plugging in a failing environment of dependencies so that we could instantly see which dependencies are being used in a test, and then we incrementally filled in those dependencies until we got a passing test, which led us to discover our feature like we had a flashlight in a dark room.

@T(00:23:34)
Let’s do that here. We can begin this test just like any Composable Architecture test, by first constructing a test store with the game over screen’s domain:

```swift
import ComposableArchitecture
import GameOverFeature
…
let store = TestStore(
  initialState: GameOverState(
    completedGame: .mock,
    isDemo: false
  ),
  reducer: gameOverReducer,
  environment: .failing
)
```

@T(00:24:12)
The `GameOverState` takes a few arguments, like a `CompletedGame`, which is a data type holding the final data for the game that was just played, as well as an `isDemo` boolean, which is used to determine if this screen is showing as part of an App Clip, in which case the experience and UI changes slightly. We also start the environment off as a failing environment, which means if any of this feature’s dependencies are executed it will instantly fail the test suite, which gives us the opportunity to be exhaustive in figuring out which dependencies we should be supplying implementations for.

@T(00:24:57)
With the test store set up, what exactly do we want to test? The majority of the game over screen’s functionality is kicked off when the screen first appears. That triggers a number of things to happen, including sending the API request to the server with the player’s puzzle and score. So, let’s send an `.onAppear` action and see what happens:

```swift
store.send(.onAppear)
```

```
Executed 1 test, with 15 failures (14 unexpected) in 0.068 (0.070) seconds
```

@T(00:25:26)
Wow, ok. There were 12 failures in just that one single test, so clearly this feature is doing quite a bit of work when `.onAppear` occurs.

@T(00:25:35)
If we look at the failures we’ll see a whole bunch of dependencies being used that we haven’t yet provided implementations for:

@T(00:25:50)
- There’s some mentions of a `RunLoop`, so we must be performing some asynchronous work and needing to schedule it back to the main thread.

@T(00:26:07)
- There’s mention of the `ApiClient`, which isn’t surprising since we expect to be making some requests.

@T(00:26:14)
- There’s mention of a `LocalDatabaseClient` and a `ServerConfig`. We use both of these things to determine if we should show the upgrade interstitial or not, because we allow you to play a few games before we start to annoy you with prompts to purchase the full game.

@T(00:26:36)
- There’s also mention of `UserNotificationsClient` dependency, which is used to determine if we should ask you to enable push notifications for the app.

@T(00:26:45)
- And there’s mention of an `AudioPlayerClient`, which we use to play some music specifically for game over.

@T(00:26:50)
So, we got quite a few dependencies we need to provide before we are going to get a passing test, and more may pop up as we go because we providing a dependency could cause us to access new logic that then grabs a different dependency.

@T(00:27:09)
Perhaps the easiest one to provide is the `RunLoop`. We have two choices for this dependency. We could use a `TestScheduler`, which allows us to explicitly control the flow of time in our test, or we can use an `ImmediateScheduler`, which just executes its actions immediately with no thread hops. To keep things simple let’s go with the immediate scheduler:

```swift
var environment = GameOverEnvironment.failing
environment.mainRunLoop = .immediate

let store = TestStore(
  initialState: GameOverState(
    completedGame: .mock,
    isDemo: false
  ),
  reducer: gameOverReducer,
  environment: environment
)

store.send(.onAppear)
```

```
Executed 1 test, with 8 failures (8 unexpected) in 0.052 (0.054) seconds
```

@T(00:27:40)
Nice, we’ve already fixed 4+ failures.

@T(00:27:51)
There’s another failure that’s pretty easy to fix. When a timed game is about to end you tend to be in a frenzied mode of trying to make as many words as possible, and so when time does officially run out and the game over screen fades into view you run the risk of accidentally tapping on something in that screen. And for that reason we initially disable the entire screen, and then one second later re-enable it. To accomplish this we send a `.delayedOnAppear` action with a 1 second delay, and in that action we mutate state to enable. That can be captured in this test using the `.receive` method on the store to make it explicit we expect an effect to feed an action back into the system:

```swift
store.receive(.delayedOnAppear) {
  $0.isViewEnabled = true
}
```

```
Executed 1 test, with 7 failures (7 unexpected) in 0.055 (0.057) seconds
```

@T(00:29:14)
One more failure has been fixed.

@T(00:29:21)
Another easy failure to fix would be the audio player. We actually already have test coverage on this dependency in our non-integration unit tests, and so it’s probably not necessary to rehash that work here. Instead the integration tests should be more focused on the direct interactions between client and server. So, if we use a `.noop` dependency for the audio client we should fix a few more failures:

```swift
environment.audioPlayer = .noop
```

```
Executed 1 test, with 5 failures (5 unexpected) in 0.448 (0.450) seconds
```

@T(00:30:04)
Two more failures have been fixed, and we’re slowly chipping away.

@T(00:30:09)
There’s a few other dependencies that are kinda similar in spirit to the audio player in that they are used to in client-side functionality that doesn’t really concern the server. This includes the `LocalDatabaseClient`, `ServerConfigClient`, and `UserNotificationsClient`, which are used to determine when to show the upgrade interstitial and when to ask for push notification permissions. We already have full test coverage on those aspects of game over in our units tests, so let’s not test those pieces of functionality right now, and instead focus on the actual client-server communication paths. This means we can put in some stubbed effects for those endpoints to keep us from having to think about them:

```swift
environment.database.playedGamesCount = { _ in .init(value: 0) }
environment.serverConfig.config = { .init() }
environment.userNotifications.getNotificationSettings = .none
```

@T(00:32:24)
Now we’re down to just 2 failures!

```
Executed 2 tests, with 2 failures (2 unexpected) in 0.447 (0.450) seconds
```

@T(00:32:26)
Note that we are still stubbing only the bare essentials of the dependency. There’s no need to stub the entire database client, or server config client or user notifications client because we know that only these 3 specific endpoints are ever accessed. This makes our test stronger by forcing us to describe exactly what parts of our dependency are being used when testing a specific slice of a feature.

@T(00:32:59)
That said, we're down to 2 failures and they both appear to be related to the API:

> Failed: ApiClient.currentPlayer is unimplemented

> Failed: ApiClient.apiRequest(.games(.submit(…))

@T(00:33:17)
The first failure comes from us trying to access the “current player” of the API, which refers to the currently authenticated player. We do this because we need to check if they have already purchased the full version of the game in order to prevent showing the upgrade interstitial.

@T(00:33:32)
The second failure is an API request being made in order to submit the game to the leaderboards. In the past the way we’ve handled this is to override this particular route in the API client:

```swift
environment.apiClient.override(
  route: .games(.submit(<#ServerRoute.Api.Route.Games.SubmitRequest#>)),
  withResponse: <#Effect<(data: Data, response: URLResponse), URLError>#>
)
```

@T(00:33:54)
This allows us to provide a response for just this one route, and every other route will continue to fail. However, overriding this route doesn’t allow us to exercise any of the server code. We are bypassing everything the server does in order to force a particular response for this route.

## Integration testing super powers: the server

@T(00:34:24)
It would be far better if we could somehow derive an API client from the server code so that when we make an API request it runs actual server code under the hood. And this is actually possible and it’s pretty awesome to do.

@T(00:34:38)
There’s an initializer on `ApiClient` that allows us to specify something known as a “middleware” and a `router`:

```swift
import IntegrationTestHelpers
…
environment.apiClient = .init(
  middleware: <#Middleware<StatusLineOpen, ResponseEnded, Unit, Data>##Middleware<StatusLineOpen, ResponseEnded, Unit, Data>##(Conn<StatusLineOpen, Unit>) -> IO<Conn<ResponseEnded, Data>>#>,
  router: <#Router<ServerRoute>#>
)
```

@T(00:35:02)
A middleware is basically the atomic unit that runs a server in our experimental web libraries. It is analogous to reducers from the Composable Architecture. It also has lots of fun compositions that allow you to break bigger problems down into smaller ones.

@T(00:35:18)
There’s a function that allows us to construct this middleware value as long as we provide it something called a `ServerEnvironment`:

```swift
import SiteMiddleware
…
environment.apiClient = .init(
  middleware: siteMiddleware(environment: <#ServerEnvironment#>),
  router: <#Router<ServerRoute>#>
)
```

@T(00:35:37)
The `ServerEnvironment` serves the exact same purpose that environments have in the Composable Architecture. It holds all of the dependencies the server needs to do its job. It holds just 10 dependencies right now:

```swift
public struct ServerEnvironment {
  public var changelog: () -> Changelog
  public var database: DatabaseClient
  public var date: () -> Date
  public var dictionary: DictionaryClient
  public var itunes: ItunesClient
  public var envVars: EnvVars
  public var mailgun: MailgunClient
  public var randomCubes: () -> ArchivablePuzzle
  public var router: Router<ServerRoute>
  public var snsClient: SnsClient

  …
}
```

@T(00:35:51)
This includes important things such as:

@T(00:35:54)
- A client for interacting with our Postgres database.

@T(00:35:58)
- A dictionary client for querying for valid words. This is the exact same client we use over in the iOS app.

@T(00:36:04)
- The `ItunesClient` handles sending receipt data to Apple for verification.

@T(00:36:13)
- The `router` is the value we use to parse incoming requests to figure out how we want to execute the logic for that request.

@T(00:36:17)
- The `SnsClient` is how we interact with Amazon’s SNS service, which is how we send push notifications.

@T(00:36:22)
And more.

@T(00:36:24)
And at the bottom of this file we also have a `.failing` implementation of this environment, which allows us to be exhaustive with our dependencies, just as we do in the Composable Architecture. Now you may get a sense that there are quite a few similarities between how we build features with the Composable Architecture and how we build the server. That’s definitely true, but unfortunately we’re not yet ready to dive too deeply into how we can build server side applications from scratch. We’re waiting for a few more things to pan out with concurrency in Swift before we start discussing those topics on Point-Free.

@T(00:36:59)
But that’s ok, even without understanding the intricacies of how we build the server we can still make our way through this test. We’ll stick in a middleware that uses the `.failing` server environment, and for the router we can also use a `.failing` one:

```swift
environment.apiClient = .init(
  middleware: siteMiddleware(environment: .failing),
  router: .failing
)
```

@T(00:37:23)
And now the API client that we hand off to the Composable Architecture is completely powered by our server code. To see this we can run tests and we will suddenly get a bunch of failures due to using dependencies on the server that have not be implemented yet.

@T(00:37:49)
And now we just repeat the script that we followed for the Composable Architecture, but now we are doing it for the server. We can find one by one plug in test dependencies for each of the failures we have. For example, there are failures that we are using endpoints from the router that are currently unimplemented.

@T(00:38:09)
We actually have a mock server router already defined that we can use. It takes care of mocking out the dependencies that the router needs, such as a date initializer, a SHA256 implementation, and JSON encoders and decoders:

```swift
var serverEnvironment = ServerEnvironment.failing
serverEnvironment.router = .test

var environment = GameOverEnvironment.failing
environment.audioPlayer = .noop
environment.apiClient = .init(
  middleware: siteMiddleware(environment: serverEnvironment),
  router: .mock
)
```

@T(00:38:57)
And now when we run tests we are back down to just 2 failures:

```
Executed 1 test, with 2 failures (1 unexpected) in 0.464 (0.467) seconds
```

@T(00:39:06)
The first failure we have is mentioning that we are using some endpoint on the `DatabaseClient` that is current unimplemented:

> Failed: DatabaseClient.fetchPlayerByAccessToken is unimplemented

@T(00:39:13)
This endpoint is pretty self explanatory, it just fetches a player from an access token, and that access token was given to us from the client.

@T(00:39:28)
The easiest way to implement this endpoint is to simply override it with some mock data. We can do this by providing a closure:

```swift
serverEnvironment.database.fetchPlayerByAccessToken = { _ in
}
```

@T(00:39:43)
And then in here we need to return something known as an `EitherIO`. This type plays an analogous role as `Effect` does in the Composable Architecture. It’s the thing that interacts with the outside world and performs side effects.

@T(00:40:07)
We can create one of these that immediately returns a value, which in this case is a `Player`:

```swift
serverEnvironment.database.fetchPlayerByAccessToken = { _ in
  .init(value: .blob)
}
```

@T(00:40:27)
Another option would be to use an actual live database client, meaning one that speaks to a real life Postgres database running on our local computer. This can even further strengthen our integration tests since you exercising even more of the application, but that takes a little more time to set up so let’s go with this approach for now.

@T(00:40:47)
Running tests again we see that the failure for the `fetchPlayerByAccessToken` endpoint goes away, but new ones show up:

> Failed: DictionaryClient.contains is unimplemented

@T(00:40:51)
The `DictionaryClient` failure is due to the fact that when scores are submitted we verify that the game played actually makes sense. We don’t want people submitting junk data to our leaderboards just to juice the stats. And in the process of verifying we make use of the dictionary client to check the words that were submitted.

@T(00:41:21)
So, hopefully by providing a better `DictionaryClient` dependency we can fix both of these failures. Let’s just override the `contains` endpoint to say that any word passed to it is contained in the dictionary:

```swift
serverEnvironment.dictionary.contains = { _, _ in true }
```

@T(00:41:57)
Now when we run tests we see that some failures went away, but we got a new one:

> Failed: DatabaseClient.submitLeaderboardScore is unimplemented

@T(00:42:28)
This is a new database endpoint being accessed, and it’s the one that actually submits the puzzle and scores to the leaderboards table in the database. It’s a function that takes a `SubmitLeaderboardScore` as an argument, which holds all the data needed to insert the row into the table, and returns a `LeaderboardScore`, which is a data type that represents the row of data just inserted into the database:

```swift
submitLeaderboardScore: (SubmitLeaderboardScore) -> EitherIO<Error, LeaderboardScore>
```

@T(00:42:43)
We can override it like the last one, and provide an `EitherIO` value that immediately returns `LeaderboardScore` value. We’ll construct this value to represent the game that the `initialState` of the test store was seeded with:

```swift
serverEnvironment.database.submitLeaderboardScore = { _ in
  .init(
    value: .init(
      createdAt: .mock,
      dailyChallengeId: nil,
      gameContext: .solo,
      gameMode: .timed,
      id: .init(rawValue: UUID()),
      language: .en,
      moves: CompletedGame.mock.moves,
      playerId: Player.blob.id,
      puzzle: .mock,
      score: score("CAB")
    )
  )
}
```

@T(00:45:02)
Again, we could have also used a live database client to handle all of this for us, and then we’d get even stronger guarantees in our tests, but this will do for now.

@T(00:45:17)
We are getting closer, but now when we run tests a new failure pops up:

> Failed: DatabaseClient.fetchLeaderboardSummary is unimplemented

@T(00:45:25)
It seems that we are accessing a new database endpoint. This is happening because as soon as we successfully submit the leaderboard score we immediately fetch the leaderboard summary, which breaks down the player’s score into ranks for the past day, week and all time.

@T(00:46:03)
The `fetchLeaderboardSummary` is a function that takes a `FetchLeaderboardSummaryRequest`, which describes what kind of summary we want (i.e. what game mode, what time scope and what language), and returns a `Rank`:

```swift
var fetchLeaderboardSummary: (FetchLeaderboardSummaryRequest) -> EitherIO<Error, LeaderboardScoreResult.Rank>
```

@T(00:46:36)
This gets called 3 times by the server, one for each time scope corresponding to past day, past week and all time.

@T(00:46:44)
To aid us in implementing this endpoint we can define a little dictionary that maps the time scopes to some mock ranks:

```swift
let ranks: [TimeScope: LeaderboardScoreResult.Rank] = [
  .allTime: .init(outOf: 10_000, rank: 1_000),
  .lastWeek: .init(outOf: 1_000, rank: 100),
  .lastDay: .init(outOf: 100, rank: 10),
]
```

@T(00:47:28)
And then implementing `fetchLeaderboardSummary` is as easy as reading from the dictionary:

```swift
serverEnvironment.database.fetchLeaderboardSummary = {
  .init(value: ranks[$0.timeScope]!)
}
```

@T(00:47:51)
Running tests we see we are down to just one failure!

```
Executed 1 test, with 1 failure (0 unexpected) in 0.464 (0.466) seconds
```

> Error: The store received 1 unexpected action after this one: …
>
> ```
> Unhandled actions: [
>   GameOverAction.submitGameResponse(
>     Result<SubmitGameResponse, ApiError>.success(
>       SubmitGameResponse.solo(
>         LeaderboardScoreResult(
>           ranks: [
>             "allTime": Rank(
>               outOf: 100,
>               rank: 10000
>             ),
>             "lastDay": Rank(
>               outOf: 1,
>               rank: 100
>             ),
>             "lastWeek": Rank(
>               outOf: 10,
>               rank: 1000
>             ),
>           ]
>         )
>       )
>     )
>   ),
> ]
> ```

We are getting so close!

@T(00:48:10)
This failure is telling us that the system received an action from an effect that we didn’t explicitly assert on. This is happening because now that we have all of the server dependencies sorted out we are finally getting some data back from the API, which feeds into the system, and the Composable Architecture forces us to be exhaustive and explicit with how effects execute in our tests.

@T(00:48:34)
From the failure we can clearly see that we received a `.submitGameResponse` action, which makes sense because we are finally getting a response back from the API:

```swift
store.receive(
  .submitGameResponse(<#Result<SubmitGameResponse, ApiError>#>)
)
```

@T(00:48:52)
Further we expect to get a successful response:

```swift
store.receive(
  .submitGameResponse(.success(<#SubmitGameResponse#>))
)
```

@T(00:48:55)
To construct a `SubmitGameResponse` we have to decide what kind of game we submitted, and in this case it was a `solo` game:

```swift
store.receive(
  .submitGameResponse(.success(.solo(<#LeaderboardScoreResult#>)))
)
```

@T(00:49:03)
To construct one of these `LeaderboardScoreResult` values we just need to provide a dictionary of ranks keyed by time scopes:

```swift
store.receive(
  .submitGameResponse(
    .success(
      .solo(
        .init(ranks: <#[TimeScope : LeaderboardScoreResult.Rank]#>)
      )
    )
  )
)
```

@T(00:49:10)
And that happens to be exactly what we defined above to help us with the database endpoint:

```swift
store.receive(
  .submitGameResponse(.success(.solo(.init(ranks: ranks))))
)
```

@T(00:49:17)
Then, when we receive this action we expect there will be some state mutations because the UI needs to display these ranks. We can open up the expectation closure, which is where we perform the mutations we think we occur after receiving this action:

```swift
store.receive(
  .submitGameResponse(.success(.solo(.init(ranks: ranks))))
) {
  $0
}
```

@T(00:49:35)
And we can even use autocomplete on `$0` in order to explore what kind of state is held in `GameOverState` in order to figure out what should change.

@T(00:49:37)
There’s a field called `summary` that holds something called a `RankSummary`, so that seems like a good start. To construct one of those we choose between a `.dailyChallenge` case and a `.leaderboard` case. This is because the game over screen looks slightly different for each of those times of games. For the test we are writing now we are not dealing with daily challenges, so let’s go with the `.leaderboard` case:

```swift
$0.summary = .leaderboard(<#[TimeScope : LeaderboardScoreResult.Rank]#>)
```

@T(00:50:08)
To construct the `.leaderboard` case we need to supply a dictionary of ranks, which again is exactly what we defined earlier:

```swift
store.receive(
  .submitGameResponse(.success(.solo(.init(ranks: ranks))))
) {
  $0.summary = .leaderboard(ranks)
}
```

@T(00:50:14)
When we run tests they now all pass!

@T(00:50:20)
So we now have our first passing integration test. We are writing what seems to be a standard, run-of-the-mill Composable Architecture test by feeding in a sequence of user actions and then asserting how state changes and how effects execute. But secretly, under the hood, the API client that the game over feature is using to run its logic is actually calling out to server code. And that server code is doing a ton of work, including routing the incoming request, executing multiple database queries, and molding all that data into a shape that can be sent back to the client. And then the client decodes that data and presents it in the UI.

@T(00:51:09)
And it’s worth mentioning that integration tests are not an either/or concept, but rather more like a spectrum. We consider the test we just now wrote to be an integration test because it is testing how two very different components interact with each other, the client and the server. We’ve also used the term “integration tests” in the past to describe writing tests for multiple Composable Architecture features at once.

@T(00:51:32)
But in each of these cases there’s another level of integration we could aspire too. For example, we decided to stub out the database in our integration test, but we could have used a live database. That would have allowed testing 3 independent components: the iOS client, the server and the Postgres database. And for Composable Architecture integration tests we could always go to the extreme by only allowing ourselves to write tests for the root app reducer in order to definitely prove that all of our features play nicely with each other.

@T(00:52:10)
But doing this comes with pros and cons. The deeper an integration test the stronger it becomes, but also the more difficult it is to set up and maintain. And vice versa, the shallower an integration test the easiest it is to write and maintain, but also it doesn’t test as much as it could.

@T(00:52:27)
So, it’s important to keep these principles in mind when approaching integration tests so that you can see where your threshold for pain versus reward lies. Perhaps when testing super focused slices of a feature it’s ok to just use a unit test that stubs out dependencies, and then maybe a few core flows of your application have a deeper test for bringing in more disparate parts of the application.

@T(00:52:50)
But the most important thing to know is that if your server and client are both built in Swift then it is totally possible to write integration tests, it’s easy to turn the dial that determines just how much integration you want, and it’s totally awesome to write tests like this.

@T(00:53:04)
And we want to also callout just how cool it is to write server tests that kinda look like our Composable Architecture tests. The failing dependencies led us step-by-step through the process of getting a passing test, and if we ever start using a new dependency on this part of our server code we should be instantly notified in our tests so that we can fix it. We’re going to have a lot to say about server-side Swift in the future on Point-Free, and we will be applying a lot of the principles we have learned with the Composable Architecture.

## Conclusion

@T(00:53:32)
Well, that concludes our tour of the isowords code base. There’s a ton of stuff that we haven’t covered, but we just had to choose some of our favorite topics and focus on them. We’ll definitely be referring back to this code base many times on Point-Free as we start to explore new topics.

@T(00:53:49)
Until next time!
