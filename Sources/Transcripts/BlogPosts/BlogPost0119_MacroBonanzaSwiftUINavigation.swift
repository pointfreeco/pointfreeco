import Foundation

extension BlogPost {
  public static let post0119_MacroBonanza = Self(
    author: .pointfree,
    blurb: """
      In part 3 of our Macro Bonanza we show how the improvements to case paths greatly simplify \
      our SwiftUINavigation library. It allows us greatly simplify how one drives navigation from \
      optionals and enums in SwiftUI.
      """,
    coverImage: nil,
    id: 119,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-15")!,
    title: "Macro Bonanza: SwiftUI Navigation"
  )
}
