import Foundation

public let post0081_ReducerProtocol = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are releasing the biggest update to the Composable Architecture ever, completely
    reimagining how features are built with the library.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Just two months ago we [announced][async-tca-blog-post] the biggest update to the
        [Composable Architecture][tca-gh] since its first release. Today we are announcing an even
        _bigger_ update by introducing the `ReducerProtocol` and a brand new dependency management
        system to everyone who upgrades to version [0.41.0][0_41_0].

        To celebrate, we are releasing a [free episode][in-practice] to show off some of the
        changes, and demonstrate how it massively simplifies many of our case studies and demo
        applications, as well as [isowords][isowords], our [open-source][isowords-gh] word game
        built entirely in the Composable Architecture and SwiftUI.

        And if you don't have time to watch the entire episode, continue reading. 😀

        ## The ReducerProtocol

        The biggest change to the library is the introduction of the
        [`ReducerProtocol`][reducer-protocol-docs], which means one defines a type to conform to
        the protocol rather than constructing an instance of `Reducer` directly. This immediately
        gives you the benefit of having a natural place to nest your feature's domain:

        ```swift
        struct Feature: ReducerProtocol {
          struct State {
            // ...
          }
          enum Action {
            // ...
          }

          func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
            // ...
          }
        }
        ```

        …and in the process of doing this can improve the stability of the Swift compiler to
        properly type check your program and provide inline warnings.

        The protocol also gives us the opportunity to reimagine what composition of reducers looks
        like. By leveraging result builders and Swift 5.7's new support for constrained opaque
        types, we can provide a way to compose multiple reducers that looks similar to SwiftUI
        syntax. For example, the app-level reducer that handles the functionality for 3 tabs in a
        tab view can look like this:

        ```swift
        struct App: ReducerProtocol {
          struct State {
            var activity: Activity.State
            var profile: Profile.State
            var search: Search.State
          }
          enum Action {
            case activity(Activity.Action)
            case profile(Profile.Action)
            case search(Search.Action)
          }

          var body: some ReducerProtocol<State, Action> {
            Scope(state: \.activity, action: /Action.activity) {
              Activity()
            }
            Scope(state: \.profile, action: /Action.profile) {
              Profile()
            }
            Scope(state: \.search, action: /Action.search) {
              Search()
            }
          }
        }
        ```

        There are also new operators that allow you to more safely compose reducers that work on
        optional state ([`ifLet`][iflet-docs]), array state ([`forEach`][foreach-docs]) and even
        enum state ([`ifCaseLet`][ifcaselet-docs]).

        ## Dependencies made easy

        The biggest new feature that the reducer protocol unlocked for the library is a brand new
        dependency management system. Now that reducers are types, they become the natural place
        to hold onto dependencies. There's no need to define a separate "environment" type that
        holds all of the dependencies the feature needs to do its job, which means no need to
        maintain the boilerplate of an initializer if you decide to modularize later.

        Even better, by taking some inspiration from SwiftUI, you can provide dependencies to your
        reducers via a [property wrapper][dependency-pw-docs] that pulls from a global store of
        dependencies:

        ```swift
        struct Feature: ReducerProtocol {
          @Dependency(\.apiClient) var apiClient
          @Dependency(\.mainQueue) var mainQueue
          @Dependnecy(\.uuid) var uuid

          // ...
        }
        ```

        There's no need to explicitly pass dependencies through every layer of the application.
        You can add a new dependency to a leaf node of your features with a single line of code
        and without updating any other feature. And it's possible to
        [override][dependency-key-writer-docs] dependencies for a specific reducer and its effects.

        The library also bakes in some extra safety around dependency usage. For example, "live"
        dependencies are not allowed to be used in tests, and if they are it will cause a test
        failure. This encourages you to be explicit with mocking dependencies so that you do not
        unknowingly interact with the real world in tests unless you explicitly state you want to.

        Further, when registering a dependency with the library you can optionally provide extra
        implementations in addition to the live value. You can provide a "test" value that will
        be used when you test your feature in a `TestStore`. And you can provide a "preview" value
        that will be used when your feature is run in an Xcode preview.

        Read our dedicated [article][dependencies-article] to learn more about how to best leverage
        the dependency system in the library, and how to best design your own dependencies.

        ## Performance improvements

        Once you have moved your features to the new `ReducerProtocol` you may see some
        performance improvements, especially for deeply nested features. The Swift compiler can do
        a much better job optimizing and inlining methods than it can with escaping closures,
        causing stack traces to become slimmer and stack memory usage to drop.

        We demonstrated this in [this week's episode][in-practice] where we showed that drilling
        many layers deep into a recursive UI led to a stack trace of 164 frames, but only 29 of
        those frames were actually from the application. To contrast, the same application running
        on the previous version of the library produced a stack trace of 191 stack frames, and 113
        of those frames were due to the application. This means the `ReducerProtocol` version of the
        application has about a fourth of the number of stack frames for that use case.

        For more information on maximizing performance when using the library, be sure to check out
        our dedicated [performance][performance-article] article.

        ## Updated documentation

        This release has also brought a massive improvement to the [documentation][tca-docs] of the
        library. Many types and methods now have fuller descriptions and explanations, some articles
        have been updated, and a few new articles have been added.

        There is now a dedicated article on [dependency management][dependencies-article]. It
        covers the "why" and "how" of dependency management, and shows how to make use of the
        controllable dependencies the library comes with, as well as how to register your own.
        It also gives a detailed explanation of how the new dependency management system works
        with testing and Xcode previews, as well as some tips on how to best design your own
        dependency clients.

        There is also a dedicated article on [migration strategies][migration-article] to the
        new `ReducerProtocol` style of building features. It outlines many scenarious you are likely
        to encounter while migrating your existing application, and if something is not covered
        we highly recommend you open a [GitHub discussion][gh-discussions] about it.

        ## Get started today

        We have barely scratched the surface of the far reaching consequences of this update. Be
        sure to watch this week's [free episode][in-practice] and update to version
        [0.41.0][0_41_0] today!

        [async-tca-blog-post]: /blog/posts/79-async-composable-architecture
        [0_41_0]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.41.0
        [in-practice]: /episodes/ep208-reducer-protocol-in-practice
        [isowords]: http://isowords.xyz
        [isowords-gh]: http://github.com/pointfreeco/isowords
        [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
        [reducer-protocol-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/reducerprotocol
        [reducer-builder-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/reducerbuilder
        [iflet-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/scope/iflet(_:action:then:file:fileid:line:)
        [foreach-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/scope/foreach(_:action:_:file:fileid:line:)
        [ifcaselet-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/scope/ifcaselet(_:action:then:file:fileid:line:)
        [dependency-pw-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/dependencies/dependency
        [dependencies-article]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/dependencymanagement/
        [migration-article]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/migratingtothereducerprotocol/
        [tca-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/
        [gh-discussions]: http://github.com/pointfreeco/swift-composable-architecture/discussions
        [dependency-key-writer-docs]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/reducerprotocol/dependency(_:_:)
        [performance-article]: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/performance/
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,  
  id: 81,
  publishedAt: .init(timeIntervalSince1970: 1665378000),
  title: "Announcing the Reducer Protocol"
)
