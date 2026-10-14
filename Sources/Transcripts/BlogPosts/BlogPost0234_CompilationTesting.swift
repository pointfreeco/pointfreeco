import Foundation

extension BlogPost {
  public static let post0234_compilationTesting = Self(
    author: .pointfree,
    blurb: """
      Introducing CompilationTesting: unit test Swift compiler diagnostics, snapshot errors and \
      warnings inline, and protect the compile-time guarantees of your libraries. Available now \
      as a beta preview for Point-Free Max members.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/15b20685-fa27-4d54-d02e-d58cd92f3600/public",
    id: 234,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-13")!,
    title: "Beta Preview: CompilationTesting"
  )
}
