import Foundation

public let post0055_OpenSourcingIsowords = BlogPost(
  author: .pointfree,
  blurb: """
    We're open sourcing the entire code base to our newly released iOS word game, isowords!
    """,
  contentBlocks: [
    .init(
      content: """
        A few months ago we announced that we were working on a new project, a word game for iOS, and we've even been giving little peeks at the code base in recent episodes of [Point-Free](/). Well, we've now officially [launched](https://www.isowords.xyz/download) the app on the App Store and we are simultaneously [open sourcing](https://www.github.com/pointfreeco/isowords) the entire code base!

        ## isowords

        [isowords](https://www.isowords.xyz) is a large, complex application built entirely in Swift. The iOS client's logic is built in the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and the UI is built mostly in SwiftUI with a little bit in SceneKit. The server is also built in Swift using our experimental web server libraries.

        The [code base](https://www.github.com/pointfreeco/isowords) is currently over 45k lines of code, for both the iOS client and server, and employs a number of techniques that have been discussed on [Point-Free](/). Here's just a small sample of some things you might be interested in:

        ### The Composable Architecture

        The whole application is powered by the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), a library we built from scratch on [Point-Free](https://www.pointfree.co/collections/composable-architecture) that provides tools for building applications with a focus on composability, modularity, and testability. This means:

        * The entire app's state is held in a single source of truth, called a `Store`.
        * The entire app's behavior is implemented by a single unit, called a `Reducer`, which is composed out of many other reducers.
        * All effectful operations are made explicit as values returned from reducers.
        * Dependencies are made explicit as simple data types wrapping their live implementations, along with various mock instances.

        There are a ton of benefits to designing applications in this manner:

        * Large, complex features can be broken down into smaller child domains, and those domains can communicate via simple state mutations. Typically this is done in SwiftUI by accessing singletons inside `ObservableObject` instances, but this is not necessary in the Composable Architecture.
        * We take control of dependencies rather than allow them to take control of us. Just because you are using `StoreKit`, `GameCenter`, `UserNotifications`, or any other 3rd party APIs in your code, it doesn't mean you should sacrifice your ability to run your app in the simulator, SwiftUI previews, or write concise tests.
        * Exhaustive tests can be written very quickly. We test very detailed user flows, capture subtle edge cases, and assert on how effects execute and how their outputs feed back into the application.
        * It is straightforward to write integration tests that exercise multiple independent parts of the application.

        ### Hyper-modularization

        The application is built in a hyper-modularized style. At the time of writing this README the client and server are split into [86 modules](https://github.com/pointfreeco/isowords/blob/main/Package.swift). This allows us to work on features without building the entire application, which improves compile times and SwiftUI preview stability. It also made it easy for us to ship an App Clip, whose size must be less than 10 MB _uncompressed_, by choosing the bare minimum of code and resources to build.

        ### Client/Server monorepo

        The code for both the iOS client and server are included in this single repository. This makes it easy to run both the client and server at the same time, and we can even debug them at the same time, e.g. set breakpoints in the server that are triggered when the simulator makes API requests.

        We also share a lot of code between client and server:

        * The core types that describe players, puzzles, moves, etc.
        * Game logic, such as the random puzzle generator, puzzle verification, dictionaries, and more.
        * The router used for handling requests on the server is the exact same code the iOS client uses to make API requests to the server. New routes only have to be specified a single time and it is immediately available to both client and server.
        * We write integration tests that simultaneously test the server and iOS client. During a test, API requests made by the client are actually running real server code under the hood.
        * And more...

        ### Automated App Store screenshots and previews

        The screenshots and preview video that we upload to the [App Store](https://www.isowords.xyz/app-store) for this app are automatically generated.

        * The [screenshots](https://github.com/pointfreeco/isowords/blob/main/Tests/AppStoreSnapshotTests/__Snapshots__/AppStoreSnapshotTests) are generated by a [test suite](https://github.com/pointfreeco/isowords/blob/main/Tests/AppStoreSnapshotTests) using our [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library, and do the work of constructing a very specific piece of state that we load into a screen, as well as framing the UI and providing the surrounding graphics.

        * The preview [video](https://apptrailers.itunes.apple.com/itunes-assets/PurpleVideo124/v4/e7/c1/8e/e7c18e28-b229-a8a7-b5b7-f151f920ae91/P233871875_default.m3u8) is generated as a screen recording of running a [slimmed-down version](https://github.com/pointfreeco/isowords/blob/main/Sources/TrailerFeature) of the app that embeds specific letters onto a cube and runs a sequence of actions to emulate a user playing the game. The app can be run locally by selecting the `TrailerPreview` target in Xcode and running it in the simulator.

        ### Preview apps

        There are times that we want to test a feature in isolation without building the entire app. SwiftUI previews are great for this but also have their limitations, such as if you need to use APIs unavailable to previews, or if you need to debug more complex flows, etc.

        So, we create [mini-applications](https://github.com/pointfreeco/isowords/blob/main/App/Previews) that build a small subset of the [86+ modules](https://github.com/pointfreeco/isowords/blob/main/Package.swift) that comprise the entire application. Setting up these applications requires minimal work. You just specify what dependencies you need in the Xcode project and then create an entry point to launch the feature.

        For example, [here](https://github.com/pointfreeco/isowords/blob/main/App/Previews/OnboardingPreview/OnboardingPreviewApp.swift) is all the code necessary to create a preview app for running the onboarding flow in isolation. If we were at the whims of the full application to test this feature we would need to constantly delete and reinstall the app since this screen is only shown on first launch.

        # Download today!

        Check out and explore the isowords [code base](https://www.github.com/pointfreeco/isowords) today. We have a lot more [Point-Free](https://www.pointfree.co) episodes coming soon that dive into some of the more advanced aspects of the code base, such as API client design, integration testing, onboarding flows, automatic trailer creation and more! 😅

        Also, be sure to [download](https://www.isowords.xyz/app-store) isowords and share with friends 😁:

        [![Download isowords on the App Store](https://d1iqsrac68iyd8.cloudfront.net/posts/0054-announcing-isowords/app-store-badge.png)](https://www.isowords.xyz/app-store)
        """,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 55,
  publishedAt: Date(timeIntervalSince1970: 1_615_996_800),
  title: "Open Sourcing isowords"
)
