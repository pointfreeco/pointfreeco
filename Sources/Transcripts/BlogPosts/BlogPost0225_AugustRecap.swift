import Foundation

extension BlogPost {
  public static let post0225_augustRecap = Self(
    author: .pointfree,
    blurb: """
      Last month we shipped 40 releases across 16 of our open source libraries, including new \
      JSON and collation tools for our modern persistence libraries, the return of preview \
      traits in Dependencies, and the completion of a years-long package rename. Here's a recap \
      of everything that happened.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 225,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-04")!,
    title: "Last Month In Point-Free: August"
  )
}
