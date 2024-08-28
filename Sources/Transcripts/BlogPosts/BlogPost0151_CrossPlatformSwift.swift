import Foundation

extension BlogPost {
  public static let post0151_CrossPlatformSwift = Self(
    author: .pointfree,
    blurb: """
      It has never been more possible to run Swift on non-Apple platforms, such as Windows, Linux
      and even the browser! Join us for a quick overview of how to get a simple, pure-Swift app
      running in WebAssembly.
      """,
    coverImage:
      "https://pointfreeco-blog.s3.amazonaws.com/posts/0151-cross-platform/wasm-counter.gif",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 151,
    publishedAt: yearMonthDayFormatter.date(from: "2024-08-28")!,
    title: "Cross-Platform Swift: Building a Swift app for the browser"
  )
}
