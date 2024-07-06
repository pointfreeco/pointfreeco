import Foundation

public let post0144_WWDCSale = BlogPost(
  author: .pointfree,
  blurb: """
    As WWDC week comes to a close we have extended our sale for just a few more days. Get 25% \
    off your first year of a Point-Free subscription, and unlock access to all past episodes, \
    and get access to our upcoming series, such as "Modern UIKit", as well as all of our future \
    deep dives into WWDC 24's announcements!
    """,
  coverImage: nil,
  hidden: .noUntil(yearMonthDayFormatter.date(from: "2024-06-19")!),
  hideFromSlackRSS: true,
  id: 144,
  publishedAt: yearMonthDayFormatter.date(from: "2024-06-14")!,
  title: "Last chance to get 25% off Point-Free!"
)
