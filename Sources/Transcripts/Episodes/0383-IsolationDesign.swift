import Foundation

extension Episode {
  public static let ep383_isolationDesign = Episode(
    blurb: """
      We leverage “Nonisolated Core, Isolated Shell” by introducing the `StoreActor`: a \
      `Store`-like object that runs in the background on the cooperative thread pool, maximizing \
      parallelism for tests and whatever you can imagine.
      """,
    codeSampleDirectory: "0383-isolation-design-pt4",
    exercises: _exercises,
    id: 383,
    length: 29 * 60 + 48,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-10-12")!,
    references: [
      .functionalCoreImperativeShell,
      .nonSendableCoreSendableShell,
    ],
    sequence: 383,
    socialImage: nil,
    subtitle: "Isolated Shell",
    title: "Designing for Isolation",
    trailerVideo: Video(
      bytesLength: 41_800_000,
      downloadUrls: .s3(
        hd1080: "0383-trailer-1080p-b0e13ae72fae44cbb67098113f25781d",
        hd720: "0383-trailer-1080p-b0e13ae72fae44cbb67098113f25781d",
        sd540: "0383-trailer-1080p-b0e13ae72fae44cbb67098113f25781d"
      ),
      id: "69c3f74818391aca43eefe68227464d9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
