import Foundation

public let post0096_ModernSwiftUIPart3 = BlogPost(
  author: .pointfree,
  blurb: """
    Learn how to best leverage optionals and enums when modeling state-driven navigation in SwiftUI.
    """,
  contentBlocks: [
    .init(
      content: #"""
        To celebrate the conclusion of our [7-part series](/collections/swiftui/modern-swiftui) on
        "Modern SwiftUI," we are releasing a blog post each day this week exploring a modern, best
        practice for SwiftUI development. Today we show how to more concisely model your domains
        for navigation in SwiftUI, but be sure to catch up on the other posts:

          * [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
          * [Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)
          * **[Modern SwiftUI: State-driven
            navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)**
          * _More coming soon_
        """#,
      type: .box(.preamble)
    ),
    .init(
      content: ###"""
        Navigation is one of the most difficult aspects of SwiftUI, and it's why we have a [big
        series of episodes][swiftui-nav-collection] dedicated to the topic. But it doesn't have
        to be that way. It's possible to model navigation in state using concise tools (_e.g._,
        optionals and enums), which makes it easy to deep link into any state imaginable in your
        application.

        ## What is "state-driven navigation"?

        You can get really far in SwiftUI using what we call "fire-and-forget" navigation, where
        there is no representation of the navigation in your state. One example of this is the
        `NavigationLink` initializer that only takes a title and destination view:

        ```swift
        NavigationLink("Go to settings") {
          SettingsView()
        }
        ```

        The only way to navigate to the settings view is for the user to literally tap the link.
        It is not possible to programmatically construct a piece of state, hand it to SwiftUI,
        and let SwiftUI do the rest. This means we can't deep link into the settings screen, whether
        that be from a push notification, URL link, state restoration, or even after performing
        some asynchronous work.

        This is why it's best to use SwiftUI's "state-driven" navigation APIs, where the
        presentation and dismissal of a view is represented as state in your actual domain. The
        `sheet` modifier for presenting modals is an example of this:

        ```swift
        struct FeatureView: View {
          @State var isPresented = false

          var body: some View {
            Button("Show sheet") {
              self.isPresented = true
            }
            .sheet(isPresented: self.$isPresented) {
              Text("Hello!")
            }
          }
        }
        ```

        It is possible to show this sheet by simply flipping a boolean to `true`. This can happen
        with a user action, such as the above button tap, but it can also happen without any user
        intervention, such as if a push notification was received.

        State-driven navigation offers a lot more flexibility and power than its "fire-and-forget"
        counterpart, but it can also be more difficult to implement correctly.

        ## Optional-driven navigation

        Many navigation APIs in SwiftUI are "optional-driven", that is, a piece of optional state
        determines whether or not a view is presented. For example, a modal sheet can be presented
        when a piece of optional state becomes non-`nil`, and then be dismissed when it becomes
        `nil`:

        ```swift
        struct FeatureView: View {
          @State var presentedValue: String?

          var body: some View {
            Button("Show sheet") {
              self.presentedValue = "Hello!"
            }
            .sheet(item: self.$presentedValue) { value in
              Text(value)
            }
          }
        }
        ```

        This works well, and can allow the modal to be dynamic based on data passed from the
        parent view.

        However, sometimes it's not powerful enough. Often we don't want just a plain, inert value
        passed to the modal, but rather a full binding so that the child can make changes to the
        value that will be observable from the parent. In order to do this we can make use of
        the [`.sheet(unwrapping:)`][sheet-unwrapping-source] view modifier that ships with our
        [SwiftUINavigation][swiftui-nav-gh] library:

         ```swift
        struct FeatureView: View {
          @State var presentedValue: String?

          var body: some View {
            Button("Show sheet") {
              self.presentedValue = "Hello!"
            }
            .sheet(unwrapping: self.$presentedValue) { $value in
              TextField("Value", text: $value)
            }
          }
        }
        ```

        This will "unwrap" the `Binding<String?>` to turn it into a `Binding<String>`, which is
        handed to the modal view presented.

        ## Enum-driven navigation

        SwiftUI ships lots of tools for dealing with state modeled on structs (_e.g._, dynamic
        member lookup for deriving bindings) and optionals (_e.g._, optional-drive navigation like
        in `.sheet(item:)`), but sadly there are no tools for enums. Enums are one of the most
        powerful features of Swift. They allow you to statically describe the mutually exclusive
        choice of a finite set of cases, and they are a great tool for modeling navigation state.

        For example, in our series on "[Modern SwiftUI](/collections/swiftui/modern-swiftui)" we
        rebuilt Apple's "[Scrumdinger][scrumdinger]" application from [scratch][standups-source],
        and in doing so we modeled navigation state as concisely as possible using enums.

        One screen, the ["standup detail" screen][standup-detail-source], has 4 possible
        destinations it can navigate to: an alert for deleting the standup, a sheet for editing the
        standup, a drill-down to a previously recorded meeting, and a drill-down to record a new
        meeting. If we use only the tools that SwiftUI gives us, then we would be forced to model
        all of these destinations as optionals:

        ```swift
        @Published var alert: AlertState<AlertAction>?
        @Published var edit: EditStandupModel?
        @Published var meeting: Meeting?
        @Published var record: RecordMeetingModel?
        ```

        We now have 2⁴=16 states to contend with, of which only 5 are actually valid (either exactly
        1 is non-`nil`, or all are `nil`). It doesn't make sense to have the delete alert _and_
        edit screen open at the same time, as well as 10 other combinations that are nonsensical.

        That kind of imprecision in the domain starts to leak complexity throughout the entire code
        base. You can never be sure of what screen is actually visible because you must check
        multiple pieces of state to see if they are `nil`, and if new destinations are added then
        existing code can all of a sudden become incorrect.

        For this reason we prefer to model this kind of state as an enum, which automatically bakes
        in compile-time proof that only one value can be instantiated at a time. This is [how it
        looks][standup-detail-destination-enum] in the actual `StandupDetailModel` that powers the
        screen:

        <div id="enum-destination"></div>

        ```swift
        class StandupDetailModel: ObservableObject {
          @Published var destination: Destination?

          enum Destination {
            case alert(AlertState<AlertAction>)
            case edit(EditStandupModel)
            case meeting(Meeting)
            case record(RecordMeetingModel)
          }

          // ...
        }
        ```

        And then, [in the view][standup-detail-destinations-view], we can make use of the tools that
        ship in our [SwiftUINavigation][swiftui-nav-gh] library, which allows you to perform all
        styles of navigation (alerts, sheets, popovers, drill-downs, _etc._) with a single, unified
        API that allows you to choose which case of an enum should drive the navigation for that
        destination:

        ```swift
        .navigationDestination(
          unwrapping: self.$model.destination,
          case: /StandupDetailModel.Destination.meeting
        ) { $meeting in
          MeetingView(meeting: meeting, standup: self.model.standup)
        }
        .navigationDestination(
          unwrapping: self.$model.destination,
          case: /StandupDetailModel.Destination.record
        ) { $model in
          RecordMeetingView(model: model)
        }
        .alert(
          unwrapping: self.$model.destination,
          case: /StandupDetailModel.Destination.alert
        ) { action in
          await self.model.alertButtonTapped(action)
        }
        .sheet(
          unwrapping: self.$model.destination,
          case: /StandupDetailModel.Destination.edit
        ) { $editModel in
          EditStandupView(model: editModel)
        }
        ```

        With that little bit of upfront work, navigating to a particular screen is as easy as just
        constructing a piece of state. For example, when the ["Edit" button is
        tapped][standup-detail-edit-button-tapped], we can show the edit sheet by simply populating
        the `destination` state:

        ```swift
        self.destination = .edit(
          withDependencies(from: self) {
            EditStandupModel(standup: self.standup)
          }
        )
        ```

        Or when the ["Start a meeting" button is tapped][standup-detail-start-meeting-tapped], we
        can drill down to the record meeting screen by populating the `destination` state:

        ```swift
        self.destination = .record(
          withDependencies(from: self) {
            RecordMeetingModel(standup: self.standup)
          }
        )
        ```

        Or when the ["Cancel" button is tapped][standup-detail-cancel-tapped], we can dismiss the
        sheet by simply `nil`-ing out the `destination` state:

        ```swift
        self.destination = nil
        ```

        This makes navigation incredibly simple, and we can let SwiftUI handle the hard part of
        actually performing the animations and displaying the new UI.

        But the best part is that deep linking, whether it be from push notifications or URLs or
        something else, can be implemented by simply constructing a deeply nested piece of state,
        handing it to SwiftUI, and letting it do its thing.

        For example, if we wanted to deep link into the app so that we are drilled down to the
        standup detail screen, and then further drill down to a new meeting, it is as easy as this:

        ```swift
        StandupsList(
          model: StandupsListModel(
            destination: .detail(
              StandupDetailModel(
                destination: .record(
                  RecordMeetingModel(standup: standup)
                ),
                standup: standup
              )
            )
          )
        )
        ```

        It is incredibly powerful!

        ## `@StateObject` versus `@ObservedObject`

        So, state-driven navigation can be powerful, but you also must be care where you keep the
        state. To unlock the most power from state-driven navigation it must be modeled in
        `ObservableObject`s instead of directly in views as `@State`, and _further_, objects
        must be installed in the view as `@ObservedObject`s rather than `@StateObject`s.

        The `@State` and `@StateObject` property wrappers are incredibly powerful, but it's
        important to know that they are local to the view and cannot be influenced from the outside.
        They create islands of behavior for features, and so it is not easy to integrate many
        features' behavior together.

        In particular, this means features modeled on `@State` and `@StateObject` are not
        conducive to deep linking. Because the view owns the state it is not easy to construct
        all of the views in a particular state.

        For example, if all of the views in our [Standups][standups-source] application used
        `@StateObject` instead of `@ObservedObject` we would have no ability to launch the app
        in a very specific state, such as drilled down to the detail screen and then the record
        screen. But with `@ObservedObject`, since the models can be passed to the view at each
        layer, it's as easy as this:

        ```swift
        StandupsList(
          model: StandupsListModel(
            destination: .detail(
              StandupDetailModel(
                destination: .record(
                  RecordMeetingModel(standup: standup)
                ),
                standup: standup
              )
            )
          )
        )
        ```

        For these reasons we highly recommend eschewing `@StateObject` in favor of `@ObservedObject`
        if deep linking is important to your application.

        ## Until next time…

        That's it for now. We hope you have learned how to better leverage enums and optionals for
        making your navigation state in SwiftUI as concise as possible. Be sure to check out our
        [SwiftUINavigation][swiftui-nav-gh] library to unlock the full power of enums in navigation
        state.

        Check back in tomorrow for the 4th part of our "Modern SwiftUI" blog series, where we show
        how to take control of dependencies in your code base, rather than let them control you.

        [pricing]: /pricing
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [swiftui-collection]: /collections/swiftui
        [swiftui-nav-collection]: /collections/swiftui/navigation
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
        [sheet-unwrapping-source]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Sources/SwiftUINavigation/Sheet.swift#L9-L61
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 96,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-25")!,
  title: "Modern SwiftUI: State-driven navigation"
)
