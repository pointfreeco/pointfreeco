import Foundation

public let post0104_TCANavBeta = BlogPost(
  author: .pointfree,
  blurb: """
    Alongside our series on navigation in the Composable Architecture we are kicking off a beta so
    that you can start testing these tools today.
    """,
  contentBlocks: .transcript {
    Array.paragraphs(
      ###"""
      We’ve been teasing navigation tools for the [Composable
      Architecture](http://github.com/pointfreeco/swift-composable-architecture) for a _long_
      time, and been working on the tools for even longer, but it is finally time to get a
      preview of what is coming to the library.

      The tools being previewed today include what has been covered in our [navigation
      series](https://www.pointfree.co/collections/composable-architecture/navigation) so far
      (episodes [#222](https://www.pointfree.co/episodes/222),
      [#223](https://www.pointfree.co/episodes/223),
      [#224](https://www.pointfree.co/episodes/224)), as well as a few tools that will be coming in
      the next few episodes. In particular, this includes the tools for dealing with alerts,
      confirmation dialogs, sheets, popovers, fullscreen covers, pre-iOS 16 navigation links, and
      `navigationDestination`. Notably, this beta does **not** currently provide the tools for the
      iOS 16 `NavigationStack`, but that will be coming soon.

      All of these changes are mostly backwards compatible with the most recent version of TCA
      (version 0.51.0 right now), which means you can point any existing project to the beta
      branch to get a preview of what the tools have to offer. If you experience any compiler
      errors please let us know.

      ## The basics

      We aren’t going to give a detailed overview of the tools in this announcement and how we
      motivated and designed them (that’s what the episodes are for 😀), but most of the case
      studies and demos in the repo have been updated to use the new tools and there is an
      _extensive_ test suite. There hasn’t been much documentation written yet, but that will be
      coming soon as the episode series plays out.

      Here is a very quick overview of what you can look forward to:

      - When a parent feature needs to navigate to a child feature you will enhance its domain
        using the new `@PresentationState` property wrapper and `PresentationAction` wrapper type:

        ```swift
        struct Parent: ReducerProtocol {
          struct State {
            @PresentationState var child: Child.State?
            …
          }
          enum Action {
            case child(PresentationAction<Child.Action>)
            …
          }

          …
        }
        ```

      - Then you will make use of the new, special `ifLet` reducer operator that can single out
        the presentation state and action and run the child feature on that state when it is
        active:

        ```swift
        var body: some ReducerProtocolOf<Self> {
          Reduce {
            …
          }
          .ifLet(\.$child, action: /Action.child) {
            Child()
          }
        }
        ```

        That is all that is needed as far as the domain and reducer is concerned. The `ifLet`
        operator has been with the library since the beginning, but is now enhanced with super
        powers, including automatically cancelling child effects when the child is dismissed,
        and *a lot* more.

      - There is one last thing you need to do, and that’s in the view. There are special
        overloads of all the SwiftUI navigation APIs (such as `.alert`, `.sheet`, `.popover`,
        `.navigationDestination` etc.) that take a store instead of a binding. If you provide a
        store focused on presentation state and actions, it will take care of the rest. For
        example, if the child feature is shown in a sheet, you will do the following:

        ```swift
        struct ParentView: View {
          let store: StoreOf<Parent>

          var body: some View {
            List {
              …
            }
            .sheet(
              store: self.store.scope(state: \.$child, action: Parent.Action.child)
            ) { store in
              ChildView(store: store)
            }
          }
        }
        ```

      And that is basically it. There’s still a lot more to the tools and things to learn, but we
      will leave it at that and we encourage you to explore the branch when you get a chance.

      ## 1.0 Preview

      As you may have [heard
      recently](https://github.com/pointfreeco/swift-composable-architecture/discussions/1905) we
      have a 1.0 preview available to everyone who wants a peek at what APIs will be renamed and
      removed for the 1.0 release. Currently that branch is targeting `main`, but soon it will
      target this `navigation-beta` branch, which means you can simultaneously see how to
      modernize your codebase for the 1.0 and check out the new navigation tools.

      ## Trying the beta

      To give the beta a shot, update your SPM dependencies to point to the `navigation-beta`
      branch:

      ```swift
      .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        branch: "navigation-beta"
      ),
      ```

      This branch also includes updated demo applications using these APIs, so check them out if
      you're curious!

      We really think these tools will make TCA even more fun and easier to use! If you take
      things for a spin, please let us know (via [Twitter](http://twitter.com/pointfreeco),
      [Mastodon](http://hachyderm.io/@pointfreeco) or [GitHub
      discussions](http://github.com/pointfreeco/swift-composable-architecture/discussions)) if you
      have any questions, comments, concerns, or suggestions!
      """###
    )
  },
  coverImage: nil,
  id: 104,
  publishedAt: yearMonthDayFormatter.date(from: "2023-02-27")!,
  title: "Composable navigation beta"
)
