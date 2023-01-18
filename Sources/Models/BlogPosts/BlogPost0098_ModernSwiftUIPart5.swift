import Foundation

public let post0098_ModernSwiftUIPart5 = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
    """,
  contentBlocks: [
    .init(
      content: #"""
        To celebrate the conclusion of our [7-part series](/collections/swiftui/modern-swiftui) on
        "Modern SwiftUI", we are releasing a blog post each day this week exploring a modern, best
        practice for SwiftUI development. In the final installment we will show how when the advice
        is followed from the preview 4 posts you get the ability to write deep, nuanced tests.

        * [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
        * [Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)
        * [Modern SwiftUI: State-driven
        navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)
        * [Modern SwiftUI: Dependencies](/blog/posts/97-modern-swiftui-dependencies)
        * **[Modern SwiftUI: Testing](/blog/posts/98-modern-swiftui-testing)**
        """#,
      type: .box(.preamble)
    ),
    .init(
      content: ###"""
        We conclude our week of "Modern SwiftUI" blog posts by discussing what we feel is the most
        important topic when it comes to maintaining a modern code base: testing. Thanks to the
        work of integrating parent and child features together, concisely modeling our domains,
        and controlling our dependencies, it is possible to write deep, nuanced tests quite
        easily.

        ## Unit tests

        In our series on "[Modern SwiftUI](/collections/swiftui/modern-swiftui)" we
        rebuilt Apple's "[Scrumdinger][scrumdinger]" application from [scratch][standups-source],
        and we made sure to write an [extensive suite of unit tests][standups-test-suite],
        exercising many nuanced user flows that execute effects and complex logic.

        For example, [we have a test][bad-data-test] that determines what happens when the
        application starts up and the previously saved data on disk can't be loaded. This helps
        us get test coverage on if the data file got corrupted somehow.

        We can can accomplish this thanks to us having controlled our dependence on the file system
        by modeling a `dataManager` interface. We can override this dependency in tests to force
        it to load nonsensical data:

        ```swift
        func testLoadingDataDecodingFailed() throws {
          let model = withDependencies {
            $0.mainQueue = .immediate
            $0.dataManager = .mock(
              initialData: Data("!@#$ BAD DATA %^&*()".utf8)
            )
          } operation: {
            StandupsListModel()
          }

          // ...
        }
        ```

        The `StandupsListModel` will now execute in an altered environment where loading data
        from the disk fails. To confirm our feature's logic handles this correctly we can confirm
        that an alert it shown. [Recall](/blog/posts/96-modern-swiftui-state-driven-navigation#enum-destination)
        that navigable destinations for a feature are modeled as an enum, and our
        [case paths][case-paths-gh] comes with a test tool for extracting a specific case from an
        enum:

        ```
        let alert = try XCTUnwrap(model.destination, case: /StandupsListModel.Destination.alert)
        XCTAssertNoDifference(alert, .dataFailedToLoad)
        ```

        If this assertion passes then it is proof that the alert showed to the user, and that it's
        contents matches what is held in [`.dataFailedToLoad`][datafailedtoload-source].

        Further, that alert gives the user an option to load some mock data just to get something
        back on the screen, and we can confirm that functions properly too:

        ```
        model.alertButtonTapped(.confirmLoadMockData)
        XCTAssertNoDifference(model.standups, [.mock, .designMock, .engineeringMock])
        ```

        For a more complicated example, the following test exercises the flow of drilling down to a
        standup, tapping its delete button, confirming an alert is shown, and then confirming
        deletion. The test will confirm that we are popped back to the root _and_ the standup is
        deleted from the root list:

        ```swift
        func testDelete() async throws {
          let model = try withDependencies { dependencies in
            dependencies.dataManager = .mock(
              initialData: try JSONEncoder().encode([Standup.mock])
            )
            dependencies.mainQueue = mainQueue.eraseToAnyScheduler()
          } operation: {
            StandupsListModel()
          }

          model.standupTapped(standup: model.standups[0])

          let detailModel = try XCTUnwrap(model.destination, case: /StandupsListModel.Destination.detail)

          detailModel.deleteButtonTapped()

          let alert = try XCTUnwrap(detailModel.destination, case: /StandupDetailModel.Destination.alert)

          XCTAssertNoDifference(alert, .deleteStandup)

          await detailModel.alertButtonTapped(.confirmDeletion)

          XCTAssertNil(model.destination)
          XCTAssertEqual(model.standups, [])
          XCTAssertEqual(detailModel.isDismissed, true)
        }
        ```

        This tests are incredibly naunced and is testing what the user will actually see on the
        screen since state drives navigation (and as long as the view is hooked up properly).

        And they run in a _fraction_ of a second (usually less than 0.01 seconds!). Typically
        you can run hundreds (if not thousands) of these kinds of tests in the time it takes to run
        a single UI test.

        ## UI tests

        Speaking of UI tests, [we also have one of those][standup-list-ui-test]. We don't recommend
        focusing all of your attention on UI tests, since they are slow and flakey, but it can be
        good to have a bit of full integration testing, and so we wanted to show how it is
        possible.

        To run a UI test with controlled dependencies you need to somehow communicate to the app
        host that the UI test runs in since it runs in a fully separate process. One way to do this
        is to set an environment variable in the `setUp` of the UI test:

        ```swift
        override func setUpWithError() throws {
          self.continueAfterFailure = false
          app.launchEnvironment = [
            "UITesting": "true"
          ]
        }
        ```

        Then check for the presence of that environment variable in the entry point of your
        application so that you can override the dependencies used, such as the data manager:

        ```swift
        @main
        struct StandupsApp: App {
          var body: some Scene {
            WindowGroup {
              if ProcessInfo.processInfo.environment["UITesting"] == "true" {
                withDependencies {
                  $0.dataManager = .mock()
                } operation: {
                  StandupsList(model: StandupsListModel())
                }
              } else {
                StandupsList(model: StandupsListModel())
              }
            }
          }
        }
        ```

        With that setup we were able to write a test that exercises the flow of adding a new
        standup from a modal sheet. Sadly it takes about 10 seconds to run, whereas the
        corresponding unit is about 400 times faster at just 0.025 seconds. But, having some test
        coverage on the true integration layer of SwiftUI can help round out your suite.

        ## A call for help!

        We hope that you find some of the topics discussed above exciting, and if you want to learn more,
        be sure to check out our [7-part series][modern-swiftui-collection] on “Modern SwiftUI.”

        We do have a favor to ask you. While we have built the Standups application in the style that makes
        the most sense to us, we know that some of these ideas aren't for everyone. We would love if others
        fork the Standups code base and re-build it in the style of their choice.

        Don't like to use an `ObservableObject` for each screen? Prefer to use `@StateObject` instead of
        `@ObservedObject`? Want to use an architectural pattern such as VIPER? Have a different way
        of handling dependencies? **Please show us!**

        We will collect links to the other ports so that there can be a single place to reference many
        different approaches for building the same application.

        ## That's all folks!

        Well, that's the end of our blog-post-a-day covering modern, best practices in SwiftUI
        application development. We highly recommend checking out our [Standups][standups-source]
        open source application to see how all of the ideas can be put to use in a real world,
        complex application.

        And if you want even _more_ in-depth coverage of these topics, then consider
        [subscribing][pricing] today to get access to the [full series][modern-swiftui-collection]!

        [datafailedtoload-source]: https://github.com/pointfreeco/swiftui-navigation/blob/1db1bcfd1e9f533a17074b7e95613d0d9a78262c/Examples/Standups/Standups/StandupsList.swift#L127-L143
        [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
        [pricing]: /pricing
        [modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
        [swiftui-collection]: https://www.pointfree.co/collections/swiftui
        [swiftui-nav-collection]: https://www.pointfree.co/collections/swiftui/navigation
        [standups-source]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [tagged-gh]: http://github.com/pointfreeco/swift-tagged
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        [swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
        [dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
        [standup-detail-destination-enum]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L24-L29
        [standup-detail-destinations-view]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L217-L255
        [standup-detail-edit-button-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L75-L81
        [standup-detail-start-meeting-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L98-L102
        [standup-detail-cancel-tapped]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L83-L85
        [standup-detail-source]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/StandupDetail.swift#L83-L85
        [standups-test-suite]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/StandupsTests
        [bad-data-test]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/StandupsTests/StandupsListTests.swift#L184-L201
        [standup-list-ui-test]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/StandupsUITests/StandupsListUITests.swift

        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 98,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-27")!,
  title: "Modern SwiftUI: Testing"
)
