import Foundation

extension BlogPost {
  public static let post0200_LiveStreamReminder = Self(
    author: .pointfree,
    blurb: """
      In less than 24 hours we are going live! Join us at 9am PST / 5pm GMT where we will \ 
      officially launch the "Point-Free Way", give a sneak peek at the next version of the \
      Composable Architecture, we'll give away 8 free yearly subscriptions (to celebrate 8 years \
      of Point-Free), we'll answer tons of questions from our views, and more!
      """,
    coverImage: nil,
    hidden: .no,
    hideFromSlackRSS: false,
    id: 200,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-04")!,
    title: """
      The "Point-Free Way", TCA 2.0 sneak peek, a giveaway, Q&A, and more!
      """
  )
}
