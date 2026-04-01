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
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/2b4c6522-30c7-4036-f9ed-c938f3935200/public",
    id: 205,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-01")!,
    title: "Beta Preview: DebugSnapshots"
  )
}
