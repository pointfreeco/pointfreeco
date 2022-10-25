import Foundation

public let post0083_NETS = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Testing is by far the #1 priority of the [Composable Architecture][gh-tca]. The library
        provides a tool, the [`TestStore`][test-store-docs], that allow you to prove how your
        features evolve over time. This not only includes how state changes with every user action,
        but also how effects are executed and how data is fed back into the system.

        While this can be powerful, it can also sometimes become cumbersome, especially when
        testing the integration of how many features interact with each other. For this reason,
        the concept of a "non-exhaustive" test store was first conceived of by
        [Krzysztof Zabłocki][merowing.info] in a [blog post][exhaustive-testing-in-tca] and a
        [conference talk][Composable-Architecture-at-Scale], which allows you to be more selective
        of which parts of the application you want to actually asssert on.

        And now, as of version [0.45.0][tca-0.45.0] of the library, there is first class support
        for non-exhaustive test stores. Join us for a quick overview of the why and how of
        exhaustive testing, as well as when it breaks down and how non-exhaustive testing can help.

        * [Why exhaustive testing?](#)
        * [How to write exhaustive tests](#)
        * [When exhaustive testing breaks down](#)
        * [Introducing non-exhaustive testing](#)
        * [Start using non-exaustive test stores today!](#)

        ## Why exhaustive testing?

        Test assertions allow you to prove that certain values in your feature are what you expect
        them to be, but each assertion lies on a spectrum of strenght. For example, if your feature
        has an "Add" button that when tapped adds an item to a collection, then you can write
        a test for that like so:

        ```swift
        XCTAssertEqual(model.items.count, 0)
        model.addButtonTapped()
        XCTAssertEqual(model.items.count, 1)
        ```

        That certainly proves that _something_ was added to the `items` collection, but it doesn't
        prove anything about the item.

        We can strenghten this assertion to further assert on the first item in the collection:

        ```swift
        XCTAssertEqual(model.items.count, 0)
        model.addButtonTapped()
        XCTAssertEqual(model.items[0], Item(name: "", quantity: 1))
        ```

        This is stronger since it now proves the first item has an empty string for its name and
        1 for its quantity, but it doesn't prove anything about what else is in the `items`
        collection.

        So, we can again strenghten this assertion to prove that the `items` array consists of only
        a single item:

        ```swift
        model.addButtonTapped()
        XCTAssertEqual(
          model.items,
          [Item(name: "", quantity: 1)]
        )
        ```

        And now this assertion is much stronger.

        But it's _still_ not as strong as it could be. We are not asserting on how anything else in
        the `model` evolves over time. What if when tapping the "Add" button we also make a network
        request to add the item in an external database, and while that request is in flight we
        show a progress view somewhere in the UI.

        Since we are not asserting on any of that behavior there could be bugs in that code that
        are not covered by the test. It is on us to be studious enough to make sure to write an
        explicit test for that behavior, but nothing is guiding us towards doing so.

        This is exactly what exhaustive testing aims to solve. You should not be allowed to write
        assertions like the above without also asserting on how the rest of the system evolves.
        You should be forced to assert on how each piece of state changes, as well as how each side
        effect executes and feeds data back into the system.

        ## How to write exhaustive tests

        Now that we know why exhaustive testing can be useful, let's see how the [Composable
        Architecture][gh-tca] gives us exhaustive testing right out of the box.

        Continuing with the example from above, to assert what happens when the user taps the "Add"
        button we construct a [`TestStore`][test-store-docs], send it an action, and provide a
        trailing closure that must mutate the previous state to the current state:

        ```swift
        func testAddItem() async {
          let store = TestStore(
            initialState: Feature.State(),
            reducer: Feature()
          )

          await store.send(.addButtonTapped) {
            $0.items = [
              Item(name: "", quantity: 1)
            ]
          }
        }
        ```

        If this tests passes, it proves that the only mutation made to state when sending the action
        was an item being added to the `items` collection. If anything else was changed in the
        feature's state we would get a test failure.

        For example, suppose the feature has additional logic, such as making a network request to
        add the item on the backend database and managing some state for showing a progress view,
        then we would get a test failure because we have not asserted on how the entire feature
        evolves.

        In fact, we get two test failures. The first is due to the fact that we did not fully
        describe how the state changes:

        ```
        🛑 A state change does not match expectation: …

              Feature.State(
            −   isAdding: false,
            +   isAdding: true,
                items: […]
              )

        (Expected: −, Actual: +)
        ```

        The failure message is clearly showing that some state changed that we did not assert
        against. In particular, the `isAdding` boolean, which will drive the showing and hiding
        of a progress indicator in the view, should be `true`, not `false`.

        To fix, we need to mutate that state to its actual value in the `send` assertion:

        ```swift
        await store.send(.addButtonTapped) {
          $0.isAddding = true
          $0.items = [
            Item(name: "", quantity: 1)
          ]
        }
        ```

        This fixes one test failure, but there's still another:

        ```
        🛑 The store received 1 unexpected action after this one: …

        Unhandled actions: [
          [0]: Feature.Action.addResponse(success: true)
        ]
        ```

        This is letting us know that the test store received an action from an effect, in
        particular the effect that communicates to our backend server, but we did not assert
        on it.

        This is a great test failure to have. If the effect action is expected, then we should
        assert on how it fed back into the system and how state changed after, otherwise we are
        giving opportunities for bugs to hide. And just as important, if the effect action is _not_
        expected, then there is a bug in the logic causing an effect to execute, and so that should
        be fixed.

        To fix this test we must assert on receiving this action as well as how state changes after
        receiving the action:

        ```swift
        await store.send(.addButtonTapped) {
          $0.isAdding = true
          $0.items = [
            Item(name: "", quantity: 1)
          ]
        }

        await store.receive(.addResponse(success: true)) {
          $0.isAdding = false
        }
        ```

        The test now passes, and we can have a lot of confidence that we are asserting on
        _everything_ happening in this feature, from state changes to effect execution. If the
        feature changes in the future by changing more state or executing more effects, we will
        instantly be notified in existing tests that more work needs to be done to assert on
        how the feature evolved.

        ## When exhaustive testing breaks down

        While exhaustive testing can be powerful, it also has its drawbacks. In particular, for
        very large, complex features, or features that are composed of many other features. In
        such cases it can be cumbersome to assert on _every_ little state change and effect
        execution inside every single feature.

        For example, suppose you have a tab-based application where the 3rd tab is a login screen.
        The user can fill in some data on the screen, then tap the "Submit" button, and then a
        series of events happens to  log the user in. Once the user is logged in, the 3rd tab
        switches from a login screen to a profile screen, _and_ the selected tab switches to the
        first tab, which is an activity screen.

        When writing tests for the login feature we will want to do that in the exhaustive style
        so that we can prove exactly how the feature would behave in production. But, suppose we
        wanted to write an integration test that proves after the user taps the "Login" button
        that eventually the selected tab switches to the first tab.

        In order to test such a complex flow we must test the integration of multiple features,
        which means dealing with complex, nested state and effects. We can emulate this flow in a
        test by sending actions that mimic the user logging in, and then eventually assert that
        the selected tab switched to activity:

        ```swift
        let store = TestStore(
          initialState: App.State(),
          reducer: App()
        )

        // 1️⃣ Emulate user tapping on submit button.
        await store.send(.login(.submitButtonTapped)) {
          // 2️⃣ Assert how state changes in the login feature
          $0.login?.isLoading = true
        }

        // 3️⃣ Login feature performs API request to login, and
        //    sends response back into system.
        await store.receive(.login(.loginResponse(.success))) {
          // 4️⃣ Assert how state changes in the login feature
          $0.login?.isLoading = false
        }

        // 5️⃣ Login feature sends a delegate action to let parent
        //    feature know it has successfully logged in.
        await store.receive(.login(.delegate(.didLogin))) {
          // 6️⃣ Assert how all of app state changes due to that action.
          $0.authenticatedTab = .loggedIn(
            Profile.State(...)
          )
          // 7️⃣ *Finally* assert that the selected tab switches to activity.
          $0.selectedTab = .activity
        }
        ```

        Doing this with exhaustive testing is verbose, and there are a few problems with this:

        * We need to be have intimate knowledge on how the login feature works so that we can
        assert on how its state changes and how its effects feed data back into the system.
        * If the login feature were to change its logic we may get test failures here even though
        the logic we are acutally trying to test doesn't really care about those changes.
        * This test is very long, and so if there are other similar but slightly different flows
        we want to test we will be tempted to copy-and-paste the whole thing, leading to lots of
        duplicated, fragile tests.

        So, exhaustive testing can definitely be cumbersome, and this is what led [Krzysztof
        Zabłocki][merowing.info] to pursue "non-exaustive" test stores.

        ## Introducing non-exhaustive testing

        Non-exhaustive testing allows us to test the integration of many complex features, such as
        the situation above, without needing to assert on _everything_ in the feature. We can be
        selective on which pieces we want to actually assert on, and only if we assert with bad
        data do we actually get a test failure.

        Take for example the above test, which wants to confirm that the selected tab switches to
        the activity tab after login. In order to do that we had to assert on all of the details
        of the login feature, including how state changed and effects executed.

        Instead, we can set the store's `exhaustivity` setting to `.none`, and then we get to
        decide what we want to actually assert on:

        ```swift
        let store = TestStore(
          initialState: App.State(),
          reducer: App()
        )
        store.exhaustivity = .none // ⬅️

        await store.send(.login(.submitButtonTapped))
        await store.receive(.login(.delegate(.didLogin))) {
          $0.selectedTab = .activity
        }
        ```

        This test passes and ignores all of the superfluous details that we do not care about for
        this particular integration test.

        In particular, it proves when the "Submit" button is tapped in the login feature that
        eventually a `.didLogin` action is sent to indicate that log in succeeded, at which point
        the selected tab switches to `.activity`. We did not assert on how the login state changed,
        or how login effects executed. This means the login feature is free to make any changes
        it wants to its logic without affecting the outcome of this test, as long as it sends
        the `.didLogin` action when log in occurs.

        The style of non-exhaustivity can even be customized. Using `.none` causes all un-asserted
        changes to pass without any notification. If you would like the test to pass but also see
        what test failures are being surprised, then you can use `.partial` exhaustivity:

        ```swift
        let store = TestStore(
          initialState: App.State(),
          reducer: App()
        )
        store.exhaustivity = .partial // ⬅️

        await store.send(.login(.submitButtonTapped))
        await store.receive(.login(.delegate(.didLogin))) {
          $0.selectedTab = .profile
        }
        ```

        When this is set, running tests in Xcode will provide grey, informational boxes on each
        assertion where some change wasn't fully asserted on:

        ```
        ◽️ A state change does not match expectation: …

             App.State(
               authenticatedTab: .loggedOut(
                 Login.State(
           −       isLoading: false
           +       isLoading: true,
                   …
                 )
               )
             )

           (Expected: −, Actual: +)

        ◽️ Skipped receiving .login(.loginResponse(.success))

        ◽️ A state change does not match expectation: …

             App.State(
           −   authenticatedTab: .loggedOut(…)
           +   authenticatedTab: .loggedIn(
           +     Profile.State(…)
           +   ),
               …
             )

           (Expected: −, Actual: +)
        ```

        The test still passes, and none of these notifications are test failures. They just let you
        know what things you are not explicitly asserting against, and can be useful to see when
        tracking down bugs that happen in production but that aren't currently detected in tests.

        ## Start using non-exaustive test stores today!

        All of these tools (and more) are available in [0.45.0][tca-0.45.0] of the library, which
        is available today. Be sure to upgrade and read the [testing documentation][testing-article]
        for more information on how exhaustive and non-exhaustive test stores work.

        [testing-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing
        [gh-tca]: http://github.com/pointfreeco/swift-composable-architecture
        [test-store-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/teststore
        [merowing.info]: http://merowing.info
        [exhaustive-testing-in-tca]: https://www.merowing.info/exhaustive-testing-in-tca/
        [Composable-Architecture-at-Scale]: https://www.merowing.info/composable-architecture-scale/
        [tca-0.45.0]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.45.0
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 83,
  publishedAt: Date(timeIntervalSince1970: 1667192400),
  title: "Non-exhaustive testing in the Composable Architecture"
)
