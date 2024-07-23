import Foundation

extension BlogPost {
  public static let post0147_IssueReporting = Self(
    author: .pointfree,
    blurb: """
      We are releasing a brand new library today: Issue Reporting. It enables you to report
      issues in your application and library code as Xcode runtime warnings, breakpoints,
      assertions, and do so in a testable manner.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 147,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-23")!,
    title: "Unobtrusive and testable issue reporting"
  )
}
