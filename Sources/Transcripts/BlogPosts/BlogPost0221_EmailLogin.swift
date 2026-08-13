import Foundation

extension BlogPost {
  public static let post0221_emailLogin = Self(
    author: .pointfree,
    blurb: """
      A GitHub account is no longer required to use Point-Free! You can now sign up and log in \
      with nothing but your email address and a one-time code, and optionally connect your \
      GitHub account later.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 221,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-12")!,
    title: "GitHub account no longer required"
  )
}
