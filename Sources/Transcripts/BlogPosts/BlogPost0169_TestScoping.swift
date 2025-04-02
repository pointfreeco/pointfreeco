import Foundation

extension BlogPost {
  public static let post0169_testScoping = Self(
    author: .pointfree,
    blurb: """
      Swift 6.1 and Xcode 16.3 are officially here, and with them comes a new testing tool that we have
      been able to take advantage of in a variety of our libraries. Join us for an overview of this tool,
      as well as an explanation of why it has been so helpful for our libraries.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 169,
    publishedAt: yearMonthDayFormatter.date(from: "2025-04-02")!,
    title: "New in Swift 6.1: Test Scoping Traits"
  )
}
