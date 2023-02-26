import Foundation

public let post0044 = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are releasing first-party support for instrumenting features built in the Composable Architecture.
    """,
  contentBlocks: [
    .init(
      content: """
        Today we are releasing first-party support for instrumenting features built in the [Composable Architecture](https://www.github.com/pointfreeco/swift-composable-architecture). This allows you to instantly get insight into how often actions are being sent, how long they take to execute, and which effects are currently in-flight.

        ---
        """,
      type: .paragraph
    ),
    .init(
      content: "",
      type: .image(
        src: "https://d3rccdn33rt8ze.cloudfront.net/point-free-pointers/0044-signposts-cover.jpg",
        sizing: .fullWidth
      )
    ),
    .init(
      content: """
        ---

        ## Signposts

        In 2018 Apple introduced [signposts](https://developer.apple.com/documentation/os/logging/recording_performance_data) (see the WWDC video [here](https://developer.apple.com/videos/play/wwdc2018/405/)), a lightweight and efficient way to measure the performance of any part of your application. By setting up "beginning" and "ending" signposts around a task, you can get immediate aggregate stats on that task in Instruments, such as number of times that code path is executed, maximum and minimum duration to execute, as well as average time to execute and standard deviation.

        Signposts, and more generally `os_log`, were designed to be lightweight and highly performant so that we shouldn't be afraid of dropping in dozens or hundreds of this measurements in our application. However, doing that at your whim without any regard to the code quality of your application is likely to lead to a lot of disparate metrics cluttering your logs and application logic.

        Lucky for us, features built in the [Composable Architecture](https://www.pointfree.co/collections/composable-architecture) have a single place that application logic is performed: in the reducer! Also lucky for us, reducers are super composable and allow us to layer on additional functionality at a high level without littering its core implementation. This has allowed us to introduce [`.signpost()`](https://github.com/pointfreeco/swift-composable-architecture/pull/142), a new [higher-order reducer](https://www.pointfree.co/collections/composable-architecture/reducers-and-stores/ep71-composable-state-management-higher-order-reducers) that instruments any reducer with signpost marks, giving you instant insight into the statistical performance of your code.

        ## How?

        To instrument any feature built in the Composable Architecture simply tack `.signpost()` onto your reducer:

        ```swift
        let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> {
          state, action, environment in

          switch action {
            // All of your feature's logic
          }
        }
        .signpost()
        ```

        That's it 🤯.

        This will set up beginning and ending signposts for each reducer invocation, allowing you to see how many times each action is sent and how long each reducer takes to execute. This can help find any business logic that is taking too long to execute, which might benefit from being moved to an effect that is executed on a background thread.

        This method will also start a signpost when an effect returned from the reducer starts, and end the signpost when the effect completes (either successfully or by cancellation). This gives you insight into what effects are currently executing and how long it takes them to finish. This is particularly useful for inspecting the lifecycle of long-living effects. For example, if you fire up a long-living effect (e.g. a location manager) in `onAppear` and forget to tear down the effect in `onDisappear`, it will clearly show in Instruments that the effect never completed.

        To read the stats from these signposts simply run your application in Instruments (⌘I), start with a blank instrument, add the `os_signpost` library by tapping the `+` icon in the top-right, and then start recording your app by tapping the red button in the top-left.

        You can apply this method locally if you are interested in just a certain feature's performance, or you can apply it to the base, app-level reducer that powers your entire application.

        ## Start instrumenting today

        We've just released version [version 0.3.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.3.0) of the Composable Architecture, and so you can start using this new feature immediately. [Let us know](https://twitter.com/pointfreeco) what you think!
        """,
      type: .paragraph
    ),
  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/point-free-pointers/0044-metadata-cover.jpg",
  id: 44,
  publishedAt: .init(timeIntervalSince1970: 1_590_555_600),
  title: "Instrumenting features built in the Composable Architecture"
)
