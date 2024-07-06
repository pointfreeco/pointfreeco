import Foundation

extension BlogPost {
  public static let post0017_typeSafeVapor = Self(
    author: .brandon,
    blurb: """
      Today we're releasing a Vapor plug-in for rendering type-safe HTML. It provides a Swift \
      compile-time API to HTML that prevents many of the runtime errors and vulnerabilities of \
      traditional templated HTML rendering.
      """,
    coverImage:
      "https://d1iqsrac68iyd8.cloudfront.net/posts/0017-type-safe-html-with-vapor/poster.jpg",
    id: 17,
    publishedAt: .init(timeIntervalSince1970: 1_536_818_400),
    title: "Type-safe HTML with Vapor"
  )
}
