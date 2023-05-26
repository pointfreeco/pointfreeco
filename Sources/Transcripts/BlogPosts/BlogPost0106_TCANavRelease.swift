import Foundation

public let post0106_TCANavRelease = BlogPost(
  author: .pointfree,
  blurb: """
    We are finally releasing first-class navigation tools for the Composable Architecture after
    16 episodes and 3 months of beta testing.
    """,
  contentBlocks: .paragraphs(###"""
    Over 3 months ago we released the [first beta preview][nav-beta-gh-discussion] of our
    navigation tools for the Composable Architecture. In that time we have released 16 episodes
    building all of the tools [from scratch][tca-nav-collection], and the community has put the
    new APIs through the wringer to help make them the best they can be.

    [nav-beta-gh-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1944
    [tca-nav-collection]: todo

    We are excited to officially release the tools, making it available to everyone who updates
    the library to version [0.54.0][tca-release]. This release brings all the tools you need
    to concisely model your domains and drive state off of optionals, enums and collections.

    [tca-release]: todo

    Join us for a quick tour of the tools, and we also have a [brand new tutorial][tca-tute]
    and [new articles][tca-nav-article] covering the tools in depth.

    [tca-nav-article]: todo
    [tca-tute]: todo

    ## Presentation tools

    It is very common to model state-driven navigation with optional values: when the value is
    non-`nil` the feature is presented, and when the value is `nil` it is dismissed. We like to
    call this style of navigation ["tree-based"][tree-based-article] because feature states
    nest inside each other to describe a path through your application, and that forms a
    tree-like structure.

    [tree-based-article]: todo

    The Composable Architecture gives you the tools to model you domains concisely using
    optionals and enums. For example, suppose you have a list of items and you want to be able
    to show a sheet to display a form for adding a new item. We can integrate state and actions
    together by utilizing the [`PresentationState`][presentation-state-docs] and
    [`PresentationAction`][presentation-action-docs] types:

    [presentation-action-docs]: todo
    [presentation-state-docs]: todo

    ```swift
    struct InventoryFeature: ReducerProtocol {
      struct State: Equatable {
        @PresentationState var addItem: ItemFormFeature.State?
        var items: IdentifiedArrayOf<Item> = []
        // ...
      }

      enum Action: Equatable {
        case addItem(PresentationAction<ItemFormFeature.Action>)
        // ...
      }

      // ...
    }
    ```

    !> [note]: The `addItem` state is held as an optional. A non-`nil` value represents that feature is being presented, and `nil` presents the feature is dismissed.

    Next you can integrate the reducers of the parent and child features by using the
    [``ifLet``][iflet-docs] reducer operator, as well as having an action
    in the parent domain for populating the child's state to drive navigation:

    [iflet-docs]: todo

    ```swift
    struct InventoryFeature: ReducerProtocol {
      struct State: Equatable { /* ... */ }
      enum Action: Equatable { /* ... */ }

      var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
          switch action {
          case .addButtonTapped:
            // Populating this state performs the navigation
            state.addItem = ItemFormFeature.State()
            return .none

          // ...
          }
        }
        .ifLet(\.$addItem, action: /Action.addItem) {
          ItemFormFeature()
        }
      }
    }
    ```

    !> [note]: The key path used with `ifLet` focuses on the `@PresentationState` projected value since it uses the `$` syntax. Also note that the action uses a [case path](http://github.com/pointfreeco/swift-case-paths), which is analogous to key paths but tuned for enums, and uses the forward slash syntax.

    That's all that it takes to integrate the domains and logic of the parent and child features. Next
    we need to integrate the features' views. This is done using view modifiers that look similar to
    SwiftUI's, but are tuned specifically to work with the Composable Architecture.

    For example, to show a sheet from the `addItem` state in the `InventoryFeature`, we can use
    the `sheet(store:)` modifier that takes a ``Store`` as an argument that is focused on presentation
    state and actions:

    ```swift
    struct InventoryView: View {
      let store: StoreOf<InventoryFeature>

      var body: some View {
        List {
          // ...
        }
        .sheet(
          store: self.store.scope(state: \.$addItem, action: { .addItem($0) })
        ) { store in
          ItemFormView(store: store)
        }
      }
    }
    ```

    !> [note]: We again must specify a key path to the `@PresentationState` projected value, _i.e._ `\.$addItem`.

    With those few steps completed the domains and views of the parent and child features are now
    integrated together, and when the `addItem` state flips to a non-`nil` value the sheet will be
    presented, and when it is `nil`'d out it will be dismissed.

    In this example we are using the `.sheet` view modifier, but the library ships with overloads for
    all of SwiftUI's navigation APIs that take stores of presentation domain, including:

      * `alert(store:)`
      * `confirmationDialog(store:)`
      * `sheet(store:)`
      * `popover(store:)`
      * `fullScreenCover(store:)`
      * `navigationDestination(store:)`
      * [``NavigationLinkStore``][nav-link-store-docs]

    [nav-link-store-docs]: todo

    This should make it possible to use optional state to drive any kind of navigation in a SwiftUI
    application.

    ## Navigation stack tools

    While the tree-based style of navigation described above is powerful, it also has some
    limitations. It is difficult to model complex, deeply nested navigation, and this is where
    ["stack-based"][stack-based-article] navigation really shines. This is where drive multi-level
    navigation with a collection of state, where adding an element to the collection represents
    drilling down to a feature, and remove the element represents popping the feature off.

    [stack-based-article]: todo

    The tools for this style of navigation include [``StackState``][stack-state-docs],
    [``StackAction``][stack-action-docs] and the [``forEach``][foreach-docs] operator, as well as a
    new [``NavigationStackStore``][nav-stack-store-docs] view that behaves like `NavigationStack`
    but is tuned specifically for the Composable Architecture.

    [stack-state-docs]: todo
    [stack-action-docs]: todo
    [foreach-docs]: todo
    [nav-stack-store-docs]: todo

    The process of integrating features into a navigation stack largely consists of 2 steps:
    integrating the features' domains together, and constructing a ``NavigationStackStore`` for
    describing all the views in the stack. One typically starts by integrating the features' domains
    together. This consists of defining a new reducer, typically called `Path`, that holds the domains
    of all the features that can be pushed onto the stack:

    ```swift
    struct RootFeature: ReducerProtocol {
      // ...

      struct Path: ReducerProtocol {
        enum State {
          case addItem(AddFeature.State)
          case detailItem(DetailFeature.State)
          case editItem(EditFeature.State)
        }
        enum Action {
          case addItem(AddFeature.Action)
          case detailItem(DetailFeature.Action)
          case editItem(EditFeature.Action)
        }
        var body: some ReducerProtocolOf<Self> {
          Scope(state: /State.addItem, action: /Action.addItem) {
            AddFeature()
          }
          Scope(state: /State.editItem, action: /Action.editItem) {
            EditFeature()
          }
          Scope(state: /State.detailItem, action: /Action.detailItem) {
            DetailFeature()
          }
        }
      }
    }
    ```

    !> [note]: The `Path` reducer is identical to the `Destination` reducer that one creates for tree-based navigation when using enums. See the ["Tree-based navigation"](todo) for more information.

    Once the `Path` reducer is defined we can then hold onto ``StackState`` and ``StackAction`` in the
    feature that manages the navigation stack:

    ```swift
    struct RootFeature: ReducerProtocol {
      struct State {
        var path = StackState<Path.State>()
        // ...
      }
      enum Action {
        case path(StackAction<Path.State, Path.Action>)
        // ...
      }
    }
    ```

    !> [note]: ``StackAction`` is generic over both state and action of the `Path` domain. This is different from ``PresentationAction``, which only has a single generic.

    And then we must make use of the ``forEach``
    method to integrate the domains of all the features that can be navigated to with the domain of the
    parent feature:

    ```swift
    struct RootFeature: ReducerProtocol {
      // ...

      var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
          // Core logic for root feature
        }
        .forEach(\.path, action: /Action.path) {
          Path()
        }
      }
    }
    ```

    That completes the steps to integrate the child and parent features together for a navigation stack.

    Next we must integrate the child and parent views together. This is done by construct a special
    version of SwiftUI's `NavigationStack` view that comes with this library, called
    ``NavigationStackStore``. This view takes 3 arguments: a store focused in on ``StackState``
    and ``StackAction`` in your domain, a trailing view builder for the root view of the stack, and
    another trailing view builder for all of the views that can be pushed onto the stack:

    ```swift
    NavigationStackStore(
      // Store focused on StackState and StackAction
    ) {
      // Root view of the navigation stack
    } destination: { state in
      switch state {
        // A view for each case of the Path.State enum
      }
    }
    ```

    To fill in the first argument you only need to scope your store to the `path` state and `path`
    action you already hold in the root feature:

    ```swift
    struct RootView: View {
      let store: StoreOf<RootFeature>

      var body: some View {
        NavigationStackStore(
          path: self.store.scope(state: \.path, action: { .path($0) })
        ) {
          // Root view of the navigation stack
        } destination: { state in
          // A view for each case of the Path.State enum
        }
      }
    }
    ```

    The root view can be anything you want, and would typically have some `NavigationLink`s or other
    buttons that push new data onto the ``StackState`` held in your domain.

    And the last trailing closure is provided a single piece of the `Path.State` enum so that you can
    switch on it:

    ```swift
    } destination: { state in
      switch state {
      case .addItem:
      case .detailItem:
      case .editItem:
      }
    }
    ```

    This will give you compile-time guarantees that you have handled each case of the `Path.State` enum,
    which can be nice for when you add new types of destinations to the stack.

    In each of these cases you can return any kind of view that you want, but ultimately you want to
    make use of the library's ``CaseLet`` view in order to scope down to a specific case of the
    `Path.State` enum:

    ```swift
    } destination: { state in
      switch state {
      case .addItem:
        CaseLet(
          state: /RootFeature.Path.State.addItem,
          action: RootFeature.Path.Action.addItem,
          then: AddView.init(store:)
        )
      case .detailItem:
        CaseLet(
          state: /RootFeature.Path.State.detailItem,
          action: RootFeature.Path.Action.detailItem,
          then: DetailView.init(store:)
        )
      case .editItem:
        CaseLet(
          state: /RootFeature.Path.State.editItem,
          action: RootFeature.Path.Action.editItem,
          then: EditView.init(store:)
        )
      }
    }
    ```

    And that is all it takes to integrate multiple child features together into a navigation stack,
    and done so with concisely modeled domains. Once those steps are taken you can easily add
    additional features to the stack by adding a new case to the `Path` reducer state and action enums,
    and you get complete introspection into what is happening in each child feature from the parent.
    Continue reading into <doc:StackBasedNavigation#Integration> for more information on that.

    ## Get started today!

    To make use of these tools be sure to update to the newest version of the
    Composable Architecture, 0.54.0. Also check out the [brand new tutorial][tca-tute]
    and [new articles][tca-nav-article] covering these tools, and a lot more, in much more depth.

    [tca-nav-article]: todo
    [tca-tute]: todo
    [stack-based-article]: todo
    [tree-based-article]: todo
    [tca-nav-article]: todo
    [tca-tute]: todo
    [tca-release]: todo
    [tca-nav-collection]: todo
    [nav-beta-gh-discussion]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1944
    """###),
  coverImage: nil,
  id: 106,
  publishedAt: yearMonthDayFormatter.date(from: "2023-05-31")!,
  title: "Navigation tools come to the Composable Architecture"
)
