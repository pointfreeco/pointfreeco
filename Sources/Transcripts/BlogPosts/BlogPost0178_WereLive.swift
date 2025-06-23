import Foundation

extension BlogPost {
  public static let post0178_WereLive = Self(
    author: .pointfree,
    blurb: """
      Our live stream will be starting soon. Tune in now to watch us discuss the new CloudKit \
      synchronization tools being added to our popular SwiftData alternative: SharingGRDB.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/b0be35bc-1f4d-4b0c-37e6-fba6b42b7f00/public",
    hidden: .noUntil(yearMonthDayFormatter.date(from: "2025-06-26")!),
    hideFromSlackRSS: false,
    id: 178,
    publishedAt: yearMonthDayFormatter.date(from: "2025-02-25")!
      .addingTimeInterval(60 * 60 * 16),  // 4:00pm GMT
    title: "We’re going live soon!"
  )
}
