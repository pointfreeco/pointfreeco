import Foundation

extension BlogPost {
  public static let post0070_UnobtrusiveRuntimeWarnings = Self(
    author: .pointfree,
    blurb: """
      Runtime warnings in libraries are a great way to notify your users that something \
      unexpected has happened, or that an API is being used in an incorrect manner. In this post \
      we give an overview of some techniques that can be employed easily today, as well as discuss \
      a technique for surfacing runtime warnings that is both very visible and unobtrusive.
      """,
    coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0070-runtime-warnings/poster.png",
    id: 70,
    publishedAt: .init(timeIntervalSince1970: 1_641_189_600),
    title: "Unobtrusive runtime warnings for libraries"
  )
}
