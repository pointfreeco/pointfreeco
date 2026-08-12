import Foundation

extension BlogPost {
  public static let post0222_lazyState = Self(
    author: .pointfree,
    blurb: """
      Announcing the newest addition to Point-Free Beta Previews: LazyState, a library that picks \
      up where WWDC's new @State macro left off by allowing state in SwiftUI views to be \
      initialized lazily _and_ dynamically, using data passed in from the parent view.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 222,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-26")!,
    title: "Beta Preview: LazyState"
  )
}
