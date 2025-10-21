import Foundation

extension BlogPost {
  public static let post0189_CaseStudyInOpenSource = Self(
    author: .pointfree,
    blurb: """
      While the Swift community largely values first-party libraries and frameworks, they aren't \
      without their disadvantages, like working with an opaque and delayed release schedule. \
      Third-party, open source libraries, operate in the open, which comes with many benefits. \
      Let's explore a few examples that recently came out of our packages.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 189,
    publishedAt: yearMonthDayFormatter.date(from: "2025-10-21")!,
    title: "Open source case study: Listening to our users"
  )
}
