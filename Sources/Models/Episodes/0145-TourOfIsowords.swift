import Foundation

extension Episode {
  public static let ep145_tourOfIsowords = Episode(
    blurb: """
      We wrap up our tour of [isowords](https://www.isowords.xyz) by showing off two powerful ways the iOS client and Swift server share code. Not only does the same code that routes server requests simultaneously power the API client, but we can write integration tests that exercise the full client–server lifecycle.
      """,
    codeSampleDirectory: "0145-tour-of-isowords-pt4",
    exercises: _exercises,
    id: 145,
    length: 53 * 60 + 54,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_620_622_800),
    references: [
      .isowords,
      .isowordsGitHub,
      .theComposableArchitecture,
      reference(
        forCollection: .composableArchitecture,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/composable-architecture"
      ),
    ],
    sequence: 145,
    subtitle: "Part 4",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 40_625_547,
      downloadUrls: .s3(
        hd1080: "0145-trailer-1080p-cf004995a5b04563a0ccbae0713a472f",
        hd720: "0145-trailer-720p-da31af47334a4a1595c62e5d541cbc8e",
        sd540: "0145-trailer-540p-02a3f8d270584369884da76d13804009"
      ),
      vimeoId: 542_946_808
    )
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep145_tourOfIsowords = Self(
    bytesLength: 518_632_255,
    downloadUrls: .s3(
      hd1080: "0145-1080p-ba2a4d4954eb46deacba5d3a8a028a20",
      hd720: "0145-720p-4e479ad219ec4590ae6412d6d4b2c416",
      sd540: "0145-540p-d87d7c86be1042e4a021045d96aa961f"
    ),
    vimeoId: 543_413_218
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep145_tourOfIsowords: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that gives a slight glimpse into how we share code between client and server. Some of the easiest things to share are data types and models, such as the puzzle and move types, as well as pure functions that do simple transformations of data, such as the verification function.
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And all of that is already pretty powerful, but there is an even cooler chunk of code being shared.
        """#,
      timestamp: 31,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The entire server routing system and the entire client-side API service are completely unified. What we mean is the code that parses incoming requests on the server is the exact same code that powers an API client in the iOS app for making network requests to the server. The moment we add a new route to the server we instantly get the ability to make requests to that route. There’s no need to read the server code or bother a colleague to figure out how a request can be constructed. It’s also impossible to construct an incorrect request. We have compile time guarantees that we didn’t accidentally misspell something in the URL request, or use camel case for a URL path that should have been kebab case, or used a GET request when it should have been a POST request, amongst a whole slew of other problems one can have when trying to build API clients.
        """#,
      timestamp: 41,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We want to give a tour of how this code works because it’s honestly amazing to see, and is going to be a big topic we dive into soon on Point-Free.
        """#,
      timestamp: (1 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"A router and API client in one"#,
      timestamp: (1 * 60 + 46),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by switching our active target to `ServerRouter`. This module contains all the code necessary to both parse an incoming request on the server-side and to generate an outgoing request for the iOS app. It also has a playground in the module, which thanks to recent improvements in SPM it’s now possible to run playgrounds in packages. So let’s open `Router.playground`.
        """#,
      timestamp: (1 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s already a little bit of code in here for importing the libraries necessary to play around with the router and it constructs a router by supplying some dependencies necessary for the router to implement its logic:
        """#,
      timestamp: (2 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Some these dependencies aren’t too surprising, like the JSON decoder encoder. There are certain parts of the router that needs to deserialize and serialize the body of a POST request, and so we inject these objects so that we can be consistent in how we do that work. The other 3 are not so obvious, but they are necessary for signing certain API requests so that they cannot be tampered with.
        """#,
      timestamp: (2 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This single value is capable of simultaneously routing incoming server side requests and constructing outgoing client side requests. Let’s demonstrate this by giving it a spin.
        """#,
      timestamp: (2 * 60 + 48),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Routing an incoming request means a raw `URLRequest` comes in and we want to parse and transform it into a first party type that we can then used to perform the actual server logic. This is basically the same principle that many of our viewers have probably employed in order to support deep linking in their applications.
        """#,
      timestamp: (2 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first class data that we want to transform into is known as `ServerRoute`, and we can hop to `ServerRoute.swift` to check it out:
        """#,
      timestamp: (3 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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

          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s basically a big ole enum of every single part of the site or API one can interact with. Some of these cases lead to further nested enums, such as `Api`, `Demo` and `SharedGame`.
        """#,
      timestamp: (3 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s try creating a request that will map to one of these cases via the router. We can start simple. The homepage is probably just a request to the root of the isowords website, so let's use the `match` method to parse out such a request. There are multiple overloads of the `match` method, including one that takes a full `URLRequest`, which includes the URL, request method, headers, and body, and some helpers that simply take a `URL` or even url `String`. Let's keep things simple:
        """#,
      timestamp: (3 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/")
        // .home
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And indeed the root URL matches the home route.
        """#,
      timestamp: (4 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The press kit is also probably something simple, maybe just `/press-kit`:
        """#,
      timestamp: (4 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/press-kit")
        // .pressKit
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And indeed it is.
        """#,
      timestamp: (4 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s now try something a little more complicated. Let’s construct the API request that fetches today’s daily challenge results so far, which is what is loaded on the home screen to populate the module at the top that says “X people have already played.”
        """#,
      timestamp: (4 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        I think I remember what most of this route looks like so I’m going to give it a shot. I know that all the API requests are nested inside the `/api` path component name space, so I’ll start there:
        """#,
      timestamp: (4 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/api/")
        // nil
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now currently this returns `nil` because there is no case of the route that represents the root of the `/api` path. But I further know that daily challenge routes are in the `/daily-challenges` path component:
        """#,
      timestamp: (5 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/api/daily-challenges")
        // nil
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This still returns `nil` because we haven’t yet constructed a request that exactly represents one of our routes. To get the results for just today’s daily challenge we need to further tack on the path component `/today`:
        """#,
      timestamp: (5 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/api/daily-challenges/today")
        // nil
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Ok this is still `nil`, but it’s only because there are some required query parameters that also need to be supplied. Most importantly every API request must have an access token attached, which is assigned to every player upon authentication in the game. We can provide this in the query params:
        """#,
      timestamp: (5 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/api/daily-challenges/today?accessToken=deadbeef-dead-beef-dead-beefdeadbeef")
        // nil
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And finally we also need to provide a language parameter so that we know for which language we are fetching daily challenge results. Currently isowords is only available in English but we hope to soon be available in other languages, and that will mean we will need to segment scores and leaderboards by language. We can provide this in the query params just like the access token:
        """#,
      timestamp: (5 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .match(string: "https://www.isowords.xyz/api/daily-challenges/today?accessToken=deadbeef-dead-beef-dead-beefdeadbeef&language=en")
        // .api(
        //   Api(
        //     accessToken: DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF,
        //     isDebug: false,
        //     route: .dailyChallenge(.today(language: .en))
        //   )
        // )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we finally get a non-`nil` value, which means our router has successfully recognized the request, and it’s this deeply nested enum value that points to an `.api` route, and inside there it points to a `.dailyChallenge` route, and inside there it points to the `.today` route with the language `.en`.
        """#,
      timestamp: (6 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this is what powers routing on our server. Whenever a request comes in we use the `.match` method on the router to figure out what route the request represents, and then we switch on the massive enum to figure out what part of the server logic to execute, not too unlike how we implement reducers in the Composable Architecture.
        """#,
      timestamp: (6 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But that’s only half the responsibilities of the router. The other half is to generate requests that can be used to make requests to the API. This is extremely important because as you can see from what we just did, some of our routes are quite complicated and there’s a lot to get right. Rather than munge together a raw `URLRequest` from scratch it would be far better to construct one of those `ServerRoute` enum values, which is statically type checked by the compiler, and let the router worry about turning it into a request.
        """#,
      timestamp: (6 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And luckily that’s exactly what our router does. The `.request(for:)` method on the router takes a `ServerRoute` value and returns a request:
        """#,
      timestamp: (7 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .request(for: <#T##ServerRoute#>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can even just do `.` in here and let autocomplete show us everything that’s possible to request. Doing that we see all the choices we saw in the `ServerRoute` file a moment ago:
        """#,
      timestamp: (7 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s choose the `.api` route:
        """#,
      timestamp: (7 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .request(for: .api(<#T##ServerRoute.Api#>))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now we have to choose a particular `.api` route, which we can explore again by just typing `.` and letting autocomplete show us the options:
        """#,
      timestamp: (7 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .init(accessToken: <#T##AccessToken#>, isDebug: <#T##Bool#>, route: <#T##ServerRoute.Api.Route#>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Looks like we only have one choice, and that’s because to construct an `.api` request we have to fill in some required fields before we are allowed to choose from all of the API’s routes. Let’s just stick some data in for these fields:
        """#,
      timestamp: (7 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .request(
            for: .api(
              .init(
                accessToken: .init(rawValue: UUID()),
                isDebug: false,
                route: <#T##ServerRoute.Api.Route#>
              )
            )
          )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we autocomplete on this `.api` route we get some choices:
        """#,
      timestamp: (8 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        changelog
        config
        currentPlayer
        dailyChallenge
        games
        leaderboard
        push
        sharedGame
        verifyReceipt
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s go into the `.dailyChallenge` route since that’s what we experimented with a moment ago:
        """#,
      timestamp: (8 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .request(
            for: .api(
              .init(
                accessToken: .init(rawValue: UUID()),
                isDebug: false,
                route: .dailyChallenge(<#T##ServerRoute.Api.Route.DailyChallenge#>)
              )
            )
          )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And let’s see what our choices are to fill this in:
        """#,
      timestamp: (8 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        results
        start
        today
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `.today` route seems like a good candidate for loading today’s results:
        """#,
      timestamp: (8 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router
          .request(
            for: .api(
              .init(
                accessToken: .init(rawValue: UUID()),
                isDebug: false,
                route: .dailyChallenge(.today(language: <#T##Language#>))
              )
            )
          )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now we’re just left with filling in the language, which we can do with English:
        """#,
      timestamp: (8 * 60 + 29),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We have now filled in all the holes for this route, and the playground is now compiling. It is amazing that we did not even have compiling code until all the holes were filled. That is giving us static, compile time guarantees that our route has been constructed correctly.
        """#,
      timestamp: (8 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And even better, the router has returned a fully constructed `URLRequest` that can be used to fire off a network request to load data from the server:
        """#,
      timestamp: (8 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        // api/daily-challenges/today?accessToken=3EE1B177-CCCD-4E75-838B-B5F6AF5068F5&language=en
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s try a more complicated route. What if we wanted to construct the API request that submits a score to the leaderboard. Turns out this one single route supports a lot of different use cases. We can start by constructing the `.games` route and then the `.submit` route:
        """#,
      timestamp: (9 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        router.request(
          for: .api(
            .init(
              accessToken: .init(rawValue: UUID()),
              isDebug: false,
              route: .games(
                .submit(<#T##ServerRoute.Api.Route.Games.SubmitRequest#>)
              )
            )
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct a `SubmitRequest` we have to supply a `gameContext` and an array of `moves`, which are the actual moves used to play the game:
        """#,
      timestamp: (9 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .init(
          gameContext: <#T##ServerRoute.Api.Route.Games.SubmitRequest.GameContext#>,
          moves: <#T##Moves#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct a `GameContext` we have to choose one of the types of games that we support:
        """#,
      timestamp: (9 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        dailyChallenge
        shared
        solo
        turnBased
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Each of these types of games provides a different set of data in order to submit to the leaderboards. Let’s go with `.solo` for the purpose of this demonstration:
        """#,
      timestamp: (9 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        gameContext: .solo(<#T##ServerRoute.Api.Route.Games.SubmitRequest.GameContext.Solo#>),
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct one of these `Solo` values we have to specify all of the important parts of a solo game, including `gameMode` (which is `.timed` or `.unlimited`), `language` (which is just English for now), and the `puzzle` is the full description of the isowords cube that was played:
        """#,
      timestamp: (9 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .init(
          gameMode: <#T##GameMode#>,
          language: <#T##Language#>,
          puzzle: <#T##ArchivablePuzzle#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s just fill in some data for these arguments. For the puzzle we can use a `.mock` that we have prepared in the `SharedModels` module:
        """#,
      timestamp: (9 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        gameContext: .solo(
          .init(
            gameMode: .timed,
            language: .en,
            puzzle: .mock
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And finally we have to provide an array of `moves`. We also have mocks for the `Move` type, so let’s use em:
        """#,
      timestamp: (10 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        moves: [
          .highScoringMove,
          .removeCube
        ]
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So all in all this is a pretty intense way of constructing an API request:
        """#,
      timestamp: (10 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, everything is fully static and type checked by the server. We do not have to guess at at which of these parameters belong in the query string, or which are apart of the request body, or perhaps maybe some of these even go in the headers. All of that is hidden from us and not important at all. The router takes care of it for us. All we have to do is provide all of these arguments and everything will just work in the background.
        """#,
      timestamp: (10 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is pretty amazing. We are able to keep the server and client in sync automatically, and we simultaneously make it a breeze to route requests on the server and construct requests on the API client. It can honestly be pretty mind blowing to simply add a new route or add extra data to an existing route and instantly see all the spots in both the server and client that need to be updated, and then everything just works.
        """#,
      timestamp: (10 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is in stark contrast with how we usually do API clients in our iOS applications. If we’re lucky someone from the backend team will have a spec or some kind of documentation so that we know what endpoints are available to hit, and if we’re not lucky we may have to just message a colleague for details or search through the server code ourselves.
        """#,
      timestamp: (11 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To see all the places in the client we are making use of this machinery we just have to do a project search for `environment.apiClient`. We’ll see dozens of spots where we are making API requests.
        """#,
      timestamp: (11 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, in the `DailyChallengeView.swift` file we make an API request to load today’s results:
        """#,
      timestamp: (11 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        case .onAppear:
          return .merge(
            environment.apiClient.apiRequest(
              route: .dailyChallenge(.today(language: .en)),
              as: [FetchTodaysDailyChallengeResponse].self
            )
            .receive(on: environment.mainRunLoop.animation())
            .catchToEffect()
            .map(DailyChallengeAction.fetchTodaysDailyChallengeResponse),

            ...
          )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is the same route we were looking at earlier. We can also take a look at the app delegate, where we're registering for push notifications:
        """#,
      timestamp: (12 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.apiClient.apiRequest(
          route: .push(
            .register(
              .init(
                authorizationStatus: .init(rawValue: settings.authorizationStatus.rawValue,
                build: environment.build.number(),
                token: token
              )
            )
          )
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Every time we make one of these API requests, all we need to do is construct a statically typed value, in this most recent case a `ServerRoute.push(.register)` with a bunch of data inside. The router is what takes care of things behind the scenes. We don't need to know whether the data we supply are header values, JSON body, or query parameters. All that gets taken care of for us automatically.
        """#,
      timestamp: (12 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Underneath the hood the live API client is using one of those router values we see right here in order to generate a `URLRequest` and fire it off with a `URLSession`. We can even see this if we jump to the file that has the live `ApiClient`. There’s a little private helper method that calls the `.request(for:)` method on the router:
        """#,
      timestamp: (12 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        guard let request = router.request(for: route, base: baseUrl)?.setHeaders()
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that’s how the router works, but I’m sure you are really curious how we implemented it. Well, we’re not ready to go deep into why and how it’s implemented the way it is, but we can give a small peek.
        """#,
      timestamp: (13 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we hop over to `Router.swift` we will see some really wild stuff. We will see a big list of values that all look like gibberish. Take for instance this one:
        """#,
      timestamp: (13 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .case(ServerRoute.Api.Route.changelog(build:))
          <¢> get %> "changelog"
          %> queryParam("build", .tagged(.int))
          <% end
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Believe it or not, this is describing a parser. Now it certainly doesn’t look like any parser we covered in any of our 21 episodes on parsing, but that’s because we have been thinking about and iterating on parsing for a very, very long time. In the early days, before we launched Point-Free, we experimented with a parsing library that looks like this. The symbols are the binary operator version of operators that we now know and love by other names, in particular they are `.map`, `.skip` and `.take`.
        """#,
      timestamp: (13 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, in today’s parsing vernacular we would formulate this parser as something like this:
        """#,
      timestamp: (13 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Get()
          .skip(Path("changelog"))
          .take(QueryParam("build", .tagged(.int))
          .skip(End())
          .map(ServerRoute.Api.Route.changelog)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This makes it very clear how we are picking apart and processing an incoming `URLRequest`. We first parse that it’s a `GET` request, then we parse off `"changelog"` from the path components and discard the results, thanks to the `.skip` operator. Then we parse off a `build` parameter from the query, and further process it as a tagged integer using our `Tagged` library. And then we `.map` on that build number to bundle it into the `.changlog` case of our API route.
        """#,
      timestamp: (14 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But, as we mentioned earlier, this expression is not just a simple parser. It is an invertible parser. This means it can also turn routes into `URLRequest`s, which is necessary for the API client in the iOS app. That means we have to do a little bit of extra work to make a syntax like this work for our router, but it’s totally possible and it’s pretty amazing to see. But we’ll have to save that for another Point-Free episode.
        """#,
      timestamp: (14 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, we want to iterate how cool this is. The very code that powers routing on our server is also powering the API client in the iOS app. Literally this little `router` value we see right here is used both on the server and in the iOS app. It’s really awesome and removes a whole slew of problems and bugs that we just never have to think about:
        """#,
      timestamp: (14 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We don’t have to manually construct URLs for the server, which runs the risk of typos. For example, the server may use kebab case for the URL path components and you may accidentally use camel case:
            /api/leaderboard-scores
            /api/leaderboardScores
            We don’t have to worry about that at all with our router because we never actually construct paths when using the router. All of that is handled automatically in the parser-printer layer that powers the router.
        """#,
      timestamp: (15 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We don’t have to remember which parameters are passed in the query params versus the headers versus the request body. All of that is hidden from us. We just construct the route enum value by providing all the arguments necessary, and the router takes care of populating query params, headers and body automatically.
        """#,
      timestamp: (15 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Also, the moment a new route is added to that big enum we showed a moment ago it is instantly available to both the client and the server. You don’t have to look through sever code or ask your backend colleague to give you the details about the new endpoint. You just need to need to construct the enum value and then you are good to go.
        """#,
      timestamp: (15 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Integration testing super powers: the client"#,
      timestamp: (16 * 60 + 1),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this is all pretty interesting stuff. Not only do we get to write our server in Swift, which we of course rather write than other popular server languages such as Ruby, Python, Go or JavaScript, but we also get to share a lot of code between client and server.
        """#,
      timestamp: (16 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But sharing code between the two platforms is only the beginning. There are also huge benefits to be had in testing. We write units tests for our client code by mocking out the API client dependency to return whatever data we want so that we can exercise every part of our feature. And at the same time we write units tests for our server by mocking out its dependencies to exercise every part of its logic. What if we could combine these somehow?
        """#,
      timestamp: (16 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        After all, the server and client are both written in Swift. What if we could provide a “mock” API client to our iOS code that secretly under the hood executes actual server code. This would allow us to write a single test that simultaneously exercises both the iOS logic and the server logic. We don’t even need to jump through any hoops to get a local server running so that we can hit it. We can just literally run server code inside our iOS app!
        """#,
      timestamp: (16 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s see how this is possible.
        """#,
      timestamp: (17 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’re going to add an integration test for the game over screen. This screen is already well covered by other simpler tests. For example, if we hop over to `GameOverFeatureTests.swift` we will see 7 tests covering all types of scenarios, such as what happens when you finish a regular solo game versus a daily challenge, as well as requesting an App Store review when you close the game over screen, and also some test coverage on showing the upgrade interstitial if you haven’t yet purchased the full game. We have some screenshot tests too.
        """#,
      timestamp: (17 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, all of these tests work by taking the failing API client and then overriding some of its endpoints to get us the data we need. For example, to test submitting a solo game’s scores we have:
        """#,
      timestamp: (18 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.apiClient.override(
          route: .games(
            .submit(
              .init(
                gameContext: .solo(.init(gameMode: .timed, language: .en, puzzle: .mock)),
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is great for writing tests really quickly and testing every little edge case of the code base, but also it’s not as strong as it could be.
        """#,
      timestamp: (19 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        What if when the `.games(.submit)` route was requested we actually ran the real server code, which is responsible for decoding the request, routing it to the function that handles this particular piece of logic, which then verifies the puzzle data submitted, makes a database request to save that data, and then returns your ranks. If we could capture all of that in a single test then I think we could have a lot more confidence that changes to the frontend or backend will not accidentally break the app.
        """#,
      timestamp: (19 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So let’s give it a shot! We’ll start by adding a new test target specifically for this integration test. We prefer to do a new target than add this test to the existing `GameOverFeatureTests` target because integration tests need to build server code, and that means building some heavy duty stuff such as our experimental web libraries and Swift NIO. We wouldn’t want to incur that build cost when we just write a simple, non-integration unit test for our feature, and so adding a new target makes it possible to keep those tests lightweight while still allowing us to a richer test experience for the integration.
        """#,
      timestamp: (19 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We will add this test target to `Package.swift` under the `client` section, since we will run client code in these integration tests:
        """#,
      timestamp: (20 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        .testTarget(
          name: "GameOverFeatureIntegrationTests",
          dependencies: [
            "GameOverFeature",
            "IntegrationTestHelpers",
            "SiteMiddleware",
          ]
        ),
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This test target depends on the core `GameOverFeature`, which is the iOS code, `IntegrationTestHelpers` which holds the code that will allow us to automatically derive and API client from the server code, and then `SiteMiddleware`, which is the server code that runs the site.
        """#,
      timestamp: (20 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        With the `Package.swift` updated we need to create the `GameOverFeatureIntegrationTests` directory inside the `Tests` directory, and create a new test file with a stub of a test:
        """#,
      timestamp: (21 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import XCTest

        class GameOverFeatureIntegrationTests: XCTestCase {
          func testSubmitSoloScore() {
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now if we try to run this test we will find we can't, because Xcode has not created a scheme for this test target. We could manually add the test to one of our preexisting schemes, but that will slow down our existing tests quite a bit because we're bringing in more dependencies for this style of test. Instead we can create a brand new dedicated scheme for this test target.
        """#,
      timestamp: (21 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So now that things are building and tests can run, where do we even start with writing such an integration test?
        """#,
      timestamp: (22 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Well, amazingly we can actually let the failing test dependencies guide us like it did in our past episodes on [better test dependencies](/collections/dependencies/better-test-dependencies). In those episodes we demonstrated how to write a test from scratch by just plugging in a failing environment of dependencies so that we could instantly see which dependencies are being used in a test, and then we incrementally filled in those dependencies until we got a passing test, which led us to discover our feature like we had a flashlight in a dark room.
        """#,
      timestamp: (23 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s do that here. We can begin this test just like any Composable Architecture test, by first constructing a test store with the game over screen’s domain:
        """#,
      timestamp: (23 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import ComposableArchitecture
        import GameOverFeature
        ...
        let store = TestStore(
          initialState: GameOverState(
            completedGame: .mock,
            isDemo: false
          ),
          reducer: gameOverReducer,
          environment: .failing
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `GameOverState` takes a few arguments, like a `CompletedGame`, which is a data type holding the final data for the game that was just played, as well as an `isDemo` boolean, which is used to determine if this screen is showing as part of an App Clip, in which case the experience and UI changes slightly. We also start the environment off as a failing environment, which means if any of this feature’s dependencies are executed it will instantly fail the test suite, which gives us the opportunity to be exhaustive in figuring out which dependencies we should be supplying implementations for.
        """#,
      timestamp: (24 * 60 + 12),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        With the test store set up, what exactly do we want to test? The majority of the game over screen’s functionality is kicked off when the screen first appears. That triggers a number of things to happen, including sending the API request to the server with the player’s puzzle and score. So, let’s send an `.onAppear` action and see what happens:
        """#,
      timestamp: (24 * 60 + 57),
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
        > Executed 1 test, with 15 failures (14 unexpected) in 0.068 (0.070) seconds

        Wow, ok. There were 12 failures in just that one single test, so clearly this feature is doing quite a bit of work when `.onAppear` occurs.
        """#,
      timestamp: (25 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we look at the failures we’ll see a whole bunch of dependencies being used that we haven’t yet provided implementations for:
        """#,
      timestamp: (25 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - There’s some mentions of a `RunLoop`, so we must be performing some asynchronous work and needing to schedule it back to the main thread.
        """#,
      timestamp: (25 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - There’s mention of the `ApiClient`, which isn’t surprising since we expect to be making some requests.
        """#,
      timestamp: (26 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - There’s mention of a `LocalDatabaseClient` and a `ServerConfig`. We use both of these things to determine if we should show the upgrade interstitial or not, because we allow you to play a few games before we start to annoy you with prompts to purchase the full game.
        """#,
      timestamp: (26 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - There’s also mention of `UserNotificationsClient` dependency, which is used to determine if we should ask you to enable push notifications for the app.
        """#,
      timestamp: (26 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And there’s mention of an `AudioPlayerClient`, which we use to play some music specifically for game over.
        """#,
      timestamp: (26 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, we got quite a few dependencies we need to provide before we are going to get a passing test, and more may pop up as we go because we providing a dependency could cause us to access new logic that then grabs a different dependency.
        """#,
      timestamp: (26 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Perhaps the easiest one to provide is the `RunLoop`. We have two choices for this dependency. We could use a `TestScheduler`, which allows us to explicitly control the flow of time in our test, or we can use an `ImmediateScheduler`, which just executes its actions immediately with no thread hops. To keep things simple let’s go with the immediate scheduler:
        """#,
      timestamp: (27 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > Executed 1 test, with 8 failures (8 unexpected) in 0.052 (0.054) seconds

        Nice, we’ve already fixed 4+ failures.
        """#,
      timestamp: (27 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s another failure that’s pretty easy to fix. When a timed game is about to end you tend to be in a frenzied mode of trying to make as many words as possible, and so when time does officially run out and the game over screen fades into view you run the risk of accidentally tapping on something in that screen. And for that reason we initially disable the entire screen, and then one second later re-enable it. To accomplish this we send a `.delayedOnAppear` action with a 1 second delay, and in that action we mutate state to enable. That can be captured in this test using the `.receive` method on the store to make it explicit we expect an effect to feed an action back into the system:
        """#,
      timestamp: (27 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.delayedOnAppear) {
          $0.isViewEnabled = true
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > Executed 1 test, with 7 failures (7 unexpected) in 0.055 (0.057) seconds

        One more failure has been fixed.
        """#,
      timestamp: (29 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Another easy failure to fix would be the audio player. We actually already have test coverage on this dependency in our non-integration unit tests, and so it’s probably not necessary to rehash that work here. Instead the integration tests should be more focused on the direct interactions between client and server. So, if we use a `.noop` dependency for the audio client we should fix a few more failures:
        """#,
      timestamp: (29 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.audioPlayer = .noop
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        > Executed 1 test, with 5 failures (5 unexpected) in 0.448 (0.450) seconds

        Two more failures have been fixed, and we’re slowly chipping away.
        """#,
      timestamp: (30 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s a few other dependencies that are kinda similar in spirit to the audio player in that they are used to in client-side functionality that doesn’t really concern the server. This includes the `LocalDatabaseClient`, `ServerConfigClient`, and `UserNotificationsClient`, which are used to determine when to show the upgrade interstitial and when to ask for push notification permissions. We already have full test coverage on those aspects of game over in our units tests, so let’s not test those pieces of functionality right now, and instead focus on the actual client-server communication paths. This means we can put in some stubbed effects for those endpoints to keep us from having to think about them:
        """#,
      timestamp: (30 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.database.playedGamesCount = { _ in .init(value: 0) }
        environment.serverConfig.config = { .init() }
        environment.userNotifications.getNotificationSettings = .none
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now we’re down to just 2 failures!

        > Executed 2 tests, with 2 failures (2 unexpected) in 0.447 (0.450) seconds
        """#,
      timestamp: (32 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Note that we are still stubbing only the bare essentials of the dependency. There’s no need to stub the entire database client, or server config client or user notifications client because we know that only these 3 specific endpoints are ever accessed. This makes our test stronger by forcing us to describe exactly what parts of our dependency are being used when testing a specific slice of a feature.
        """#,
      timestamp: (32 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        That said, we're down to 2 failures and they both appear to be related to the API:
        """#,
      timestamp: (32 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        🛑 ApiClient.currentPlayer is unimplemented
        ...
        🛑 ApiClient.apiRequest(.games(.submit(...))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The first failure comes from us trying to access the “current player” of the API, which refers to the currently authenticated player. We do this because we need to check if they have already purchased the full version of the game in order to prevent showing the upgrade interstitial.
        """#,
      timestamp: (33 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The second failure is an API request being made in order to submit the game to the leaderboards. In the past the way we’ve handled this is to override this particular route in the API client:
        """#,
      timestamp: (33 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.apiClient.override(
          route: .games(.submit(<#T##ServerRoute.Api.Route.Games.SubmitRequest#>)),
          withResponse: <#T##Effect<(data: Data, response: URLResponse), URLError>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This allows us to provide a response for just this one route, and every other route will continue to fail. However, overriding this route doesn’t allow us to exercise any of the server code. We are bypassing everything the server does in order to force a particular response for this route.
        """#,
      timestamp: (33 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Integration testing super powers: the server"#,
      timestamp: (34 * 60 + 24),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        It would be far better if we could somehow derive an API client from the server code so that when we make an API request it runs actual server code under the hood. And this is actually possible and it’s pretty awesome to do.
        """#,
      timestamp: (34 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s an initializer on `ApiClient` that allows us to specify something known as a “middleware” and a `router`:
        """#,
      timestamp: (34 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import IntegrationTestHelpers
        ...
        environment.apiClient = .init(
          middleware: <#T##Middleware<StatusLineOpen, ResponseEnded, Unit, Data>##Middleware<StatusLineOpen, ResponseEnded, Unit, Data>##(Conn<StatusLineOpen, Unit>) -> IO<Conn<ResponseEnded, Data>>#>,
          router: <#T##Router<ServerRoute>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        A middleware is basically the atomic unit that runs a server in our experimental web libraries. It is analogous to reducers from the Composable Architecture. It also has lots of fun compositions that allow you to break bigger problems down into smaller ones.
        """#,
      timestamp: (35 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s a function that allows us to construct this middleware value as long as we provide it something called a `ServerEnvironment`:
        """#,
      timestamp: (35 * 60 + 18),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import SiteMiddleware
        ...
        environment.apiClient = .init(
          middleware: siteMiddleware(environment: <#T##ServerEnvironment#>),
          router: <#T##Router<ServerRoute>#>
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `ServerEnvironment` serves the exact same purpose that environments have in the Composable Architecture. It holds all of the dependencies the server needs to do its job. It holds just 10 dependencies right now:
        """#,
      timestamp: (35 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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

          ...
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This includes important things such as:
        """#,
      timestamp: (35 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - A client for interacting with our Postgres database.
        """#,
      timestamp: (35 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - A dictionary client for querying for valid words. This is the exact same client we use over in the iOS app.
        """#,
      timestamp: (35 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `ItunesClient` handles sending receipt data to Apple for verification.
        """#,
      timestamp: (36 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `router` is the value we use to parse incoming requests to figure out how we want to execute the logic for that request.
        """#,
      timestamp: (36 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `SnsClient` is how we interact with Amazon’s SNS service, which is how we send push notifications.
        """#,
      timestamp: (36 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And more.
        """#,
      timestamp: (36 * 60 + 22),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And at the bottom of this file we also have a `.failing` implementation of this environment, which allows us to be exhaustive with our dependencies, just as we do in the Composable Architecture. Now you may get a sense that there are quite a few similarities between how we build features with the Composable Architecture and how we build the server. That’s definitely true, but unfortunately we’re not yet ready to dive too deeply into how we can build server side applications from scratch. We’re waiting for a few more things to pan out with concurrency in Swift before we start discussing those topics on Point-Free.
        """#,
      timestamp: (36 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But that’s ok, even without understanding the intricacies of how we build the server we can still make our way through this test. We’ll stick in a middleware that uses the `.failing` server environment, and for the router we can also use a `.failing` one:
        """#,
      timestamp: (36 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        environment.apiClient = .init(
          middleware: siteMiddleware(environment: .failing),
          router: .failing
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now the API client that we hand off to the Composable Architecture is completely powered by our server code. To see this we can run tests and we will suddenly get a bunch of failures due to using dependencies on the server that have not be implemented yet.
        """#,
      timestamp: (37 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now we just repeat the script that we followed for the Composable Architecture, but now we are doing it for the server. We can find one by one plug in test dependencies for each of the failures we have. For example, there are failures that we are using endpoints from the router that are currently unimplemented.
        """#,
      timestamp: (37 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We actually have a mock server router already defined that we can use. It takes care of mocking out the dependencies that the router needs, such as a date initializer, a SHA256 implementation, and JSON encoders and decoders:
        """#,
      timestamp: (38 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var serverEnvironment = ServerEnvironment.failing
        serverEnvironment.router = .test

        var environment = GameOverEnvironment.failing
        environment.audioPlayer = .noop
        environment.apiClient = .init(
          middleware: siteMiddleware(environment: serverEnvironment),
          router: .mock
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And now when we run tests we are back down to just 2 failures:
        """#,
      timestamp: (38 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > Executed 1 test, with 2 failures (1 unexpected) in 0.464 (0.467) seconds

        The first failure we have is mentioning that we are using some endpoint on the `DatabaseClient` that is current unimplemented:
        """#,
      timestamp: (39 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 DatabaseClient.fetchPlayerByAccessToken is unimplemented

        This endpoint is pretty self explanatory, it just fetches a player from an access token, and that access token was given to us from the client.
        """#,
      timestamp: (39 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The easiest way to implement this endpoint is to simply override it with some mock data. We can do this by providing a closure:
        """#,
      timestamp: (39 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        serverEnvironment.database.fetchPlayerByAccessToken = { _ in
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then in here we need to return something known as an `EitherIO`. This type plays an analogous role as `Effect` does in the Composable Architecture. It’s the thing that interacts with the outside world and performs side effects.
        """#,
      timestamp: (39 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can create one of these that immediately returns a value, which in this case is a `Player`:
        """#,
      timestamp: (40 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        serverEnvironment.database.fetchPlayerByAccessToken = { _ in
          .init(value: .blob)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Another option would be to use an actual live database client, meaning one that speaks to a real life Postgres database running on our local computer. This can even further strengthen our integration tests since you exercising even more of the application, but that takes a little more time to set up so let’s go with this approach for now.
        """#,
      timestamp: (40 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Running tests again we see that the failure for the `fetchPlayerByAccessToken` endpoint goes away, but new ones show up:
        """#,
      timestamp: (40 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 DictionaryClient.contains is unimplemented

        The `DictionaryClient` failure is due to the fact that when scores are submitted we verify that the game played actually makes sense. We don’t want people submitting junk data to our leaderboards just to juice the stats. And in the process of verifying we make use of the dictionary client to check the words that were submitted.
        """#,
      timestamp: (40 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, hopefully by providing a better `DictionaryClient` dependency we can fix both of these failures. Let’s just override the `contains` endpoint to say that any word passed to it is contained in the dictionary:
        """#,
      timestamp: (41 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        serverEnvironment.dictionary.contains = { _, _ in true }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now when we run tests we see that some failures went away, but we got a new one:
        """#,
      timestamp: (41 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 DatabaseClient.submitLeaderboardScore is unimplemented

        This is a new database endpoint being accessed, and it’s the one that actually submits the puzzle and scores to the leaderboards table in the database. It’s a function that takes a `SubmitLeaderboardScore` as an argument, which holds all the data needed to insert the row into the table, and returns a `LeaderboardScore`, which is a data type that represents the row of data just inserted into the database:
        """#,
      timestamp: (42 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        submitLeaderboardScore: (SubmitLeaderboardScore) -> EitherIO<Error, LeaderboardScore>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can override it like the last one, and provide an `EitherIO` value that immediately returns `LeaderboardScore` value. We’ll construct this value to represent the game that the `initialState` of the test store was seeded with:
        """#,
      timestamp: (42 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
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
        """#,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Again, we could have also used a live database client to handle all of this for us, and then we’d get even stronger guarantees in our tests, but this will do for now.
        """#,
      timestamp: (45 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We are getting closer, but now when we run tests a new failure pops up:
        """#,
      timestamp: (45 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > 🛑 DatabaseClient.fetchLeaderboardSummary is unimplemented

        It seems that we are accessing a new database endpoint. This is happening because as soon as we successfully submit the leaderboard score we immediately fetch the leaderboard summary, which breaks down the player’s score into ranks for the past day, week and all time.
        """#,
      timestamp: (45 * 60 + 25),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The `fetchLeaderboardSummary` is a function that takes a `FetchLeaderboardSummaryRequest`, which describes what kind of summary we want (i.e. what game mode, what time scope and what language), and returns a `Rank`:
        """#,
      timestamp: (46 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        var fetchLeaderboardSummary: (FetchLeaderboardSummaryRequest) -> EitherIO<Error, LeaderboardScoreResult.Rank>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This gets called 3 times by the server, one for each time scope corresponding to past day, past week and all time.
        """#,
      timestamp: (46 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To aid us in implementing this endpoint we can define a little dictionary that maps the time scopes to some mock ranks:
        """#,
      timestamp: (46 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        let ranks: [TimeScope: LeaderboardScoreResult.Rank] = [
          .allTime: .init(outOf: 10_000, rank: 1_000),
          .lastWeek: .init(outOf: 1_000, rank: 100),
          .lastDay: .init(outOf: 100, rank: 10),
        ]
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then implementing `fetchLeaderboardSummary` is as easy as reading from the dictionary:
        """#,
      timestamp: (47 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        serverEnvironment.database.fetchLeaderboardSummary = {
          .init(value: ranks[$0.timeScope]!)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Running tests we see we are down to just one failure!
        """#,
      timestamp: (47 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        > Executed 1 test, with 1 failure (0 unexpected) in 0.464 (0.466) seconds
        >
        > 🛑 The store received 1 unexpected action after this one: …
        >
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

        We are getting so close!
        """#,
      timestamp: (48 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This failure is telling us that the system received an action from an effect that we didn’t explicitly assert on. This is happening because now that we have all of the server dependencies sorted out we are finally getting some data back from the API, which feeds into the system, and the Composable Architecture forces us to be exhaustive and explicit with how effects execute in our tests.
        """#,
      timestamp: (48 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        From the failure we can clearly see that we received a `.submitGameResponse` action, which makes sense because we are finally getting a response back from the API:
        """#,
      timestamp: (48 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(<#T##Result<SubmitGameResponse, ApiError>#>))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Further we expect to get a successful response:
        """#,
      timestamp: (48 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(<#T##SubmitGameResponse#>)))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct a `SubmitGameResponse` we have to decide what kind of game we submitted, and in this case it was a `solo` game:
        """#,
      timestamp: (48 * 60 + 55),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(.solo(<#T##LeaderboardScoreResult#>))))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct one of these `LeaderboardScoreResult` values we just need to provide a dictionary of ranks keyed by time scopes:
        """#,
      timestamp: (49 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(.solo(.init(ranks: <#T##[TimeScope : LeaderboardScoreResult.Rank]#>)))))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And that happens to be exactly what we defined above to help us with the database endpoint:
        """#,
      timestamp: (49 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(.solo(.init(ranks: ranks)))))
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then, when we receive this action we expect there will be some state mutations because the UI needs to display these ranks. We can open up the expectation closure, which is where we perform the mutations we think we occur after receiving this action:
        """#,
      timestamp: (49 * 60 + 17),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(.solo(.init(ranks: ranks))))) {
          $0
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we can even use autocomplete on `$0` in order to explore what kind of state is held in `GameOverState` in order to figure out what should change.
        """#,
      timestamp: (49 * 60 + 35),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s a field called `summary` that holds something called a `RankSummary`, so that seems like a good start. To construct one of those we choose between a `.dailyChallenge` case and a `.leaderboard` case. This is because the game over screen looks slightly different for each of those times of games. For the test we are writing now we are not dealing with daily challenges, so let’s go with the `.leaderboard` case:
        """#,
      timestamp: (49 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        $0.summary = .leaderboard(<#T##[TimeScope : LeaderboardScoreResult.Rank]#>)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        To construct the `.leaderboard` case we need to supply a dictionary of ranks, which again is exactly what we defined earlier:
        """#,
      timestamp: (50 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        store.receive(.submitGameResponse(.success(.solo(.init(ranks: ranks))))) {
          $0.summary = .leaderboard(ranks)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        When we run tests they now all pass!
        """#,
      timestamp: (50 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So we now have our first passing integration test. We are writing what seems to be a standard, run-of-the-mill Composable Architecture test by feeding in a sequence of user actions and then asserting how state changes and how effects execute. But secretly, under the hood, the API client that the game over feature is using to run its logic is actually calling out to server code. And that server code is doing a ton of work, including routing the incoming request, executing multiple database queries, and molding all that data into a shape that can be sent back to the client. And then the client decodes that data and presents it in the UI.
        """#,
      timestamp: (50 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And it’s worth mentioning that integration tests are not an either/or concept, but rather more like a spectrum. We consider the test we just now wrote to be an integration test because it is testing how two very different components interact with each other, the client and the server. We’ve also used the term “integration tests” in the past to describe writing tests for multiple Composable Architecture features at once.
        """#,
      timestamp: (51 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But in each of these cases there’s another level of integration we could aspire too. For example, we decided to stub out the database in our integration test, but we could have used a live database. That would have allowed testing 3 independent components: the iOS client, the server and the Postgres database. And for Composable Architecture integration tests we could always go to the extreme by only allowing ourselves to write tests for the root app reducer in order to definitely prove that all of our features play nicely with each other.
        """#,
      timestamp: (51 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But doing this comes with pros and cons. The deeper an integration test the stronger it becomes, but also the more difficult it is to set up and maintain. And vice versa, the shallower an integration test the easiest it is to write and maintain, but also it doesn’t test as much as it could.
        """#,
      timestamp: (52 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, it’s important to keep these principles in mind when approaching integration tests so that you can see where your threshold for pain versus reward lies. Perhaps when testing super focused slices of a feature it’s ok to just use a unit test that stubs out dependencies, and then maybe a few core flows of your application have a deeper test for bringing in more disparate parts of the application.
        """#,
      timestamp: (52 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But the most important thing to know is that if your server and client are both built in Swift then it is totally possible to write integration tests, it’s easy to turn the dial that determines just how much integration you want, and it’s totally awesome to write tests like this.
        """#,
      timestamp: (52 * 60 + 50),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And we want to also callout just how cool it is to write server tests that kinda look like our Composable Architecture tests. The failing dependencies led us step-by-step through the process of getting a passing test, and if we ever start using a new dependency on this part of our server code we should be instantly notified in our tests so that we can fix it. We’re going to have a lot to say about server-side Swift in the future on Point-Free, and we will be applying a lot of the principles we have learned with the Composable Architecture.
        """#,
      timestamp: (53 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Conclusion"#,
      timestamp: (53 * 60 + 32),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Well, that concludes our tour of the isowords code base. There’s a ton of stuff that we haven’t covered, but we just had to choose some of our favorite topics and focus on them. We’ll definitely be referring back to this code base many times on Point-Free as we start to explore new topics.
        """#,
      timestamp: (53 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Until next time!
        """#,
      timestamp: (53 * 60 + 49),
      type: .paragraph
    ),
  ]
}
