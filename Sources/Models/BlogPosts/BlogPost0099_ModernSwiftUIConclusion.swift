import Foundation

public let post0099_ModernSwiftUIConclusion = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
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

        To celebrate the conclusion of our "Modern SwiftUI" series, we have released a blog post
        _every day_ this week, detailing a different aspect of building SwiftUI applications using
        modern, best practices. Check them all out here:

        * [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
        * [Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)
        * [Modern SwiftUI: State-driven
        navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)
        * [Modern SwiftUI: Dependencies](/blog/posts/97-modern-swiftui-dependencies)
        * **[Modern SwiftUI: Testing](/blog/posts/98-modern-swiftui-testing)**

        ## A call for help!

        We hope that you find some of the topics discussed above exciting, and if you want to learn
        more, be sure to check out our [7-part series][modern-swiftui-collection] on “Modern
        SwiftUI.”

        We do have a favor to ask you. While we have built the [Standups][standups-source]
        application in the style that makes the most sense to us, we know that some of these ideas
        aren't for everyone. We would love if others fork the Standups code base and re-build it in
        the style of their choice.

        Don't like to use an `ObservableObject` for each screen? Prefer to use `@StateObject`
        instead of `@ObservedObject`? Want to use an architectural pattern such as VIPER? Have a
        different way of handling dependencies? **Please show us!**

        We will collect links to the other ports so that there can be a single place to reference
        many different approaches for building the same application.

        [datafailedtoload-source]: https://github.com/pointfreeco/swiftui-navigation/blob/1db1bcfd1e9f533a17074b7e95613d0d9a78262c/Examples/Standups/Standups/StandupsList.swift#L127-L143
        [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
        [pricing]: /pricing
        [modern-swiftui-collection]: https://www.pointfree.co/collections/swiftui/modern-swiftui
        [swiftui-collection]: https://www.pointfree.co/collections/swiftui
        [swiftui-nav-collection]: https://www.pointfree.co/collections/swiftui/navigation
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
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  hidden: false,
  id: 99,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-27")!,
  title: "Modern SwiftUI"
)
