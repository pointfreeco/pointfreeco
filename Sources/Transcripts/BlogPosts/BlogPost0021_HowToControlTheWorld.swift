import Foundation

extension BlogPost {
  public static let post0021_howToControlTheWorld = Self(
    author: .stephen,
    blurb: """
      APIs that interact with the outside world are unpredictable and make it difficult to test \
      and simulate code paths in our apps. Existing solutions to this problem are verbose and \
      complicated, so let's explore a simpler solution by embracing singletons and global \
      mutation, and rejecting protocol-oriented programming and dependency injection.
      """,
    coverImage:
      "https://d1iqsrac68iyd8.cloudfront.net/posts/0021-how-to-control-the-world/poster.jpg",
    id: 21,
    publishedAt: Date(timeIntervalSince1970: 1_539_093_600),
    title: "How to Control the World"
  )
}
