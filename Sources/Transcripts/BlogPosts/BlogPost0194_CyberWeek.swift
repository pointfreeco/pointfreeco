import Foundation

extension BlogPost {
  public static let post0194_CyberWeek = Self(
    author: .pointfree,
    blurb: """
      We're extending our 30% discount through Cyber Week! Get instant access to all past 346 
      episodes instantly, as well as access to everything we have planned for 2026.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/9045fa26-782a-4c9f-4ae4-0b8f0fa8a300/public",
    hidden: .no,
    hideFromSlackRSS: true,
    id: 194,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-03")!,
    title: "CYBER WEEK: Save 30% on Point-Free"
  )
}
