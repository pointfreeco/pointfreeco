import Foundation

extension BlogPost {
  public static let post0214_debugSnapshotsBindings = Self(
    author: .pointfree,
    blurb: """
      DebugSnapshots now logs changes made through SwiftUI bindings, making it even easier to \
      understand how observable models evolve as you interact with your views.
      """,
    coverImage: nil,
    id: 214,
    publishedAt: yearMonthDayFormatter.date(from: "2026-06-22")!,
    title: "DebugSnapshots now logs SwiftUI bindings"
  )
}
