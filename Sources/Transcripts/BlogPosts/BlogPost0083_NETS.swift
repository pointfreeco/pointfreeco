import Foundation

extension BlogPost {
  public static let post0083_NETS = Self(
    author: .pointfree,
    blurb: """
      Exhaustive testing is one of the most powerful features of the Composable Architecture, but \
      it can also be cumbersome for large, highly composed features. Join us for an overview of \
      the "why" and "how" of exhaustive testing, as well as when it breaks down, and how \
      non-exhaustive testing can help.
      """,
    coverImage:
      "https://pointfreeco-blog.s3.amazonaws.com/posts/0083-non-exhaustive-test-store/poster-light.jpg",
    id: 83,
    publishedAt: Date(timeIntervalSince1970: 1_667_192_400),
    title: "Non-exhaustive testing in the Composable Architecture"
  )
}
