import Foundation

public let post0097_ModernSwiftUIPart4 = BlogPost(
  author: .pointfree,
  blurb: """
    Learn about what dependencies are and why they wreak so much havoc in a code base, and then see
    what can be done to take back control over dependencies rather than let them control you.
    """,
  contentBlocks: [
    .init(
      content: #"""
        To celebrate the conclusion of our [7-part series](/collections/swiftui/modern-swiftui) on
        "Modern SwiftUI," we are releasing a blog post each day this week exploring a modern, best
        practice for SwiftUI development. Today we show how to control dependencies in your
        application rather than let them control you.

          * [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
          * [Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)
          * [Modern SwiftUI: State-driven
          navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)
          * **[Modern SwiftUI: Dependencies](/blog/posts/97-modern-swiftui-dependencies)**
        """#,
      type: .box(.preamble)
    ),
    .init(
      content: ###"""
        It doesn't matter how much time you spend writing "clean" code with precisely modeled
        domains if you don't also control your dependencies. Uncontrolled dependencies make it
        difficult to run your application in Xcode previews, simulators, and devices; make it
        difficult to write tests; and make your code base just harder to deal with.

        ## What is a dependency?

        Dependencies are the types and functions in your application that need to interact with
        outside systems that you do not control. Classic examples of this are API clients that make
        network requests to servers, but also seemingly innocuous things such as the `UUID` and
        `Date` initializers, file access, user defaults, and even clocks and timers, can all be
        thought of as dependencies.

        You can get really far in application development without ever thinking about dependency
        management (or, as some like to call it, "dependency injection”), but eventually,
        uncontrolled dependencies can cause many problems in your code base and development cycle:

          * Uncontrolled dependencies make it **difficult to write fast, deterministic tests**
            because you are susceptible to the vagaries of the outside world, such as file systems,
            network connectivity, internet speed, server uptime, and more.
          * Many dependencies **do not work well in SwiftUI previews**, such as location managers
            and speech recognizers, and some **do not work even in simulators**, such as motion
            managers, and more. This prevents you from being able to easily iterate on the design of
            features if you make use of those frameworks.
          * Dependencies that interact with 3rd party, non-Apple libraries (such as Firebase, web
            socket libraries, network libraries, video streaming libraries, _etc._) tend to be
            heavyweight and take a **long time to compile**. This can slow down your development
            cycle.

        ## Controlling dependencies

        For the reasons above, and a lot more, it is highly encouraged that you to take control of
        your dependencies rather than let them control you.

        In fact, in our series on "[Modern SwiftUI](/collections/swiftui/modern-swiftui)," where we
        rebuild Apple's "[Scrumdinger][scrumdinger]" application from [scratch][standups-source],
        we came face-to-face with this lesson as soon as we introduced code that called out to
        Apple's Speech framework. We found that directly accessing Speech APIs from our feature
        completely broke the preview, making it difficult to iterate on the UI and functionality. We
        were forced to run the full app in the simulator, which destroyed the fast iteration cycle
        that previews give us.

        So, we decided to take control of our dependence on Speech (and a lot of other
        dependencies too!) by putting an [interface][speech-client-source] that we own in front of
        the framework:

        ```swift
        struct SpeechClient {
          var authorizationStatus:
            @Sendable () -> SFSpeechRecognizerAuthorizationStatus
          var requestAuthorization:
            @Sendable () async -> SFSpeechRecognizerAuthorizationStatus
          var startTask:
            @Sendable (SFSpeechAudioBufferRecognitionRequest) async -> AsyncThrowingStream<
              SpeechRecognitionResult, Error
            >
        }
        ```

        Then we made use of our new [Dependencies][dependencies-gh] library to inject the dependency
        into the [feature][record-model-source] that needs to interact with the Speech framework:

        ```swift
        class RecordMeetingModel: ObservableObject {
          @Dependency(\.speechClient) var speechClient
          …
        }
        ```

        So we no longer reach for Speech APIs directly, and instead we only go through the
        `speechClient` interface. For example, when asking for [speech recognition
        authorization][speech-rec-auth-source]:

        ```swift
        let authorization = await self.speechClient.authorizationStatus() == .notDetermined
          ? self.speechClient.requestAuthorization()
          : self.speechClient.authorizationStatus()
        ```

        With that little bit of upfront work we were able to restore functionality in our previews
        because we can now mock the speech client to act as if the user had previously authorized
        speech recognition:

        ```swift
        struct RecordMeeting_Previews: PreviewProvider {
          static var previews: some View {
            NavigationStack {
              RecordMeetingView(
                model: withDependencies {
                  $0.speechClient.authorizationStatus = { .authorized }
                } operation: {
                  RecordMeetingModel(standup: .mock)
                }
              )
            }
          }
        }
        ```

        The Speech framework isn't the only dependency we controlled in our
        [Standups][standups-source] application. We also controlled our dependence on the `Date` and
        `UUID` initializers, our dependence on clocks for time-based asynchrony, our dependence
        on the file system for persisting application data, and even our dependence on an
        `AVAudioEngine` for playing sound effects in the app.

        ## Until next time…

        That's it for now. We hope you have learned a bit about why dependencies can be so
        pernicious and how you might take back control over them. Be sure to check out our
        [Dependencies][dependencies-gh] library to start wrangling in your dependencies today!

        Check back in tomorrow for the 5th, and final, part of our "Modern SwiftUI" blog series,
        where we show how to write deep, nuanced tests now that our application is built with a
        precisely modeled domain and all dependencies controlled.

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
        [speech-rec-auth-source]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/RecordMeeting.swift#L80-L83
        [speech-client-source]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/Dependencies/SpeechClient.swift
        [record-model-source]: https://github.com/pointfreeco/swiftui-navigation/blob/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups/Standups/RecordMeeting.swift
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 97,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-26")!,
  title: "Modern SwiftUI: Dependencies"
)
