import Foundation

public let post0105_TCANavBeta2 = BlogPost(
  author: .pointfree,
  blurb: """
    As we begin to explore navigation stacks in the Composable Architecture we are releasing the
    second beta of our navigation tools.
    """,
  contentBlocks: .transcript {
    Array.paragraphs(
      ###"""
      It's been just under two months since we kicked off our [navigation beta](https://github.com/pointfreeco/swift-composable-architecture/discussions/1944), in
      which we released an assortment of tools to manage presentation in the Composable
      Architecture. This included tools for dealing with alerts, confirmation dialogs, sheets,
      popovers, fullscreen covers, pre-iOS 16 navigation links, and the tree-based
      [`navigationDestination`][nav-dest-tree] view modifier. The beta notably did **not** provide
      tools for iOS 16's `NavigationStack`, but that changes today.

      ## Composable Stack Navigation Basics

      Like last time, we're not going to give a detailed overview of these new tools and how we
      motivated or designed them (see the forthcoming [episodes][stacks-ep] for that 😉), and
      documentation is still in-progress, but here is a very quick overview of the stack-based tools
      and how to use them.

        * When a root feature contains a navigation stack of elements to be presented, you will
          enhance its domain using the new `StackState` and `StackAction` types:

          ```swift
          struct Root: ReducerProtocol {
            struct State {
              var path = StackState<Child.State>()
              …
            }
            enum Action {
              case path(StackAction<Child.State, Child.Action>)
              …
            }
          }
          ```

          `StackState` is a collection type that is specialized for navigation operations in the
          Composable Architecture, where each element represents a screen in the stack that is
          powered by its own reducer. It is similar to SwiftUI's [`NavigationPath`][nav-path-docs],
          and has many of the same operations like `append` and `removeLast`, but it is not
          type-erased: you can freely inspect and mutate the data inside.

        * Then you will make use of the new, special `forEach` reducer operator that can single out
          the stack state and action, and run the child feature on that element when it is active:

          ```swift
          var body: some ReducerProtocolOf<Self> {
            Reduce { state, action in
              …
            }
            .forEach(\.path, action: /Action.path) {
              Child()
            }
          }
          ```

          That's all that is needed as far as the domain and reducer is concerned. The `forEach`
          operator has been with the library since the beginning, but is now enhanced with super
          powers, including automatically cancelling child effects when they are dismissed, and
          more.

        * The last step is in the view, where the library provides a new `NavigationStackStore`
          view, which powers a `NavigationStack` and its destinations using a store.

          ```swift
          struct RootView: View {
            let store: StoreOf<Root>

            var body: some View {
              NavigationStackStore(
                self.store.scope(state: \.path, action: Root.Action.path)
              ) {
                Text("Welcome")
              } destination: { store in
                ChildView(store: store)
              }
            }
          }
          ```


      That's the basics. There's a whole lot more to learn, but we will leave it at that for now,
      and we encourage you to explore the updated branch when you get a chance.

      ## Trying the beta

      These new stack-based tools are already available on the `navigation-beta` branch. If you've
      been testing things so far, you can pull the latest and immediately make use of these tools.
      The [1.0
      preview](https://github.com/pointfreeco/swift-composable-architecture/discussions/1905)
      likewise has been updated with the latest, greatest tools. Otherwise, you can update your SPM
      dependencies to point to the `navigation-beta` branch:

      ```swift
      .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        branch: "navigation-beta"
      ),
      ```

      We hope these tools fill a gap in the library and make it ready for its first major release.

      As always, if you take things for a spin, please let us know (via
      [Twitter](https://twitter.com/pointfreeco), [Mastodon](http://hachyderm.io/@pointfreeco),
      [GitHub
      discussions](https://github.com/pointfreeco/swift-composable-architecture/discussions), or our
      new [Slack](http://pointfree.co/slack-invite) community) if you have questions, comments,
      concerns, or suggestions!

      [stacks-ep]: /episodes/ep231-composable-stacks-vs-trees
      [nav-dest-tree]: https://developer.apple.com/documentation/swiftui/view/navigationdestination(ispresented:destination:)
      [nav-path-docs]: https://developer.apple.com/documentation/swiftui/navigationpath
      """###
    )
  },
  coverImage: nil,
  id: 105,
  publishedAt: yearMonthDayFormatter.date(from: "2023-04-17")!,
  title: "Composable navigation beta, part 2"
)
