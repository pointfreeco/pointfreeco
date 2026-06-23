import Foundation

extension BlogPost {
  public static let post0215_swiftNavigationMacros = Self(
    author: .pointfree,
    blurb: """
      SwiftNavigation is getting two new macros: @CaseBindable for deriving bindings to enum-case \
      payloads, and an @UITransactionEntry macro for defining custom UITransaction keys with far \ 
      less boilerplate.
      """,
    coverImage: nil,
    id: 215,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-23")!,
    title: "New macros for SwiftNavigation"
  )
}
