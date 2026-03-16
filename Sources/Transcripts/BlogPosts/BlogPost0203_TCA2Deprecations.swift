import Foundation

extension BlogPost {
  public static let post0203_TCA2Deprecations = Self(
    author: .pointfree,
    blurb: """
      A novel use of SwiftPM traits can strike a nice balance between soft and hard deprecations, \
      giving users a friendly migration path towards major breaking changes. We explore this \
      concept in the context of our upcoming Composable Architecture 2.0 release.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/03a4549c-c20e-40d7-b51f-3df825a52500/public",
    id: 203,
    publishedAt: yearMonthDayFormatter.date(from: "2026-03-16")!,
    title: "Hard Deprecations and Soft Landings with SwiftPM Traits"
  )
}
