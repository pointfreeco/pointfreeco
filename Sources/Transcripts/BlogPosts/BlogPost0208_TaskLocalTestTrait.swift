import Foundation

extension BlogPost {
  public static let post0208_taskLocalTestTrait = Self(
    author: .pointfree,
    blurb: """
      Concurrency Extras now includes a Swift Testing trait that scopes any task local to a \
      test or suite. It removes repetitive withValue wrappers, composes with other traits, and \
      works around an Xcode build system bug around companion test-support libraries.
      """,
    coverImage: nil,
    id: 208,
    publishedAt: yearMonthDayFormatter.date(from: "2026-05-28")!,
    title: "TaskLocal test traits"
  )
}
