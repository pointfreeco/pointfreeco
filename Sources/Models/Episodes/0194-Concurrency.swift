import Foundation

extension Episode {
  public static let ep194_concurrency = Episode(
    blurb: """
      There are amazing features of Swift concurrency that don't quite fit into our narrative of examining it through the lens of past concurrency tools. Instead, we'll examine them through the lens of a past programming paradigm, structured programming, and see what is has to say about structured concurrency.
      """,
    codeSampleDirectory: "0194-concurrency-pt5",
    exercises: _exercises,
    id: 194,
    length: 61 * 60 + 42,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1656306000),
    references: [
      .nsOperationNsHipster,
      .libdispatchEfficiencyTechniques,
      .modernizingGrandCentralDispatchUsage,
      .whatWentWrongWithTheLibdispatch,
      .introducingSwiftAtomics,
    ],
    sequence: 194,
    subtitle: "Structured and Unstructured",
    title: "Concurrency's Future",
    trailerVideo: .init(
      bytesLength: 185_300_000,
      downloadUrls: .s3(
        hd1080: "0194-trailer-1080p-eb4ddd885f064e2e96b2b8aa0822e471",
        hd720: "0194-trailer-720p-ede8b03f797947e49309c0322992ecca",
        sd540: "0194-trailer-540p-4f81ab5db121451195e0db4f1e60bfd3"
      ),
      vimeoId: 722393610
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
