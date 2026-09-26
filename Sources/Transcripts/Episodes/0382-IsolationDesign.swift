import Foundation

extension Episode {
  public static let ep382_isolationDesign = Episode(
    blurb: """
      Modern concurrency tools like `nonisolated(nonsending)` and `Task.immediate` got us closer \
      to our goal, but we still haven't succeeded. We will take a new approach inspired by Gary \
      Bernhardt's "functional core, imperative shell" pattern that we like to call "nonisolated \
      core, isolated shell."
      """,
    codeSampleDirectory: "0382-isolation-design-pt3",
    exercises: _exercises,
    id: 382,
    length: 25 * 60 + 33,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-05")!,
    references: [
      .functionalCoreImperativeShell,
      .nonSendableCoreSendableShell,
    ],
    sequence: 382,
    socialImage: nil,
    subtitle: "Nonisolated Core",
    title: "Designing for Isolation",
    trailerVideo: Video(
      bytesLength: 44_500_000,
      downloadUrls: .s3(
        hd1080: "0382-trailer-1080p-3fadd2dcf8764647a264df9e27908e60",
        hd720: "0382-trailer-1080p-3fadd2dcf8764647a264df9e27908e60",
        sd540: "0382-trailer-1080p-3fadd2dcf8764647a264df9e27908e60"
      ),
      id: "b2c3c4edd5576317c4be9a4b672d4578"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
