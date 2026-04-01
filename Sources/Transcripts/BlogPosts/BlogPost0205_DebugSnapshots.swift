import Foundation

extension BlogPost {
  public static let post0205_debugSnapshots = Self(
    author: .pointfree,
    blurb: """
      Introducing DebugSnapshots: a new library that brings exhaustive testing to reference types. \
      Apply the @DebugSnapshot macro to your @Observable classes and assert exactly how their \
      state changes over time.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/debug-snapshots-beta/public",
    id: 205,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-01")!,
    title: "Beta Preview: DebugSnapshots"
  )
}
