import Foundation

extension BlogPost {
  public static let postXYZW_TODO = Self(
    author: .pointfree,  // todo
    blurb: """
      TODO \
      TODO
      """,
    coverImage: nil,  // TODO
    hidden: .no,  // todo
    hideFromSlackRSS: false,  // todo
    id: 0,  // TODO
    publishedAt: yearMonthDayFormatter.date(from: "2099-01-01")!,  // TODO
    title: "TODO"
  )
}
