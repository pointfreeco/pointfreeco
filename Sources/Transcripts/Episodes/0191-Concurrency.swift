import Foundation

extension Episode {
  public static let ep191_concurrency = Episode(
    blurb: """
      Before developing Swift's modern concurrency tools, Apple improved upon threads with several other abstractions, including operation queues, Grand Central Dispatch, and Combine. Let's see what these newer tools brought to the table.
      """,
    codeSampleDirectory: "0191-concurrency-pt2",
    exercises: _exercises,
    id: 191,
    length: 62 * 60 + 57,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_653_886_800),
    references: [
      .nsOperationNsHipster,
      .libdispatchEfficiencyTechniques,
      .modernizingGrandCentralDispatchUsage,
      .whatWentWrongWithTheLibdispatch,
      .introducingSwiftAtomics,
    ],
    sequence: 191,
    subtitle: "Queues and Combine",
    title: "Concurrency's Present",
    trailerVideo: .init(
      bytesLength: 131_000_000,
      downloadUrls: .s3(
        hd1080: "0191-trailer-1080p-94d6b5ba01c94739ad58697ee6ea1898",
        hd720: "0191-trailer-720p-feae142e18824f7992cbdd888be1a355",
        sd540: "0191-trailer-540p-8cf5f2b5a5174be3b53a614a3f466d79"
      ),
      id: "edb69640aa266f25fbb60098020c6eee"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
