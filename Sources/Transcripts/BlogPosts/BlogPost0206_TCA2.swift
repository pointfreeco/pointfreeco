import Foundation

extension BlogPost {
  public static let post0206_tca2 = Self(
    author: .pointfree,
    blurb: """
      A preview of ComposableArchitecture 2.0: a fundamental redesign featuring the @Feature \
      macro, implicit store access for async work, lifecycle hooks, new communication patterns, \
      and deep integration with DebugSnapshots for testing.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/cf5ce39b-dba6-42ad-e63b-8b43a838d800/public",
    id: 206,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-01")!,
    title: "Beta Preview: ComposableArchitecture 2.0"
  )
}
