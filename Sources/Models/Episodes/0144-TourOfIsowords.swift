import Foundation

extension Episode {
  public static let ep144_tourOfIsowords = Episode(
    blurb: """
      It's time to take a look at the other half of the [isowords](https://www.isowords.xyz) code base: the server! We'll get you running the server locally, and then explore some benefits of developing client and server in Swift, such as simultaneously debugging both applications together, and sharing code.
      """,
    codeSampleDirectory: "0144-tour-of-isowords-pt3",
    exercises: _exercises,
    id: 144,
    length: 32 * 60 + 25,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_620_018_000),
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
    sequence: 144,
    subtitle: "Part 3",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 75_040_556,
      downloadUrls: .s3(
        hd1080: "0144-trailer-1080p-ae83079618d84e4baf5cbbeb0a2df306",
        hd720: "0144-trailer-720p-e9241f26e1734e96ac64e68406449a8a",
        sd540: "0144-trailer-540p-1f06a22a4a814b3b9ad5bae55f3f069d"
      ),
      vimeoId: 542_626_322
    )
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep144_tourOfIsowords = Self(
    bytesLength: 363_938_131,
    downloadUrls: .s3(
      hd1080: "0144-1080p-ae83079618d84e4baf5cbbeb0a2df306",
      hd720: "0144-720p-e9241f26e1734e96ac64e68406449a8a",
      sd540: "0144-540p-1f06a22a4a814b3b9ad5bae55f3f069d"
    ),
    vimeoId: 542_626_967
  )
}

