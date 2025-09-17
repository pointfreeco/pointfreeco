import Foundation

extension BlogPost {
  public static let post0177_LiveStreamReminder = Self(
    author: .pointfree,
    blurb: """
      In less than 24 hours we are going live! Join us at 9am PDT / 4pm GMT where we will discuss \
      the new CloudKit synchronization tools we are bringing to our popular SwiftData alternative: \
      SQLiteData.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/22a21fcd-723e-44c1-06f8-bfe0264e0900/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 177,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-24")!,
    title: "Live stream reminder: A SwiftData alternative with CloudKit synchronization"
  )
}
