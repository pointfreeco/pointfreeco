import Foundation

extension BlogPost {
  public static let post0204_betaPreviews = Self(
    author: .pointfree,
    blurb: """
      Announcing Point-Free Beta Previews: get early access to pre-release versions of our \
      libraries before they go public. Launching today with two betas: a brand new testing \
      library called DebugSnapshots, and a preview of ComposableArchitecture 2.0.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/cf5ce39b-dba6-42ad-e63b-8b43a838d800/public",
    id: 204,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-01")!,
    title: "Introducing: Point-Free Beta Previews"
  )
}
