import Foundation

extension BlogPost {
  public static let post0229_officeHoursInOneHour = Self(
    author: .pointfree,
    blurb: """
      Point-Free Office Hours begin in one hour. Max members can join us for a casual live Q&A, \
      submit last-minute questions, and vote on the topics they would most like us to cover.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/201401ab-857a-4425-60cf-165480d8db00/public",
    hidden: .yes,
    hideFromSlackRSS: true,
    id: 229,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-16")!
      .addingTimeInterval(60 * 60 * 16),  // 4:00pm GMT
    title: "Office Hours start in one hour"
  )
}
