import Foundation

extension BlogPost {
  public static let post0100_Anniversary = Self(
    author: .pointfree,
    blurb: """
      We launched Point-Free 5 years ago today! There's still so much more we want to do, but \
      we'll start with two things that many people have asked for: livestreams and a community \
      Slack!
      """,
    coverImage: nil,
    id: 100,
    publishedAt: yearMonthDayFormatter.date(from: "2023-01-29")!,
    title: "Point-Free turns 5"
  )
}
