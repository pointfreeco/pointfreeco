import Foundation

extension BlogPost {
  public static let post0232_MacroTypes = Self(
    author: .pointfree,
    blurb: """
      The first advanced Swift macro technique we will discuss is how macros can peek at a small
      amount of static type information, such as checking if a type conforms to a protocol or
      not. This seems to run contrary to Swift macro limitations, but it absolutely is possible.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/27b1e744-d094-4e62-13cd-c3af7067a100/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 232,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-07")!,
    title: "Advanced macro technique #1: Static type information"
  )
}
