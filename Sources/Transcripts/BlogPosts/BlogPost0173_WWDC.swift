import Foundation

extension BlogPost {
  public static let post0173_WWDC = Self(
    author: .pointfree,
    blurb: """
      WWDC is here! 🎉 We are excited to explore all of the new tools and APIs, and we will have \
      a lot of exciting announcements to share really soon. Subscribe today with a 30% \
      discount to get unlock all past episodes and everything we have planned for the future.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7903112b-fc0b-41d8-4322-c19334bc2b00/public",
    hidden: .no,
    hideFromSlackRSS: true,
    id: 173,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-10")!,
    title: "WWDC Sale: 30% of your first year of Point-Free"
  )
}