extension Array where Element == Episode.TranscriptBlock {
  public static let ep144_tourOfIsowords: Self = [
    Episode.TranscriptBlock(
      content: #"Introduction"#,
      timestamp: 5,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this is pretty amazing. By using the Composable Architecture we have a nice, data-oriented description of all the actions that can happen in our application, and that makes it trivial to replay a script of user actions to emulate what it’s like for someone to actually play the game. And even better, creating this autonomously running trailer looks no different than any other feature we have built in this application. It consists of some domain, a reducer for the logic, and a view. We didn’t have to hack in any escape hatches or litter our core game code with weird logic just to support the trailer. It just all came basically for free. And we could even write tests for the trailer if we really wanted to, but we haven’t gone that far yet 😁
        """#,
      timestamp: 5,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So far we’ve mostly focused on running the iOS client locally and explored some of the more interesting parts of the code base. But the client is only half of what makes isowords the game it is today. The other half is the server.
        """#,
      timestamp: 49,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The server handles a variety of tasks:
        """#,
      timestamp: (1 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It allows the client to authenticate with the server so that the user can be associated with scores submitted to the leaderboards. Right now we heavily lean on Game Center to allow for seamless authentication, which means we don’t have to ask you for any info whatsoever.
        """#,
      timestamp: (1 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The server also handles generating a random daily challenge puzzle each day that everyone in the world plays, and it does some extra work to make sure that people can’t cheat by playing the game multiple times.
        """#,
      timestamp: (1 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The server is responsible for sending push notifications, which currently happens when a new daily challenge is available, or if it is about to end and you haven’t finished your game yet.
        """#,
      timestamp: (1 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - And finally the server handles in app purchases. The game is free to play, but after you’ve played a few games we will start to show you annoying interstitials to entice you to support our development efforts. The server is used to verify those transactions.
        """#,
      timestamp: (1 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The server is built entirely in Swift using our experimental Swift web libraries, which is also what we use to build this very site. We want to devote some time on Point-Free building up those concepts from scratch, but we are waiting for the concurrency story to play out on Swift Evolution before diving too deep into those topics.
        """#,
      timestamp: (2 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There are a lot of really cool things in the server portion of this code base that we’d like to demo, such as how we share code between client and server, how we designed the API client for communicating with the server, and how we write integration tests for both client and server at the same time.
        """#,
      timestamp: (2 * 60 + 26),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Client-server debugging"#,
      timestamp: (2 * 60 + 46),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s start by getting everyone running the isowords server locally.
        """#,
      timestamp: (2 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, let’s start by getting everyone running the isowords server locally. There’s another bootstrap command we can run to get our local environment working:
        """#,
      timestamp: (2 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        $ make bootstrap-server
        """#,
      timestamp: nil,
      type: .code(lang: .shell)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This command makes sure that you have Postgres running locally, and if not it tells you to install, and if you do have it installed it will create some isowords databases on your machine for development and testing.
        """#,
      timestamp: (3 * 60 + 5),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Once that is completed you should be able to select the `server` target in Xcode and hit cmd+R to run the server. After a moment of compiling you should get some logs in the console letting you know everything is up and running:
        """#,
      timestamp: (3 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        ⏳ Bootstrapping isowords...
          ⏳ Loading environment...
          ✅ Loaded!
          ⏳ Connecting to PostgreSQL
          ✅ Connected to PostgreSQL!
          -----------------------------
        ✅ isowords Bootstrapped!
        Listening on 0.0.0.0:9876...
        """#,
      timestamp: nil,
      type: .code(lang: .plainText)
    ),
    Episode.TranscriptBlock(
      content: #"""
        By default the server runs on port 9876, so you should be able to visit `0.0.0.0:9876` in your browser and see the isowords homepage.
        """#,
      timestamp: (3 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now the really cool thing is that earlier when we were running the isowords app in the iOS simulator it was technically hitting `0.0.0.0:9876` for the API. But, since the server wasn’t running those requests would immediately fail, and that’s why we saw blocked out UI elements on the home screen.
        """#,
      timestamp: (4 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we were to run the app now we should actually see some data populating. In this case it says that no one has played the daily challenge yet, and that’s not too surprising since we are running a local instance of the server that no one else is hitting.
        """#,
      timestamp: (4 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can drill down into the daily challenge screen, start a game, play a few words, force end the game, and we’ll see we even get results back in the game over screen. Again nothing too surprising here. We don’t have any other players hitting this local environment so of course we placed number 1!
        """#,
      timestamp: (5 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, the server is definitely running and the simulator is hitting that server. One really interesting thing about having both the client and server written in Swift is that we can run both targets at the same time.
        """#,
      timestamp: (5 * 60 + 58),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        That means we have two debuggable executables running allowing us to put breakpoints at any point of the full the request-to-response lifecycle.
        """#,
      timestamp: (6 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, when you finish an isowords game we don’t just submit your score to the leaderboards so that it can be recorded. That would make it very easy to send fraudulent data. We instead send the entire puzzle and every move you made on the cube, which consists of the letters you played to find a word and each time you double tapped to remove a cube.
        """#,
      timestamp: (6 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then the server verifies that data to make sure you played a legitimate game. It does this by iterating over the list of moves passed to the server and making sure that that move was even possible and that it resulted in a valid word.
        """#,
      timestamp: (6 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we ever want to live debug the moment the iOS client submits a game to the leaderboards and the moment the server tries to verify the payload, we can just put in some breakpoints. If we hop over to `Verification.swift` we will see the function that performs the verification. We can put a breakpoint in it, play another game in the iOS simulator and end it, and then the breakpoint will be triggered:
        """#,
      timestamp: (7 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
          public func verify(
            moves: Moves,
            playedOn puzzle: ArchivablePuzzle,
            isValidWord: (String) -> Bool
          ) -> VerifiedPuzzleResult? {
        🔵  var puzzle = Puzzle(archivableCubes: puzzle)

          }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        As far as the iOS app is concerned we are still in mid-flight for the API request. We can now live step through server code as the iOS client waits for a response. If we step over a few times we can then step into the `verify` move function, which verifies that just a single move is valid. Stepping through this function we see:
        """#,
      timestamp: (7 * 60 + 49),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - It does some work to make sure all the faces selected in the word are unique. This is because you can’t use a single cube face multiple times to form a word.
        """#,
      timestamp: (8 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - Then it verifies it’s a valid by:
            - checking that the played word contains at least 3 letters
            - the word is in the dictionary
            - the score passed to us from the client matches the score that we compute locally
            - and that the word was formed using only playable, touching letters
        """#,
      timestamp: (8 * 60 + 41),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Being able to live debug both the client and the server at the same time in the same IDE is pretty awesome.
        """#,
      timestamp: (9 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Sharing domain code"#,
      timestamp: (9 * 60 + 32),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, now we’ve got the server bootstrapped and the simulator and server are talking to each other, let’s dive into some of the really cool things we’ve accomplished with this monorepo.
        """#,
      timestamp: (9 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Perhaps the main reason to write server code in Swift is the hope that you can share code between the client and server. This can be difficult to do in practice, but it is absolutely possible. We were able to share a pretty significant chunk of code between server and client, and it has helped us catch potential problems earlier, allowed us to keep client and server in sync more easily, and just have more confidence in our code.
        """#,
      timestamp: (9 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s hop over to the `Package.swift` file to see how we share modules between client and server.
        """#,
      timestamp: (10 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        As we mentioned before our `Package.swift` is a little intense. It houses all of the modules for both the client and the server, of which they are currently 91. So the file is very long, but it’s also structured a little differently from a standard SPM manifest. At the very top we get the first hint that something is different by noticing the `package` variable is defined as `var` rather than a `let` as is customary:
        """#,
      timestamp: (10 * 60 + 13),
      type: .paragraph
    ),
    .init(
      content: """
        One of our viewers [pointed out](https://github.com/pointfreeco/isowords/discussions/106) that `Package` is a class in SPM and so the `var` is not necessary. We can use `let` and still make these mutations just fine.
        """,
      timestamp: nil,
      type: .correction
    ),
    Episode.TranscriptBlock(
      content: #"""
        // MARK: - shared
        var package = Package(
          …
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is because the products defined here are only the modules that are shared between client and server. There are two sections down below that further mutate this `package` variable to add additional products and dependencies for both the client and server. In fact, if we click the “No selection” link next to `Package.swift` in the directory navigator we will see the 3 main sections of the file. There’s the portion dedicated to shared code, which we are currently looking at, and then markers for client and server.
        """#,
      timestamp: (10 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we hop down to the client marker we will see this is where we depend on the Composable Architecture package, which of course only makes sense for the iOS client. We’ll also see a whole bunch of products and targets being added to the package.
        """#,
      timestamp: (10 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we hope down to the server marker we will see a few more dependencies being added, such as a library for signing AWS requests, a library for handling Postgres databases, as well as our experimental Swift web libraries. We also add some new products to the package, including executables that run the server and various cron jobs, as well as targets that expose the functionality for certain features of the server, such as leaderboards, daily challenges and verifying Apple receipts.
        """#,
      timestamp: (11 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s go back to the top to see what code is shared between both client and server:
        """#,
      timestamp: (11 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        products: [
          .library(name: "Build", targets: ["Build"]),
          .library(name: "DictionaryClient", targets: ["DictionaryClient"]),
          .library(name: "DictionarySqliteClient", targets: ["DictionarySqliteClient"]),
          .library(name: "FirstPartyMocks", targets: ["FirstPartyMocks"]),
          .library(name: "PuzzleGen", targets: ["PuzzleGen"]),
          .library(name: "ServerConfig", targets: ["ServerConfig"]),
          .library(name: "ServerRouter", targets: ["ServerRouter"]),
          .library(name: "SharedModels", targets: ["SharedModels"]),
          .library(name: "Sqlite", targets: ["Sqlite"]),
          .library(name: "TestHelpers", targets: ["TestHelpers"]),
          .library(name: "XCTestDebugSupport", targets: ["XCTestDebugSupport"]),
        ],
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Some of the things we are sharing:
        """#,
      timestamp: nil,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - `Build` holds an interface and some types for describing the build number of the iOS app.
        """#,
      timestamp: (11 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - `DictionaryClient` is the interface to an underlying dictionary representation that the game is using, and `DictionarySqliteClient` is a live implementation of that interface using SQLite under the hood.
        """#,
      timestamp: (11 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - `PuzzleGen` holds the code for randomly generating puzzles, which takes into account the distribution of English letters in order to come up with puzzles that are easier to find words. We even use the `swift-gen` library for composable randomness that we open sourced nearly 3 years ago.
        """#,
      timestamp: (11 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - `ServerRouter` holds the code that is responsible for parsing an incoming request to the server so that we know what logic to execute. For example, if a `GET` request for `/api/leaderboards-scores/vocab` comes in we need to figure out that we need to query the database for the vocab leaderboards and send back the results.

            Now you may be wondering why this module is included in the shared modules. After all, it seems to be purely a server concern of parsing requests. Well, this module is pulling double duty, because just as there are times we want to parse an incoming request for the server to process there are also times we want to generate a request to send to the server. In particular, the iOS client needs to construct API requests so that it can actually load some data from the server.

            These are two sides of the same coin, and the code to accomplish both tasks lives in one place, which we call the `ServerRouter` module. We’ll take a deeper look into this in a moment.
        """#,
      timestamp: (12 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - The `SharedModels` module holds a bunch of types and functions that are important for both client and server. Things like the fundamental definition of what an isowords puzzle is, functions for computing scores on a puzzle, as well as the models that are used to allow the client and server to communicate with each other.
        """#,
      timestamp: (12 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The code in these packages is not insignificant. It’s nearly 4,000 lines of code and helps create a kind of connective tissue between client and server. It gives us a lot of confidence that changes in one isn’t going to break the other, and honestly makes building new features a joy.
        """#,
      timestamp: (13 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The most interesting of these shared modules is `SharedModels` and `ServerRouter`, so let’s take a deeper look at each of them.
        """#,
      timestamp: (13 * 60 + 27),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, if we browse the `SharedModels` directory we will find a bunch of core domain types that define what exactly a puzzle is in isowords. We could start by visiting the `CubeFace.swift` file which holds a data type that describes a face:
        """#,
      timestamp: (13 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct CubeFace: Codable, Equatable {
          public var letter: String
          public var side: Side
          public var useCount: Int

          …

          public enum Side: Int, CaseIterable, Codable, Equatable, Hashable {
            case top = 0
            case left = 1
            case right = 2
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s defined by the letter on the face, what “side” it’s on (.e.g. top, left or right), and how much times that face has been used.
        """#,
      timestamp: (13 * 60 + 53),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We can then back up a level and look at the data type that defines a single cube in the puzzle by visiting the `Cube.swift` file:
        """#,
      timestamp: (14 * 60 + 1),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct Cube: Codable, Equatable {
          public var left: CubeFace
          public var right: CubeFace
          public var top: CubeFace
          public var wasRemoved: Bool

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This holds 3 cube faces for left, right and top, as well as a boolean that determines if the cube was removed, which can happen if you double tap a cube.
        """#,
      timestamp: (14 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Zooming out one more level we come to the `Puzzle.swift` file which defines the data type for an entire isowords puzzle:
        """#,
      timestamp: (14 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public typealias Puzzle = Three<Three<Three<Cube>>>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s a simple typealias and uses some `Three` type that we haven’t discussed yet. The `Three` type is our type-safe version of an array of 3 elements. We want to make sure to force the puzzle to be exactly a 3x3x3 cube, and to do that we had originally defined `Three` as a generic struct with 3 fields:
        """#,
      timestamp: (14 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        struct Three<A> {
          let first, second, third: A
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        However, there seems to be a bug in the Swift compiler that led to crashes when using this type and building for release. We fixed it by boxing up the elements in a private array, and then controlling the ways in which this type can be constructed and accessed:
        """#,
      timestamp: (14 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        @dynamicMemberLookup
        public struct Three<Element>: Sequence {
          …
          private var rawValue: [Element]
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It’s not as ideal as if we could have compile time proof that our type holds exactly 3 values, but it’s good enough.
        """#,
      timestamp: (15 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Another core game data type is this `Move` type in `Move.swift`:
        """#,
      timestamp: (15 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct Move: Codable, Equatable {
          public var playedAt: Date
          public var playerIndex: PlayerIndex?
          public var reactions: [PlayerIndex: Reaction]?
          public var score: Int
          public var type: MoveType

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It contains all the data necessary to describe a move from a player, such as the timestamp it was played, the player index of the player (which is only important for multiplayer games), the reactions to the move (again only important for multiplayer games), the score and the type of move. The type of move is described by an enum because it can either be that a word was played or a cube was removed:
        """#,
      timestamp: (15 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public enum MoveType: Codable, Equatable {
          case playedWord([IndexedCubeFace])
          case removedCube(LatticePoint)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        A `.playedWord` move consists of a sequence of this thing called `IndexedCubeFace`, which is way of identifying cube faces in the puzzle. In consists of an index, called a `LatticePoint`, which is a triplet of either 0, 1 or 2:
        """#,
      timestamp: (15 * 60 + 36),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct LatticePoint: Codable, Equatable, Hashable {
          public enum Index: Int, CaseIterable, Codable, Comparable {
            case zero = 0
            case one = 1
            case two = 2
          }

          public var x: Index
          public var y: Index
          public var z: Index

          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And a cube face side. Those two pieces of information allow us to uniquely point to any face on the cube. On the other hand, removing a cube only needs one of these `LatticePoint`’s because that’s how we identify an entire cube.
        """#,
      timestamp: (16 * 60 + 3),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this is some pretty heavy duty domain modeling we’re doing for the puzzle. We spent extra time making sure that this modeling was as airtight as possible because any leaks in its facade are going to make the core game logic more complicated, and it’s already quite complicated.
        """#,
      timestamp: (16 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But luckily for us we get to share this domain modeling between client and server. All of these types are transported back and forth between iOS app and server, and all of the benefits we reap on the client are equally applicable on the server. The code we wrote to verify leaderboard scores  on the server side get to take advantage of the succinct data types, making the algorithm simpler and more straightforward. It would be a real bummer if we had to do this domain modeling twice, once for the client and once for the server, and even worse if it was done in different languages.
        """#,
      timestamp: (16 * 60 + 30),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Sharing logic"#,
      timestamp: (17 * 60 + 0),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So this already cool, but sharing code between client and server goes well beyond simply sharing models. We can actually share functionality and behavior. There are two really cool examples of this.
        """#,
      timestamp: (17 * 60 + 0),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We’ve already seen a bit of the first example, and that’s the puzzle verification code. If we hop over to `Verification.swift` we’ll see the code that can be run on any puzzle to verify that the moves supplied were a reasonable set of moves. This means that the played words were actually possible at the time they were played, and that the scores submitted matched what we calculate server side.
        """#,
      timestamp: (17 * 60 + 14),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The cool thing about the code in this file is that it’s actually used on both the server and the client. We’ve already seen how it’s used on the server because it’s run when a score is submitted to the backend, which we witnessed when we put the breakpoint in.
        """#,
      timestamp: (17 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        But we also use these verification functions on the client side. If we hop over to `GameCore.swift` we’ll see that find a method called `removeCube`:
        """#,
      timestamp: (18 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        mutating func removeCube(at index: LatticePoint, playedAt: Date) {
          let move = Move(
            playedAt: playedAt,
            playerIndex: self.turnBasedContext?.localPlayerIndex,
            reactions: nil,
            score: 0,
            type: .removedCube(index)
          )

          let result = verify(
            move: move,
            on: &self.cubes,
            isValidWord: { _ in false },
            previousMoves: self.moves
          )

          guard result != nil
          else { return }

          self.moves.append(move)
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This method is called when we want to remove a cube from the puzzle. It first constructs a `Move` that we want to apply to the current state of the puzzle, it then runs that move and the puzzle through the `verify` function, and if that says everything is ok we append the move to the array of moves.
        """#,
      timestamp: (18 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We see something similar if we jump down to the `playSelectedWord`, which is called when we want to play the selected word. It also constructs the move that we want to apply to the puzzle, runs it through the `verify` function, and then if that checks out we append the move to the moves array and play a sound effect.
        """#,
      timestamp: (18 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        By sharing this logic we can make sure that the verification code between client and server stay in sync. There’s no reason to maintain this verification logic in two separate places. Consolidating this logic into one place also fixes some small bugs we had when we first launched isowords. We were getting a handful of leaderboard submissions failing because there were small race conditions in the view code that allowed the user to create invalid sequences of moves. Sharing this logic fixed all of those problems.
        """#,
      timestamp: (19 * 60 + 16),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There’s another key spot where we share code, and that’s puzzle generation. We generate random puzzles on both the client-side and server-side. The client generates puzzles when you play solo or multiplayer games, and then the server generates them for the daily challenge so that everyone in the world plays the same puzzle.
        """#,
      timestamp: (19 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Again, it would be a bit of a bummer if we had to duplicate the logic required to generate a puzzle, but luckily that is not the case. The `PuzzleGen` module holds some code that is shared between both client and server, and it utilizes a library that we discussed on Point-Free and open sourced nearly three years ago! And that’s our `Gen` library that turns the concept of randomness into a composable unit, similar to other concepts we have discussed on Point-Free such as snapshot testing, parsing, architecture, and more.
        """#,
      timestamp: (20 * 60 + 6),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we hop over to the `English.swift` file we will find out what it takes to generate an English language puzzle. It starts with a transform on the `Gen` type, which is the composable basis of randomness. It allows you to turn a generator of `Value`s into a generator of `Three` values, where `Three` is that generic type holding three fields:
        """#,
      timestamp: (20 * 60 + 37),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        extension Gen {
          public var three: Gen<Three<Value>> {
            zip(self, self, self).map(Three.init)
          }
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        With that defined we define a generator for a random puzzle. The function `randomCubes` takes a generator of letters as an argument:
        """#,
      timestamp: (21 * 60 + 15),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public func randomCubes(for letter: Gen<String>) -> Gen<Puzzle> {
          …
        }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        And this is because we do not simply choose letters from the English language with an equal distribution. Some letters should show up more frequently, such as vowels, and some letters less frequently, such as Zs and Qs.
        """#,
      timestamp: (21 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        To accomplish this we use a helper on `Gen` that allows us to randomly choose from a bunch of values given a table of distributions. Here is how we distribute the letters of the English language:
        """#,
      timestamp: (21 * 60 + 43),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public let isowordsLetter = Gen.frequency(
          (16, .always("A")),
          (4, .always("B")),
          (6, .always("C")),
          (8, .always("D")),
          (24, .always("E")),
          (4, .always("F")),
          (5, .always("G")),
          (5, .always("H")),
          (13, .always("I")),
          (2, .always("J")),
          (2, .always("K")),
          (7, .always("L")),
          (6, .always("M")),
          (13, .always("N")),
          (15, .always("O")),
          (4, .always("P")),
          (2, .always("QU")),
          (13, .always("R")),
          (10, .always("S")),
          (15, .always("T")),
          (7, .always("U")),
          (3, .always("V")),
          (4, .always("W")),
          (2, .always("X")),
          (4, .always("Y")),
          (2, .always("Z"))
        )
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        So, once we have a way of generating random letters with some kind of special distribution, we immediately zip up 3 of those letter generators:
        """#,
      timestamp: (22 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        zip(letter, letter, letter)
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This will give us 3 random letters, one for each side of a cube: top, left and right. Then we map on those three letters in order to embed them in a `Cube` value:
        """#,
      timestamp: (22 * 60 + 24),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        zip(letter, letter, letter)
          .map { left, right, top in
            Cube(
              left: .init(letter: left, side: .left),
              right: .init(letter: right, side: .right),
              top: .init(letter: top, side: .top)
            )
          }
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        That gives us a generator of a random cube with all of its fields populated.
        """#,
      timestamp: (22 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we hit that with the `.three` helper we mentioned above:
        """#,
      timestamp: (22 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        zip(letter, letter, letter)
          .map { left, right, top in
            Cube(
              left: .init(letter: left, side: .left),
              right: .init(letter: right, side: .right),
              top: .init(letter: top, side: .top)
            )
          }
          .three
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        That gives us a random generator of three random cubes.
        """#,
      timestamp: (22 * 60 + 47),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Then we hit that with the `.three` helper again:
        """#,
      timestamp: (22 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        zip(letter, letter, letter)
          .map { left, right, top in
            Cube(
              left: .init(letter: left, side: .left),
              right: .init(letter: right, side: .right),
              top: .init(letter: top, side: .top)
            )
          }
          .three
          .three
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        That gives us a random generator of a 3-by-3 grid of random cubes.
        """#,
      timestamp: (22 * 60 + 54),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And then finally we hit that with the `.three` helper again:
        """#,
      timestamp: (22 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        zip(letter, letter, letter)
          .map { left, right, top in
            Cube(
              left: .init(letter: left, side: .left),
              right: .init(letter: right, side: .right),
              top: .init(letter: top, side: .top)
            )
          }
          .three
          .three
          .three
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        Giving us a random generator of a 3-by-3-by-3 cube of random cubes, which is the same thing as a generator of random puzzles!
        """#,
      timestamp: (22 * 60 + 59),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And this exact code here is run on both the iOS client for generating puzzles locally and the server for generating puzzles. They will simultaneously share the letter distribution logic as well as any other fancy things we may incorporate in the future.
        """#,
      timestamp: (23 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Also we just want to call out that this little bit of code is showing a pattern we have demonstrated on Point-Free time and time again. We develop the concepts for a core, atomic unit that solves a single problem, and then explore the compositions on that type that allow us to break large, complex problems into smaller ones that glue together. We are seeing here that randomness is one of these situations, and we’ve also seen it with snapshot testing, parsing and architecture.
        """#,
      timestamp: (23 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Sharing design patterns"#,
      timestamp: (24 * 60 + 4),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        Now that we've seen not only can we share basic data types, but we can also share the data transformations between those data types and we get a lot of power out of doing that, but also we can share more general design patterns that we like to use on the iOS client with the server as well.
        """#,
      timestamp: (24 * 60 + 4),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, the `Tagged` type is something we love using in the iOS client because it allows us to distinguish identical types that have different semantic meanings. And we use the `Tagged` type in a whole bunch of different models in the iOS client.
        """#,
      timestamp: (24 * 60 + 23),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        If we hop over to `Move.swift` we see that `Tagged` is used to distinguish the player index of the move. In multiplayer games, GameCenter identifies players uniquely by their position in an array of players.
        """#,
      timestamp: (24 * 60 + 40),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public typealias PlayerIndex = Tagged<Move, Int>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This index is used in a lot of different algorithms throughout the application, for example in order to figure out the score of a player, but if we were just passing around integers everywhere, it would become harder to remember what a particular integer represents. By tagging the player index, we can be a little more certain that we're going to use it in the correct way.
        """#,
      timestamp: (24 * 60 + 57),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        `Tagged` is extremely helpful in an iOS client with no corresponding Swift backend, but when you _do_ have a Swift backend, it becomes even more important to assign semantic meaning to what would otherwise be just a bare, primitive type.
        """#,
      timestamp: (25 * 60 + 13),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, our Postgres database has the concept of a "player":
        """#,
      timestamp: (25 * 60 + 32),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct Player: Codable, Equatable {
          public typealias Id = Tagged<Self, UUID>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        We use the `Tagged` type to distinguish its id from other Postgres tables.
        """#,
      timestamp: (25 * 60 + 39),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        GameCenter also has its own concept of a "player". We employ our techniques from our series on [Designing Dependencies](/collections/dependencies) in order to wrap GameKit's APIs in a lightweight way in order to make things more testable, but we also take the opportunity to tag its types in order to assign more semantic meaning, as well.
        """#,
      timestamp: (25 * 60 + 46),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct Player: Equatable {
          public typealias Id = Tagged<Self, String>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        This is another `Player` type but instead of representing a row in a Postgres table, it represents a `GKPlayer` in GameKit.
        """#,
      timestamp: (26 * 60 + 8),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        By tagging both of these player ids with the corresponding data type, we get a more obvious way to distinguish these two data models. If we were to pass these ids around between functions, we would never lose track of what the id represents because it's encoded directly in the types.
        """#,
      timestamp: (26 * 60 + 11),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There are 26 different `Tagged` entities in the isowords code base so far, across both client and server. And it's pretty cool to be able to share this pattern both places!
        """#,
      timestamp: (26 * 60 + 42),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There's another pattern we like to share between client and server, and that's how we design dependencies, which is a topic we've had many of episodes about on Point-Free. What we like to do is write lightweight wrapper types for just the interface of the underlying dependency, and then separately create implementations of the live, heavyweight version of the dependency.
        """#,
      timestamp: (27 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        There's another pattern we like to share between client and server, and that's how we design dependencies, which is a topic we've had many of episodes about on Point-Free. What we like to do is write lightweight wrapper types for just the interface of the underlying dependency, and then separately create implementations of the live, heavyweight version of the dependency.
        """#,
      timestamp: (27 * 60 + 7),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We've got a bunch of these dependencies defined in the codebase. If we take a look at the sources directory we'll see:
        """#,
      timestamp: (27 * 60 + 28),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We have separate `ApiClient` and `ApiClientLive` modules that follow the pattern of one module for the lightweight interface and another module for the heavyweight implementation.
        """#,
      timestamp: (27 * 60 + 34),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We have an `AudioPlayerClient` wrapper as well, though it does not have a separate live module because it simply uses CoreAudio under the hood, which is not a heavyweight dependency that introduces additional compiler overhead.
        """#,
      timestamp: (27 * 60 + 38),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        - We have similar wrappers for system frameworks like StoreKit, GameCenter and UserNotifications.
        """#,
      timestamp: (27 * 60 + 51),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        All of these examples are client-side, but we use the exact same pattern on the server!
        """#,
      timestamp: (27 * 60 + 56),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        For example, we have an `SnsClient` module and an `SnsClientLive` mode, which the server uses to send push notifications through Amazon's Simple Notification Service. The interface for sending a push notification is pretty simple:
        """#,
      timestamp: (28 * 60 + 2),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct SnsClient {
          public var createPlatformEndpoint: (CreatePlatformRequest) -> EitherIO<Error, CreatePlatformEndpointResponse>
          public var deleteEndpoint: (EndpointArn) -> EitherIO<Error, DeleteEndpointResponse>
          public var publish: (_ targetArn: EndpointArn, _ payload: AnyEncodable) -> EitherIO<Error, PublishResponse>
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        It can:

        - Create a platform endpoint, which means send them a push token to save.
        - Delete that endpoint.
        - Or we can publish a push notification.
        """#,
      timestamp: (28 * 60 + 19),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        This module compiles very quickly, but the live client picks up an extra dependency. It has to worry about signing requests it makes, so it needs to invoke code from another module that needs to be compiled.
        """#,
      timestamp: (28 * 60 + 31),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        import SwiftAWSSignatureV4
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        By separating this live implementation from the interface, we are able to depend on `SnsClient` wherever we need it without incurring the cost of the live dependency, which makes working on features much faster. The only time we incur that cost is when running the live server or when we deploy it to production.
        """#,
      timestamp: (28 * 60 + 52),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We use this style with our Postgres client, as well. We have `DatabaseClient` and `DatabaseLive` modules that separate the interface from the implementation. The interface is a simple struct with fields for each endpoint:
        """#,
      timestamp: (29 * 60 + 21),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        public struct DatabaseClient {
          public var completeDailyChallenge:
            (DailyChallenge.Id, Player.Id) -> EitherIO<Error, DailyChallengePlay>
          public var createTodaysDailyChallenge:
            (CreateTodaysDailyChallengeRequest) -> EitherIO<Error, DailyChallenge>
          public var fetchActiveDailyChallengeArns: () -> EitherIO<Error, [DailyChallengeArn]>
          public var fetchAppleReceipt: (Player.Id) -> EitherIO<Error, AppleReceipt?>
          public var fetchDailyChallengeById: (DailyChallenge.Id) -> EitherIO<Error, DailyChallenge>
          …
        """#,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: #"""
        While this interface compiles almost immediately, the live implementation does not. It depends on PostgresKit, which depends on Vapor, which depends on NIO, which can take a long time to compile. But when we write feature code, we can feel free to depend on `DatabaseClient` without ever worrying about taking on the cost of compiling NIO and other live dependencies. The only time we ever have to take on that additional time is when we run or deploy our server.
        """#,
      timestamp: (29 * 60 + 45),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        So the principles we use to modularize and streamline our iOS app development also applies to the server. It's super powerful to separate the lightweight stuff from the heavyweight stuff so we can build and test our features with a super fast feedback loop, all without ever worrying about the compile time cost of our application's heavyweight, live dependencies.
        """#,
      timestamp: (30 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"Next time: shared routing"#,
      timestamp: (30 * 60 + 44),
      type: .title
    ),
    Episode.TranscriptBlock(
      content: #"""
        So that gives a slight glimpse into how we share code between client and server. Some of the easiest things to share are data types and models, such as the puzzle and move types, as well as pure functions that do simple transformations of data, such as the verification function.
        """#,
      timestamp: (30 * 60 + 44),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        And all of that is already pretty powerful, but there is an even cooler chunk of code being shared.
        """#,
      timestamp: (31 * 60 + 10),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        The entire server routing system and the entire client-side API service are completely unified. What we mean is the code that parses incoming requests on the server is the exact same code that powers an API client in the iOS app for making network requests to the server. The moment we add a new route to the server we instantly get the ability to make requests to that route. There’s no need to read the server code or bother a colleague to figure out how a request can be constructed. It’s also impossible to construct an incorrect request. We have compile time guarantees that we didn’t accidentally misspell something in the URL request, or use camel case for a URL path that should have been kebab case, or used a GET request when it should have been a POST request, amongst a whole slew of other problems one can have when trying to build API clients.
        """#,
      timestamp: (31 * 60 + 20),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        We want to give a tour of how this code works because it’s honestly amazing to see, and is going to be a big topic we dive into soon on Point-Free.
        """#,
      timestamp: (32 * 60 + 9),
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: #"""
        Let’s start by taking a look at the server router...next time!
        """#,
      timestamp: (32 * 60 + 17),
      type: .paragraph
    ),
  ]
}
