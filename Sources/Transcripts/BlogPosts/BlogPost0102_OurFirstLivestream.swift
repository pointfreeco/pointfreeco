import Foundation

extension BlogPost {
  public static let post0102_OurFirstLivestream = Self(
    author: .pointfree,
    blurb: """
      Last week we hosted our first ever livestream. In an hour and a half we discussed some of \
      the tools that our Dependencies library comes with that we didn't have time to discuss in \
      episodes, and we live refactored our open-source Standups app to use the new iOS 16 \
      `NavigationStack`. We also answered 18 viewer questions, and just have 94 more left in the \
      queue. 😅
      """,
    coverImage: "https://d3rccdn33rt8ze.cloudfront.net/episodes/0221.jpeg",
    id: 102,
    publishedAt: yearMonthDayFormatter.date(from: "2023-02-06")!,
    title: "Watch our first ever livestream"
  )
}
