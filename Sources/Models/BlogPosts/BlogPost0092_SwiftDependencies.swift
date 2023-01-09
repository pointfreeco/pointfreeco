import Foundation

public let post0092_SwiftDependencies = BlogPost(
  author: .pointfree,
  blurb: """
    We are open sourcing a new dependency management system for Swift. Take control of your
    dependencies, don't let them control you.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        We are excited to [open source][swift-deps-gh] a brand new dependency management system for Swift
        applications. It makes it easy to propagate dependencies deep into your application in an ergonomic,
        but also safe, manner. Once you start to control your dependencies you will instantly be able to
        write simpler tests, unlock new superpowers from Xcode previews, improve compile times, and a whole
        bunch more.

        Join us for a quick overview, and consider adding the [library][swift-deps-gh] to your application
        today!

        ## Overview

        Dependencies are the types and functions in your application that need to interact with outside
        systems that you do not control. Classic examples of this are API clients that make network requests
        to servers, but also seemingly innocuous things such as `UUID` and `Date` initializers, file access,
        user defaults, and even clocks and timers, can all be thought of as dependencies.

        You can get really far in application development without ever thinking about dependency management
        (or, as some like to call it, "dependency injection”), but eventually uncontrolled dependencies can
        cause many problems in your code base and development cycle:

        * Uncontrolled dependencies make it **difficult to write fast, deterministic tests** because you are
          susceptible to the vagaries of the outside world, such as file systems, network connectivity,
          internet speed, server uptime, and more.
        * Many dependencies **do not work well in SwiftUI previews**, such as location managers and speech
          recognizers, and some **do not work even in simulators**, such as motion managers, and more. This
          prevents you from being able to easily iterate on the design of features if you make use of those
          frameworks.
        * Dependencies that interact with 3rd party, non-Apple libraries (such as Firebase, web socket
          libraries, network libraries, video streaming libraries, etc.) tend to be heavyweight and take a
          **long time to compile**. This can slow down your development cycle.

        For these reasons, and a lot more, it is highly encouraged for you to take control of your
        dependencies rather than let them control you.

        But controlling a dependency is only the beginning. Once you have controlled your dependencies,
        you are faced with a whole set of new problems:

        * How can you **propagate dependencies** throughout your entire application that is more ergonomic
          than explicitly passing them around everywhere, but safer than having a global dependency?
        * How can you override dependencies for just one portion of your application? This can be handy
          for **overriding dependencies** in tests and SwiftUI previews, as well as specific user flows,
          such as onboarding experiences.
        * How can you be sure you **overrode _all_ dependencies** a feature uses in tests? It would be
          incorrect for a test to mock out some dependencies but leave others open to interacting with the
          outside world.

        This library addresses all of the points above, and much, _much_ more.

        ## Using your first dependency

        The library allows you to register your own dependencies, but it also comes with many controllable
        dependencies out of the box (see [`DependencyValues`][dep-values-docs] for a full list), and there
        is a good chance you can immediately make use of one. If you are using `Date()`, `UUID()`,
        `Task.sleep`, or Combine schedulers directly in your feature's logic, you can already start to use
        this library.

        Any place you are using one of those dependencies directly in feature logic without passing it
        explicitly to the feature can be updated to first declare your dependency in the feature using
        the [`@Dependency`][dep-pw-docs] property wrapper:

        ```swift
        final class FeatureModel: ObservableObject {
          @Dependency(\.continuousClock) var clock  // Controllable async sleep
          @Dependency(\.date.now) var now           // Controllable current date
          @Dependency(\.mainQueue) var mainQueue    // Controllable main queue scheduling
          @Dependency(\.uuid) var uuid              // Controllable UUID creation

          // ...
        }
        ```

        Once your dependencies are declared, rather than reaching out to the `Date()`, `UUID()`, `Task`,
        etc., directly, you can use the dependency that is defined on your feature's model:

        ```swift
        final class FeatureModel: ObservableObject {
          // ...

          func addButtonTapped() async throws {
            try await self.clock.sleep(for: .seconds(1))  // 👈 Don't use 'Task.sleep'
            self.items.append(
              Item(
                id: self.uuid(),  // 👈 Don't use 'UUID()'
                name: "",
                createdAt: self.now  // 👈 Don't use 'Date()'
              )
            )
          }
        }
        ```

        That is all it takes to start using controllable dependencies in your features. With that little
        bit of upfront work done you can start to take advantage of the library's powers.

        For example, you can easily control these dependencies in tests. If you want to test the logic
        inside the `addButtonTapped` method, you can use the [`withDependencies`][with-deps-docs]
        function to override any dependencies for the scope of one single test. It's as easy as 1-2-3:

        ```swift
        func testAdd() async throws {
          let model = withDependencies {
            // 1️⃣ Override any dependencies that your feature uses.
            $0.clock = ImmediateClock()
            $0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
            $0.uuid = .incrementing
          } operation: {
            // 2️⃣ Construct the feature's model
            FeatureModel()
          }

          // 3️⃣ The model now executes in a controlled environment of dependencies,
          //    and so we can make assertions against its behavior.
          try await model.addButtonTapped()
          XCTAssertEqual(
            model.items,
            [
              Item(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                name: "",
                createdAt: Date(timeIntervalSinceReferenceDate: 1234567890)
              )
            ]
          )
        }
        ```

        Here we controlled the `date` dependency to always return the same date, and we controlled the
        `uuid` dependency to return an auto-incrementing UUID every time it is invoked. If we did not
        control these dependencies this test would be very difficult to write since there is no way to
        accurately predict what will be returned by `Date()` and `UUID()`.

        But, controllable dependencies aren't only useful for tests. They can also be used in Xcode
        previews. Suppose the feature above makes use of a clock to sleep for an amount of time before
        something happens in the view. If you don't want to literally wait for time to pass in order
        to see how the view changes, you can override the clock dependency to be an "immediate" clock
        using the [`withDependencies`][with-deps-docs] helper:

        ```swift
        struct Feature_Previews: PreviewProvider {
          static var previews: some View {
            FeatureView(
              model: withDependencies {
                $0.clock = ImmediateClock()
              } operation: {
                FeatureModel()
              }
            )
          }
        }
        ```

        This will make it so that the preview uses an immediate clock when run, but when running in a
        simulator or on device it will still use a live `ContinuousClock`. This makes it possible to
        override dependencies just for previews without affecting how your app will run in production.

        That is the basics to getting started with using the library, but there is still a lot more you
        can do. You can learn more in depth in our [documentation][docs] and articles.

        ## Multiplatform

        While this dependencies library works really great for SwiftUI applications, it is useful in
        many other situations too.

        #### UIKit

        It can be used with UIKit applications in exactly the same way as SwiftUI applications, except
        instead of adding dependencies to an `ObservableObject` you can add them to your `UIViewController`
        subclasses:

        ```swift
        class FeatureController: UIViewController {
          @Dependency(\.continuousClock) var clock
          @Dependency(\.date) var date
          @Dependency(\.mainQueue) var mainQueue
          @Dependency(\.uuid) var uuid

          // ...
        }
        ```

        This makes it possible to construct this class in a controlled environment, such as in tests and
        Xcode previews.

        #### Third party frameworks

        Third party frameworks can integrate the library in order to provide a dependency system to the
        users of the framework. For example, this dependencies library powers the dependency management
        system for the [Composable Architecture][tca-gh]. In fact, this library originated from the
        Composable Architecture, but we soon realized it would be useful in vanilla SwiftUI and other
        frameworks, so we decided to split it out into its own library (and it's the [8th
        time][tca-deps-permalink] we've done that!).

        #### Server-side Swift

        It can even be used with server side applications. In fact, this very site is [built in
        Swift][pf-gh], and now [uses the dependencies library][pf-deps-pr] to control dependencies and make
        our server code more testable.

        And that's just barely scratching the surface.

        ## Documentation

        We have written an extensive amount of [documentation][docs] for this library, including a
        collection of articles for learning about dependencies, how to design them, how to use them in live,
        test and preview contexts, and a whole lot more:

        ### Getting started

        * **[Quick start][quick-start-article]**:
          Learn the basics of getting started with the library before diving deep into all of its features.

        * **[What are dependencies?][what-are-dependencies-article]**:
          Learn what dependencies are, how they complicate your code, and why you want to control them.

        ### Essentials

        * **[Using dependencies][using-dependencies-article]**:
          Learn how to use the dependencies that are registered with the library.

        * **[Registering dependencies][registering-dependencies-article]**:
          Learn how to register your own dependencies with the library so that they immediately become
          available from any part of your code base.

        * **[Live, preview, and test dependencies][live-preview-test-article]**:
          Learn how to provide different implementations of your dependencies for use in the live
          application, as well as in Xcode previews, and even in tests.

        ### Advanced

        * **[Designing dependencies][designing-dependencies-article]**:
          Learn techniques on designing your dependencies so that they are most flexible for injecting into
          features and overriding for tests.

        * **[Overriding dependencies][overriding-dependencies-article]**:
          Learn how dependencies can be changed at runtime so that certain parts of your application can use
          different dependencies.

        * **[Dependency lifetimes][lifetimes-article]**:
          Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how
          dependencies are inherited.

        * **[Single entry point systems][single-entry-point-systems-article]**:
          Learn about "single entry point" systems, and why they are best suited for this dependencies
          library, although it is possible to use the library with non-single entry point systems.

        ### Miscellaneous

        * **[Concurrency support][concurrency-support-article]**:
          Learn about the concurrency tools that come with the library that make writing tests and
          implementing dependencies easy.

        ## Get started with Dependencies today!

        We hope we have convinced you that it's worth trying to reign in dependencies in your applications.
        You will instantly be able to write simpler tests, unlock superpowers in Xcode previews, improve
        compile times, and a lot more.

        Add [Dependencies 0.1.0][0_1_0] to your project today to start exploring these ideas!

        [0_1_0]: http://github.com/pointfreeco/swift-dependencies/releases/tag/0.1.0
        [swift-deps-gh]: http://github.com/pointfreeco/swift-dependencies
        [docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/
        [concurrency-support-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/concurrencysupport
        [designing-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/designingdependencies
        [live-preview-test-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest
        [lifetimes-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/lifetimes
        [overriding-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/overridingdependencies
        [registering-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/registeringdependencies
        [single-entry-point-systems-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/singleentrypointsystems
        [using-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/usingdependencies
        [what-are-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/whataredependencies
        [quick-start-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/quickstart
        [registering-dependencies-article]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/registeringdependencies
        [dep-values-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/dependencyvalues
        [dep-pw-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/dependency
        [with-deps-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:)-4uz6m
        [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
        [pf-gh]: http://github.com/pointfreeco/pointfreeco
        [pf-deps-pr]: https://github.com/pointfreeco/pointfreeco/pull/809
        [tca-deps-permalink]: https://github.com/pointfreeco/swift-composable-architecture/blob/cbf8a45fa97ca4afb858f6cd99730bb67952813a/Package.swift#L26-L32
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 92,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-09")!,
  //      Take control of your dependencies, don't let them control you
  title: "A new library to control dependencies and avoid letting them control you"
)
