import Foundation

extension Episode {
  public static let ep192_concurrency = Episode(
    blurb: """
      Let’s look at what the future of concurrency looks like in Swift. A recent release of Swift came with a variety of tools with concurrency. Let's examine its fundamental unit in depth, and explore how they "cooperate" in your applications.
      """,
    codeSampleDirectory: "0192-concurrency-pt3",
    exercises: _exercises,
    id: 192,
    length: 45 * 60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1655096400),
    references: [
      .nsOperationNsHipster,
      .libdispatchEfficiencyTechniques,
      .modernizingGrandCentralDispatchUsage,
      .whatWentWrongWithTheLibdispatch,
      .introducingSwiftAtomics,
    ],
    sequence: 192,
    subtitle: "Tasks and Cooperation",
    title: "Concurrency's Future",
    trailerVideo: .init(
      bytesLength: 58_900_000,
      downloadUrls: .s3(
        hd1080: "0192-trailer-1080p-eefc1f39906b46eea4bbfaee7369edb7",
        hd720: "0192-trailer-720p-b66e32086d134463bff3e56d6e5ad002",
        sd540: "0192-trailer-540p-b3cfe6a6b0284d4492137098c8f5d1aa"
      ),
      vimeoId: 718_809_383
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
