import Foundation

extension BlogPost {
  public static let post0195_CyberConclusion = Self(
    author: .pointfree,
    blurb: """
      Today marks the final day of our sale! We're offering a 30% off Point-Free subscriptions and \
      gifts! Get or gift instant access to all past 346 episodes instantly, as well as access to \
      everything we have planned for 2026.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/9045fa26-782a-4c9f-4ae4-0b8f0fa8a300/public",
    hidden: .no,
    hideFromSlackRSS: true,
    id: 195,
    publishedAt: yearMonthDayFormatter.date(from: "2025-12-05")!,
    title: "LAST CHANCE: Save 30% on Point-Free"
  )
}
