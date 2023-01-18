import Foundation

public let post0094_ModernSwiftUIPart1 = BlogPost(
  author: .pointfree,
  blurb: """
    We are celebrating the conclusion of our 7-part series on Modern SwiftUI by releasing a blog
    post every day, detailing an area of SwiftUI development that can be modernized.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        This week we finished our ambitious, [7-part series][modern-swiftui-collection] exploring
        modern, best practices for SwiftUI development. In those episodes we re-built Apple’s
        ”[Scrumdinger][scrumdinger]” application, which is a great showcase for many of the problems
        one encounters in a real life application. Every step of the way we challenged ourselves to
        write the code in the most scalable and future-proof way possible, including:

        1. We eschew plain arrays for lists and instead embrace [identified
        arrays][identified-collections-gh].
        1. All of navigation is state-driven and concisely modeled.
        1. All side effects and dependencies are controlled.
        1. A full test suite is provided to test many complex and nuanced user flows.

        …and a whole bunch more.

        To celebrate the conclusion of the series we are going to release one new blog post every
        day this week detailing an area of SwiftUI development that can be modernized, starting
        with parent-child communication.

        If you find this interesting, then consider [subscribing][pricing] today to get access
        to the [full series][modern-swiftui-collection]!

        <!-- mention the app we built -->

        ## Parent-child view communication

        It is common to break up a complex view into smaller pieces. Even something as simple as
        showing a sheet is done by having a dedicated view for the present*ing* view and present*ed*
        view.


        Even something as simple as a view presented in a sheet is typically modeled by having a
        dedicated view for both the parent and child domains:

        ```swift
        struct StandupsList: View {
          @State var standups: [Standup] = []
          @State var presentedStandup: Standup?

          var body: some View {
            List {
              ForEach(self.standup) { standup in
                Button(standup.title) { self.presentedStandup = standup }
              }
            }
            .sheet(item: self.$presentedStandup) { standup in
              StandupForm(standup: standup)
            }
          }
        }

        struct StandupForm: View {
          let standup: Standup

          var body: some View {
            Form {
              // …
            }
          }
        }
        ```

        This is great for keeping views small and understandable, but as soon as you do that you
        have to think carefully about how the two separate views can communicate with each other.
        This isn't an issue when the entirety of the UI is in a single view.

        The easiest way to accomplish this is to use "delegate closures". That is, the child view,
        `StandupForm` in this case, can expose a closure that is invoked whenever some event occurs
        inside the child view, and the parent can override that closure. We are calling it a
        "delegate closure" because it is reminescent of the delegate pattern that is popular in
        UIKit.

        For example, suppose the `StandupForm` has a delete button, and when tapped that row should
        be deleted. The form view can't possibly perform the deletion logic since it doesn't have
        access to the full array of standups. Only the standups list domain has that data.

        So, the form can hold onto a closure that it will invoke whenever it wants to tell the
        parent to perform the actual deletion logic:

         ```swift
        struct StandupForm: View {
          let standup: Standup
          let onDeleteButtonTapped: () -> Void

          var body: some View {
            Form {
              // ...
              Button("Delete") {
                self.onDeleteButtonTapped()
              }
            }
          }
        }
        ```
        """###,
      type: .paragraph
    ),
    .init(
      content: ###"""
        We prefer to name these closures in the style of beginning with "on…" and then describing
        exactly what action the user performed, rather than being named after what the child
        _thinks_ the parent should do (e.g. _deleteStandup_). This makes it easy for the parent
        domain to know what exactly happened inside the view, and it's free to implement whatever
        logic it wants.
        """###,
      type: .box(.tip)
    ),
    .init(
      content: ###"""
        Then, when the parent view (`StandupsList`) constructs the child view (`StandupForm`)
        it will provide a closure for `onDeleteButtonTapped`, and in that closure it is appropriate
        for the parent domain to implement the deletion logic:

        ```swift
        struct StandupsList: View {
          @State var standups: [Standup] = []
          @State var presentedStandup: Standup?

          var body: some View {
            List {
              // ...
            }
            .sheet(item: self.$presentedStandup) { standup in
              StandupForm(standup: standup)
            }
          }
        }
        ```

        This is simple and it works great in practice.

        However, it is not always appropriate to perform all of this logic in the view. Right now
        this code is testable only in a UI test, which can be slow and flakey. And in the future
        the child domain may want to perform its own complex logic before telling the parent to
        delete, and so we may want to move the behavior to an `ObservableObject` for each of the
        child and parent domains.

        ## Parent-child ObservableObject communication

        But things get more complicated when needing to express a parent-child relationship between
        `ObservableObject`s rather than views. You may want to do this if the logic and behavior
        inside the standup form and lists views gets complex.

        For example, we could define an `ObservableObject` for the "standup form" domain that holds
        onto a standup and has an endpoint that is called when the delete button is tapped:

        ```swift
        class StandupFormModel: ObservableObject {
          @Published var standup: Standup

          func deleteButtonTapped() {
          }
        }
        ```

        And we can define an `ObservableObject` for the "standup list" domain that holds onto an
        optional `StandupFormModel` that is set when the sheet should be presented:

        ```swift
        class StandupListsModel: ObservableObject {
          @Published var standups: [Standup] = []
          @Published var presentedStandup: StandupFormModel?

          func standupTapped(standup: Standup) {
            self.presentedStandup = StandupFormModel(standup: standup)
          }
        }
        ```

        We now need some way to have these two objects communicate with each other. We can try
        repeating the pattern for views by adding a delegate callback closure to the child domain:

        ```swift
        class StandupFormModel: ObservableObject {
          @Published var standup: Standup
          var onDeleteButtonTapped: () -> Void

          func deleteButtonTapped() {
            self.onDeleteButtonTapped()
          }
        }
        ```

        And then when constructing the `StandupFormModel` we can provide a closure in order to
        implement the logic for when the delete button is tapped:

        ```swift
        func standupTapped(standup: Standup) {
          let model = StandupFormModel(standup: standup) { [weak self] _ in
            guard let self
            else { return }
            self.standups.remove { $0 == standup }
          }
          self.presentedStandup = model
        }
        ```

        This works, but it's also a little strange. The way this is designed now, we have to be
        prepared to provide the closure anytime a `StandupFormModel` is constructed, and that might
        not always be convenient or even possible.

        For example, if we want to launch the application in a state where the form sheet is
        presented, it should be as easy as constructing a `StandupsListModel` with the
        `presentedStandup` state populated, but sadly we have to provide the deletion closure too:

        ```swift
        @main
        struct StandupsApp: App {
          var body: some Scene {
            WindowGroup {
              StandupsList(
                model: StandupsListModel(
                  standups: [
                    // ...
                  ],
                  presentedStandup: StandupFormModel(standup: standup) {
                    // ???
                  }
                )
              )
            }
          }
        }
        ```

        However, it's not possible to implement this logic here. Only the `StandupsListModel`
        can implement this logic.

        An alternative approach is to provide a default

        ```swift
        class StandupFormModel: ObservableObject {
          @Published var standup: Standup
          var onDeleteButtonTapped: () -> Void = {}

          // ....
        }




        ## Unimplemented delegate callbacks

        ## Until next time

        That's it for now, check back in tomorrow for the 2nd part of our "Modern SwiftUI" blog
        series.


        [pricing]: /pricing
        [modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 94,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-23")!,
  title: "Modern SwiftUI: Parent-child communication"  // TODO: Delegate callbacks
)
