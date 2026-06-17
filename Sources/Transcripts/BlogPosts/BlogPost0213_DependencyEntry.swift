import Foundation

extension BlogPost {
  public static let post0213_dependencyEntry = Self(
    author: .pointfree,
    blurb: """
      Dependencies now ships an @DependencyEntry macro for registering dependencies with far less \
      boilerplate. It was tricky to design because the library must model live, preview, and test \
      environments, but the final API manages to stay concise without giving up that power.
      """,
    coverImage: "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/1060d8b2-8e8c-46b1-e4f2-5b2bae549e00/public",
    id: 213,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-17")!,
    title: "Introducing @DependencyEntry"
  )
}
