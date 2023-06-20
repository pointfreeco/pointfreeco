import Foundation

extension Episode {
  public static let ep221_pfLive_dependenciesStacks = Episode(
    blurb: """
      Our first ever livestream! We talk about a few new features that made it into our
      [Dependencies](http://github.com/pointfreeco/swift-dependencies) library when we extracted it
      from the Composable Architecture, live code our way through a `NavigationStack` refactor of
      our [Standups](http://github.com/pointfreeco/standups) app, and answer your questions along
      the way!
      """,
    codeSampleDirectory: "0221-pflive-dependencies-stacks",
    exercises: _exercises,
    format: .livestream,
    fullVideo: .init(
      bytesLength: 960_800_000,
      downloadUrls: .s3(
        hd1080: "0221-1080p-69767068a5104055babcf7b8993daaeb",
        hd720: "0221-720p-8449bf17411249aa8dc3f31272f779cc",
        sd540: "0221-540p-b7bbf287996d41e384a31377c633d67d"
      ),
      vimeoId: 795_040_266
    ),
    id: 221,
    length: 94 * 60 + 34,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-06")!,
    questions: [
      Question(
        answer: """
          Yes! The next series of episodes we are tackling is navigation in the
          [Composable Architecture](http://github.com/pointfreeco/swift-composable-architecture).
          After that series the library will finally be ready for a 1.0, and at that time we will
          do a brand new "tour" series of episodes, most likely rebuilding the
          [Standups](http://github.com/pointfreeco/standups) application with the library.
          """,
        question: """
          Do you plan make a series of episodes like “Modern SwiftUI,” but for the Composable
          Architecture, to show best practices for updated library?
          """,
        timestamp: .timestamp(hours: 1, minutes: 26, seconds: 45)
      ),
      Question(
        answer: """
          Yes we are, but progress on the actual implementation has been paused since we can't
          do it ourselves (C++ 🙄) and the implementor at Apple has been pulled to other projects.
          We hope that work can begin on it again someday soon, but we hope that when that day
          comes there will be a focus on the `embed` functionality and not just the `extract`.

          While the extraction of an associated value from an enum can be handy, it's only half the
          story. Just as key paths wouldn't be as useful if they only handled getting and not
          setting, so too would case paths be unnecessarily hindered if they only extraction
          capabilities without embed.
          """,
        question: """
          Are you still pursuing the idea of introducing CasePaths to Swift as a first-class
          language feature? The official Swift evolution proposal has been stalled.
          """,
        timestamp: .timestamp(hours: 1, minutes: 30, seconds: 50)
      ),
      Question(
        answer: """
          We name our observable objects this way because it's how Apple has started naming them
          in their sample code. We don't think the naming is important though, and if you feel
          more comfortable it them "view model" or something else, feel free!
          """,
        question: """
          Why do you name your observable objects “Model”?
          """,
        timestamp: .timestamp(minutes: 47, seconds: 20)
      ),
      Question(
        answer: """
          We feel that callback closures and delegates are really just two sides of the same coin.
          It is roughly equivalent for one object to delegate to another by invoking callback
          closures, versus conforming to a delegate protocol and holding onto a weak reference
          of that object. But, callback closures can be a little more lightweight and ergonomic
          than a delegate protocol.

          Further, Apple has even started shying away from the delegate protocol pattern in some
          of their more modern APIs, and instead opt for a simple collection of closures.
          """,
        question: """
          Why are you using callbacks instead of a delegate?
          """,
        timestamp: .timestamp(minutes: 54, seconds: 51)
      ),
      Question(
        answer: """
          The SwiftUINavigation library was really only built with vanilla SwiftUI in mind,
          for those times you can't use the Composable Architecture. As such, it doesn't really
          play nicely with the Composable Architecture, and that is why we are building navigation
          tools from the ground up specifically for the Composable Architecture.
          """,
        question: """
          Are there going to be episodes on best practices of using the SwiftUINavigation library
          with the Composable Architecture?
          """,
        timestamp: .timestamp(hours: 1, minutes: 30, seconds: 3)
      ),
      Question(
        answer: """
          You can try being selective with what methods and properties of your model are marked as
          `@MainActor`, but typically it ends up being most of the model, and so we just tend to
          mark the whole thing as `@MainActor`.
          """,
        question: """
          Do you see any issue with use @MainActor on models by default? Or should it only be
          added when required?
          """,
        timestamp: .timestamp(hours: 1, minutes: 2, seconds: 18)
      ),
      Question(
        answer: """
          If your application has navigation paths that create cycles, then the easiest way to
          break the cycle is to adopt a stack-based navigation, such as `NavigationStack`.
          """,
        question: """
          How can you break cycles between modules?
          """,
        timestamp: .timestamp(hours: 1, minutes: 29, seconds: 28)
      ),
      Question(
        answer: """
          This is a bit of an open question with our Dependencies library currently, but it is
          something we are actively thinking about and hope to have a better solution for someday.

          Currently there is one safe guard to help you out. If you access a dependency that does
          not have a live implementation while running your app in the simulator, a purple
          runtime warning will be generated in Xcode.
          """,
        question: """
          How can a large, modularized codebasse guard against missing `liveValue` in their
          implementation modules?
          """,
        timestamp: .timestamp(hours: 0, minutes: 27, seconds: 12)
      ),
      Question(
        answer: """
          Our library doesn't directly provide any tools to help with dependency version, other than
          getting you to think about dependencies in general. It's still on you to employ
          dependency inversion where appropriate in your application.
          """,
        question: """
          How does your Dependencies library relate to “dependency inversion”?
          """,
        timestamp: .timestamp(hours: 0, minutes: 23, seconds: 24)
      ),
      Question(
        answer: """
          It is fine to use `@Dependency` from inside another dependency. This only works for
          dependencies that form a tree or acyclic graph, and if you do have any cycles your
          app will crash at runtime. We also do not currently try detecting cycles, so it's on you
          to make sure there are none.
          detect
          """,
        question: """
          How can one dependency depend on another dependency?
          """,
        timestamp: .timestamp(hours: 0, minutes: 24, seconds: 35)
      ),
      Question(
        answer: """
          Yes, this is possible, and we have more information in [this
          article](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Separating-interface-and-implementation) in the library's documentation.
          """,
        question: """
          Is it possible to declare a dependency interface in one module and provide the
          implementation in another module?
          """,
        timestamp: .timestamp(hours: 0, minutes: 16, seconds: 45)
      ),
      Question(
        answer: """
          Yes, our dependencies library is powered by `@TaskLocal`s under the hood, which has a
          well-defined, though restrictive, way of mutating values. Because of this, our library
          is most suitable for "[single entry point systems](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/singleentrypointsystems)",
          but tools are also provided to propogate dependencies for longer periods of time.
          """,
        question: """
          Are TaskLocals the reason that the Dependencies library is suitable for single entry
          point systems?
          """,
        timestamp: .timestamp(hours: 0, minutes: 12, seconds: 42)
      ),
      Question(
        answer: """
          Dependencies are instantiated only when first accessed, and then they are held for the
          duration of the application lifecycle.
          """,
        question: """
          Are all dependencies held in memory during the app lifecycle? Are they all instantiated
          when the app starts or at the moment when they are needed?
          """,
        timestamp: .timestamp(hours: 0, minutes: 19, seconds: 6)
      ),
      Question(
        answer: """
          SwiftUI environment values work great for accessing values deep in a view heirarchy
          without passing those values through every layer, but also it only works for views. If
          you access an `@Environment` variable when not in a view you will get a purple runtime
          warning in Xcode letting you know that is not allowed.

          Our `@Dependency` wrapper allows you to pass values deep into your application in places
          other than views, such as observable objects.

          Further, our dependencies library supports platforms beyond just SwiftUI, such as UIKit,
          AppKit, server applications, Linux, SwiftWasm and more.
          """,
        question: """
          What is the difference between @Dependency and @Environment.
          """,
        timestamp: .timestamp(hours: 0, minutes: 9, seconds: 33)
      ),
      Question(
        answer: """
          We are excited about the new [observation
          pitch](https://forums.swift.org/t/pitch-observation/62051) as it should allow us to
          simplify the Composable Architecture and make it possible to support non-Apple platforms,
          such as Windows and SwiftWasm.

          We are also excited for the new macro system, as it may help us clean up some boilerplate
          problems in our libraries.
          """,
        question: """
          What future Swift features excite you the most and why?
          """,
        timestamp: .timestamp(hours: 1, minutes: 32, seconds: 34)
      ),
      Question(
        answer: """
          You shouldn't think of a dependency as needing an `async` initializer, and instead has
          having an `async` endpoint that can initialize it.
          """,
        question: """
          How can one define a dependency where its initializer is async?
          """,
        timestamp: .timestamp(hours: 1, minutes: 27, seconds: 27)
      ),
      Question(
        answer: """
          Actors can be useful for dependencies, but you don't need the actor itself to be the
          dependency, and instead you can use an actor for the implementation of the dependency.
          """,
        question: """
          What do actor-based dependencies look like?
          """,
        timestamp: .timestamp(hours: 1, minutes: 28, seconds: 29)
      ),
      Question(
        answer: """
          The second half of this livestream should answer this question. In order to decouple
          destinations you must use stack-based navigation instead of tree-based, such as
          `NavigationStack`.
          """,
        question: """
          State-driven navigation is great, but the Standups example is coupled closely to the
          view's model. How would you approach something like a "coordinator" or "router" pattern
          where the view doesn't know anything about the other destinations?
          """,
        timestamp: .timestamp(hours: 1, minutes: 25, seconds: 19)
      ),
    ],
    references: [
      .onTheNewPointFreeDependenciesLibrary,
      .swiftDependencies,
      .dependenciesSeparatingInterfaceAndImplementation,
      .designingDependencies,
      .standupsApp,
      .swiftUINav,
      .swiftUINavigation,
      .theComposableArchitecture,
      .isowordsGitHub,
      .isowords,
      .observationPitch,
    ],
    sequence: 221,
    subtitle: "Dependencies & Stacks",
    title: "Point-Free Live",
    trailerVideo: .init(
      bytesLength: 44_200_000,
      downloadUrls: .s3(
        hd1080: "0221-trailer-1080p-8979f93a83ee49fcad7acb291c15264c",
        hd720: "0221-trailer-720p-b434d9a0fca44f14990171929136754f",
        sd540: "0221-trailer-540p-5cd5fcac05ed4dd288f1a56a6550d01b"
      ),
      vimeoId: 795_389_609
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 221)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Fix all of the tests for the newly refactored Standups app now that it uses `NavigationStack`.
      """
  )
]
