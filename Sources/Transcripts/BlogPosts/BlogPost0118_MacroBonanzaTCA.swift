import Foundation

extension BlogPost {
  public static let post0118_MacroBonanza = Self(
    author: .pointfree,
    blurb: """
      In part 2 of our Macro Bonanza we show what macros bring to our popular library, the \
      Composable Architecture. It can make our feature code simpler, more succinct and safer!
      """,
    coverImage: nil,
    id: 118,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-14")!,
    title: "Macro Bonanza: Composable Architecture"
  )
}
