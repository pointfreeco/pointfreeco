import Foundation

extension BlogPost {
  public static let post0217_taskLocalProposal = Self(
    author: .pointfree,
    blurb: """
      We have proposed bringing task-local test traits directly to Swift Testing, continuing our \
      work on pushing ideas explored in Point-Free libraries back into the broader Swift ecosystem.
      """,
    coverImage: nil,
    id: 217,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-25")!,
    title: "Proposing task-local test traits for Swift Testing"
  )
}
