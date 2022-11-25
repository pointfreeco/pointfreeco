import Foundation

public let post0084_SwiftUINavRelease = BlogPost(
  author: .pointfree,
  blurb: """
    Navigation in SwiftUI can be complex, but it doesn't have to be that way. We are releasing a
    new version of our SwiftUI Navigation library that makes it easier to use NavigationStack,
    alerts, confirmation dialogs, and even fixes a few bugs in SwiftUI.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Today we are releasing the biggest update to our [SwiftUINavigation][swiftui-nav-gh] library
        since its first release [one year ago][swiftui-nav-blog-post]. This brings support for new
        iOS 16 APIs, bug fixes for some of Apple’s navigation tools, better support for alerts
        and confirmation dialogs, and improved documentation.

        Join us for a quick overview of the new features, and be sure to update to
        [0.4.0][0_4_0_release] to get access to all of this, and more:

        - [Navigation stacks](#stacks)
        - [Navigation bugs fixes](#bug-fixes)
        - [Alerts and confirmation dialogs](#alerts)
        - [Get started today!](#get-started)

        <div id="stacks"></div>

        ## Navigation stacks

        iOS 16 largely reinvented the way drill-down navigations are performed by introducing a
        new top-level view, [`NavigationStack`][nav-stack-docs], a new view modifier,
        [`navigationDestination`][nav-dest-docs], and new initializers on
        [`NavigationLink`][nav-link-init-docs]. These new tools allow for greater decoupling of
        source and destination of navigation, and allow for better managing of deep stacks of
        features.

        Our library brings a new tool to the table, and it’s built on the back of the
        [`navigationDestination(isPresented:)`][nav-dest-ispresented-docs] view modifier, which
        allows driving navigation from a boolean binding. This tool fixes one of the biggest
        drawbacks to `NavigationLink`, which is that it was difficult to use in a list view since a
        drill-down would only occur if the row was visible in the list. This means you could not
        programmatically deep link to a screen if the row was not currently visible.

        The `navigationDestination` view modifier fixes this by allowing you to have a single place
        to express navigation, rather than embedding it in each row of the list:

        ```swift
        func navigationDestination<V>(
          isPresented: Binding<Bool>,
          destination: () -> V
        ) -> some View where V : View
        ```

        However, a boolean binding is too simplistic of a domain modeling tool to use. What if you
        wanted to control navigation via a piece of optional state, and further hand that state to
        the destination view?

        This is why our library comes with an additional overload, named
        [`navigationDestination(unwrapping:)`][nav-dest-unwrapping-code], which can drive navigation
        from a binding to an optional:

        ```swift
        public func navigationDestination<Value, Destination: View>(
          unwrapping value: Binding<Value?>,
          @ViewBuilder destination: (Binding<Value>) -> Destination
        ) -> some View {
        ```

        This makes it easy to have a list of data for which you want to drill down when a row is
        tapped:

        ```swift
        struct UsersListView: View {
          @State var users: [User]
          @State var editingUser: User?

          var body: some View {
            List {
              ForEach(self.users) { user in
                Button("\(user.name)") { self.editingUser = user }
              }
            }
            .navigationDestination(unwrapping: self.$editingUser) { $user in
              EditUserView(user: $user)
            }
          }
        }
        ```

        This works great if you only have a single destination to navigate to. But, if you need to
        support multiple destinations, you may be tempted to hold multiple pieces of optional state.
        However, that leads to an explosion of invalid states, such as when more than 1 is non-`nil`
        at the same time. SwiftUI considers that a user error, and can lead to the interface
        becoming non-responsive or even crash.

        > Subscribe to Point-Free through
        > [our Black Friday sale](https://www.pointfree.co/discounts/black-friday-2022)
        > at a 30% discount! Learn how we motivated and built the SwiftUI Navigation library along
        > with [many other topics](https://www.pointfree.co/collections).

        That’s why our library ships with another overload, named
        [`navigationDestination(unwrapping:case:)`][nav-dest-unwrapping-case-code], which allows
        driving multiple destinations from a single piece of enum state:

        ```swift
        public func navigationDestination<Enum, Case, Destination: View>(
          unwrapping enum: Binding<Enum?>,
          case casePath: CasePath<Enum, Case>,
          @ViewBuilder destination: (Binding<Case>) -> Destination
        ) -> some View {
        ```

        This allows you to model all destinations for a feature as a single enum and a single piece
        of optional state pointing to that enum. For example, a list with rows for users and
        categories for which tapping either should drill-down to the corresponding edit screen:

        ```swift
        struct UsersListView: View {
          @State var categories: [Category]
          @State var users: [User]
          @State var destination: Destination?
          enum Destination {
            case edit(user: User)
            case edit(category: Category)
          }

          var body: some View {
            List {
              Section(header: Text("Users")) {
                ForEach(self.users) { user in
                  Button("\(user.name)") { self.destination = .edit(user: user) }
                }
              }
              Section(header: Text("Categories")) {
                ForEach(self.categories) { category in
                  Button("\(category.name)") { self.destination = .edit(category: user) }
                }
              }
            }
            .navigationDestination(
              unwrapping: self.$destination,
              case: /Destination.edit(user:)
            ) { $user in
              EditUserView(user: $user)
            }
            .navigationDestination(
              unwrapping: self.$destination,
              case: /Destination.edit(category:)
            ) { $category in
              EditCategoryView(user: $category)
            }
          }
        }
        ```

        This makes it so that the compiler can prove that two destinations are never active at the
        same time. After all, the destinations are modeled on an enum, and cases of an enum are
        mutually exclusive.

        <div id="bug-fixes"></div>

        ## Navigation bug fixes

        The [`navigationDestination(isPresented:)`][nav-dest-ispresented-docs]view modifier
        released in iOS 16 is powerful, and the above shows we can build powerful APIs on top of it,
        however it does have some bugs.

        If you launch your application with the navigation state already hydrated, meaning you
        should be drilled down into the destination, the UI will be completely broken. It will not
        be drilled down, and worse tapping on the button to force the drill down will not work.

        We filed a [feedback][nav-dest-ispresented-fb] (and we recommend you duplicate it!), and
        this simple example shows the problem:

        ```swift
        struct UserView: View {
          @State var isPresented = true

          var body: some View {
            Button("Go to destination") {
              self.isPresented = true
            }
            .navigationDestination(isPresented: self.$isPresented) {
              Text("Hello!")
            }
          }
        }
        ```

        This is pretty disastrous. If you are using `navigationDestination(isPresented:)` in your
        code you simply will not be able to support things like URL deep linking or push
        notification deep linking.

        However, we were able to fix that bug in our APIs. If you use
        `navigationDestination(unwrapping:case:)` then you can rest assured that deep linking will
        work correctly, and it will work any number of levels deep. This also fixes a long standing
        bug in iOS <16’s `NavigationLink`, which is notorious for not being able to deep link more
        than 2 levels deep.

        <div id="alerts"></div>

        ## Alerts and confirmation dialogs

        Our SwiftUINavigation has had support for better [alert][alerts-code] and [confirmation
        dialog][dialogs-code] APIs using optionals and enums from the very beginning, but with the
        [0.4.0][0_4_0_release] release we have made them even more powerful.

        The library now ships data types that allow you to describe the presentation of an alert or
        confirmation dialog in a way that is friendlier to testing (i.e. they are `Equatable`). This
        makes it possible to store these values in your `ObservableObject` conformances so that you
        can get test coverage on any logic.

        For example, suppose you have an interface with a button that can delete an inventory item,
        but only if it is not “locked.” We can model this in our `ObservableObject` as a published
        property of `AlertState`, along with an enum to describe any actions the user can take in
        the alert:

        ```swift
        @Published var alert: AlertState<AlertAction>
        enum AlertAction {
          case confirmDeletion
        }
        ```

        Then you are free to hydrate this state at anytime to represent that an alert should be
        displayed:

        ```swift
        func deleteButtonTapped() {
          if item.isLocked {
            self.alert = AlertState {
              TextState("Cannot be deleted")
            } message: {
              TextState("This item is locked, and so cannot be deleted.")
            }
          } else {
            self.alert = AlertState {
              TextState("Delete?")
            } actions: {
              ButtonState(role: .destructive, action: .confirmDeletion) {
                TextState("Yes, delete")
              }
              ButtonState(role: cancel) {
                TextState("Nevermind")
              }
            } message: {
              TextState(#"Are you sure you want to delete "\(item.name)"?"#)
            }
          }
        }
        ```

        And the final step for the model layer is to implement a method that handles when an alert
        button is tapped:

        ```swift
        func alertButtonTapped(_ action: AlertAction) {
          switch action {
          case .confirmDeletion:
            self.inventory.remove(id: item.id)
          }
        }
        ```

        Then, to make the view show the alert when the `alert` state becomes non-`nil` we just have
        to make use of the [`alert(unwrapping:)`][alert-unwrapping-code] API that ships with our
        library:

        ```swift
        struct ItemView: View {
          @ObservedObject var model: ItemModel

          var body: some View {
            Form {
              …
            }
            .alert(unwrapping: self.$model.alert) { action in
              self.model.alertButtonTapped(action)
            }
          }
        }
        ```

        Notice that there is no logic in the view for what kind of alert to show. All of the logic
        for when to display the alert and what information is displayed (title, message, buttons)
        has all been moved into the model, and therefore very easy to test.

        To test, you can simply assert against any parts of the alert state you want. For example,
        if you want to verify that the message of the alert is what you expected, can just use
        `XCTAssertEqual`:

        ```swift
        let headphones = Item(…)
        let model = ItemModel(item: headphones)
        model.deleteButtonTapped()

        XCTAssertEqual(
          model.alert.message,
          TextState(#"Are you sure you want to delete "Headphones"?"#)
        )
        ```

        <div id="get-started"></div>

        ## Get started today

        Start taking advantage of all of the powerful domain modeling tools that Swift comes with
        (enums and optionals!) by adding [SwiftUINavigation][swiftui-nav-gh] to your project today!

        [0_4_0_release]: https://github.com/pointfreeco/swiftui-navigation/releases/tag/0.4.0
        [swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
        [swiftui-nav-blog-post]: /blog/posts/66-open-sourcing-swiftui-navigation
        [nav-stack-docs]: https://developer.apple.com/documentation/swiftui/navigationstack/
        [nav-dest-docs]: https://developer.apple.com/documentation/swiftui/view/navigationdestination(for:destination:)
        [nav-link-init-docs]: https://developer.apple.com/documentation/swiftui/navigationlink/init(value:label:)-4jswo
        [nav-dest-ispresented-docs]: https://developer.apple.com/documentation/swiftui/view/navigationdestination(ispresented:destination:)
        [nav-dest-unwrapping-code]: https://github.com/pointfreeco/swiftui-navigation/blob/102ab45e10986a27ef2cfacac00f03410461436b/Sources/SwiftUINavigation/NavigationDestination.swift#LL41-L44
        [nav-dest-unwrapping-case-code]: https://github.com/pointfreeco/swiftui-navigation/blob/102ab45e10986a27ef2cfacac00f03410461436b/Sources/SwiftUINavigation/NavigationDestination.swift#L70-L74
        [alert-unwrapping-code]: https://github.com/pointfreeco/swiftui-navigation/blob/102ab45e10986a27ef2cfacac00f03410461436b/Sources/SwiftUINavigation/Alert.swift#L119-L122
        [nav-dest-ispresented-fb]: https://gist.github.com/mbrandonw/f8b94957031160336cac6898a919cbb7#file-fb11056434-md
        [alerts-code]: https://github.com/pointfreeco/swiftui-navigation/blob/5bf9dadd086d2d6beef5ea1fe9a2070ad4eab2b8/Sources/SwiftUINavigation/Alert.swift
        [dialogs-code]: https://github.com/pointfreeco/swiftui-navigation/blob/5bf9dadd086d2d6beef5ea1fe9a2070ad4eab2b8/Sources/SwiftUINavigation/ConfirmationDialog.swift
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 84,
  publishedAt: Date(timeIntervalSince1970: 1_669_010_400),
  title: "Better SwiftUI navigation APIs"
)
