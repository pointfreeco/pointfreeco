import Foundation

extension BlogPost {
  public static let post0207_debugSnapshotsPublicBeta = Self(
    author: .pointfree,
    blurb: """
      DebugSnapshots is now in public beta! After incubating in Point-Free Beta Previews, it is \
      the first library to graduate to the public, bringing exhaustive testing and focused \
      debugging tools to reference types, @Observable models, and more.
      """,
    coverImage:
      "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/2b4c6522-30c7-4036-f9ed-c938f3935200/public",
    id: 207,
    publishedAt: yearMonthDayFormatter.date(from: "2026-05-27")!,
    title: "DebugSnapshots: Public beta"
  )
}
