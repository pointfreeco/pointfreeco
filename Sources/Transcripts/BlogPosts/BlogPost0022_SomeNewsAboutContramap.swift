import Foundation

extension BlogPost {
  public static let post0022_someNewsAboutContramap = Self(
    author: .brandon,
    blurb: """
      We've seen that contramap is a powerful operation, but the name isn't fantastic. We propose \
      a much more intuitive name for this operation, and in doing so make our code much easier to \
      read.
      """,
    coverImage:
      "https://d1iqsrac68iyd8.cloudfront.net/posts/0022-some-news-about-contramap/poster.png",
    id: 22,
    publishedAt: .init(timeIntervalSince1970: 1_540_803_600),
    title: "Some news about contramap"
  )
}
