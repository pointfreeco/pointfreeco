import Foundation

extension BlogPost {
  public static let post0175_LivestreamModernPersistence = Self(
    author: .pointfree,
    blurb: """
      We are hosting a live stream on June 25th to unveil our vision for modern persistence. Learn \
      how to seamlessly synchronize your app's data across many devices, including sharing data \
      with other iCloud useres.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/22a21fcd-723e-44c1-06f8-bfe0264e0900/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 175,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-17")!,
    title: "Upcoming live stream: A vision for modern persistence"
  )
}
