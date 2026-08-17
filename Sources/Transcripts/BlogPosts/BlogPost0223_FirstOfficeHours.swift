import Foundation

extension BlogPost {
  public static let post0223_firstOfficeHours = Self(
    author: .pointfree,
    blurb: """
      Introducing Office Hours: periodic livestreams exclusively for Point-Free Max subscribers \
      where we answer your questions in a smaller, more casual setting. Submit questions ahead \
      of time, vote on what we should cover, and join us for our first session.
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 223,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-25")!,
    title: "Office Hours: live Q&A for Max subscribers"
  )
}
