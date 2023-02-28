import Foundation

extension Episode {
  public static let ep115_redactions_pt1 = Episode(
    alternateSlug: "redacted-swiftui-the-problem",
    blurb: """
      SwiftUI has introduced the concept of “████ed views”, which gives you a really nice way to ████ the text and images from views. This is really powerful, but just because the view has been ████ed it doesn't mean the logic has also been ████ed. We show why this is problematic and why we want to fix it.
      """,
    codeSampleDirectory: "0115-redacted-swiftui-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 327_899_376,
      downloadUrls: .s3(
        hd1080: "0115-1080p-254ec06aae444762a2cc7f62871c5a3a",
        hd720: "0115-720p-1a21dc3f54df446b93c2e272657c33be",
        sd540: "0115-540p-779d1b589f1f48c980b99ef16e6a77d6"
      ),
      vimeoId: 452_176_076
    ),
    id: 115,
    length: 25 * 60 + 49,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_598_850_000),
    references: [
      .init(
        author: nil,
        blurb: #"""
          Apple's new API for redacting content in SwiftUI.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
        publishedAt: nil,
        title: "redacted(reason:)"
      ),
      .init(
        author: "Federico Zanetello",
        blurb: #"""
          Federico demonstrates how you can use `RedactionReasons` to render custom redactions differently than the standard API.
          """#,
        link: "https://fivestars.blog/code/redacted-custom-effects.html",
        publishedAt: yearMonthDayFormatter.date(from: "2020-07-28"),
        title: "Creating custom .redacted effects"
      ),
      .init(
        author: nil,
        blurb: #"""
          "Separation of Concerns" is a design pattern that is expressed often but is a very broad guideline, and not something that can be rigorously applied.
          """#,
        link: "https://en.wikipedia.org/wiki/Separation_of_concerns",
        publishedAt: nil,
        title: "Separation of Concerns"
      ),
      .init(
        author: "Curt Clifton, Luca Bernadi, and Raj Ramamurthy",
        blurb: #"""
          This WWDC 2020 session covers the various APIs SwiftUI provides to drive your views with your data models using bindings, `@State`, `@ObservedObject`, and the newly-introduced `@StateObject`.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2020/10040/",
        publishedAt: yearMonthDayFormatter.date(from: "2020-06-27"),
        title: "Data Essentials in SwiftUI"
      ),
      .init(
        author: nil,
        blurb: #"""
          Apple's guidance for managing a SwiftUI application's data model using bindings, `@State`, `@ObservedObject`, and the newly-introduced `@StateObject`.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app",
        publishedAt: nil,
        title: "Managing Model Data in Your App"
      ),
      .init(
        author: "Chris Eidhof, et al.",
        blurb: #"""
          A Twitter thread between the community and several Apple engineers about when to use `@StateObject` and when to use `@ObservedObject`. Nick Lockwood [succinctly explains](https://twitter.com/nicklockwood/status/1280133214489710596) that `@StateObject` is persisted across view instantiations, while SwiftUI engineer Luca Bernardi gives both [a general guideline](https://twitter.com/luka_bernardi/status/1280224429637681152) on when to use which, while [expanding](https://twitter.com/luka_bernardi/status/1279124141837185025) that it should be valid to instantiate a `StateObject` with data it depends on.
          """#,
        link: "https://twitter.com/chriseidhof/status/1280085055021383681",
        publishedAt: yearMonthDayFormatter.date(from: "2020-07-06"),
        title: "StateObject vs. ObservedObject"
      ),
      .init(
        author: "Joe Groff",
        blurb: #"""
          Swift engineer Joe Groff explains how `@State` should only be initialized where the property is declared and that parent views should not pass data to child views to be handed to any internal `@State`.
          """#,
        link: "https://twitter.com/jckarter/status/1270135428394315776",
        publishedAt: yearMonthDayFormatter.date(from: "2020-07-06"),
        title: "Initializing @State from a parent"
      ),
    ],
    sequence: 115,
    subtitle: "The Problem",
    title: "█████ed SwiftUI",
    trailerVideo: .init(
      bytesLength: 49_832_966,
      downloadUrls: .s3(
        hd1080: "0115-trailer-1080p-927e645377704ec6854b8677fa2da743",
        hd720: "0115-trailer-720p-c974fe4220364471944d499bcf0d05f9",
        sd540: "0115-trailer-540p-ab6ab95586cc4332a3a1b8b2ccb20d0e"
      ),
      vimeoId: 453_129_382
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 115)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
