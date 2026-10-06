import Foundation

extension BlogPost {
  public static let post0231_MacroTypes = Self(
    author: .pointfree,
    blurb: """
      Today we are embarking on a 2-part blog series to explore advanced macro techniques. We will
      show how to go beyond the limitations of Swift macros by showing that they can get access
      to static type information and even inferred types.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/25ecb9a5-44d0-4c11-574a-d963a5bce900/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 231,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-06")!,
    title: "Advanced techniques in Swift macros"
  )
}
