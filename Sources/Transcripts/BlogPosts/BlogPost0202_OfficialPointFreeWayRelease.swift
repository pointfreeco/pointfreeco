import Foundation

extension BlogPost {
  public static let post0202_pfwRelease = Self(
    author: .pointfree,
    blurb: """
      The Point-Free Way is officially released: a curated set of practical workflows, patterns, \
      and skills for building better Swift applications.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/28d2f776-ab34-449a-6852-18f038942500/public",
    hideFromSlackRSS: false,
    id: 202,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-06")!,
    title: #"Introducing: The Point-Free Way"#
  )
}
