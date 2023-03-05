import Foundation

extension Episode {
  public static let ep157_searchable = Episode(
    blurb: """
      We finish our search-based application by adding and controlling another MapKit API, integrating it into our application so we can annotate a map with search results, and then we'll go the extra mile and write tests for the entire thing!
      """,
    codeSampleDirectory: "0157-searchable-pt2",
    exercises: _exercises,
    id: 157,
    length: 57 * 60 + 40,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_629_090_000),
    references: [
      Episode.Reference(
        author: "Harry Lane",
        blurb: #"""
          A WWDC session exploring the `.searchable` view modifier.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2021/10176/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-06-09"),
        title: "Craft search experiences in SwiftUI"
      ),
      .init(
        author: "Sarun Wongpatcharapakorn",
        blurb: """
          A comprehensive article explaining the full `.searchable` API, including some things we did not cover in this episode, such as the `.dismissSearch` environment value and search completions.

          > SwiftUI finally got native search support in iOS 15. We can add search functionality to any navigation view with the new searchable modifier. Let's explore its capability and limitation.
          """,
        link: "https://sarunw.com/posts/searchable-in-swiftui/",
        publishedAt: yearMonthDayFormatter.date(from: "2021-07-07"),
        title: "Searchable modifier in SwiftUI"
      ),
      Episode.Reference(
        author: nil,
        blurb: #"""
          Documentation for the `.searchable` view modifier.
          """#,
        link:
          "https://developer.apple.com/documentation/swiftui/view/searchable(_:text:placement:suggestions:)-7g7oo",
        publishedAt: nil,
        title: "`searchable(_:text:placement:suggestions:)`"
      ),
    ],
    sequence: 157,
    subtitle: "Part 2",
    title: "Searchable SwiftUI",
    trailerVideo: .init(
      bytesLength: 31_768_150,
      downloadUrls: .s3(
        hd1080: "0157-trailer-1080p-a289eb51065b46f6b78bc6037c5effc3",
        hd720: "0157-trailer-720p-dd0fe41cde30487aa863b732ca668b07",
        sd540: "0157-trailer-540p-85ded24a704549c6bc1f4813d1fd8742"
      ),
      vimeoId: 585_305_341
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 157)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      In the episode we were able to get by without having to wrap Apple's `MKMapItem` type, but let's now go the extra mile and do so by introducing our own `MapItem` type. How does controlling this type affect our application and test code?
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Add an endpoint to `LocalSearchClient` that can perform a local search with a query string instead of a completion. The [`MKLocalSearch.Request`](https://developer.apple.com/documentation/mapkit/mklocalsearch/request) type has a `naturalLanguageQuery` mutable field that does just this.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      WWDC introduced another search-related API that we didn't have time to explore, and that's the [`onSubmit(of:_:)`](https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)/) view modifier, which evaluates an action closure when it detects a particular "submit trigger" is executed, which includes a "search" trigger:

      ```swift
      .onSubmit(of: .search) { … }
      ```

      Use this API to introduce the ability for a user to fire off a search by submitting the current query string to the local search endpoint from the previous exercise.
      """#,
    solution: nil
  ),
  .init(
    problem: #"""
      Let's clean up the `LocalSearchClient` dependency. There are a few things we can fix and make nicer:

      * `MKLocalSearch.Request` has a `region` field that we've been ignoring, but we should pass the app's region to the dependency as input so that it can apply the region to the search request.

      * We have 2 separate endpoints for local search, but it might be nicer to unify this into a single interface to better match Apple's APIs.
      """#,
    solution: nil
  ),
]

extension Episode.Video {
  public static let ep157_searchable = Self(
    bytesLength: 488_685_581,
    downloadUrls: .s3(
      hd1080: "0157-1080p-b623f91dffa24fc1b5edcbc36b35b507",
      hd720: "0157-720p-8cb81a8b39074cbc8b50ff84cf6f5379",
      sd540: "0157-540p-f08c1316a1ee4c7888d4f24c1df3c690"
    ),
    vimeoId: 585_305_356
  )
}
