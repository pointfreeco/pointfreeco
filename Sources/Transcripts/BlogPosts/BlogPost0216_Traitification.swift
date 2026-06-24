import Foundation

extension BlogPost {
  public static let post0216_traitification = Self(
    author: .pointfree,
    blurb: """
      We are continuing to adopt SwiftPM traits across our libraries so that users can opt out of \
      pieces they do not need, starting with SwiftNavigation as our test bed.
      """,
    coverImage: nil,
    id: 216,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-24")!,
    title: "“Trait-ifying” our libraries to reduce transitive dependencies"
  )
}
