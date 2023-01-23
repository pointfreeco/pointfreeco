import Foundation

public let post0094_ModernSwiftUIPart1 = BlogPost(
  author: .pointfree,
  blurb: """
    We are celebrating the conclusion of our 7-part series on Modern SwiftUI by releasing a blog
    post every day, detailing an area of SwiftUI development that can be modernized. We begin
    by exploring ways to facilitate parent-child communication in SwiftUI in a safe and ergonomic
    manner.
    """,
  contentBlocks: [
    .init(
      content: ###"""
        This week we finished our ambitious, [7-part series][modern-swiftui-collection] exploring
        modern, best practices for SwiftUI development. In those episodes we rebuilt Apple’s
        ”[Scrumdinger][scrumdinger]” application ([source code here][standups-source]), which is a
        great showcase for many of the problems one encounters in a real life application. Every
        step of the way we challenged ourselves to write the code in the most scalable and
        future-proof way possible, including:

        1. We eschew plain arrays for lists and instead embrace [identified
        arrays][identified-collections-gh].
        1. All of navigation is [state-driven][swiftui-nav-gh] and concisely modeled.
        1. All side effects and [dependencies][dependencies-gh] are controlled.
        1. A [full test suite][standups-test-suite] is provided to test many complex and nuanced
        user flows.

        …and a whole bunch more.

        To celebrate the conclusion of the series we are going to release one new blog post every
        day this week detailing an area of SwiftUI development that can be modernized, starting
        today with parent-child communication.

        If you find any of this interesting, then consider [subscribing][pricing] today to get
        access to the [full series][modern-swiftui-collection], as well as our entire back catalog
        of episodes!

        ## Parent-child view communication

        It is common to break up a complex view into smaller pieces. Even something as simple as
        showing a sheet is typically done by having a dedicated view for the present**ing** view and
        present**ed** view. For example, a list of rows such that when one is tapped it brings up a
        sheet for editing:

        ```swift
        struct StandupsList: View {
          @State var standups: [Standup] = []
          @State var editStandup: Standup?

          var body: some View {
            List {
              ForEach(self.standup) { standup in
                Button(standup.title) { self.editStandup = standup }
              }
            }
            .sheet(item: self.$editStandup) { standup in
              EditStandup(standup: standup)
            }
          }
        }

        struct EditStandup: View {
          let standup: Standup

          var body: some View {
            Form {
              …
            }
          }
        }
        ```

        This is great for keeping views small and understandable, but as soon as you do that you
        have to think carefully about how the two separate views can communicate with each other.
        This isn't an issue when the entirety of the UI is in a single view.

        The easiest way to accomplish this is to use "delegate closures." That is, the child view,
        `EditStandup` in this case, can expose a closure that is invoked whenever some event occurs
        inside the child view, and the parent can override that closure. We are calling it a
        "delegate closure" because it is reminiscent of the delegate pattern that is popular in
        UIKit.

        For example, suppose the `EditStandup` has a delete button, and when tapped that row should
        be deleted. The edit view can't possibly perform the deletion logic since it doesn't have
        access to the full array of standups. Only the standups list domain has that data.

        So, the view can hold onto a closure that it will invoke whenever it wants to tell the
        parent to perform the actual deletion logic:

        ```swift
        struct EditStandup: View {
          let standup: Standup
          let onDeleteButtonTapped: () -> Void

          var body: some View {
            Form {
              …
              Button("Delete") {
                self.onDeleteButtonTapped()
              }
            }
          }
        }
        ```

        [standups-test-suite]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/StandupsTests
        [dependencies-gh]: http://github.com/pointfreeco/swiftui-dependencies
        [swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
        [standups-source]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups
        [pricing]: /pricing
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        [runtime-warn-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [xctest-dynamic-overlay]: http://github.com/pointfreeco/xctest-dynamic-overlay
        [unimplemented-docs]: https://pointfreeco.github.io/xctest-dynamic-overlay/main/documentation/xctestdynamicoverlay/unimplemented(_:fileid:line:)-5098a
        """###,
      type: .paragraph
    ),
    .init(
      content: ###"""
        We prefer to name these closures in the style of beginning with `on*` and then describing
        exactly what action the user performed (_e.g._, `onDeleteButtonTapped`), rather than being
        named after what the child _thinks_ the parent should do (_e.g._, `deleteStandup`). This
        makes it easy for the parent domain to know what exactly happened inside the view, and it's
        free to implement whatever logic it wants.
        """###,
      type: .box(.tip)
    ),
    .init(
      content: ###"""
        Then, when the parent view (`StandupsList`) constructs the child view (`EditStandup`) it
        will provide a closure for `onDeleteButtonTapped`, and in that closure it is appropriate for
        the parent domain to implement the deletion logic:

        ```swift
        struct StandupsList: View {
          @State var standups: [Standup] = []
          @State var editStandup: Standup?

          var body: some View {
            List {
              …
            }
            .sheet(item: self.$editStandup) { standup in
              EditStandup(standup: standup) {
                // ✅ Perform logic when "Delete" button is tapped in sheet
                self.standups.removeAll { $0 == standup }
              }
            }
          }
        }
        ```

        This is simple and it works great in practice.

        However, it is not always appropriate to perform all of this logic in the view. Right now
        this code is testable only in a UI test, which can be slow and flakey. And in the future
        the child domain may want to perform its own complex logic before telling the parent to
        delete (such as tracking analytics or performing API requests), and so we may want to move
        the behavior to an `ObservableObject` for each of the child and parent domains.

        ## Parent-child `ObservableObject` communication

        But things get more complicated when needing to express a parent-child relationship between
        `ObservableObject`s rather than views. You may want to do this if the logic and behavior
        inside the edit standup and list views gets too complex to have all in the view.

        For example, we could define an `ObservableObject` for the "edit standup" domain that holds
        onto a standup and has an endpoint that is called when the delete button is tapped:

        ```swift
        class EditStandupModel: ObservableObject {
          @Published var standup: Standup

          func deleteButtonTapped() {
          }

          …
        }
        ```

        And we can define an `ObservableObject` for the "standup list" domain that holds onto an
        optional `EditStandupModel` that is set when the sheet should be presented:

        ```swift
        class StandupListsModel: ObservableObject {
          @Published var standups: [Standup] = []
          @Published var editStandup: EditStandupModel?

          func standupTapped(standup: Standup) {
            self.editStandup = EditStandupModel(standup: standup)
          }

          …
        }
        ```

        We now need some way to have these two objects communicate with each other. We can try
        repeating the pattern for views by adding a delegate callback closure to the child domain:

        ```swift
        class EditStandupModel: ObservableObject {
          @Published var standup: Standup
          var onDeleteButtonTapped: () -> Void

          func deleteButtonTapped() {
            // Let the parent know that the delete button was tapped.
            self.onDeleteButtonTapped()
          }

          …
        }
        ```

        And then when constructing the `EditStandupModel` we can provide a closure in order to
        implement the logic for when the delete button is tapped, taking great care to not create a
        retain cycle since we are now dealing with reference types:

        ```swift
        func standupTapped(standup: Standup) {
          let model = EditStandupModel(standup: standup) { [weak self] _ in
            guard let self
            else { return }
            self.standups.remove { $0 == standup }
          }
          self.editStandup = model
        }
        ```

        This works, but it's also a little strange. The way this is designed now, we have to be
        prepared to provide the closure anytime a `EditStandupModel` is constructed, and that might
        not always be convenient or even possible.

        For example, if we want to launch the application in a state where the edit sheet is
        presented, it should be as easy as constructing a `StandupsListModel` with the
        `editStandup` state populated, but sadly we have to provide the deletion closure too:

        ```swift
        @main
        struct StandupsApp: App {
          var body: some Scene {
            WindowGroup {
              StandupsList(
                model: StandupsListModel(
                  standups: [
                    …
                  ],
                  editStandup: EditStandupModel(
                    standup: standup,
                    onDeleteButtonTapped: <#() -> Void#>  // ???
                  )
                )
              )
            }
          }
        }
        ```

        However, it's not possible to implement this logic here. Only the `StandupsListModel`
        can implement this logic. And this is only the tip of the iceberg. There are going to be
        many times we want to construct a `EditStandupModel` for which it is not possible to provide
        the deletion closure immediately.

        An alternative approach is to provide a default for the closure so that you can create
        a `EditStandupModel` without the closure:

        ```swift
        class EditStandupModel: ObservableObject {
          @Published var standup: Standup
          var onDeleteButtonTapped: () -> Void = {}

          …
        }
        ```

        …and then you bind the closure at a later time. You need to do this in two situations:
        when the `editStandup` state changes and when the parent domain is created:

        ```swift
        class StandupListsModel: ObservableObject {
          @Published var standups: [Standup] = []
          @Published var editStandup: EditStandupModel? {
            didSet { self.bind() }  // 👈
          }

          init(
            standups: [Standup] = [],
            editStandup: EditStandupModel? = nil
          ) {
            self.standups = standups
            self.editStandup = editStandup
            self.bind()  // 👈
          }

          // Override delegate closures in all child models.
          private func bind() {
            self.editStandup?.onDeleteButtonTapped = { [weak self] in
              guard let self
              else { return }
              self.standups.remove { $0 == self.editStandup?.standup }
            }
          }
        }
        ```

        With that you are free to construct `EditStandupModel` objects without providing the
        closure, yet the closure will still be properly bound from inside the parent domain.

        So, sounds like a win-win!

        ## Safety versus ergonomics

        Well, not so fast. We have actually lost some safety with this approach.

        When we were requiring the closure at initialization of `EditStandupModel` we could
        guarantee that the closure would be provided, it just wasn't very ergonomic to do so. But
        now that we have provided a default, it's possible for you to construct a `EditStandupModel`
        and be blissfully unaware that you need to provide this extra bit of functionality.

        So, if in the future the "edit standup" domain gains a new feature for duplicating the
        standup, and it needs to communicate that to the parent:

        ```swift
        class EditStandupModel: ObservableObject {
          var onDeleteButtonTapped: () -> Void = {}
          var onDuplicateButtonTapped: () -> Void = {}
          …
        }
        ```

        …then it will be on us to remember to update the `bind` method to tap into this new closure.
        Nothing will let us know this is needed, and if we forget, then our feature will just be
        subtly broken and we will need to hunt through the code to figure out what went wrong.

        So, there's a choice to be made: do we want the safety of a required delegate closure while
        not having the best ergonomics, or do we want ergonomics at the cost of losing some safety?

        ## "Unimplemented" delegate closures

        Well, fortunately for us there's a middle ground. We can have safety _and_ ergonomics by
        using what we like to call "unimplemented delegate closures". The idea is to provide a
        default for the closure so that it is not required at initialization time, _but_ make a
        loud noise when that closure is invoked. This allows you to be easily notified when you have
        not correctly configured the model.

        The strength of this approach largely depends on how exactly you make a "loud noise." If you
        only print a message to the console, that will not be nearly loud enough and so will be easy
        to miss. On the other hand, if you performed a `fatalError` then it would be _super_ loud,
        but will be far to disruptive to your workflow.

        A better approach is to show a purple, runtime warning in Xcode, much like what is shown
        when the thread sanitizer detects a problem, or when you update UI on a non-main thread.
        We've [written about this approach][runtime-warn-blog] in the past, and we even have an
        [open source library][xctest-dynamic-overlay] that has a tool to make this super ergonomic.

        The tool is called [`unimplemented`][unimplemented-docs], and it is capable of generating a
        closure of virtually any signature, and if ever invoked it will cause a runtime warning in
        Xcode, and even a test failure when run in tests:

        ```swift
        import XCTestDynamicOverlay

        class EditStandupModel: ObservableObject {
          var onDeleteButtonTapped: () -> Void = unimplemented(
            "EditStandupModel.onDeleteButtonTapped"
          )
          var onDuplicateButtonTapped: () -> Void = unimplemented(
            "EditStandupModel.onDuplicateButtonTapped"
          )
          …
        }
        ```

        This makes it so that you don't need to provide the closures upon initialization of
        `EditStandupModel`, but also if you forget to do so you will get a loud, yet unobtrusive,
        runtime warning or test failure.

        The warning even gives you a stack trace of how things went wrong, which acts as breadcrumbs
        to trace back to the problematic line of code:

        [pricing]: /pricing
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        [runtime-warn-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [xctest-dynamic-overlay]: http://github.com/pointfreeco/xctest-dynamic-overlay
        [unimplemented-docs]: https://pointfreeco.github.io/xctest-dynamic-overlay/main/documentation/xctestdynamicoverlay/unimplemented(_:fileid:line:)-5098a
        """###,
      type: .paragraph
    ),
    .init(
      content: ###"""
        Foo bar
        """###,
      type: .image(
        src:
          "https://pointfreeco-blog.s3.amazonaws.com/posts/0094-modern-swiftui-delegate-closures/on-delete-unimplemented.png",
        sizing: .fullWidth
      )
    ),
    .init(
      content: ###"""
        From this it is obvious to see that the `EditStandupModel` has a `onDeleteButtonTapped`
        closure that we need to override.

        ## Until next time…

        That's it for now. We hope you learned something about parent-child communication with
        `ObservableObject`s, and hope that you try our making such communication safer and more
        ergonomic by making use of "[unimplemented delegate closures][xctest-dynamic-overlay]."

        Check back tomorrow for the 2nd part of our "Modern SwiftUI" blog series, where we will show
        how to make collections safer and more performant to use in SwiftUI lists.

        [standups-source]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups
        [pricing]: /pricing
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        [runtime-warn-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [xctest-dynamic-overlay]: http://github.com/pointfreeco/xctest-dynamic-overlay
        [unimplemented-docs]: https://pointfreeco.github.io/xctest-dynamic-overlay/main/documentation/xctestdynamicoverlay/unimplemented(_:fileid:line:)-5098a
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 94,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-23")!,
  title: "Modern SwiftUI: Parent-child communication"
)
