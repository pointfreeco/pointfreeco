import Foundation

extension BlogPost {
  public static let post0210_dependencyEntry = Self(
    author: .pointfree,
    blurb: """
      Dependencies now ships an @DependencyEntry macro for registering dependencies with far less \
      boilerplate. It was tricky to design because the library must model live, preview, and test \
      environments, but the final API manages to stay concise without giving up that power.
      """,
    coverImage: nil,
    id: 210,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-09")!,
    title: "Introducing @DependencyEntry"
  )
}
