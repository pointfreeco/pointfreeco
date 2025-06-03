import Foundation

extension BlogPost {
  public static let post0171_MitigatingSwiftSyntax = Self(
    author: .pointfree,
    blurb: """
      Learn how to mitigating long build times when using Swift macros by leveraging the \
      new prebuilt SwiftSyntax binaries in your project.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/1261d83a-80db-4f0f-8051-5797d8952b00/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 171,
    publishedAt: yearMonthDayFormatter.date(from: "2025-06-03")!,
    title: "Mitigating SwiftSyntax build times"
  )
}
