import Foundation

extension BlogPost {
  public static let post0228_lazyStateRelease = Self(
    author: .pointfree,
    blurb: """
      LazyState has graduated from Point-Free Beta Previews and is now available to everyone as \
      version 1.0. It brings SwiftUI's new lazy state initialization to state that must be created \
      dynamically from data passed in by a parent view.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/b1189a85-a5ed-49bc-5b6f-5a2394b7d800/public",
    hidden: .no,
    hideFromSlackRSS: false,
    id: 228,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-14")!,
    title: "LazyState 1.0: Now available to everyone"
  )
}
