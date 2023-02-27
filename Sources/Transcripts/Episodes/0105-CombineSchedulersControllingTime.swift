import Foundation

extension Episode {
  public static let ep105_combineSchedulers_controllingTime = Episode(
    blurb: """
      The `Scheduler` protocol of Combine is a powerful abstraction that unifies many ways of executing asynchronous work, and it can even control the flow of time through our code. Unfortunately Combine doesn't give us this ability out of the box, so let's build it from scratch.
      """,
    codeSampleDirectory: "0105-combine-schedulers-pt2",
    exercises: _exercises,
    id: 105,
    length: 66 * 60 + 28,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_591_592_400),
    references: [
      .combineSchedulers
    ],
    sequence: 105,
    subtitle: "Controlling Time",
    title: "Combine Schedulers",
    trailerVideo: .init(
      bytesLength: 20_432_712,
      downloadUrls: .s3(
        hd1080: "0105-trailer-1080p-8236f9ed6ead4480a9aa9aa91d4bbd37",
        hd720: "0105-trailer-720p-400dcbd76c7a42a8891783700572fd70",
        sd540: "0105-trailer-540p-7f7f99cae64c44d88a1088407b97c6e6"
      ),
      vimeoId: 426_821_769
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
