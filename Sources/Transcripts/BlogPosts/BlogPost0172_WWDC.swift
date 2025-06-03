import Foundation

extension BlogPost {
  public static let post0172_WWDC = Self(
    author: .pointfree,
    blurb: """
      WWDC is just around the corner, and to celebrate we are offering a 30% discount off the first 
      year for first-time subscribers. The offer will only remain valid until June 16th.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7903112b-fc0b-41d8-4322-c19334bc2b00/public",
    hidden: .no,
    hideFromSlackRSS: true,
    id: 172,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-03")!,
    title: "WWDC Sale: 30% of your first year of Point-Free"
  )
}
