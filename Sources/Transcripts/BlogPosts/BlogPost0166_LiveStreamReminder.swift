import Foundation

extension BlogPost {
  public static let post0166_LiveStreamReminder = Self(
    author: .pointfree,
    blurb: """
      In less than 24 hours we are going live! Join us at 9am PST / 5pm GMT where we will open
      source a brand new project, give a sneak peek at our next series of episodes, we'll give
      7 free yearly subscriptions away (to celebrate our 7th year anniversary), we'll answer
      tons of questions from our views, and more!
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 166,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-13")!,
    title: "A new project, episodes sneak peek, a giveaway, Q&A, and more!"
  )
}
