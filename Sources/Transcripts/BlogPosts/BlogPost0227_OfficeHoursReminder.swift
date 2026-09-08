import Foundation

extension BlogPost {
  public static let post0227_officeHoursReminder = Self(
    author: .pointfree,
    blurb: """
      A quick reminder for Point-Free Max members: our first Office Hours session is coming up. \
      Submit your questions, vote on what you would like us to cover, and join us for a live Q&A.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/201401ab-857a-4425-60cf-165480d8db00/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 227,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-09")!,
    title: "Reminder: Office Hours for Max members"
  )
}
