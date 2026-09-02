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
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/ff8506c9-5cff-4693-3f45-baf1688c0e00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 225,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-04")!,
    title: "Last Month in Point-Free: August"
  )
}
