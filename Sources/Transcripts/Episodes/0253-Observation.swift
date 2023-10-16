import Foundation

extension Episode {
  public static let ep253_observation = Episode(
    blurb: """
      The `@Observable` macro is here and we will see how it improves on nearly every aspect of the old tools in SwiftUI. We will also take a peek behind the curtain to not only get comfortable with the code the macro expands to, but also the actual open source code that powers the framework.
      """,
    codeSampleDirectory: "0253-observation-pt2",
    exercises: _exercises,
    id: 253,
    length: 52 * 60 + 37,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-10-16")!,
    references: [
      Episode.Reference(
        author: "Chris Eidhof and Florian Kugler",
        blurb: """
          Chris and Florian spent 2 episodes of [Swift Talk](https://talk.objc.io) building most
          of Swift 5.9's Observation framework from scratch. Watch these episodes if you want an
          even deeper dive into the concepts behind obsevation:

          * [Swift Observation: Access Tracking](https://talk.objc.io/episodes/S01E362-swift-observation-access-tracking)
          * [Swift Observation: Calling Observers](https://talk.objc.io/episodes/S01E363-swift-observation-calling-observers)
          """,
        link: "https://talk.objc.io/episodes/S01E362-swift-observation-access-tracking",
        publishedAt: yearMonthDayFormatter.date(from: "2023-07-07"),
        title: "Swift Observation: Access Tracking, Calling Observers"
      )
    ],
    sequence: 253,
    subtitle: "The Present",
    title: "Observation",
    trailerVideo: .init(
      bytesLength: 86_300_000,
      downloadUrls: .s3(
        hd1080: "0253-trailer-1080p-80b92a7e95a947209088423b8bb8e8c7",
        hd720: "0253-trailer-720p-bda0d3649cd54bf69551c999465ab1a4",
        sd540: "0253-trailer-540p-566636a3e0bd4d26aedd7b185bc14003"
      ),
      vimeoId: 872_120_730
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
