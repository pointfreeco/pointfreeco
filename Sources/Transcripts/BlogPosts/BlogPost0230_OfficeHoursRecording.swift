import Foundation

extension BlogPost {
  public static let post0230_officeHoursRecording = Self(
    author: .pointfree,
    blurb: """
      The recording of our first Office Hours session is now available for Point-Free Max members. \
      Watch every question as a chapter in the transcript, browse everything we have answered, \
      and vote on the questions we should cover next.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/201401ab-857a-4425-60cf-165480d8db00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 230,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-18")!,
    title: "Our first Office Hours recording is live"
  )
}
