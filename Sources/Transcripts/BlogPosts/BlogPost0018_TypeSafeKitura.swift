import Foundation

extension BlogPost {
  public static let post0018_typeSafeKitura = Self(
    author: .brandon,
    blurb: """
      Today we're releasing a Kitura plug-in for rendering type-safe HTML. It provides a Swift \
      compile-time API to HTML that prevents many of the runtime errors and vulnerabilities of \
      traditional templated HTML rendering.
      """,
    coverImage:
      "https://d1iqsrac68iyd8.cloudfront.net/posts/0018-type-safe-html-with-kitura/poster.jpg",
    id: 18,
    publishedAt: .init(timeIntervalSince1970: 1_536_818_401),
    title: "Type-safe HTML with Kitura"
  )
}
