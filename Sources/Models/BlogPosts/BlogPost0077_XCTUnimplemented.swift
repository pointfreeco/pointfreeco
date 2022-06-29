import Foundation

public let post0077_XCTUnimplemented = BlogPost(
  author: .pointfree,
  blurb: """
    We've added a new tool to our XCTest Dynamic Overlay library, which makes it easier to construct stronger dependencies for tests.
    """,
  contentBlocks: [
    .init(
      content: #"""
        We have just released 0.3.0 of our [XCTest Dynamic Overlay][dynamic-overlay-github] library, which brings a new tool that aids in constructing stronger dependencies for tests.

        ## Dynamic `XCTFail`

        We first open sourced XCTest Dynamic Overlay over [a year ago][better-testing-bonanza], and its sole purpose at that time was to allow using `XCTFail` in application code. This allows you to write test helpers right alongside feature code without importing XCTest, which otherwise does not compile for simulators or devices.

        For example, suppose you have a lightweight dependency for tracking analytics in your client:

        ```swift
        struct AnalyticsClient {
          var track: (Event) -> Void

          struct Event: Equatable {
            var name: String
            var properties: [String: String]
          }
        }
        ```

        For the production app you can use a "live" version of the dependency that actually sends data to an analytics server:

        ```swift
        extension AnalyticsClient {
          static let live = Self(
            track: { event in
              // Send event to server
            }
          )
        }
        ```

        But for tests we can use an "unimplemented" version of the analytics client, which allows us to prove when we don't expect a dependency to be used in a test:

        ```swift
        import XCTestDynamicOverlay

        extension AnalyticsClient {
          static let unimplemented = Self(
            track: { _ in XCTFail("\(Self.self).track is unimplemented.") }
          )
        }
        ```

        If you pass along `AnalyticsClient.unimplemented` to your feature in tests and the test passes, you have proof that the slice of your feature you are exercising definitely does not track any analytics. That is incredibly powerful.

        Without XCTest Dynamic Overlay you would need to extract this unimplemented instance to its own module just so that it could only be imported in tests. That causes a proliferation of unnecessary modules for something that should be quite simple.

        ## `XCTUnimplemented`

        The new `XCTUnimplemented` function builds on XCTest Dynamic Overlay's core functionality by making it even easier to construct unimplemented dependencies. It is a massively overloaded function that allows you to construct a function of any form (up to 5 arguments, throwing and non-throwing, async and non-async) that immediately fails the test suite if it is ever invoked.

        For example, the `Analytics.unimplemented` instance can now be constructed simply as:

        ```swift
        import XCTestDynamicOverlay

        extension AnalyticsClient {
          static let unimplemented = Self(
            track: XCTUnimplemented("\(Self.self).track")
          )
        }
        ```

        And this helper really shines with more complicated dependencies with lots of endpoints:

        ```swift
        struct AppDependencies {
          var date: () -> Date = Date.init,
          var fetchUser: (User.ID) async throws -> User,
          var uuid: () -> UUID = UUID.init
        }

        extension AppDependencies {
          static let unimplemented = Self(
            date: XCTUnimplemented("\(Self.self).date", placeholder: Date()),
            fetchUser: XCTUnimplemented("\(Self.self).fetchUser"),
            date: XCTUnimplemented("\(Self.self).uuid", placeholder: UUID())
          )
        }
        ```

        ## Start using it today!

        Add [XCTest Dynamic Overlay][dynamic-overlay-github] to your project today to start building testing tools right along side your application code!

        If you are interested in learning more about the concept of "unimplemented" dependencies, be sure to check out our [episode][failability-episode] on the topic!

        [dynamic-overlay-github]: http://github.com/pointfreeco/xctest-dynamic-overlay
        [better-testing-bonanza]: https://www.pointfree.co/blog/posts/56-better-testing-bonanza
        [failability-episode]: https://www.pointfree.co/collections/dependencies/better-test-dependencies/ep139-better-test-dependencies-failability
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 77,
  publishedAt: Date(timeIntervalSince1970: 1_656_478_800),
  title: "Introducing XCTUnimplemented"
)
