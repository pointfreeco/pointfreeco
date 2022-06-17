import Foundation

extension Episode {
  public static let ep193_concurrency = Episode(
    blurb: """
      When working with concurrent code, you must content with data synchronization and data races. While the tools of the past made it difficult to reason about these issues, Swift's new tools make it a breeze, including the `Sendable` protocol,  `@Sendable` closures, and actors.
      """,
    codeSampleDirectory: "0193-concurrency-pt4",
    exercises: _exercises,
    id: 193,
    length: 48 * 60 + 35,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_655_701_200),
    references: [
      .nsOperationNsHipster,
      .libdispatchEfficiencyTechniques,
      .modernizingGrandCentralDispatchUsage,
      .whatWentWrongWithTheLibdispatch,
      .introducingSwiftAtomics,
    ],
    sequence: 193,
    subtitle: "Sendable and Actors",
    title: "Concurrency's Future",
    trailerVideo: .init(
      bytesLength: 45_000_000,
      downloadUrls: .s3(
        hd1080: "0193-trailer-1080p-f6a90f0581e9415a8234921616544d58",
        hd720: "0193-trailer-720p-7d8c951c82dc408f908e5b22c68c958d",
        sd540: "0193-trailer-540p-07034511b97d4a2485a5c4eea99f47c8"
      ),
      vimeoId: 718_879_363
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
