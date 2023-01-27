import Foundation

public let post0095_ModernSwiftUIPart2 = BlogPost(
  author: .pointfree,
  blurb: """
    Learn how to make lists of data in your SwiftUI applications safer and more performant by
    scrapping plain arrays and embracing "identified arrays".
    """,
  contentBlocks: [
    .init(
      content: #"""
        To celebrate the conclusion of our [7-part series](/collections/swiftui/modern-swiftui) on
        "Modern SwiftUI," we are releasing a blog post each day this week exploring a modern, best
        practice for SwiftUI development. Today we show how make lists of data in your SwiftUI
        applications safer and more performant, but be sure to catch up on the other posts:

        * [Modern SwiftUI: Parent-child communication](/blog/posts/94-modern-swiftui-parent-child-communication)
        * **[Modern SwiftUI: Identified arrays](/blog/posts/95-modern-swiftui-identified-arrays)**
        * [Modern SwiftUI: State-driven
          navigation](/blog/posts/96-modern-swiftui-state-driven-navigation)
        * [Modern SwiftUI: Dependencies](/blog/posts/97-modern-swiftui-dependencies)
        * [Modern SwiftUI: Testing](/blog/posts/98-modern-swiftui-testing)
        """#,
      type: .box(.preamble)
    ),
    .init(
      content: ###"""
        The `List` and `ForEach` views in SwiftUI are foundational and incredibly easy to get
        started with. Compared to the days of UIKit, lists have never been easier. However, if used
        naively, in particular using plain arrays, it is possible to introduce subtle bugs and
        crashes to your applications.

        We will describe how to avoid those problems by using the
        [`IdentifiedArray`][identified-collections-gh] type, which allows you to read and modify
        elements of a collection by their stable ID rather than positional index.

        ## The problem with positional indices

        By far the easiest way to model data for lists is to use a plain array:

        ```swift
        struct StandupsList: View {
          @State var standups: [Standup] = […]

          var body: some View {
            List {
              ForEach(self.standups) { standup in
                StandupRow(standup: standup)
              }
            }
          }
        }
        ```

        However, using plain arrays often leads one to referencing its elements by its positional
        index. Doing this can be precarious, leading to corrupt data and even crashes.

        For example, because `ForEach` deals primarily with `Identifiable` types, it is common that
        we have the stable ID of an element that we need to convert to a positional index so that we
        can perform some work, say, removing the element:

        ```swift
        func deleteStandup(id: Standup.ID) {
          guard let index = self.standups.firstIndex(where: { $0.id == id })
          else { return }

          self.standups.remove(at: index)
        }
        ```

        Try searching your code base for "`.firstIndex(where`" to see how many times you do this
        yourself. Unfortunately, this code is both inefficient _and_ dangerous.

        It is a potential performance problem because you are linearly scanning an array to find an
        element by its ID. If your collection has thousands of elements (or hundreds of thousands of
        elements!), this can be a serious problem.

        Further, this code is not safe. Suppose that we have an API service to communicate with when
        deleting the standup. If we do this naively:

        ```swift
        func deleteStandup(id: Standup.ID) async throws {
          guard let index = self.standups.firstIndex(where: { $0.id == id })
          else { return }

          try await self.apiClient.delete(id: id)

          self.standups.remove(at: index)
        }
        ```

        …then we can accidentally update the wrong standup or even crash. While the API client is
        suspending, it is possible for the `standups` array to shuffle its elements or even remove
        some elements when the API request is in flight. So, after the suspension resumes, the
        `index` may no longer correspond to the correct element, or may even fall outside the bounds
        of the array.

        To fix this you must always recompute indices you use after _every_ suspension point, and if
        there are multiple suspension points then you may need to compute the index multiple times.

        ## Using identified arrays

        SwiftUI is well aware of the problems of using positional indices in lists of data, and
        that's why `ForEach` forces data types to have a stable identifier via the `Identifiable`
        protocol. Unfortunately, there is no type that ships with the Swift standard library to
        embrace this pattern in your domain modeling. That's precisely the gap that
        [IdentifiedArray][identified-collections-gh] aims to fill.

        In our series on "[Modern SwiftUI][modern-swiftui-collection]" we rebuilt Apple's
        "[Scrumdinger][scrumdinger]" application from [scratch][standups-source] to showcase modern,
        best practices, and the first change we made was to scrap plain arrays when modeling data
        for lists. Instead, we made use of our [IdentifiedArray][identified-collections-gh] data
        type, which allows referencing elements by their stable ID rather than their unstable
        positional index.

        In practice, this simply means changing code like this:

        ```swift
        var standups: [Standup] = []
        ```

        …to code like this:

        ```swift
        import IdentifiedCollections

        var standups: IdentifiedArrayOf<Standup> = []
        ```

        Even with that change, all code should continue to compile because identified arrays mostly
        behave like regular arrays. However, they come with additional APIs that allow for the safe
        and efficient reading and modifying of elements by their ID. Such as removing an element by
        its ID:

        ```swift
        func deleteStandup(id: Standup.ID) async throws {
          try await self.apiClient.delete(id: id)
          self.standups.remove(id: id)
        }
        ```

        Because we are now removing the element by its ID, it does not matter how long the API
        client suspends for, we will always remove the correct element.

        We can also update an element by its ID:

        ```swift
        self.standups[id: standup.id] = standup
        ```

        …and more.

        ## Until next time…

        That's it for now. We hope you have learned how to better model lists of data in your
        SwiftUI applications. By embracing our [`IdentifiedArray`][identified-collections-gh]
        data type you can more efficiently read and modify elements in your lists, _and_ do so
        more safely.

        Check back in tomorrow for the 3rd part of our "Modern SwiftUI" blog series, where we show
        how to more concisely model your domains for navigation in SwiftUI.

        [pricing]: /pricing
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
        [identified-collections-gh]: http://github.com/pointfreeco/swift-identified-collections
        [runtime-warn-blog]: /blog/posts/70-unobtrusive-runtime-warnings-for-libraries
        [xctest-dynamic-overlay]: http://github.com/pointfreeco/xctest-dynamic-overlay
        [unimplemented-docs]: https://pointfreeco.github.io/xctest-dynamic-overlay/main/documentation/xctestdynamicoverlay/unimplemented(_:fileid:line:)-5098a
        [standups-source]: https://github.com/pointfreeco/swiftui-navigation/tree/5e97ce756293f941c2c336693283493a965458f6/Examples/Standups
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 95,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-24")!,
  title: "Modern SwiftUI: Identified arrays"
)
